<?php
/**
 * Sincronizacion automatica con el sistema central de la universidad.
 *
 * Uso:
 *   php scripts/sincronizar_api.php                 (sincroniza todo)
 *   php scripts/sincronizar_api.php alumnos         (solo alumnos)
 *   php scripts/sincronizar_api.php facultades sedes
 *
 * Programar en el Programador de tareas de Windows (o cron en Linux):
 *   php C:\xampp\htdocs\SistemaUnvesGestion\scripts\sincronizar_api.php
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('Este script solo puede ejecutarse desde la linea de comandos.');
}

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));

require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';

use App\Core\Config;
use App\Core\Database;
use App\Services\UniversidadApiService;

Config::cargar();
date_default_timezone_set((string) Config::obtener('app.zona_horaria', 'America/Asuncion'));

$tipos = array_slice($argv, 1);
if ($tipos === []) {
    $tipos = ['facultades', 'sedes', 'carreras', 'periodos', 'alumnos'];
}

$validos = ['facultades', 'sedes', 'carreras', 'periodos', 'alumnos'];
$servicio = new UniversidadApiService();

echo "=====================================================\n";
echo " Sincronizacion con el sistema central de la UNVES\n";
echo ' Inicio: ' . date('d/m/Y H:i:s') . "\n";
echo "=====================================================\n\n";

if (!$servicio->habilitada()) {
    echo "[!] La API no esta configurada.\n";
    echo "    Configura la URL y el token desde: Configuracion -> Integracion\n";
    echo "    o cargando los valores api_universidad_url y api_universidad_token\n";
    echo "    en la tabla `configuracion`.\n";
    exit(1);
}

$prueba = $servicio->probarConexion();
echo ($prueba['ok'] ? '[OK] ' : '[!] ') . $prueba['mensaje'] . "\n\n";

if (!$prueba['ok']) {
    exit(1);
}

$totales = ['nuevos' => 0, 'actualizados' => 0, 'errores' => 0];
$salida  = 1;

foreach ($tipos as $tipo) {
    if (!in_array($tipo, $validos, true)) {
        echo "[!] Tipo no soportado: {$tipo}\n";
        continue;
    }

    echo "-> Sincronizando {$tipo}...\n";
    $inicio = microtime(true);
    $r      = $servicio->sincronizar($tipo, null);
    $ms     = (int) round((microtime(true) - $inicio) * 1000);

    printf(
        "   [%s] %d recibidos | %d nuevos | %d actualizados | %d errores (%d ms)\n",
        $r['estado'],
        $r['recibidos'],
        $r['nuevos'],
        $r['actualizados'],
        $r['errores'],
        $ms
    );

    if ($r['detalle'] !== []) {
        foreach (array_slice($r['detalle'], 0, 10) as $error) {
            echo '     · ' . $error['registro'] . ' -> ' . $error['error'] . "\n";
        }
    }

    $totales['nuevos']       += $r['nuevos'];
    $totales['actualizados'] += $r['actualizados'];
    $totales['errores']      += $r['errores'];

    if ($r['estado'] === 'Exitoso') {
        $salida = 0;
    }
}

// Limpieza de registros antiguos
try {
    $resets  = Database::instancia()->consulta('DELETE FROM password_resets WHERE expira_en < DATE_SUB(NOW(), INTERVAL 1 DAY)')->filasAfectadas();
    $sesiones = Database::instancia()->consulta('DELETE FROM sesiones_web WHERE estado <> "Activa" AND ultimo_acceso < DATE_SUB(NOW(), INTERVAL 90 DAY)')->filasAfectadas();
    echo "\n-> Limpieza: {$resets} token(s) expirado(s), {$sesiones} sesion(es) antigua(s).\n";
} catch (Throwable $e) {
    echo "\n[!] No se pudo limpiar registros antiguos: " . $e->getMessage() . "\n";
}

echo "\n=====================================================\n";
printf(" RESUMEN: %d nuevos | %d actualizados | %d errores\n", $totales['nuevos'], $totales['actualizados'], $totales['errores']);
echo ' Fin: ' . date('d/m/Y H:i:s') . "\n";
echo "=====================================================\n";

exit($salida);
