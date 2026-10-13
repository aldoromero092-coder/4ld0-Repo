<?php
/**
 * Genera (o regenera) el alumno de demostracion completo para probar el
 * portal de pagos de punta a punta: perfil, beca, matriculas historicas,
 * obligaciones en todos los estados, pagos reales con comprobante y factura,
 * inscripciones a examen, tramites, notificaciones y trazabilidad.
 *
 * Uso:
 *   php scripts/demo_alumno.php            Genera o regenera el alumno demo.
 *   php scripts/demo_alumno.php --borrar   Elimina unicamente sus datos.
 *   php scripts/demo_alumno.php --silencioso
 *
 * Es idempotente: cada ejecucion borra lo anterior del alumno demo y lo
 * vuelve a construir, sin tocar los datos semilla de los demas usuarios.
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('Este script solo puede ejecutarse desde la linea de comandos.');
}

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));

require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';

use App\Core\Auth;
use App\Core\App;
use App\Core\Config;
use App\Core\Database;
use App\Core\Logger;
use App\Core\Session;
use App\Models\Alumno;
use App\Models\AlumnoBeca;
use App\Models\Comprobante;
use App\Models\Examen;
use App\Models\InscripcionExamen;
use App\Models\Matricula;
use App\Models\Notificacion;
use App\Models\Obligacion;
use App\Models\Pago;
use App\Models\PagoDetalle;
use App\Models\Persona;
use App\Models\SesionWeb;
use App\Models\Tramite;
use App\Models\Usuario;
use App\Services\ExamenService;
use App\Services\FacturaService;
use App\Services\MatriculaService;
use App\Services\ObligacionService;
use App\Services\PagoService;
use App\Services\TramiteService;

Config::cargar();
date_default_timezone_set((string) Config::obtener('app.zona_horaria', 'America/Asuncion'));

// Los helpers url()/recurso() se apoyan en SCRIPT_NAME. Desde la consola eso
// apuntaria al propio script y sin la carpeta del proyecto, asi que lo
// reescribimos como si la peticion hubiera entrado por el portal.
$scriptCli = str_replace('\\', '/', (string) ($_SERVER['SCRIPT_NAME'] ?? ''));
$carpeta   = basename(RAIZ);

if ($carpeta !== '' && !str_contains($scriptCli, '/' . $carpeta . '/')) {
    $scriptCli = '/' . $carpeta . '/' . ltrim($scriptCli, '/');
}

$_SERVER['SCRIPT_NAME'] = preg_replace('#/(scripts|public)/[^/]+\.php$#', '/index.php', $scriptCli) ?: '/index.php';

// La sesion debe abrirse antes de escribir en la consola: una vez que la SAPI
// CLI emite la primera linea, PHP ya no permite iniciarla.
Session::iniciar();

$silencioso = in_array('--silencioso', $argv, true);
$soloBorrar = in_array('--borrar', $argv, true);

// =====================================================================
//  Datos fijos del alumno de demostracion
// =====================================================================
const DEMO_CEDULA         = '5234891-6';
const DEMO_USUARIO        = 'lucia.villalba';
const DEMO_CORREO         = 'lucia.villalba@unves.edu.py';
const DEMO_CLAVE          = 'Unves.2026';
const DEMO_LEGAJO         = '2024-ISI-070';
const DEMO_CODIGO_EXTERNO = 'EXT-2070';
const DEMO_ID_CARRERA     = 4;   // Ingenieria en Sistemas Informaticos
const DEMO_ID_FACULTAD    = 2;   // Facultad de Ingenieria
const DEMO_ID_SEDE        = 1;   // Campus Central - Villarrica
const DEMO_ID_PERIODO     = 3;   // 2026 - Segundo Semestre (activo)
const DEMO_ID_ROL_ALUMNO  = 2;
const DEMO_ID_BECA        = 2;   // Beca Deportiva 30%
const DEMO_PORC_BECA      = 0.30;
const DEMO_EXAMEN_HISTORICO = 'Mesa Final - Analisis de Sistemas';
const DEMO_MORA_DIARIA    = 2000;
const DEMO_DIAS_GRACIA    = 5;

/** Estado mutable del generador. */
$ctx = [
    'id_persona'  => 0,
    'id_usuario'  => 0,
    'id_alumno'   => 0,
    'comprobantes' => [],
    'facturas'    => 0,
    'pagos'       => 0,
];

// =====================================================================
//  Utilidades de consola
// =====================================================================
function linea(string $texto = ''): void
{
    global $silencioso;
    if (!$silencioso) {
        echo $texto . PHP_EOL;
    }
}

function fase(string $titulo): void
{
    linea();
    linea('── ' . $titulo . ' ' . str_repeat('─', max(0, 62 - mb_strlen($titulo))));
}

function dato(string $etiqueta, string $valor): void
{
    linea(sprintf('   %-26s %s', $etiqueta, $valor));
}

function ok(string $texto): void
{
    linea('   [OK] ' . $texto);
}

function aviso(string $texto): void
{
    linea('   [!]  ' . $texto);
}

function db(): Database
{
    return Database::instancia();
}

function consultar(string $sql, array $parametros = []): array
{
    return db()->consulta($sql, $parametros)->obtener() ?? [];
}

function valor(string $sql, array $parametros = [])
{
    return db()->consulta($sql, $parametros)->valor();
}

function ejecutar(string $sql, array $parametros = []): int
{
    return db()->consulta($sql, $parametros)->filasAfectadas();
}

// =====================================================================
//  Borrado de los datos del alumno demo
// =====================================================================
function marcadores(array $ids): string
{
    return implode(', ', array_fill(0, count($ids), '?'));
}

function ids(string $sql, array $parametros, string $columna): array
{
    $valores = array_map('intval', db()->consulta($sql, $parametros)->lista($columna));

    return array_values(array_unique(array_filter($valores, static fn (int $v): bool => $v > 0)));
}

/**
 * Identificadores del alumno demo. Se resuelven por cedula, usuario, correo,
 * legajo, codigo externo y por los pagos registrados a su nombre, para poder
 * limpiar tambien ejecuciones que quedaron a medias.
 *
 * @return array{personas: array<int>, usuarios: array<int>, alumnos: array<int>}
 */
function localizarDemo(): array
{
    $usuarios = ids('SELECT id_usuario FROM usuarios WHERE user = ? OR email = ?', [DEMO_USUARIO, DEMO_CORREO], 'id_usuario');

    $personas = array_values(array_unique(array_merge(
        ids('SELECT id_persona FROM personas WHERE cedula = ?', [DEMO_CEDULA], 'id_persona'),
        ids('SELECT id_persona FROM usuarios WHERE user = ? OR email = ?', [DEMO_USUARIO, DEMO_CORREO], 'id_persona')
    )));

    $alumnos = array_values(array_unique(array_merge(
        ids('SELECT id_alumno FROM alumnos WHERE legajo = ? OR codigo_externo = ?', [DEMO_LEGAJO, DEMO_CODIGO_EXTERNO], 'id_alumno'),
        $personas === []
            ? []
            : ids('SELECT id_alumno FROM alumnos WHERE id_persona IN (' . marcadores($personas) . ')', $personas, 'id_alumno'),
        $usuarios === []
            ? []
            : ids('SELECT id_alumno FROM pagos WHERE id_usuario IN (' . marcadores($usuarios) . ')', $usuarios, 'id_alumno')
    )));

    return ['personas' => $personas, 'usuarios' => $usuarios, 'alumnos' => $alumnos];
}

/**
 * Elimina todo el rastro del alumno demo.
 *
 * Las comprobaciones de claves foraneas se desactivan durante la limpieza
 * porque el orden de borrado depende de datos que pueden haber quedado
 * incompletos; despues se restablecen.
 */
function eliminarDemo(): int
{
    $ref = localizarDemo();

    if ($ref['personas'] === [] && $ref['usuarios'] === [] && $ref['alumnos'] === []) {
        return 0;
    }

    $porUsuario = $ref['usuarios'] === [] ? '' : marcadores($ref['usuarios']);
    $porAlumno  = $ref['alumnos'] === [] ? ''  : marcadores($ref['alumnos']);
    $porPersona = $ref['personas'] === [] ? '' : marcadores($ref['personas']);

    // Condicion que abarca todo pago del alumno demo.
    $condPago   = [];
    $paramsPago = [];
    if ($porAlumno !== '') {
        $condPago[]   = 'id_alumno IN (' . $porAlumno . ')';
        $paramsPago   = array_merge($paramsPago, $ref['alumnos']);
    }
    if ($porUsuario !== '') {
        $condPago[]   = 'id_usuario IN (' . $porUsuario . ')';
        $paramsPago   = array_merge($paramsPago, $ref['usuarios']);
    }
    if ($condPago === []) {
        return 0;
    }

    $wherePago     = implode(' OR ', $condPago);
    $subPago       = 'SELECT id_pago FROM pagos WHERE ' . $wherePago;

    $pasos = [];

    if ($porUsuario !== '') {
        foreach (['carrito_items', 'notificaciones', 'sesiones_web', 'password_resets',
                  'logs_actividad', 'auditorias', 'mensajes_contacto', 'usuario_rol'] as $tabla) {
            $pasos[] = [$tabla, "DELETE FROM `{$tabla}` WHERE id_usuario IN ({$porUsuario})", $ref['usuarios']];
        }
    }

    if ($porAlumno !== '') {
        foreach (['solicitudes_tramite', 'inscripciones_examen', 'matriculas', 'obligaciones_pago', 'alumno_beca'] as $tabla) {
            $pasos[] = [$tabla, "DELETE FROM `{$tabla}` WHERE id_alumno IN ({$porAlumno})", $ref['alumnos']];
        }
    }

    $pasos[] = ['pago_detalles', "DELETE FROM pago_detalles WHERE id_pago IN ({$subPago})", $paramsPago];
    $pasos[] = ['gateway_logs', "DELETE FROM gateway_logs WHERE id_pago IN ({$subPago})", $paramsPago];
    $pasos[] = ['comprobantes', "DELETE FROM comprobantes WHERE id_pago IN ({$subPago})", $paramsPago];
    $pasos[] = ['avisos internos de pago',
        "DELETE FROM notificaciones
          WHERE titulo = 'Nuevo pago registrado'
            AND url IN (SELECT CONCAT(?, id_pago) FROM pagos WHERE {$wherePago})",
        array_merge([App::url('/pagos/detalle/')], $paramsPago)];

    if ($porAlumno !== '') {
        $pasos[] = ['factura_detalles',
            "DELETE FROM factura_detalles WHERE id_factura IN (SELECT id_factura FROM facturas
                WHERE id_pago IN ({$subPago}) OR id_alumno IN ({$porAlumno}))",
            array_merge($paramsPago, $ref['alumnos'])];
        $pasos[] = ['facturas',
            "DELETE FROM facturas WHERE id_pago IN ({$subPago}) OR id_alumno IN ({$porAlumno})",
            array_merge($paramsPago, $ref['alumnos'])];
    } else {
        $pasos[] = ['factura_detalles',
            "DELETE FROM factura_detalles WHERE id_factura IN (SELECT id_factura FROM facturas WHERE id_pago IN ({$subPago}))",
            $paramsPago];
        $pasos[] = ['facturas', "DELETE FROM facturas WHERE id_pago IN ({$subPago})", $paramsPago];
    }

    $pasos[] = ['pagos', "DELETE FROM pagos WHERE {$wherePago}", $paramsPago];

    if ($porPersona !== '') {
        $pasos[] = ['datos_fiscales', "DELETE FROM datos_fiscales WHERE id_persona IN ({$porPersona})", $ref['personas']];
    }

    $condAlumno = [];
    $paramsAlumno = [];
    if ($porAlumno !== '') {
        $condAlumno[]   = 'id_alumno IN (' . $porAlumno . ')';
        $paramsAlumno   = array_merge($paramsAlumno, $ref['alumnos']);
    }
    if ($porPersona !== '') {
        $condAlumno[]   = 'id_persona IN (' . $porPersona . ')';
        $paramsAlumno   = array_merge($paramsAlumno, $ref['personas']);
    }
    $condAlumno[]     = 'legajo = ?';
    $paramsAlumno[]   = DEMO_LEGAJO;
    $condAlumno[]     = 'codigo_externo = ?';
    $paramsAlumno[]   = DEMO_CODIGO_EXTERNO;
    $pasos[] = ['alumnos', 'DELETE FROM alumnos WHERE ' . implode(' OR ', $condAlumno), $paramsAlumno];

    $condUsuario  = [];
    $paramsUsuario = [];
    if ($porUsuario !== '') {
        $condUsuario[]  = 'id_usuario IN (' . $porUsuario . ')';
        $paramsUsuario  = array_merge($paramsUsuario, $ref['usuarios']);
    }
    if ($porPersona !== '') {
        $condUsuario[]  = 'id_persona IN (' . $porPersona . ')';
        $paramsUsuario  = array_merge($paramsUsuario, $ref['personas']);
    }
    $condUsuario[]  = 'user = ?';
    $paramsUsuario[] = DEMO_USUARIO;
    $condUsuario[]  = 'email = ?';
    $paramsUsuario[] = DEMO_CORREO;
    $pasos[] = ['usuarios', 'DELETE FROM usuarios WHERE ' . implode(' OR ', $condUsuario), $paramsUsuario];

    $condPersona  = [$porPersona === '' ? '1 = 0' : 'id_persona IN (' . $porPersona . ')', 'cedula = ?'];
    $paramsPersona = array_merge($ref['personas'], [DEMO_CEDULA]);
    $pasos[] = ['personas', 'DELETE FROM personas WHERE ' . implode(' OR ', $condPersona), $paramsPersona];

    $pasos[] = ['examenes (mesa historica)',
        'DELETE FROM examenes WHERE nombre = ? AND id_periodo = 2 AND NOT EXISTS
            (SELECT 1 FROM (SELECT id_examen FROM inscripciones_examen) x WHERE x.id_examen = examenes.id_examen)',
        [DEMO_EXAMEN_HISTORICO]];

    $borrados = 0;
    ejecutar('SET FOREIGN_KEY_CHECKS = 0');

    foreach ($pasos as [$etiqueta, $sql, $parametros]) {
        try {
            $filas = ejecutar($sql, $parametros);
            if ($filas > 0) {
                $borrados += $filas;
                linea(sprintf('   · %-24s %d registro(s)', $etiqueta, $filas));
            }
        } catch (Throwable $e) {
            aviso('No se pudo limpiar ' . $etiqueta . ': ' . $e->getMessage());
        }
    }

    ejecutar('SET FOREIGN_KEY_CHECKS = 1');

    return $borrados;
}
// =====================================================================
//  Helpers de dominio
// =====================================================================
function crearObligacion(array $datos): int
{
    $id = (new ObligacionService())->crear($datos);

    // La emision historica se fija despues de crear para conservar el orden real.
    if (!empty($datos['fecha_emision'])) {
        ejecutar(
            'UPDATE obligaciones_pago SET creado_en = ? WHERE id_obligacion = ?',
            [$datos['fecha_emision'] . ' 09:00:00', $id]
        );
    }

    return $id;
}

/**
 * Registra un pago real (usa PagoService) y lo fecha en el momento historico.
 *
 * @return array{id_pago:int, monto:float, comprobante:string, fecha:string}
 */
function registrarPago(int $idAlumno, array $idsObligaciones, int $idMetodo, string $pasarela, string $fecha, string $observacion = ''): array
{
    $servicio = new PagoService();
    $contexto = [
        'id_sede'     => DEMO_ID_SEDE,
        'id_periodo'  => DEMO_ID_PERIODO,
        'id_usuario'  => $GLOBALS['ctx']['id_usuario'],
        'observacion' => $observacion !== '' ? $observacion : null,
    ];

    if ($pasarela === 'caja') {
        $resultado = $servicio->cobrarEnCaja($idAlumno, $idsObligaciones, $idMetodo, $contexto + [
            'monto_recibido' => null,
            'vuelto'         => 0,
        ]);
    } else {
        $creacion = $servicio->crearIntencion($idAlumno, $idsObligaciones, $idMetodo, $pasarela, $contexto + [
            'tipo_pago' => 'Online',
        ]);

        if (!$creacion['ok']) {
            throw new RuntimeException('No se pudo iniciar el pago: ' . $creacion['mensaje']);
        }

        $resultado = $servicio->confirmar((int) $creacion['id_pago'], [
            'observacion' => $contexto['observacion'] ?? 'Pago en linea',
        ]);
    }

    if (!$resultado['ok']) {
        throw new RuntimeException('No se pudo confirmar el pago: ' . ($resultado['mensaje'] ?? ''));
    }

    $idPago = (int) $resultado['id_pago'];
    fecharPago($idPago, $fecha);

    $pago = consultar('SELECT monto_total, numero_comprobante FROM pagos WHERE id_pago = ?', [$idPago]);

    $GLOBALS['ctx']['pagos']++;
    $GLOBALS['ctx']['comprobantes'][] = (string) ($pago['numero_comprobante'] ?? '');

    return [
        'id_pago'     => $idPago,
        'monto'       => (float) ($pago['monto_total'] ?? 0),
        'comprobante' => (string) ($pago['numero_comprobante'] ?? ''),
        'fecha'       => $fecha,
    ];
}

/** Reubica la fecha de un pago y todo su rastro documental. */
function fecharPago(int $idPago, string $fecha): void
{
    $sello = $fecha . ' 10:00:00';

    ejecutar('UPDATE pagos SET fecha_pago = ?, creado_en = ? WHERE id_pago = ?', [$sello, $sello, $idPago]);
    ejecutar('UPDATE comprobantes SET fecha_generacion = ? WHERE id_pago = ?', [$sello, $idPago]);
    ejecutar('UPDATE facturas SET fecha_emision = ? WHERE id_pago = ?', [$sello, $idPago]);
    ejecutar('UPDATE gateway_logs SET fecha_registro = ? WHERE id_pago = ?', [$sello, $idPago]);
}

function notificar(int $idUsuario, string $titulo, string $mensaje, string $tipo = 'info', ?string $url = null, bool $leida = false): int
{
    $modelo = new Notificacion();

    return $modelo->crear([
        'id_usuario' => $idUsuario,
        'titulo'     => $titulo,
        'mensaje'    => $mensaje,
        'tipo'       => $tipo,
        'url'        => $url,
        'leida'      => $leida ? 1 : 0,
        'fecha_lectura' => $leida ? date('Y-m-d H:i:s') : null,
    ]);
}

// =====================================================================
//  Ejecucion
// =====================================================================
linea();
linea('======================================================================');
linea(' UNVES · Generador del alumno de demostracion');
linea(' ' . date('d/m/Y H:i:s'));
linea('======================================================================');

if ($soloBorrar) {
    fase('Eliminando los datos del alumno de demostracion');
    $total = eliminarDemo();
    $total > 0 ? ok($total . ' registro(s) eliminado(s).') : aviso('No habia datos del alumno demo.');
    linea();
    exit(0);
}

fase('Limpiando ejecuciones anteriores');
$habiaDatos = localizarDemo();
$previos    = eliminarDemo();
$previos > 0
    ? ok($previos . ' registro(s) previo(s) eliminado(s).')
    : ($habiaDatos['alumnos'] === [] && $habiaDatos['usuarios'] === []
        ? ok('Sin datos previos: primera ejecucion.')
        : aviso('No habia registros que eliminar.'));

fase('Verificando el entorno');
$periodo = consultar('SELECT * FROM periodos_academicos WHERE id_periodo = ?', [DEMO_ID_PERIODO]);
if ($periodo === [] || strcasecmp((string) $periodo['estado'], 'Activo') !== 0) {
    aviso('El periodo ' . DEMO_ID_PERIODO . ' no existe o no esta activo. Corregilo antes de continuar.');
    exit(1);
}
dato('Periodo activo', (string) $periodo['nombre'] . ' (' . $periodo['fecha_inicio'] . ' a ' . $periodo['fecha_fin'] . ')');

$carrera = consultar('SELECT * FROM carreras WHERE id_carrera = ?', [DEMO_ID_CARRERA]);
if ($carrera === []) {
    aviso('No existe la carrera ' . DEMO_ID_CARRERA . '.');
    exit(1);
}
dato('Carrera', (string) $carrera['nombre']);

$timbrado = valor('SELECT COUNT(*) FROM timbrados WHERE id_sede = ? AND estado = "Activo"', [DEMO_ID_SEDE]);
if ((int) $timbrado === 0) {
    aviso('No hay timbrado activo para la sede ' . DEMO_ID_SEDE . ': los comprobantes no podran facturarse.');
}

// ---------------------------------------------------------------------
fase('Creando el perfil del alumno');

$idPersona = (new Persona())->crear([
    'cedula'       => DEMO_CEDULA,
    'nombres'      => 'Lucia Fernanda',
    'apellidos'    => 'Villalba Rios',
    'telefono'     => '+595 991 234 567',
    'celular'      => '0991 234 567',
    'email'        => DEMO_CORREO,
    'direccion'    => 'Barrio San Blas, calle Mcal. Estigarribia 1245, Villarrica',
    'id_ciudades'  => 1,
    'fecha_nac'    => '2004-06-12',
    'nacionalidad' => 'Paraguaya',
    'sexo'         => 'F',
    'estado'       => 'Activo',
]);
$ctx['id_persona'] = $idPersona;
ok('Persona creada (ID ' . $idPersona . ') · cedula ' . DEMO_CEDULA);

$idUsuario = (new Usuario())->crear([
    'user'       => DEMO_USUARIO,
    'email'      => DEMO_CORREO,
    'id_persona' => $idPersona,
    'pass'       => Auth::hash(DEMO_CLAVE),
    'estado'     => 'Activo',
    'id_rol'     => DEMO_ID_ROL_ALUMNO,
    'sucursal_cod' => '001',
    'sucursal'     => 'Campus Central',
    'facultad'     => 'Ingenieria',
]);
$ctx['id_usuario'] = $idUsuario;

ejecutar('INSERT IGNORE INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)', [$idUsuario, DEMO_ID_ROL_ALUMNO]);
ok('Usuario ' . DEMO_USUARIO . ' creado (ID ' . $idUsuario . ') · clave ' . DEMO_CLAVE);

$idAlumno = (new Alumno())->crear([
    'id_persona'         => $idPersona,
    'legajo'             => DEMO_LEGAJO,
    'codigo_externo'     => DEMO_CODIGO_EXTERNO,
    'id_carrera'         => DEMO_ID_CARRERA,
    'id_facultades'      => DEMO_ID_FACULTAD,
    'id_sede'            => DEMO_ID_SEDE,
    'id_periodo_ingreso' => 2,
    'semestre_actual'    => 6,
    'estado_academico'   => 'Activo',
    'modalidad'          => 'Presencial',
    'turno'              => 'Noche',
    'fecha_ingreso'      => '2024-02-05',
    'promedio_general'   => 4.28,
    'creditos_aprobados' => 152,
    'origen_datos'       => 'API',
    'ultima_sincronizacion' => date('Y-m-d H:i:s'),
    'observaciones'      => 'Registro traido desde el sistema central de la universidad.',
    'estado'             => 'Activo',
]);
$ctx['id_alumno'] = $idAlumno;
ok('Legajo ' . DEMO_LEGAJO . ' creado (ID ' . $idAlumno . ')');

// La sesion de consola se autentica como el alumno para que la auditoria,
// las notificaciones y los comprobantes queden a su nombre.
Session::guardar('__usuario_id', $idUsuario);
Session::guardar('__usuario_rol', DEMO_ID_ROL_ALUMNO);
ok('Sesion de consola asociada al alumno demo (auditoria a su nombre)');

$idBecaAsignada = (new AlumnoBeca())->crear([
    'id_alumno'        => $idAlumno,
    'id_beca'          => DEMO_ID_BECA,
    'id_periodo'       => DEMO_ID_PERIODO,
    'fecha_asignacion' => '2026-07-15',
    'fecha_fin'        => (string) $periodo['fecha_fin'],
    'estado'           => 'Activo',
    'observaciones'    => 'Beca Deportiva 30% por representar a la UNVES en los Juegos Universitarios.',
]);
ok('Beca Deportiva 30% asignada (ID ' . $idBecaAsignada . ')');

// ---------------------------------------------------------------------
fase('Matriculas');

$hoy = date('Y-m-d');

// --- Matriculas historicas (se insertan directo para conservar sus fechas)
$idMatricula2025 = (new Matricula())->crear([
    'numero_matricula' => 'MAT-2025-2-0070',
    'id_alumno'        => $idAlumno,
    'id_periodo'       => 1,
    'id_carrera'       => DEMO_ID_CARRERA,
    'id_facultades'    => DEMO_ID_FACULTAD,
    'id_sede'          => DEMO_ID_SEDE,
    'semestre'         => 4,
    'turno'            => 'Noche',
    'modalidad'        => 'Presencial',
    'monto_matricula'  => 780000,
    'fecha_solicitud'  => '2025-07-16 09:40:00',
    'fecha_confirmacion' => '2025-07-18 10:15:00',
    'estado'           => 'Confirmada',
    'documentacion_ok' => 1,
]);
ejecutar('UPDATE matriculas SET creado_en = ?, actualizado_en = ? WHERE id_matricula = ?',
    ['2025-07-16 09:40:00', '2025-07-18 10:15:00', $idMatricula2025]);

$idMatricula2026_1 = (new Matricula())->crear([
    'numero_matricula' => 'MAT-2026-1-0070',
    'id_alumno'        => $idAlumno,
    'id_periodo'       => 2,
    'id_carrera'       => DEMO_ID_CARRERA,
    'id_facultades'    => DEMO_ID_FACULTAD,
    'id_sede'          => DEMO_ID_SEDE,
    'semestre'         => 5,
    'turno'            => 'Noche',
    'modalidad'        => 'Presencial',
    'monto_matricula'  => 820000,
    'fecha_solicitud'  => '2026-01-26 14:10:00',
    'fecha_confirmacion' => '2026-01-28 09:30:00',
    'estado'           => 'Confirmada',
    'documentacion_ok' => 1,
]);
ejecutar('UPDATE matriculas SET creado_en = ?, actualizado_en = ? WHERE id_matricula = ?',
    ['2026-01-26 14:10:00', '2026-01-28 09:30:00', $idMatricula2026_1]);

ok('Matricula 2025-2 confirmada (ID ' . $idMatricula2025 . ')');
ok('Matricula 2026-1 confirmada (ID ' . $idMatricula2026_1 . ')');

// --- Matricula del periodo activo: se usa el flujo real del portal
$servicioMatricula = new MatriculaService();
$solicitud = $servicioMatricula->solicitar($idAlumno, DEMO_ID_PERIODO, [
    'turno'            => 'Noche',
    'modalidad'        => 'Presencial',
    'documentacion_ok' => true,
    'observaciones'    => 'Solicitud en linea desde el portal de pagos.',
]);

if (!$solicitud['ok']) {
    aviso('No se pudo registrar la matricula del periodo activo: ' . $solicitud['mensaje']);
    exit(1);
}

$idMatricula2026_2 = (int) $solicitud['id_matricula'];
$idObligacionMatricula = (int) $solicitud['id_obligacion'];
ok('Matricula ' . $solicitud['numero'] . ' solicitada (ID ' . $idMatricula2026_2 . ')');

fase('Becas y obligaciones de periodos anteriores');

// Matricula 2025-2
$obligMatricula2025 = crearObligacion([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 1,
    'id_periodo'        => 1,
    'id_matricula'      => $idMatricula2025,
    'descripcion'       => 'Matricula 2025-2',
    'referencia'        => 'MAT-2025-2-0070',
    'monto'             => 780000,
    'fecha_emision'     => '2025-07-16',
    'fecha_vencimiento' => '2025-08-15',
    'prioridad'         => 'Alta',
]);

// Arancel agosto 2025
$obligArancel2025 = crearObligacion([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 3,
    'id_periodo'        => 1,
    'id_arancel'        => 3,
    'descripcion'       => 'Arancel Agosto 2025',
    'referencia'        => 'ARA-2025-08',
    'monto'             => 650000,
    'fecha_emision'     => '2025-08-01',
    'fecha_vencimiento' => '2025-08-10',
]);

// Matricula 2026-1
$obligMatricula2026_1 = crearObligacion([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 1,
    'id_periodo'        => 2,
    'id_matricula'      => $idMatricula2026_1,
    'descripcion'       => 'Matricula 2026-1',
    'referencia'        => 'MAT-2026-1-0070',
    'monto'             => 820000,
    'fecha_emision'     => '2026-01-26',
    'fecha_vencimiento' => '2026-02-15',
    'prioridad'         => 'Alta',
]);

ok('3 obligaciones historicas creadas (matriculas 2025-2 / 2026-1 y arancel 2025-08)');

fase('Pagos historicos');

$p1 = registrarPago($idAlumno, [$obligMatricula2025], 7, 'sandbox', '2025-07-18', 'Pago de matricula 2025-2');
dato('1. Matricula 2025-2', dinero($p1['monto']) . '  ·  ' . $p1['comprobante'] . '  ·  ' . $p1['fecha']);

$p2 = registrarPago($idAlumno, [$obligArancel2025], 2, 'transferencia', '2025-08-07', 'Arancel Agosto 2025 por transferencia');
dato('2. Arancel Agosto 2025', dinero($p2['monto']) . '  ·  ' . $p2['comprobante'] . '  ·  ' . $p2['fecha']);

$p3 = registrarPago($idAlumno, [$obligMatricula2026_1], 7, 'sandbox', '2026-01-28', 'Pago de matricula 2026-1');
dato('3. Matricula 2026-1', dinero($p3['monto']) . '  ·  ' . $p3['comprobante'] . '  ·  ' . $p3['fecha']);

// ---------------------------------------------------------------------
fase('Examen de un periodo cerrado (rendido)');

$examenAnterior = (new Examen())->crear([
    'nombre'            => 'Mesa Final - Analisis de Sistemas',
    'materia'           => 'Analisis de Sistemas',
    'tipo'              => 'Final',
    'id_periodo'        => 2,
    'id_carrera'        => DEMO_ID_CARRERA,
    'id_facultades'     => DEMO_ID_FACULTAD,
    'id_sede'           => DEMO_ID_SEDE,
    'id_concepto_pago'  => 6,
    'monto'             => 140000,
    'fecha_examen'      => '2026-06-25',
    'hora_inicio'       => '18:00:00',
    'duracion_min'      => 90,
    'aula'              => 'Aula 09',
    'cupo_maximo'       => 30,
    'inscritos'         => 1,
    'fecha_limite_insc' => '2026-06-20',
    'requiere_pago'     => 1,
    'estado'            => 'Finalizado',
]);
ejecutar('UPDATE examenes SET creado_en = ? WHERE id_examen = ?', ['2026-06-01 08:00:00', $examenAnterior]);

$obligExamenAnterior = crearObligacion([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 6,
    'id_periodo'        => 2,
    'descripcion'       => 'Final - Analisis de Sistemas',
    'referencia'        => 'EXA-HIST',
    'monto'             => 140000,
    'fecha_emision'     => '2026-06-15',
    'fecha_vencimiento' => '2026-06-25',
]);

$idInscripcionAnterior = (new InscripcionExamen())->crear([
    'id_examen'         => $examenAnterior,
    'id_alumno'         => $idAlumno,
    'id_obligacion'     => $obligExamenAnterior,
    'fecha_inscripcion' => '2026-06-15 11:20:00',
    'estado'            => 'Pendiente',
    'condicion'         => 'Regular',
    'observaciones'     => 'Mesa final del primer semestre 2026.',
]);
ok('Mesa final de Analisis de Sistemas creada (examen ' . $examenAnterior . ')');

$p4 = registrarPago($idAlumno, [$obligExamenAnterior], 5, 'sandbox', '2026-06-20', 'Derecho de examen final');
dato('4. Examen Analisis de Sistemas', dinero($p4['monto']) . '  ·  ' . $p4['comprobante'] . '  ·  ' . $p4['fecha']);

ejecutar(
    'UPDATE inscripciones_examen SET estado = "Rendido", nota = 4.50, id_pago = ? WHERE id_inscripcion = ?',
    [$p4['id_pago'], $idInscripcionAnterior]
);

// ---------------------------------------------------------------------
fase('Matricula del periodo activo con beca');

$p5 = registrarPago($idAlumno, [$idObligacionMatricula], 7, 'sandbox', '2026-07-23', 'Pago de matricula 2026-2');
dato('5. Matricula 2026-2 (beca 30%)', dinero($p5['monto']) . '  ·  ' . $p5['comprobante'] . '  ·  ' . $p5['fecha']);

// ---------------------------------------------------------------------
fase('Aranceles mensuales 2026-2');

$meses = [
    ['Arancel Julio 2026',      'ARA-2026-07', '2026-07-01', '2026-08-10'],
    ['Arancel Agosto 2026',     'ARA-2026-08', '2026-08-01', '2026-09-10'],
    ['Arancel Septiembre 2026', 'ARA-2026-09', '2026-09-01', '2026-10-10'],
    ['Arancel Octubre 2026',    'ARA-2026-10', '2026-10-01', '2026-11-10'],
    ['Arancel Noviembre 2026',  'ARA-2026-11', '2026-11-01', '2026-12-10'],
];

$obligacionesArancel = [];
foreach ($meses as [$descripcion, $referencia, $emision, $vencimiento]) {
    $obligacionesArancel[$referencia] = crearObligacion([
        'id_alumno'         => $idAlumno,
        'id_concepto_pago'  => 3,
        'id_periodo'        => DEMO_ID_PERIODO,
        'id_arancel'        => 3,
        'descripcion'       => $descripcion,
        'referencia'        => $referencia,
        'monto'             => 720000,
        'aplicar_beca'      => true,
        'fecha_emision'     => $emision,
        'fecha_vencimiento' => $vencimiento,
    ]);
}

$arancelJulio = $obligacionesArancel['ARA-2026-07'];
$arancelAgosto = $obligacionesArancel['ARA-2026-08'];
$arancelSeptiembre = $obligacionesArancel['ARA-2026-09'];
$arancelOctubre = $obligacionesArancel['ARA-2026-10'];
$arancelNoviembre = $obligacionesArancel['ARA-2026-11'];

$montoArancel = (float) valor('SELECT monto_final FROM obligaciones_pago WHERE id_obligacion = ?', [$arancelJulio]);
ok('5 aranceles generados con beca del 30% · cuota ' . dinero($montoArancel));

$p6 = registrarPago($idAlumno, [$arancelJulio], 2, 'transferencia', '2026-08-05', 'Arancel Julio 2026 por transferencia');
dato('6. Arancel Julio 2026', dinero($p6['monto']) . '  ·  ' . $p6['comprobante'] . '  ·  ' . $p6['fecha']);

$p7 = registrarPago($idAlumno, [$arancelAgosto], 5, 'sandbox', '2026-09-08', 'Arancel Agosto 2026 con Tigo Money');
dato('7. Arancel Agosto 2026', dinero($p7['monto']) . '  ·  ' . $p7['comprobante'] . '  ·  ' . $p7['fecha']);

$p8 = registrarPago($idAlumno, [$arancelSeptiembre], 3, 'sandbox', '2026-10-02', 'Arancel Septiembre 2026 con tarjeta');
dato('8. Arancel Septiembre 2026', dinero($p8['monto']) . '  ·  ' . $p8['comprobante'] . '  ·  ' . $p8['fecha']);

// ---------------------------------------------------------------------
fase('Tramites academicos');

$servicioTramite = new TramiteService();

$tramiteConstancia = $servicioTramite->solicitar($idAlumno, 1, [
    'tipo_entrega'   => 'Digital',
    'observaciones'  => 'Constancia para presentar en el banco.',
]);
if (!$tramiteConstancia['ok']) {
    aviso('No se pudo solicitar la constancia: ' . $tramiteConstancia['mensaje']);
} else {
    ejecutar(
        'UPDATE solicitudes_tramite SET fecha_solicitud = ?, creado_en = ? WHERE id_solicitud = ?',
        ['2026-10-03 09:15:00', '2026-10-03 09:15:00', $tramiteConstancia['id_solicitud']]
    );
    ok('Constancia de alumno regular solicitada (' . $tramiteConstancia['codigo'] . ')');

    $p9 = registrarPago($idAlumno, [(int) $tramiteConstancia['id_obligacion']], 7, 'sandbox', '2026-10-05', 'Arancel de constancia de alumno regular');
    dato('9. Constancia de alumno regular', dinero($p9['monto']) . '  ·  ' . $p9['comprobante'] . '  ·  ' . $p9['fecha']);

    $servicioTramite->cambiarEstado((int) $tramiteConstancia['id_solicitud'], 'Entregado', [
        'id_usuario'     => $ctx['id_usuario'],
        'observaciones'  => 'Constancia entregada en ventanilla de secretaria.',
    ]);
}

// --- Pago parcial del arancel de octubre (queda en estado Parcial)
$saldoOctubre = (float) valor('SELECT monto_final FROM obligaciones_pago WHERE id_obligacion = ?', [$arancelOctubre]);
$entregaParcial = round($saldoOctubre * 0.6, -3);

$modeloPago = new Pago();
$numeroParcial = $modeloPago->siguienteNumeroComprobante();

$idPagoParcial = $modeloPago->crear([
    'id_alumno'          => $idAlumno,
    'id_metodo_pago'     => 1,
    'id_usuario'         => $ctx['id_usuario'],
    'id_periodo'         => DEMO_ID_PERIODO,
    'id_sede'            => DEMO_ID_SEDE,
    'codigo_transaccion' => 'TX-PARCIAL-20261008',
    'pasarela'           => 'caja',
    'monto_total'        => $entregaParcial,
    'moneda'             => 'PYG',
    'tipo_pago'          => 'Caja',
    'monto_recibido'     => $entregaParcial,
    'vuelto'             => 0,
    'fecha_pago'         => '2026-10-08 10:00:00',
    'estado_pago'        => 'Aprobado',
    'numero_comprobante' => $numeroParcial,
    'observacion'        => 'Entrega parcial del arancel de octubre en caja.',
]);

(new PagoDetalle())->crear([
    'id_pago'       => $idPagoParcial,
    'id_obligacion' => $arancelOctubre,
    'monto_pagado'  => $entregaParcial,
]);

(new Obligacion())->recalcular($arancelOctubre);

(new Comprobante())->crear([
    'id_pago'    => $idPagoParcial,
    'numero'     => $numeroParcial,
    'tipo'       => 'Recibo',
    'id_usuario' => $ctx['id_usuario'],
]);

$modeloPago->actualizar($idPagoParcial, ['url_comprobante' => url('/pagos/comprobante/' . $idPagoParcial)]);

try {
    (new FacturaService())->emitirDesdePago($idPagoParcial);
} catch (Throwable $e) {
    aviso('No se pudo emitir la factura del pago parcial: ' . $e->getMessage());
}

fecharPago($idPagoParcial, '2026-10-08');

$ctx['pagos']++;
$ctx['comprobantes'][] = $numeroParcial;
dato('10. Arancel Octubre 2026 (pago parcial)', dinero($entregaParcial) . '  ·  ' . $numeroParcial . '  ·  2026-10-08');

$tramiteCertificado = $servicioTramite->solicitar($idAlumno, 2, [
    'tipo_entrega'  => 'Digital',
    'observaciones' => 'Certificado para postulacion a una pasantia.',
]);
if (!$tramiteCertificado['ok']) {
    aviso('No se pudo solicitar el certificado: ' . $tramiteCertificado['mensaje']);
} else {
    ejecutar(
        'UPDATE solicitudes_tramite SET fecha_solicitud = ?, creado_en = ? WHERE id_solicitud = ?',
        ['2026-10-09 16:40:00', '2026-10-09 16:40:00', $tramiteCertificado['id_solicitud']]
    );
    ok('Certificado de calificaciones solicitado (' . $tramiteCertificado['codigo'] . ')');

    $p11 = registrarPago($idAlumno, [(int) $tramiteCertificado['id_obligacion']], 4, 'sandbox', '2026-10-11', 'Arancel del certificado de calificaciones');
    dato('11. Certificado de calificaciones', dinero($p11['monto']) . '  ·  ' . $p11['comprobante'] . '  ·  ' . $p11['fecha']);

    $servicioTramite->cambiarEstado((int) $tramiteCertificado['id_solicitud'], 'Listo para retirar', [
        'id_usuario'    => $ctx['id_usuario'],
        'observaciones' => 'Listo para retirar en Registro Academico.',
    ]);
}

// --- Tramite sin costo, en proceso
$tramiteCambio = $servicioTramite->solicitar($idAlumno, 7, [
    'observaciones' => 'Solicito evaluar el cambio a Ingenieria Industrial.',
]);
if ($tramiteCambio['ok']) {
    $servicioTramite->cambiarEstado((int) $tramiteCambio['id_solicitud'], 'En proceso', ['id_usuario' => $ctx['id_usuario']]);
    ok('Cambio de carrera solicitado (' . $tramiteCambio['codigo'] . ') · En proceso');
}

// --- Tramite pendiente de pago
$tramiteDuplicado = $servicioTramite->solicitar($idAlumno, 3, [
    'tipo_entrega'  => 'Presencial',
    'observaciones' => 'Perdi mi credencial universitaria.',
]);
if ($tramiteDuplicado['ok']) {
    ok('Duplicado de credencial solicitado (' . $tramiteDuplicado['codigo'] . ') · Pendiente de pago ' . dinero((float) $tramiteDuplicado['monto']));
}

// ---------------------------------------------------------------------
fase('Obligaciones pendientes, vencidas y anuladas');

$obligLab = crearObligacion([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 4,
    'id_periodo'        => DEMO_ID_PERIODO,
    'id_arancel'        => 13,
    'descripcion'       => 'Laboratorio Ing. Sistemas 2026',
    'referencia'        => 'LAB-2026',
    'monto'             => 300000,
    'fecha_emision'     => '2026-08-01',
    'fecha_vencimiento' => '2026-09-30',
    'prioridad'         => 'Alta',
]);

// Mora calculada con la misma regla que usa la aplicacion (mora diaria + dias de gracia).
$diasMora = (int) (valor(
    'SELECT GREATEST(0, DATEDIFF(CURDATE(), fecha_vencimiento) - ?) FROM obligaciones_pago WHERE id_obligacion = ?',
    [DEMO_DIAS_GRACIA, $obligLab]
) ?? 0);
$moraLab = round($diasMora * DEMO_MORA_DIARIA, 2);
ejecutar(
    'UPDATE obligaciones_pago
        SET monto_mora = ?, monto_final = monto_original + ? - monto_descuento,
            saldo = GREATEST(0, monto_original + ? - monto_descuento - monto_pagado), estado = "Vencido"
      WHERE id_obligacion = ?',
    [$moraLab, $moraLab, $moraLab, $obligLab]
);
$saldoLab = (float) valor('SELECT saldo FROM obligaciones_pago WHERE id_obligacion = ?', [$obligLab]);
ok('Laboratorio vencido: ' . $diasMora . ' dia(s) de mora (' . dinero($moraLab) . ') · saldo ' . dinero($saldoLab));

$obligKit = crearObligacion([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 13,
    'id_periodo'        => DEMO_ID_PERIODO,
    'id_arancel'        => 12,
    'descripcion'       => 'Kit universitario 2026',
    'referencia'        => 'KIT-2026',
    'monto'             => 250000,
    'fecha_emision'     => '2026-08-01',
    'fecha_vencimiento' => '2026-09-30',
]);
$anulacion = (new ObligacionService())->anular($obligKit, 'El alumno ya contaba con el kit del ano anterior.');
$anulacion['ok'] ? ok('Kit universitario anulado (estado Anulado)') : aviso($anulacion['mensaje']);

// ---------------------------------------------------------------------
fase('Inscripciones a examen del periodo activo');

$servicioExamen = new ExamenService();

foreach ([1 => 'Programacion Web', 2 => 'Base de Datos II'] as $idExamen => $materia) {
    $inscripcion = $servicioExamen->inscribir($idAlumno, $idExamen, ['condicion' => 'Regular']);

    if ($inscripcion['ok']) {
        ok('Inscripto en "' . $materia . '" · obligacion ' . dinero((float) $inscripcion['monto']));
    } else {
        aviso('No se pudo inscribir en "' . $materia . '": ' . $inscripcion['mensaje']);
    }
}

$obligacionesExamen = (int) valor(
    'SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ? AND id_periodo = ? AND id_concepto_pago IN (6,7) AND estado <> "Anulado"',
    [$idAlumno, DEMO_ID_PERIODO]
);
ok($obligacionesExamen . ' derecho(s) de examen del periodo activo registrados');

// ---------------------------------------------------------------------
fase('Notificaciones, sesiones y trazabilidad');

notificar($ctx['id_usuario'], 'Bienvenida al portal de pagos',
    'Hola Lucia, ya podés consultar tus obligaciones, pagar en linea y descargar tus comprobantes.', 'info', '/panel', true);

notificar($ctx['id_usuario'], 'Beca Deportiva asignada',
    'Se te otorgo la Beca Deportiva del 30% sobre matriculas y aranceles del periodo 2026 - Segundo Semestre.', 'exito', '/mi-perfil', true);

notificar($ctx['id_usuario'], 'Nuevo arancel disponible',
    'Ya esta disponible el arancel de noviembre 2026 por ' . dinero($montoArancel) . ' con tu beca aplicada.', 'info', '/pagos/pendientes');

notificar($ctx['id_usuario'], 'Arancel de laboratorio vencido',
    'El arancel de laboratorio vencio el 30/09/2026 y ya acumula mora. Regularizalo para evitar bloqueos.', 'advertencia', '/pagos/pendientes');

notificar($ctx['id_usuario'], 'Constancia de alumno regular',
    'Tu constancia de alumno regular fue generada y entregada en secretaria.', 'exito', '/tramites', true);

notificar($ctx['id_usuario'], 'Certificado listo para retirar',
    'Tu certificado de calificaciones esta listo. Podés retirarlo en Registro Academico.', 'exito', '/tramites');

$anio = date('Y');
$mes  = date('m');
$idSesionActiva = (new SesionWeb())->crear([
    'id_usuario'    => $ctx['id_usuario'],
    'token'         => hash('sha256', 'demo-activa-' . $anio . $mes),
    'ip_origen'     => '190.104.10.25',
    'user_agent'    => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0 Safari/537.36',
    'navegador'     => 'Chrome',
    'plataforma'    => 'Windows',
    'fecha_inicio'  => date('Y-m-d H:i:s', strtotime('-2 hours')),
    'ultimo_acceso' => date('Y-m-d H:i:s', strtotime('-5 minutes')),
    'estado'        => 'Activa',
]);
(new SesionWeb())->crear([
    'id_usuario'    => $ctx['id_usuario'],
    'token'         => hash('sha256', 'demo-movil-' . $anio . $mes),
    'ip_origen'     => '181.123.44.9',
    'user_agent'    => 'Mozilla/5.0 (Linux; Android 14; SM-A546E) AppleWebKit/537.36 Chrome/131.0 Mobile Safari/537.36',
    'navegador'     => 'Chrome Mobile',
    'plataforma'    => 'Android',
    'fecha_inicio'  => date('Y-m-d H:i:s', strtotime('-9 days')),
    'ultimo_acceso' => date('Y-m-d H:i:s', strtotime('-8 days')),
    'fecha_cierre'  => date('Y-m-d H:i:s', strtotime('-8 days')),
    'estado'        => 'Cerrada',
]);
ok('2 sesiones web registradas (1 activa, 1 cerrada) · sesion activa #' . $idSesionActiva);

Logger::registrar('sesion_iniciada', 'Inicio de sesion desde el portal web', 'auth', 'info', ['origen' => 'demo']);
Logger::registrar('perfil_actualizado', 'El alumno actualizo su numero de celular', 'perfil', 'info');
Logger::auditar('alumnos', (string) $idAlumno, 'ACTUALIZAR',
    ['telefono' => '+595 991 000 000', 'direccion' => 'Sin registrar'],
    ['telefono' => '+595 991 234 567', 'direccion' => 'Barrio San Blas, calle Mcal. Estigarribia 1245, Villarrica']
);
ok('Logs de actividad y auditoria generados');

ejecutar(
    'INSERT INTO mensajes_contacto (id_usuario, nombre, email, telefono, asunto, mensaje, canal, estado, respuesta, id_usuario_gestor, fecha_creacion, fecha_respuesta)
     VALUES (?, ?, ?, ?, ?, ?, "whatsapp", "Respondido", ?, 6, ?, ?)',
    [
        $ctx['id_usuario'], 'Lucia Fernanda Villalba Rios', DEMO_CORREO, '+595 991 234 567',
        'Consulta sobre el arancel de laboratorio',
        'Buenas tardes, queria saber si el arancel de laboratorio se puede pagar en cuotas.',
        'El arancel de laboratorio se puede abonar en hasta 2 cuotas en la ventanilla de caja. Ya cargamos el plan en tu cuenta.',
        date('Y-m-d H:i:s', strtotime('-4 days')), date('Y-m-d H:i:s', strtotime('-3 days')),
    ]
);
ok('Mensaje de contacto (WhatsApp) respondido');

// Los avisos internos de pagos historicos ya fueron atendidos por caja:
// se dejan solo los 3 mas recientes como no leidos.
$marcados = ejecutar(
    'UPDATE notificaciones SET leida = 1, fecha_lectura = NOW()
      WHERE leida = 0 AND titulo = "Nuevo pago registrado"
        AND id_usuario IN (SELECT id_usuario FROM usuarios WHERE id_rol IN (1,4,6))
        AND id_notificacion NOT IN (
              SELECT reciente.id FROM (
                  SELECT id_notificacion AS id FROM notificaciones
                   WHERE leida = 0 AND titulo = "Nuevo pago registrado"
                   ORDER BY id_notificacion DESC LIMIT 3
              ) reciente
        )'
);
linea('   · Avisos internos historicos marcados como leidos: ' . $marcados);

// ---------------------------------------------------------------------
fase('Verificacion final');

$resumen = consultar(
    'SELECT
        (SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ?) AS obligaciones,
        (SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ? AND estado = "Pagado") AS pagadas,
        (SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ? AND estado = "Pendiente") AS pendientes,
        (SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ? AND estado = "Vencido") AS vencidas,
        (SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ? AND estado = "Parcial") AS parciales,
        (SELECT COUNT(*) FROM obligaciones_pago WHERE id_alumno = ? AND estado = "Anulado") AS anuladas,
        (SELECT COUNT(*) FROM pagos WHERE id_alumno = ? AND estado_pago = "Aprobado") AS pagos,
        (SELECT COALESCE(SUM(monto_total),0) FROM pagos WHERE id_alumno = ? AND estado_pago = "Aprobado") AS recaudado,
        (SELECT COALESCE(SUM(saldo),0) FROM obligaciones_pago WHERE id_alumno = ? AND estado <> "Anulado") AS por_pagar,
        (SELECT COUNT(*) FROM facturas WHERE id_alumno = ?) AS facturas,
        (SELECT COUNT(*) FROM comprobantes WHERE id_pago IN (SELECT id_pago FROM pagos WHERE id_alumno = ?)) AS comprobantes,
        (SELECT COUNT(*) FROM matriculas WHERE id_alumno = ?) AS matriculas,
        (SELECT COUNT(*) FROM inscripciones_examen WHERE id_alumno = ?) AS inscripciones,
        (SELECT COUNT(*) FROM solicitudes_tramite WHERE id_alumno = ?) AS tramites,
        (SELECT COUNT(*) FROM notificaciones WHERE id_usuario = ?) AS notificaciones,
        (SELECT COUNT(*) FROM notificaciones WHERE id_usuario = ? AND leida = 0) AS notif_nuevas,
        (SELECT COUNT(*) FROM logs_actividad WHERE id_usuario = ?) AS logs,
        (SELECT COUNT(*) FROM auditorias WHERE id_usuario = ?) AS auditorias',
    [
        $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'],
        $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'],
        $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'], $ctx['id_alumno'],
        $ctx['id_usuario'], $ctx['id_usuario'], $ctx['id_usuario'], $ctx['id_usuario'],
    ]
);

if ($resumen !== []) {
    dato('Obligaciones', (string) $resumen['obligaciones'] . ' (' . $resumen['pagadas'] . ' pagadas, '
        . $resumen['pendientes'] . ' pendientes, ' . $resumen['vencidas'] . ' vencidas, '
        . $resumen['parciales'] . ' parciales, ' . $resumen['anuladas'] . ' anuladas)');
    dato('Pagos aprobados', (string) $resumen['pagos'] . ' por ' . dinero((float) $resumen['recaudado']));
    dato('Saldo por pagar', dinero((float) $resumen['por_pagar']));
    dato('Facturas / comprobantes', $resumen['facturas'] . ' / ' . $resumen['comprobantes']);
    dato('Matriculas', (string) $resumen['matriculas']);
    dato('Inscripciones a examen', (string) $resumen['inscripciones']);
    dato('Tramites', (string) $resumen['tramites']);
    dato('Notificaciones', $resumen['notificaciones'] . ' (' . $resumen['notif_nuevas'] . ' sin leer)');
    dato('Logs / auditorias', $resumen['logs'] . ' / ' . $resumen['auditorias']);
}

linea();
linea('======================================================================');
linea(' ACCESO DE PRUEBA');
linea('======================================================================');
dato('URL', url_absoluta(url('/login')));
dato('Usuario', DEMO_USUARIO);
dato('Correo', DEMO_CORREO);
dato('Clave', DEMO_CLAVE);
linea();
linea(' Con esta cuenta podes probar: carrito y pago en linea, pago pendiente,');
linea(' pago parcial, mora, beca, comprobantes, facturas, examenes y tramites.');
linea('======================================================================');
linea();

exit(0);
