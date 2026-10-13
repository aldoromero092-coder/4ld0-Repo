<?php
/**
 * TEMPORAL: crea una obligación y una intención de pago para revisar la
 * pantalla de la pasarela en el navegador.
 *
 * Uso: php scripts/tmp_preparar_pasarela.php [transferencia|tarjeta]
 */

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));
require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';

use App\Core\Config;
use App\Core\Database;
use App\Services\ObligacionService;
use App\Services\PagoService;

Config::cargar();
date_default_timezone_set((string) Config::obtener('app.zona_horaria', 'America/Asuncion'));

$modo    = $argv[1] ?? 'tarjeta';
$db      = Database::instancia();
$servicio = new PagoService();

$idAlumno = (int) $db->consulta(
    'SELECT a.id_alumno FROM alumnos a INNER JOIN personas p ON p.id_persona = a.id_persona WHERE p.cedula = "5234891-6"'
)->valor();

$idObligacion = (new ObligacionService())->crear([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 1,
    'id_periodo'        => 3,
    'descripcion'       => $modo === 'transferencia' ? 'Arancel Noviembre 2026 (transferencia)' : 'Arancel Noviembre 2026',
    'referencia'        => 'DEMO-' . strtoupper($modo) . '-' . date('His'),
    'monto'             => 504000,
    'fecha_vencimiento' => date('Y-m-d', strtotime('+12 days')),
]);

$resultado = $servicio->crearIntencion(
    $idAlumno,
    [$idObligacion],
    $modo === 'transferencia' ? 2 : 3,
    $modo === 'transferencia' ? 'transferencia' : 'sandbox',
    ['nombre' => 'Lucia Fernanda Villalba Rios', 'email' => 'lucia.villalba@unves.edu.py', 'telefono' => '0991461220']
);

echo "obligacion=$idObligacion pago=" . (int) ($resultado['id_pago'] ?? 0) . "\n";
