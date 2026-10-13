<?php
/**
 * TEMPORAL: verifica el checkout con tarjeta de punta a punta.
 *
 * Crea una obligación y una intención de pago temporales, recorre la pasarela
 * con tarjeta aprobada, rechazada, transferencia y QR, y limpia todo al final.
 *
 * Uso: php scripts/tmp_probe_pasarela.php
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

$base = 'http://localhost/SistemaUnvesGestion';
$db   = Database::instancia();
$jar  = sys_get_temp_dir() . '/unves_tmp_psr.txt';
@unlink($jar);

$ok = 0;
$fallas = [];
$idObligacion = 0;

function chk(string $etiqueta, bool $cond, string $detalle = ''): void
{
    global $ok, $fallas;
    if ($cond) { $ok++; echo "  OK    [$etiqueta]\n"; }
    else { $fallas[] = "[$etiqueta] $detalle"; echo "  FALLA [$etiqueta] $detalle\n"; }
}

function req(string $url, array $post = []): array
{
    global $jar;
    $c = curl_init();
    curl_setopt_array($c, [
        CURLOPT_URL => $url, CURLOPT_RETURNTRANSFER => true,
        CURLOPT_COOKIEJAR => $jar, CURLOPT_COOKIEFILE => $jar,
        CURLOPT_FOLLOWLOCATION => true, CURLOPT_MAXREDIRS => 6, CURLOPT_TIMEOUT => 30,
    ]);
    if ($post) {
        curl_setopt($c, CURLOPT_POST, true);
        curl_setopt($c, CURLOPT_POSTFIELDS, http_build_query($post));
    }
    $body = (string) curl_exec($c);
    $code = (int) curl_getinfo($c, CURLINFO_HTTP_CODE);
    curl_close($c);

    return ['code' => $code, 'body' => $body];
}

function token(string $html): string
{
    return preg_match('/name="_token" value="([^"]+)"/', $html, $m) ? $m[1] : '';
}

function agregarCarrito(string $base, int $idObligacion): void
{
    $lista = req("$base/pagos");
    req("$base/pagos/carrito/agregar", [
        '_token'        => token($lista['body']),
        'obligaciones'  => [$idObligacion],
        'id_obligacion' => $idObligacion,
    ]);
}

echo "=== Probe: checkout con tarjeta ===\n\n";

$idAlumno = (int) $db->consulta(
    'SELECT id_alumno FROM alumnos a INNER JOIN personas p ON p.id_persona = a.id_persona
      WHERE p.cedula = "5234891-6"'
)->valor();

$idUsuario = (int) $db->consulta(
    'SELECT id_usuario FROM usuarios u INNER JOIN personas p ON p.id_persona = u.id_persona
      WHERE p.cedula = "5234891-6"'
)->valor();

// ------------------------------------------------------------- preparación
$idObligacion = (new ObligacionService())->crear([
    'id_alumno'         => $idAlumno,
    'id_concepto_pago'  => 1,
    'id_periodo'        => 3,
    'descripcion'       => 'Prueba de checkout con tarjeta',
    'referencia'        => 'PROBE-' . date('YmdHis'),
    'monto'             => 150000,
    'fecha_vencimiento' => date('Y-m-d', strtotime('+10 days')),
]);

echo "  (obligación temporal #$idObligacion por " . number_format(150000, 0, ',', '.') . ")\n\n";

try {
    $r = req("$base/login");
    $r = req("$base/login", ['_token' => token($r['body']), 'usuario' => 'lucia.villalba', 'clave' => 'Unves.2026']);
    chk('Inicio de sesión', !str_contains($r['body'], 'name="usuario"'), 'no ingresó');

    agregarCarrito($base, $idObligacion);
    $r = req("$base/pagos/checkout");
    chk('Checkout responde', $r['code'] === 200, 'code=' . $r['code']);
    $conf = req("$base/pagos/checkout", [
        '_token'             => token($r['body']),
        'id_metodo_pago'     => 7,
        'pasarela'           => 'sandbox',
        'acepta_condiciones' => 1,
    ]);

    if (!preg_match('~/pagos/pasarela/(\d+)~', $conf['body'], $mm)) {
        echo "  No se pudo llegar a la pasarela. Abortando.\n";
        echo substr($conf['body'], 0, 400) . "\n";
        exit(1);
    }
    $idPago = (int) $mm[1];
    echo "  (pago temporal #$idPago)\n\n";

    // ------------------------------------------------------ pantalla inicial
    $psr = req("$base/pagos/pasarela/$idPago");
    chk('GET pasarela responde 200', $psr['code'] === 200, 'code=' . $psr['code']);
    chk('Muestra el formulario de tarjeta', str_contains($psr['body'], 'name="tarjeta"'));
    chk('Muestra el titular y el CVV', str_contains($psr['body'], 'name="titular"') && str_contains($psr['body'], 'name="cvv"'));
    chk('Ofrece 5 planes de cuotas', substr_count($psr['body'], 'name="cuotas"') === 5, 'n=' . substr_count($psr['body'], 'name="cuotas"'));
    chk('Lista 6 tarjetas de prueba', substr_count($psr['body'], 'data-psr-prueba') === 6, 'n=' . substr_count($psr['body'], 'data-psr-prueba'));
    chk('Incluye el QR real en SVG', str_contains($psr['body'], '<svg') && str_contains($psr['body'], 'aria-label="Código QR de pago"'));
    chk('Muestra los datos de transferencia', str_contains($psr['body'], 'Referencia') && str_contains($psr['body'], 'Cuenta corriente'));
    chk('Incluye pestañas de medios de pago', substr_count($psr['body'], 'data-psr-pestana=') === 4);

    // ------------------------------------------------------- tarjeta inválida
    $r = req("$base/pagos/pasarela/$idPago/confirmar", [
        '_token' => token($psr['body']),
        'accion' => 'tarjeta',
        'tarjeta' => '4509 0000 0000 0001',
        'titular' => 'Lucia Villalba',
        'vencimiento' => '12/30',
        'cvv' => '123',
        'cuotas' => 3,
        'acepta_procesamiento' => 1,
    ]);
    chk('Rechaza un número que no pasa Luhn', str_contains($r['body'], 'no es válido'), 'sin mensaje');

    $estado = (string) $db->consulta('SELECT estado_pago FROM pagos WHERE id_pago = ?', [$idPago])->valor();
    chk('El pago sigue pendiente tras el error local', $estado === 'Pendiente', 'estado=' . $estado);

    // -------------------------------------------------------- tarjeta válida
    $psr  = req("$base/pagos/pasarela/$idPago");
    $r = req("$base/pagos/pasarela/$idPago/confirmar", [
        '_token' => token($psr['body']),
        'accion' => 'tarjeta',
        'tarjeta' => '4509 0000 0000 0016',   // fondos insuficientes
        'titular' => 'Lucia Villalba',
        'vencimiento' => '12/30',
        'cvv' => '123',
        'cuotas' => 6,
        'acepta_procesamiento' => 1,
    ]);
    $estado = (string) $db->consulta('SELECT estado_pago FROM pagos WHERE id_pago = ?', [$idPago])->valor();
    chk('Aprueba la validación y rechaza con la tarjeta de fondos insuficientes', $estado === 'Rechazado', 'estado=' . $estado);
    chk('El mensaje de rechazo llega a la pantalla de resultado', str_contains($r['body'], 'fondos insuficientes'), 'sin mensaje');

    $log = $db->consulta(
        'SELECT request_payload, response_payload, codigo_respuesta FROM gateway_logs
          WHERE id_pago = ? ORDER BY id_log DESC LIMIT 1', [$idPago]
    )->obtener();
    chk('Registra la operación en gateway_logs', $log !== null && $log['codigo_respuesta'] === '05', json_encode($log));
    chk('No guarda el número completo de la tarjeta', $log !== null && !str_contains((string) $log['request_payload'], '4509000000000016'));
    chk('Guarda sólo los últimos cuatro dígitos', $log !== null && str_contains((string) $log['request_payload'], '0016'));

    // ------------------------------------------- nueva operación aprobada
    agregarCarrito($base, $idObligacion);
    $r = req("$base/pagos/checkout");
    $conf = req("$base/pagos/checkout", [
        '_token' => token($r['body']), 'id_metodo_pago' => 7, 'pasarela' => 'sandbox', 'acepta_condiciones' => 1,
    ]);
    preg_match('~/pagos/pasarela/(\d+)~', $conf['body'], $mm2);
    $idPago2 = (int) ($mm2[1] ?? 0);
    chk('Se genera una segunda intención de pago', $idPago2 > 0, substr(strip_tags($conf['body']), 0, 200));

    $psr = req("$base/pagos/pasarela/$idPago2");
    $r = req("$base/pagos/pasarela/$idPago2/confirmar", [
        '_token' => token($psr['body']),
        'accion' => 'tarjeta',
        'tarjeta' => '4509000000000008',        // aprobada
        'titular' => 'Lucia Villalba',
        'vencimiento' => '12/30',
        'cvv' => '123',
        'cuotas' => 3,
        'acepta_procesamiento' => 1,
    ]);
    $pago2  = $db->consulta('SELECT estado_pago, numero_comprobante, observacion FROM pagos WHERE id_pago = ?', [$idPago2])->obtener();
    $estado = (string) ($pago2['estado_pago'] ?? '');
    chk('Aprueba la operación con la tarjeta de prueba', $estado === 'Aprobado', 'estado=' . $estado);
    chk('Emite el comprobante del pago', !empty($pago2['numero_comprobante']), json_encode($pago2));
    chk('Muestra la confirmación en pantalla', str_contains($r['body'], 'Pago confirmado'), 'sin confirmación');
    chk(
        'Conserva la descripción original del pago',
        str_contains((string) ($pago2['observacion'] ?? ''), 'Prueba de checkout'),
        'observacion=' . ($pago2['observacion'] ?? '')
    );

    $saldo = (float) $db->consulta('SELECT saldo FROM obligaciones_pago WHERE id_obligacion = ?', [$idObligacion])->valor();
    chk('La obligación queda saldada', $saldo <= 0.01, 'saldo=' . $saldo);

    // ------------------------------------- transferencia (queda pendiente)
    $r = (new ObligacionService())->crear([
        'id_alumno'         => $idAlumno,
        'id_concepto_pago'  => 1,
        'id_periodo'        => 3,
        'descripcion'       => 'Prueba de transferencia',
        'referencia'        => 'PROBE-TRF-' . date('YmdHis'),
        'monto'             => 75000,
        'fecha_vencimiento' => date('Y-m-d', strtotime('+10 days')),
    ]);
    $idObligacionTrf = (int) $r;

    $lista = req("$base/pagos");
    req("$base/pagos/carrito/agregar", [
        '_token'        => token($lista['body']),
        'obligaciones'  => [$idObligacionTrf],
        'id_obligacion' => $idObligacionTrf,
    ]);
    $r = req("$base/pagos/checkout");
    $conf = req("$base/pagos/checkout", [
        '_token' => token($r['body']), 'id_metodo_pago' => 2, 'pasarela' => 'transferencia', 'acepta_condiciones' => 1,
    ]);
    preg_match('~/pagos/pasarela/(\d+)~', $conf['body'], $mm3);
    $idPago3 = (int) ($mm3[1] ?? 0);
    chk('Se genera la intención de pago por transferencia', $idPago3 > 0);

    $psr = req("$base/pagos/pasarela/$idPago3");
    chk('La pantalla ofrece la pestaña de transferencia', str_contains($psr['body'], 'UNVES-' . str_pad((string) $idPago3, 8, '0', STR_PAD_LEFT)));

    $r = req("$base/pagos/pasarela/$idPago3/confirmar", [
        '_token' => token($psr['body']),
        'accion' => 'transferencia',
        'referencia' => 'UNVES-' . str_pad((string) $idPago3, 8, '0', STR_PAD_LEFT),
        'banco' => 'Banco Continental',
        'acepta_procesamiento' => 1,
    ]);
    $estadoTrf = (string) $db->consulta('SELECT estado_pago FROM pagos WHERE id_pago = ?', [$idPago3])->valor();
    chk('La transferencia queda pendiente de acreditación', $estadoTrf === 'Pendiente', 'estado=' . $estadoTrf);
    chk('Informa al alumno que la acreditación está pendiente', str_contains($r['body'], 'acreditad'), 'sin aviso');
    chk('La obligación sigue pendiente', (float) $db->consulta('SELECT saldo FROM obligaciones_pago WHERE id_obligacion = ?', [$idObligacionTrf])->valor() > 0);

    $logTrf = $db->consulta('SELECT codigo_respuesta FROM gateway_logs WHERE id_pago = ? ORDER BY id_log DESC LIMIT 1', [$idPago3])->valor();
    chk('Registra la transferencia como pendiente', $logTrf === 'PENDIENTE', 'codigo=' . $logTrf);

    // ----------------------------------------------- billetera electrónica
    $r = (new ObligacionService())->crear([
        'id_alumno'         => $idAlumno,
        'id_concepto_pago'  => 1,
        'id_periodo'        => 3,
        'descripcion'       => 'Prueba de billetera',
        'referencia'        => 'PROBE-BIL-' . date('YmdHis'),
        'monto'             => 60000,
        'fecha_vencimiento' => date('Y-m-d', strtotime('+10 days')),
    ]);
    $idObligacionBil = (int) $r;

    $lista = req("$base/pagos");
    req("$base/pagos/carrito/agregar", [
        '_token'        => token($lista['body']),
        'obligaciones'  => [$idObligacionBil],
        'id_obligacion' => $idObligacionBil,
    ]);
    $r = req("$base/pagos/checkout");
    $conf = req("$base/pagos/checkout", [
        '_token' => token($r['body']), 'id_metodo_pago' => 7, 'pasarela' => 'sandbox', 'acepta_condiciones' => 1,
    ]);
    preg_match('~/pagos/pasarela/(\d+)~', $conf['body'], $mm4);
    $idPago4 = (int) ($mm4[1] ?? 0);

    $psr = req("$base/pagos/pasarela/$idPago4");
    $r = req("$base/pagos/pasarela/$idPago4/confirmar", [
        '_token' => token($psr['body']),
        'accion' => 'billetera',
        'proveedor' => 'Tigo Money',
        'telefono' => '0991123456',
        'acepta_procesamiento' => 1,
    ]);
    $estadoBil = (string) $db->consulta('SELECT estado_pago FROM pagos WHERE id_pago = ?', [$idPago4])->valor();
    chk('La billetera queda pendiente de confirmación', $estadoBil === 'Pendiente', 'estado=' . $estadoBil);

    // ------------------------------------------------------------- limpieza
    foreach ([$idObligacionTrf, $idObligacionBil] as $extra) {
        foreach ($db->consulta('SELECT DISTINCT id_pago FROM pago_detalles WHERE id_obligacion = ?', [$extra])->lista('id_pago') as $idP) {
            $db->consulta('DELETE FROM gateway_logs WHERE id_pago = ?', [(int) $idP]);
            $db->consulta('DELETE FROM comprobantes WHERE id_pago = ?', [(int) $idP]);
            $db->consulta('DELETE FROM factura_detalles WHERE id_factura IN (SELECT id_factura FROM facturas WHERE id_pago = ?)', [(int) $idP]);
            $db->consulta('DELETE FROM facturas WHERE id_pago = ?', [(int) $idP]);
            $db->consulta('DELETE FROM pago_detalles WHERE id_pago = ?', [(int) $idP]);
            $db->consulta('DELETE FROM pagos WHERE id_pago = ?', [(int) $idP]);
        }
        $db->consulta('DELETE FROM obligaciones_pago WHERE id_obligacion = ?', [$extra]);
    }
    $db->consulta('DELETE FROM carrito_items WHERE id_usuario = ?', [$idUsuario]);
} finally {
    if ($idObligacion > 0) {
        $idsPagos = $db->consulta(
            'SELECT DISTINCT id_pago FROM pago_detalles WHERE id_obligacion = ?', [$idObligacion]
        )->lista('id_pago');

        foreach ($idsPagos as $idPagoLimpieza) {
            $db->consulta('DELETE FROM gateway_logs WHERE id_pago = ?', [(int) $idPagoLimpieza]);
            $db->consulta('DELETE FROM comprobantes WHERE id_pago = ?', [(int) $idPagoLimpieza]);
            $db->consulta('DELETE FROM factura_detalles WHERE id_factura IN
                (SELECT id_factura FROM facturas WHERE id_pago = ?)', [(int) $idPagoLimpieza]);
            $db->consulta('DELETE FROM facturas WHERE id_pago = ?', [(int) $idPagoLimpieza]);
            $db->consulta('DELETE FROM pago_detalles WHERE id_pago = ?', [(int) $idPagoLimpieza]);
            $db->consulta('DELETE FROM pagos WHERE id_pago = ?', [(int) $idPagoLimpieza]);
        }

        $db->consulta('DELETE FROM carrito_items WHERE id_usuario = ?', [$idUsuario]);
        $db->consulta('DELETE FROM obligaciones_pago WHERE id_obligacion = ?', [$idObligacion]);
        echo "\n  (datos temporales eliminados)\n";
    }
}

echo "\n=== RESULTADO: $ok OK / " . count($fallas) . " FALLAS ===\n";
foreach ($fallas as $f) { echo "  - $f\n"; }
exit($fallas === [] ? 0 : 1);
