<?php
/**
 * Prueba de humo end-to-end del portal.
 * Uso: php pruebas_humo.php [usuario] [clave]
 */

$base  = $argv[1] ?? 'http://localhost/SistemaUnvesGestion';
$user  = $argv[2] ?? 'admin';
$pass  = $argv[3] ?? 'Unves.2026';
$jar   = sys_get_temp_dir() . '/unves_cookies_' . $user . '.txt';
@unlink($jar);

$ok = 0; $fail = 0;

function peticion(string $url, array $opciones = []): array
{
    global $jar;
    $curl = curl_init();
    curl_setopt_array($curl, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_COOKIEJAR => $jar,
        CURLOPT_COOKIEFILE => $jar,
        CURLOPT_FOLLOWLOCATION => false,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HEADER => false,
        CURLOPT_HTTPHEADER => $opciones['headers'] ?? [],
    ]);
    if (isset($opciones['post'])) {
        curl_setopt($curl, CURLOPT_POST, true);
        curl_setopt($curl, CURLOPT_POSTFIELDS, is_array($opciones['post']) ? http_build_query($opciones['post']) : $opciones['post']);
    }
    $cuerpo = curl_exec($curl);
    $codigo = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $loc    = curl_getinfo($curl, CURLINFO_REDIRECT_URL);
    curl_close($curl);
    return ['cuerpo' => (string) $cuerpo, 'codigo' => $codigo, 'location' => $loc];
}

function probar(string $etiqueta, string $url, array $esperados, array $opciones = []): array
{
    global $ok, $fail;
    $r = peticion($url, $opciones);
    $bien = in_array($r['codigo'], $esperados, true);
    // Detecta errores de PHP embebidos en el HTML
    if ($bien && str_contains($r['cuerpo'], 'Fatal error')) { $bien = false; $r['error_php'] = 'Fatal error'; }
    if ($bien && preg_match('/<b>(Fatal error|Warning|Parse error|Uncaught)/i', $r['cuerpo'])) { $bien = false; $r['error_php'] = 'aviso PHP'; }
    // Detecta la pagina de error 500 propia de la app
    if ($bien && str_contains($r['cuerpo'], '>500<') && str_contains($r['cuerpo'], 'Error interno')) { $bien = false; $r['error_php'] = 'pagina 500'; }

    $r['etiqueta'] = $etiqueta;
    if ($bien) { $ok++; echo "  OK    [$etiqueta] HTTP {$r['codigo']}\n"; }
    else { $fail++; echo "  FALLA [$etiqueta] HTTP {$r['codigo']} " . ($r['error_php'] ?? '') . "\n"; }
    return $r;
}

function extraerToken(string $html): string
{
    if (preg_match('/name="_token" value="([^"]+)"/', $html, $m)) return $m[1];
    if (preg_match('/name="csrf-token" content="([^"]+)"/', $html, $m)) return $m[1];
    return '';
}

echo "=== Prueba de humo: $user ===\n\n";

echo "-- Sitio publico --\n";
probar('Portada', "$base/", [200]);
probar('Carreras', "$base/carreras", [200]);
probar('Institucional', "$base/institucional", [200]);
probar('Ayuda', "$base/ayuda", [200]);
probar('Contacto', "$base/contacto", [200]);
probar('Seguimiento', "$base/seguimiento", [200]);
probar('404', "$base/ruta-que-no-existe", [404]);
probar('API estado', "$base/api/estado", [200]);

echo "\n-- Autenticacion --\n";
$login = probar('Login (GET)', "$base/login", [200]);
$token = extraerToken($login['cuerpo']);
echo "  token CSRF: " . substr($token, 0, 12) . "...\n";
$post = probar('Login (POST)', "$base/login", [302], ['post' => ['_token' => $token, 'usuario' => $user, 'clave' => $pass]]);

echo "\n-- Panel y modulos --\n";
probar('Panel', "$base/panel", [200]);
probar('Panel resumen', "$base/panel/resumen", [200, 403, 401]);
probar('Perfil', "$base/perfil", [200]);
probar('Perfil sesiones', "$base/perfil/sesiones", [200]);
probar('Notificaciones', "$base/notificaciones", [200]);

$rutas = [
    'Pagos' => '/pagos', 'Pagos pendientes' => '/pagos/pendientes', 'Pagos historial' => '/pagos/historial',
    'Carrito' => '/pagos/carrito', 'Checkout' => '/pagos/checkout', 'Matriculas' => '/matriculas',
    'Matriculas nueva' => '/matriculas/nueva', 'Matriculas admin' => '/matriculas/admin',
    'Examenes' => '/examenes', 'Examenes disponibles' => '/examenes/disponibles',
    'Mis inscripciones' => '/examenes/mis-inscripciones', 'Examenes admin' => '/examenes/admin',
    'Tramites' => '/tramites', 'Tramites solicitar' => '/tramites/solicitar', 'Tramites admin' => '/tramites/admin',
    'Tramites tipos' => '/tramites/admin/tipos',
    'Caja' => '/caja', 'Arqueo' => '/caja/arqueo',
    'Alumnos' => '/alumnos', 'Alumnos nuevo' => '/alumnos/nuevo', 'Alumnos exportar' => '/alumnos/exportar',
    'Usuarios' => '/usuarios', 'Usuarios nuevo' => '/usuarios/nuevo', 'Roles' => '/usuarios/roles',
    'Academico' => '/academico', 'Facultades' => '/academico/facultades', 'Sedes' => '/academico/sedes',
    'Carreras admin' => '/academico/carreras', 'Periodos' => '/academico/periodos',
    'Aranceles' => '/aranceles', 'Conceptos' => '/aranceles/conceptos', 'Generar obligaciones' => '/aranceles/generar',
    'Becas' => '/becas', 'Becas asignadas' => '/becas/asignadas',
    'Facturacion' => '/facturacion', 'Facturas' => '/facturacion/facturas',
    'Timbrados' => '/facturacion/timbrados', 'Datos fiscales' => '/facturacion/datos-fiscales',
    'Reportes' => '/reportes', 'Reportes recaudacion' => '/reportes/recaudacion',
    'Reportes morosidad' => '/reportes/morosidad', 'Reportes matriculas' => '/reportes/matriculas',
    'Reportes examenes' => '/reportes/examenes', 'Reportes tramites' => '/reportes/tramites',
    'Reportes alumnos' => '/reportes/alumnos',
    'Auditoria' => '/auditoria', 'Auditoria actividad' => '/auditoria/actividad',
    'Auditoria sesiones' => '/auditoria/sesiones', 'Auditoria acciones' => '/auditoria/acciones',
    'Integracion' => '/integracion', 'Integracion historial' => '/integracion/historial',
    'Configuracion' => '/configuracion', 'Configuracion logs' => '/configuracion/logs',
    'Respaldos' => '/configuracion/respaldos',
    'Mensajes' => '/mensajes',
];

echo "\n-- Modulos (esperado 200 o 302/403 por permisos) --\n";
foreach ($rutas as $etiqueta => $ruta) {
    probar($etiqueta, $base . $ruta, [200, 302, 403, 404]);
}

echo "\n-- Flujo de pago --\n";
$pagos = probar('Listado de obligaciones', "$base/pagos", [200, 302, 403]);
if (preg_match('/name="obligaciones\[\]"\s+value="(\d+)"/s', $pagos['cuerpo'], $m)) {
    $idObligacion = (int) $m[1];
    echo "  obligacion detectada: $idObligacion\n";
    $tok = extraerToken($pagos['cuerpo']);
    $add = probar('Agregar al carrito', "$base/pagos/carrito/agregar", [200, 302], [
        'post' => ['_token' => $tok, 'obligaciones' => [$idObligacion]],
        'headers' => ['X-Requested-With: XMLHttpRequest', 'Accept: application/json'],
    ]);
    echo '  respuesta: ' . substr(strip_tags($add['cuerpo']), 0, 160) . "\n";

    $carrito = probar('Ver carrito', "$base/pagos/carrito", [200]);
    $tok2 = extraerToken($carrito['cuerpo']);
    $checkout = probar('GET checkout', "$base/pagos/checkout", [200]);
    if ($checkout['codigo'] === 200) {
        $tok3 = extraerToken($checkout['cuerpo']);
        $conf = probar('POST checkout', "$base/pagos/checkout", [302], [
            'post' => ['_token' => $tok3, 'id_metodo_pago' => 7, 'pasarela' => 'sandbox', 'acepta_condiciones' => 1],
        ]);
        if ($conf['codigo'] === 302) {
            echo '  redirige a: ' . ($conf['location'] ?? '?') . "\n";
            if (preg_match('~/pagos/pasarela/(\d+)~', (string) ($conf['location'] ?? ''), $mm)) {
                $idPago = (int) $mm[1];
                $pas = probar('Pantalla pasarela', "$base/pagos/pasarela/$idPago", [200]);
                $tok4 = extraerToken($pas['cuerpo']);
                $fin = probar('Confirmar pago', "$base/pagos/pasarela/$idPago/confirmar", [302], [
                    'post' => ['_token' => $tok4, 'accion' => 'aprobar', 'cuota' => 1],
                ]);
                echo '  redirige a: ' . ($fin['location'] ?? '?') . "\n";
                probar('Resultado del pago', "$base/pagos/resultado/$idPago", [200]);
                probar('Detalle del pago', "$base/pagos/detalle/$idPago", [200]);
                probar('Comprobante', "$base/pagos/comprobante/$idPago", [200]);
                probar('Historial tras pago', "$base/pagos/historial", [200]);
            }
        }
    }
} else {
    echo "  (sin obligaciones pendientes para este usuario)\n";
}

echo "\n-- Cerrar sesion --\n";
$panel = peticion("$base/perfil");
$tok5 = extraerToken($panel['cuerpo'] ?: $login['cuerpo']);
probar('Logout', "$base/logout", [302], ['post' => ['_token' => $tok5]]);

echo "\n=== RESULTADO: $ok OK / $fail FALLAS ===\n";
exit($fail > 0 ? 1 : 0);
