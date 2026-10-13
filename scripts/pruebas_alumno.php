<?php
/**
 * Pruebas del flujo del alumno: inscripcion a examen, solicitud de tramite
 * y matricula, verificando el resultado en la base de datos.
 *
 * Uso: php pruebas_alumno.php [base] [usuario] [clave]
 */

$base = $argv[1] ?? 'http://localhost/SistemaUnvesGestion';
$user = $argv[2] ?? 'maria.lopez';
$pass = $argv[3] ?? 'Unves.2026';
$jar  = sys_get_temp_dir() . '/unves_alu_' . $user . '.txt';
@unlink($jar);

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));
require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';
\App\Core\Config::cargar();

$ok = 0; $fallas = [];

function db(): \App\Core\Database { return \App\Core\Database::instancia(); }

function contar(string $tabla, string $where, array $p): int
{
    return (int) db()->consulta("SELECT COUNT(*) FROM `{$tabla}` WHERE {$where}", $p)->entero();
}

function req(string $url, array $post = []): array
{
    global $jar;
    $c = curl_init();
    curl_setopt_array($c, [
        CURLOPT_URL => $url, CURLOPT_RETURNTRANSFER => true,
        CURLOPT_COOKIEJAR => $jar, CURLOPT_COOKIEFILE => $jar,
        CURLOPT_FOLLOWLOCATION => true, CURLOPT_MAXREDIRS => 3, CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTPHEADER => ['X-Requested-With: XMLHttpRequest', 'Accept: application/json, text/html'],
    ]);
    if ($post) { curl_setopt($c, CURLOPT_POST, true); curl_setopt($c, CURLOPT_POSTFIELDS, http_build_query($post)); }
    $body = curl_exec($c);
    $code = (int) curl_getinfo($c, CURLINFO_HTTP_CODE);
    curl_close($c);
    $json = json_decode((string) $body, true);
    return ['code' => $code, 'body' => (string) $body, 'json' => is_array($json) ? $json : null];
}

function tk(string $h): string { return preg_match('/name="_token" value="([^"]+)"/', $h, $m) ? $m[1] : ''; }

function res(string $etiqueta, bool $ok_, string $detalle = ''): void
{
    global $ok, $fallas;
    if ($ok_) { $ok++; echo "  OK    [$etiqueta]\n"; }
    else { $fallas[] = "[$etiqueta] $detalle"; echo "  FALLA [$etiqueta] $detalle\n"; }
}

echo "=== Flujo del alumno: $user ===\n\n";

$r = req("$base/login");
$r = req("$base/login", ['_token' => tk($r['body']), 'usuario' => $user, 'clave' => $pass]);
res('Inicio de sesion', !str_contains($r['body'], 'name="usuario"'), 'no ingreso');

$idAlumno = (int) db()->consulta(
    'SELECT a.id_alumno FROM alumnos a INNER JOIN personas p ON p.id_persona = a.id_persona WHERE p.cedula = ?',
    [db()->consulta('SELECT p.cedula FROM usuarios u INNER JOIN personas p ON p.id_persona = u.id_persona WHERE u.user = ?', [$user])->valor()]
)->valor();
echo "  (alumno id: $idAlumno)\n\n";

// --- INSCRIPCION A EXAMEN ---------------------------------------------
echo "-- Examenes --\n";
$p = req("$base/examenes/disponibles");
$t = tk($p['body']);
res('Listado de examenes disponibles', $p['code'] === 200 && $t !== '');

$idExamen = (int) db()->consulta(
    'SELECT id_examen FROM examenes
      WHERE fecha_examen >= CURDATE() AND estado IN ("Programado","Inscripcion abierta")
        AND id_examen NOT IN (SELECT id_examen FROM inscripciones_examen WHERE id_alumno = ?)
      ORDER BY fecha_examen LIMIT 1',
    [$idAlumno]
)->valor();

if ($idExamen > 0) {
    $antes = contar('inscripciones_examen', 'id_examen = ? AND id_alumno = ?', [$idExamen, $idAlumno]);
    $r = req("$base/examenes/inscribir", ['_token' => $t, 'id_examen' => $idExamen, 'condicion' => 'Regular']);
    $despues = contar('inscripciones_examen', 'id_examen = ? AND id_alumno = ?', [$idExamen, $idAlumno]);

    $mensaje  = (string) ($r['json']['mensaje'] ?? '');
    if ($mensaje === '') {
        // El controlador responde con PRG: buscamos el mensaje flash en el HTML
        if (preg_match('/(?s)class="alerta alerta-(?:error|advertencia|exito|info)".*?<div class="crecer">(.*?)<\/div>/', $r['body'], $mm)) {
            $mensaje = trim(html_entity_decode(strip_tags($mm[1]), ENT_QUOTES | ENT_HTML5, 'UTF-8'));
        }
    }

    $bloqueado = stripos($mensaje, 'otro examen el mismo') !== false
        || stripos($mensaje, 'No quedan cupos') !== false
        || stripos($mensaje, 'cerrado') !== false
        || stripos($mensaje, 'Ya estás inscripto') !== false
        || stripos($mensaje, 'no está disponible') !== false;

    res(
        'Inscripcion a examen',
        $despues > $antes || $bloqueado,
        'HTTP ' . $r['code'] . ' ' . $mensaje
    );

    if ($despues > $antes) {
        $idInscripcion = (int) db()->consulta('SELECT id_inscripcion FROM inscripciones_examen WHERE id_examen = ? AND id_alumno = ?', [$idExamen, $idAlumno])->valor();
        res('Se genero la obligacion de pago del examen',
            contar('inscripciones_examen', 'id_inscripcion = ? AND id_obligacion IS NOT NULL', [$idInscripcion]) > 0);
    } else {
        res('Regla de negocio aplicada (no se inscribio)', $bloqueado, $mensaje);
    }
} else {
    $inscriptas = contar('inscripciones_examen', 'id_alumno = ?', [$idAlumno]);
    res('Inscripcion a examen (ya inscripta en todos los disponibles)', $inscriptas > 0, 'la alumna no tiene inscripciones');
}

// --- SOLICITUD DE TRAMITE ---------------------------------------------
echo "\n-- Tramites --\n";
$p = req("$base/tramites/solicitar");
$t = tk($p['body']);
res('Catalogo de tramites', $p['code'] === 200 && $t !== '');

$idTipo = (int) db()->consulta(
    'SELECT t.id_tipo_tramite FROM tipos_tramite t
      WHERE t.estado = "Activo"
        AND t.id_tipo_tramite NOT IN (
            SELECT s.id_tipo_tramite FROM solicitudes_tramite s WHERE s.id_alumno = ?
              AND s.estado_tramite NOT IN ("Entregado","Rechazado","Anulado","Cancelado"))
      ORDER BY t.id_tipo_tramite LIMIT 1',
    [$idAlumno]
)->valor();

if ($idTipo > 0) {
    $antes = contar('solicitudes_tramite', 'id_alumno = ?', [$idAlumno]);
    $r = req("$base/tramites/solicitar", ['_token' => $t, 'id_tipo_tramite' => $idTipo, 'tipo_entrega' => 'Digital', 'observaciones' => 'Solicitud de prueba automatica']);
    $despues = contar('solicitudes_tramite', 'id_alumno = ?', [$idAlumno]);
    res('Solicitud de tramite', $despues > $antes, 'HTTP ' . $r['code'] . ' ' . ($r['json']['mensaje'] ?? ''));
} else {
    echo "  (sin tipos de tramite disponibles)\n";
}

// --- PAGO DE TODO LO PENDIENTE (carrito completo) ----------------------
echo "\n-- Pago de obligaciones pendientes --\n";
$p = req("$base/pagos");
$t = tk($p['body']);
preg_match_all('/name="obligaciones\[\]"\s+value="(\d+)"/s', $p['body'], $m);
$ids = array_map('intval', $m[1] ?? []);
echo '  obligaciones pendientes detectadas: ' . count($ids) . "\n";

if ($ids !== []) {
    $r = req("$base/pagos/carrito/agregar", ['_token' => $t, 'obligaciones' => $ids]);
    res('Agregar todas al carrito', ($r['json']['ok'] ?? false) === true, $r['json']['mensaje'] ?? '');

    $c = req("$base/pagos/checkout");
    $tc = tk($c['body']);
    $r = req("$base/pagos/checkout", ['_token' => $tc, 'id_metodo_pago' => 7, 'pasarela' => 'sandbox', 'acepta_condiciones' => 1]);
    if (preg_match('~/pagos/pasarela/(\d+)~', $r['body'], $mm)) {
        $idPago = (int) $mm[1];
        $pa = req("$base/pagos/pasarela/$idPago");
        $tp = tk($pa['body']);
        $r  = req("$base/pagos/pasarela/$idPago/confirmar", ['_token' => $tp, 'accion' => 'aprobar', 'cuotas' => 1]);
        $aprobado = contar('pagos', 'id_pago = ? AND estado_pago = "Aprobado"', [$idPago]) > 0;
        res('Pago de todo el carrito', $aprobado, 'pago #' . $idPago . ' no quedo aprobado');
        res('Se genero la factura del pago', contar('facturas', 'id_pago = ?', [$idPago]) > 0);

        $saldos = (int) db()->consulta(
            'SELECT COUNT(*) FROM obligaciones_pago o
              INNER JOIN pago_detalles pd ON pd.id_obligacion = o.id_obligacion
             WHERE pd.id_pago = ? AND o.saldo > 0',
            [$idPago]
        )->entero();
        res('Las obligaciones quedaron saldadas', $saldos === 0, $saldos . ' con saldo pendiente');

        $comp = req("$base/pagos/comprobante/$idPago");
        res('Comprobante imprimible', $comp['code'] === 200 && str_contains($comp['body'], 'RECIBO DE PAGO'));
    } else {
        res('Checkout', false, 'no se obtuvo el id de pago');
    }
}

echo "\n=== RESULTADO: $ok exitos, " . count($fallas) . " fallas ===\n";
if ($fallas !== []) { foreach ($fallas as $f) { echo "  · $f\n"; } }
exit($fallas === [] ? 0 : 1);
