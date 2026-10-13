<?php
/**
 * Pruebas funcionales de los formularios de gestion (POST) con verificacion
 * directa en la base de datos.
 *
 * Uso: php pruebas_modulos.php [base] [usuario] [clave]
 */

$base = $argv[1] ?? 'http://localhost/SistemaUnvesGestion';
$user = $argv[2] ?? 'admin';
$pass = $argv[3] ?? 'Unves.2026';
$jar  = sys_get_temp_dir() . '/unves_mod_' . $user . '.txt';
@unlink($jar);

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));
require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';
\App\Core\Config::cargar();

$ok = 0;
$fallas = [];

function db(): \App\Core\Database
{
    return \App\Core\Database::instancia();
}

function contar(string $tabla, string $where, array $params): int
{
    return (int) db()->consulta("SELECT COUNT(*) FROM `{$tabla}` WHERE {$where}", $params)->entero();
}

function pedir(string $url, array $op = []): array
{
    global $jar;
    $c = curl_init();
    curl_setopt_array($c, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_COOKIEJAR => $jar,
        CURLOPT_COOKIEFILE => $jar,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_MAXREDIRS => 3,
        CURLOPT_TIMEOUT => 30,
    ]);
    if (isset($op['post'])) {
        curl_setopt($c, CURLOPT_POST, true);
        curl_setopt($c, CURLOPT_POSTFIELDS, is_array($op['post']) ? http_build_query($op['post']) : $op['post']);
    }
    if (!empty($op['headers'])) {
        curl_setopt($c, CURLOPT_HTTPHEADER, $op['headers']);
    }
    $cuerpo = curl_exec($c);
    $codigo = (int) curl_getinfo($c, CURLINFO_HTTP_CODE);
    curl_close($c);
    return ['cuerpo' => (string) $cuerpo, 'codigo' => $codigo];
}

function token(string $html): string
{
    return preg_match('/name="_token" value="([^"]+)"/', $html, $m) ? $m[1] : '';
}

function enviar(string $url, array $datos): array
{
    global $jar;
    $c = curl_init();
    curl_setopt_array($c, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_COOKIEJAR => $jar,
        CURLOPT_COOKIEFILE => $jar,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_MAXREDIRS => 3,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => http_build_query($datos),
        CURLOPT_HTTPHEADER => ['X-Requested-With: XMLHttpRequest', 'Accept: application/json, text/html'],
        CURLOPT_TIMEOUT => 30,
    ]);
    $cuerpo = curl_exec($c);
    $codigo = (int) curl_getinfo($c, CURLINFO_HTTP_CODE);
    curl_close($c);

    $json = json_decode((string) $cuerpo, true);

    return [
        'codigo' => $codigo,
        'json'   => is_array($json) ? $json : null,
        'error'  => str_contains((string) $cuerpo, 'Fatal error') || str_contains((string) $cuerpo, 'Error interno'),
    ];
}

function abrir(string $url): string
{
    $r = pedir($url);
    return $r['codigo'] === 200 ? token($r['cuerpo']) : '';
}

function resultado(string $etiqueta, bool $bien, string $detalle = ''): void
{
    global $ok, $fallas;
    if ($bien) {
        $ok++;
        echo "  OK    [$etiqueta]\n";
    } else {
        $fallas[] = "[$etiqueta] $detalle";
        echo "  FALLA [$etiqueta] $detalle\n";
    }
}

/** Envia el formulario y verifica que el registro exista en la base. */
function probar_alta(string $etiqueta, string $urlForm, string $urlPost, array $datos, string $tabla, string $columna, string $valor): void
{
    $tok = abrir($urlForm);
    if ($tok === '') {
        resultado($etiqueta, false, 'no se pudo abrir ' . $urlForm);
        return;
    }

    $r = enviar($urlPost, array_merge(['_token' => $tok], $datos));

    if ($r['error']) {
        resultado($etiqueta, false, 'error PHP en la respuesta (HTTP ' . $r['codigo'] . ')');
        return;
    }

    $existe = contar($tabla, "`{$columna}` = ?", [$valor]) > 0;
    $mensaje = $r['json']['mensaje'] ?? '';

    resultado($etiqueta, $existe, $existe ? '' : ('no se guardo en ' . $tabla . ' (HTTP ' . $r['codigo'] . ') ' . $mensaje));
}

echo "=== Pruebas de gestion: $user ===\n\n";

$login = pedir("$base/login");
if (token($login['cuerpo']) === '') {
    exit("No se pudo cargar el formulario de ingreso.\n");
}
$tok = token($login['cuerpo']);
$r   = enviar("$base/login", ['_token' => $tok, 'usuario' => $user, 'clave' => $pass]);
if (!str_contains($r['codigo'] === 200 ? '' : '', 'x') && $r['codigo'] !== 200) {
    exit("No se pudo iniciar sesion con $user (HTTP {$r['codigo']})\n");
}
if (str_contains($r['cuerpo'] ?? '', 'name="usuario"')) {
    exit("No se pudo iniciar sesion con $user\n");
}
echo "Sesion iniciada.\n\n";

$sufijo = date('His');
$marca  = 'ZZ' . $sufijo;

// --- ALUMNOS ---------------------------------------------------------
echo "-- Alumnos --\n";
$cedula = '9' . substr((string) time(), -6);
probar_alta('Alta de alumno', "$base/alumnos/nuevo", "$base/alumnos/guardar", [
    'cedula' => $cedula, 'nombres' => 'Prueba', 'apellidos' => 'Auto' . $sufijo,
    'email' => "alumno{$sufijo}@test.local", 'celular' => '0981 000 111',
    'id_carrera' => 4, 'id_sede' => 1, 'semestre_actual' => 1,
    'estado_academico' => 'Activo', 'turno' => 'Noche', 'modalidad' => 'Presencial',
], 'personas', 'cedula', $cedula);

// --- ESTRUCTURA ACADEMICA ---------------------------------------------
echo "\n-- Estructura academica --\n";
probar_alta('Alta de sede', "$base/academico/sedes", "$base/academico/sedes/guardar",
    ['nombre' => 'Sede ' . $marca, 'direccion' => 'Calle Falsa 123', 'telefono' => '+595 900 000 000', 'id_ciudades' => 1, 'estado' => 'Activo'],
    'sedes', 'nombre', 'Sede ' . $marca);

probar_alta('Alta de facultad', "$base/academico/facultades", "$base/academico/facultades/guardar",
    ['nombre' => 'Facultad ' . $marca, 'id_sede' => 1, 'estado' => 'Activo'],
    'facultades', 'nombre', 'Facultad ' . $marca);

probar_alta('Alta de carrera', "$base/academico/carreras", "$base/academico/carreras/guardar",
    ['codigo_carrera' => substr($sufijo, -3), 'nombre' => 'Carrera ' . $marca, 'id_facultades' => 1, 'duracion_anio' => 5, 'estado' => 'Activo'],
    'carreras', 'nombre', 'Carrera ' . $marca);

probar_alta('Alta de periodo', "$base/academico/periodos", "$base/academico/periodos/guardar",
    ['nombre' => 'Periodo ' . $marca, 'fecha_inicio' => date('Y-m-d', strtotime('+400 days')),
     'fecha_fin' => date('Y-m-d', strtotime('+550 days')), 'estado' => 'Planificado'],
    'periodos_academicos', 'nombre', 'Periodo ' . $marca);

// --- ARANCELES ---------------------------------------------------------
echo "\n-- Aranceles --\n";
probar_alta('Alta de concepto de pago', "$base/aranceles/conceptos", "$base/aranceles/conceptos/guardar",
    ['codigo' => substr($sufijo, -3) . 'Z', 'nombre' => 'Concepto ' . $marca, 'descripcion' => 'Generado por prueba automatica',
     'categoria' => 'General', 'es_recurrente' => 0, 'orden' => 90, 'estado' => 'Activo'],
    'conceptos_pago', 'nombre', 'Concepto ' . $marca);

$idConceptoNuevo = (int) db()->consulta('SELECT id_concepto_pago FROM conceptos_pago WHERE nombre = ?', ['Concepto ' . $marca])->valor();
$idPeriodoNuevo  = (int) db()->consulta('SELECT id_periodo FROM periodos_academicos WHERE nombre = ?', ['Periodo ' . $marca])->valor();

probar_alta('Alta de arancel', "$base/aranceles", "$base/aranceles/guardar",
    ['id_concepto_pago' => $idConceptoNuevo ?: 1, 'id_periodo' => $idPeriodoNuevo ?: 3,
     'nombre' => 'Arancel ' . $marca, 'monto_base' => 150000,
     'monto_mora_diaria' => 1000, 'dias_gracia' => 3, 'cuotas' => 1,
     'fecha_vencimiento' => date('Y-m-d', strtotime('+30 days')), 'estado' => 'Activo'],
    'aranceles', 'nombre', 'Arancel ' . $marca);

// --- BECAS -------------------------------------------------------------
echo "\n-- Becas --\n";
probar_alta('Alta de beca', "$base/becas", "$base/becas/guardar",
    ['nombre' => 'Beca ' . $marca, 'tipo' => 'Porcentaje', 'porcentaje_descuento' => 15, 'estado' => 'Activo'],
    'becas', 'nombre', 'Beca ' . $marca);

// --- USUARIOS -----------------------------------------------------------
echo "\n-- Usuarios --\n";
$userNuevo = 'prb' . $sufijo;
probar_alta('Alta de usuario', "$base/usuarios/nuevo", "$base/usuarios/guardar",
    ['user' => $userNuevo, 'email' => "usuario{$sufijo}@test.local", 'nombres' => 'Usuario',
     'apellidos' => 'Prueba' . $sufijo, 'cedula' => '8' . substr((string) time(), -6),
     'id_rol' => 4, 'estado' => 'Activo', 'clave' => 'Prueba.2026', 'clave_confirmacion' => 'Prueba.2026'],
    'usuarios', 'user', $userNuevo);

// --- TRAMITES -----------------------------------------------------------
echo "\n-- Tramites --\n";
probar_alta('Alta de tipo de tramite', "$base/tramites/admin/tipos", "$base/tramites/admin/tipos/guardar",
    ['nombre_tramite' => 'Tramite ' . $marca, 'id_concepto_pago' => 1, 'dias_resolucion' => 3,
     'requiere_aprobacion' => 0, 'estado' => 'Activo'],
    'tipos_tramite', 'nombre_tramite', 'Tramite ' . $marca);

// --- EXAMENES -----------------------------------------------------------
echo "\n-- Examenes --\n";
probar_alta('Alta de examen', "$base/examenes/admin", "$base/examenes/admin/guardar",
    ['nombre' => 'Examen ' . $marca, 'materia' => 'Materia ' . $marca, 'tipo' => 'Final', 'id_periodo' => 3,
     'id_carrera' => 4, 'id_sede' => 1, 'id_concepto_pago' => 6, 'monto' => 150000,
     'fecha_examen' => date('Y-m-d', strtotime('+20 days')), 'hora_inicio' => '18:00',
     'duracion_min' => 90, 'aula' => 'Aula Test', 'cupo_maximo' => 30,
     'fecha_limite_insc' => date('Y-m-d', strtotime('+15 days')), 'requiere_pago' => 1,
     'estado' => 'Inscripcion abierta'],
    'examenes', 'nombre', 'Examen ' . $marca);

// --- FACTURACION --------------------------------------------------------
echo "\n-- Facturacion --\n";

// Buscar (o preparar) un pago aprobado sin factura para probar la emision
$idPagoLibre = (int) db()->consulta(
    'SELECT pg.id_pago FROM pagos pg
      WHERE pg.estado_pago = "Aprobado"
        AND NOT EXISTS (SELECT 1 FROM facturas f WHERE f.id_pago = pg.id_pago)
      ORDER BY pg.id_pago DESC LIMIT 1'
)->valor();

if ($idPagoLibre === 0) {
    db()->consulta('UPDATE pagos SET estado_pago = "Aprobado", fecha_pago = NOW() WHERE id_pago = 7');
    $idPagoLibre = 7;
}

$tok   = abrir("$base/facturacion/facturas");
$r     = enviar("$base/facturacion/emitir", ['_token' => $tok, 'id_pago' => $idPagoLibre]);
$ahora = contar('facturas', '`id_pago` = ?', [$idPagoLibre]) > 0;

resultado('Emision de factura', !$r['error'] && $r['codigo'] === 200 && $ahora,
    'HTTP ' . $r['codigo'] . ' ' . ($r['json']['mensaje'] ?? ''));

$tok = abrir("$base/facturacion/timbrados");
$r   = enviar("$base/facturacion/timbrados/guardar", [
    '_token' => $tok, 'id_sede' => 1, 'numero_timbrado' => 'T' . $sufijo, 'tipo_documento' => 'Factura',
    'punto_expedicion' => '003', 'establecimiento' => '001',
    'fecha_inicio_vigencia' => date('Y-01-01'), 'fecha_fin_vigencia' => date('Y-12-31'),
    'numero_inicio' => 1, 'numero_fin' => 1000, 'numero_actual' => 0, 'estado' => 'Activo',
]);
$existeTimbrado = contar('timbrados', '`numero_timbrado` = ?', ['T' . $sufijo]) > 0;
resultado('Alta de timbrado', $existeTimbrado, 'HTTP ' . $r['codigo'] . ' ' . ($r['json']['mensaje'] ?? ''));

// --- CONFIGURACION ------------------------------------------------------
echo "\n-- Configuracion --\n";
$tok = abrir("$base/configuracion");
$r   = enviar("$base/configuracion/guardar", [
    '_token' => $tok,
    'config' => [
        'contacto_email'   => 'pagos@unves.edu.py',
        'whatsapp_numero'  => '595991461220',
        'app_siglas'       => 'UNVES',
        'pasarela_activa'  => 'sandbox',
    ],
]);
resultado('Guardar configuracion', !$r['error'] && $r['codigo'] === 200, 'HTTP ' . $r['codigo'] . ' ' . ($r['json']['mensaje'] ?? ''));

// --- INTEGRACION --------------------------------------------------------
echo "\n-- Integracion --\n";
$r = pedir("$base/integracion/probando", ['headers' => ['X-Requested-With: XMLHttpRequest', 'Accept: application/json']]);
resultado('Probar conexion API', $r['codigo'] === 200, 'HTTP ' . $r['codigo']);

// --- CONTACTO publico ---------------------------------------------------
echo "\n-- Contacto --\n";
$tok = abrir("$base/contacto");
$r   = enviar("$base/contacto", [
    '_token' => $tok, 'nombre' => 'Visitante Prueba', 'email' => "visitante{$sufijo}@test.local",
    'asunto' => 'Consulta ' . $marca, 'mensaje' => 'Mensaje generado por la prueba automatica.',
]);
$existe = contar('mensajes_contacto', '`email` = ?', ["visitante{$sufijo}@test.local"]) > 0;
resultado('Envio de mensaje de contacto', $existe, 'HTTP ' . $r['codigo']);

// --- MENSAJES ------------------------------------------------------------
echo "\n-- Bandeja de mensajes --\n";
$lista = pedir("$base/mensajes")['cuerpo'];
resultado('Bandeja de mensajes renderiza', str_contains($lista, 'Visitante Prueba') || str_contains($lista, 'Consulta ' . $marca), '');

// --- LIMPIEZA -----------------------------------------------------------
// Los registros ZZ<his> son solo fixtures de la prueba: se eliminan para no
// contaminar el catalogo publico ni los listados administrativos.
echo "\n-- Limpieza --\n";
$limpieza = [
    ['aranceles', 'nombre', 'Arancel ' . $marca],
    ['conceptos_pago', 'nombre', 'Concepto ' . $marca],
    ['periodos_academicos', 'nombre', 'Periodo ' . $marca],
    ['carreras', 'nombre', 'Carrera ' . $marca],
    ['facultades', 'nombre', 'Facultad ' . $marca],
    ['sedes', 'nombre', 'Sede ' . $marca],
    ['mensajes_contacto', 'email', "visitante{$sufijo}@test.local"],
];
$borrados = 0;
foreach ($limpieza as [$tabla, $columna, $valor]) {
    $borrados += (int) db()->consulta("DELETE FROM `{$tabla}` WHERE `{$columna}` = ?", [$valor])->filasAfectadas();
}
echo "  Fixtures eliminados: $borrados\n";

echo "\n=== RESULTADO: $ok exitos, " . count($fallas) . " fallas ===\n";
if ($fallas !== []) {
    echo "\nDetalle de fallas:\n";
    foreach ($fallas as $f) {
        echo "  · $f\n";
    }
}
exit($fallas === [] ? 0 : 1);
