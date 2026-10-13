<?php
/**
 * TEMPORAL: verifica el flujo HTTP de matricula con seleccion de materias.
 * Uso: php scripts/tmp_probe_matricula.php
 */

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));
require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';
\App\Core\Config::cargar();

$base = 'http://localhost/SistemaUnvesGestion';
$db   = \App\Core\Database::instancia();

$usuario  = 'tmp.probe';
$cedula   = 'TMP-9999999';
$clave    = 'Prueba.2026';
$jar      = sys_get_temp_dir() . '/unves_tmp_probe.txt';
@unlink($jar);

$ok = 0;
$fallas = [];

function chk(string $etiqueta, bool $cond, string $detalle = ''): void
{
    global $ok, $fallas;
    if ($cond) { $ok++; echo "  OK    [$etiqueta]\n"; }
    else { $fallas[] = "[$etiqueta] $detalle"; echo "  FALLA [$etiqueta] $detalle\n"; }
}

function req(string $url, array $post = [], bool $json = false): array
{
    global $jar;
    $c = curl_init();
    curl_setopt_array($c, [
        CURLOPT_URL => $url, CURLOPT_RETURNTRANSFER => true,
        CURLOPT_COOKIEJAR => $jar, CURLOPT_COOKIEFILE => $jar,
        CURLOPT_FOLLOWLOCATION => true, CURLOPT_MAXREDIRS => 5, CURLOPT_TIMEOUT => 30,
    ]);
    if ($post) {
        curl_setopt($c, CURLOPT_POST, true);
        curl_setopt($c, CURLOPT_POSTFIELDS, http_build_query($post));
    }
    $body = (string) curl_exec($c);
    $code = (int) curl_getinfo($c, CURLINFO_HTTP_CODE);
    curl_close($c);
    $dec = json_decode($body, true);

    return ['code' => $code, 'body' => $body, 'json' => is_array($dec) ? $dec : null];
}

function token(string $html): string
{
    return preg_match('/name="_token" value="([^"]+)"/', $html, $m) ? $m[1] : '';
}

// ---------------------------------------------------------------- setup
echo "=== Probe: matricula con materias de la malla ===\n\n";

$db->consulta('DELETE FROM usuarios WHERE user = ?', [$usuario]);
$prev = $db->consulta('SELECT a.id_alumno, a.id_persona FROM alumnos a
    INNER JOIN personas p ON p.id_persona = a.id_persona WHERE p.cedula = ?', [$cedula])->obtener();
if ($prev !== null) {
    $db->consulta('DELETE FROM matriculas WHERE id_alumno = ?', [(int) $prev['id_alumno']]);
    $db->consulta('DELETE FROM alumnos WHERE id_alumno = ?', [(int) $prev['id_alumno']]);
    $db->consulta('DELETE FROM personas WHERE id_persona = ?', [(int) $prev['id_persona']]);
}

$hash = password_hash($clave, PASSWORD_DEFAULT);
$db->consulta(
    'INSERT INTO personas (nombres, apellidos, cedula, email, telefono, estado, creado_en)
     VALUES (?, ?, ?, ?, ?, "Activo", NOW())',
    ['Prueba', 'Temporal', $cedula, 'tmp.probe@unves.edu.py', '0991000000']
);
$idPersona = (int) $db->ultimoId();
$db->consulta(
    'INSERT INTO usuarios (user, email, id_persona, pass, estado, id_rol, creado_en)
     VALUES (?, ?, ?, ?, "Activo", 2, NOW())',
    [$usuario, 'tmp.probe@unves.edu.py', $idPersona, $hash]
);
$idUsuario = (int) $db->ultimoId();
$db->consulta(
    'INSERT INTO alumnos (id_persona, legajo, codigo_externo, id_carrera, id_facultades, id_sede,
                          id_periodo_ingreso, semestre_actual, estado_academico, modalidad, turno,
                          fecha_ingreso, estado, creado_en, actualizado_en)
     VALUES (?, ?, ?, 4, 6, 1, 1, 6, "Activo", "Presencial", "Noche", "2023-08-01", "Activo", NOW(), NOW())',
    [$idPersona, 'TMP-9999', 'TMP-EXT-9999']
);
$idAlumno = (int) $db->ultimoId();
echo "  (alumno temporal: #$idAlumno, usuario: $usuario)\n\n";

try {
    // ------------------------------------------------------------ login
    $r = req("$base/login");
    $r = req("$base/login", ['_token' => token($r['body']), 'usuario' => $usuario, 'clave' => $clave]);
    chk('Inicio de sesión', !str_contains($r['body'], 'name="usuario"'), 'no ingresó');

    // -------------------------------------------------- formulario nueva
    $form = req("$base/matriculas/nueva");
    chk('GET /matriculas/nueva responde 200', $form['code'] === 200, 'code=' . $form['code']);
    chk('Muestra el bloque de materias', str_contains($form['body'], 'Materias del periodo'));
    chk('Renderiza checkboxes materias[]', str_contains($form['body'], 'name="materias[]"'));
    chk('Muestra el aviso de ventana', str_contains($form['body'], 'alerta ') && str_contains($form['body'], 'matriculación'));

    preg_match_all('/name="materias\[\]" value="(\d+)"/', $form['body'], $mm);
    $idsMaterias = array_map('intval', $mm[1]);
    chk('Moldea 5 materias de la malla (curso 3, sem 2)', count($idsMaterias) === 5, 'n=' . count($idsMaterias));

    $esperadas = $db->consulta(
        'SELECT m.codigo, m.horas_catedra, m.creditos FROM materias m
          INNER JOIN mallas_curriculares mc ON mc.id_malla = m.id_malla AND mc.estado = "Activo"
         WHERE m.id_carrera = 4 AND m.curso = 3 AND m.semestre = 2 AND m.estado = "Activo"',
        []
    )->obtenerTodo();
    chk('Materias esperadas = 5', count($esperadas) === 5, 'n=' . count($esperadas));

    // -------------------------------------------------------- solicitar
    $t = token($form['body']);
    $r = req("$base/matriculas/solicitar", [
        '_token'        => $t,
        'id_carrera'    => 4,
        'id_sede'       => 1,
        'turno'         => 'Noche',
        'modalidad'     => 'Presencial',
        'conformidad'   => 1,
        'observaciones' => 'Prueba automatizada',
        'materias'      => $idsMaterias,
    ]);
    chk('POST /matriculas/solicitar OK', $r['code'] === 200, 'code=' . $r['code'] . ' ' . substr($r['body'], 0, 200));

    $mat = $db->consulta(
        'SELECT * FROM matriculas WHERE id_alumno = ? AND id_periodo = 3 ORDER BY id_matricula DESC LIMIT 1',
        [$idAlumno]
    )->obtener();

    chk('Se creó la matrícula', $mat !== null);
    if ($mat !== null) {
        $idMatricula = (int) $mat['id_matricula'];
        chk('Guarda id_malla de la carrera', (int) $mat['id_malla'] > 0, 'id_malla=' . $mat['id_malla']);
        chk('Curso = 3', (int) $mat['curso'] === 3, 'curso=' . $mat['curso']);
        chk('Semestre global = 6', (int) $mat['semestre'] === 6, 'semestre=' . $mat['semestre']);
        chk('total_materias = 5', (int) $mat['total_materias'] === 5, 'total=' . $mat['total_materias']);
        chk('total_creditos = 15', (float) $mat['total_creditos'] === 15.0, 'creditos=' . $mat['total_creditos']);
        chk('Tiene obligación de pago', (int) $mat['id_obligacion'] > 0);

        $ins = $db->consulta(
            'SELECT COUNT(*) AS n, COALESCE(SUM(horas),0) AS h, COALESCE(SUM(creditos),0) AS c
               FROM matricula_materias WHERE id_matricula = ?', [$idMatricula]
        )->obtener();
        chk('matricula_materias = 5 filas', (int) $ins['n'] === 5, 'n=' . $ins['n']);
        chk('Horas guardadas = 450', (int) $ins['h'] === 450, 'h=' . $ins['h']);

        $ob = $db->consulta('SELECT * FROM obligaciones_pago WHERE id_obligacion = ?', [(int) $mat['id_obligacion']])->obtener();
        chk('Obligación creada por el arancel vigente', $ob !== null && (float) $ob['monto_final'] > 0, json_encode($ob));

        // ------------------------------------------------------- detalle
        $det = req("$base/matriculas/detalle/$idMatricula");
        chk('GET detalle responde 200', $det['code'] === 200, 'code=' . $det['code']);
        chk('Detalle lista las materias', str_contains($det['body'], 'Materias inscriptas'));
        preg_match_all('/<td class="mono">([^<]+)<\/td>/', $det['body'], $mm2);
        chk('Detalle muestra 5 códigos', count($mm2[1]) === 5, 'n=' . count($mm2[1]));

        // --------------------------------------------------- sin materias
        $db->consulta('DELETE FROM matricula_materias WHERE id_matricula = ?', [$idMatricula]);
        $db->consulta('DELETE FROM obligaciones_pago WHERE id_obligacion = ?', [(int) $mat['id_obligacion']]);
        $db->consulta('DELETE FROM matriculas WHERE id_matricula = ?', [$idMatricula]);

        $form2 = req("$base/matriculas/nueva");
        $r2    = req("$base/matriculas/solicitar", [
            '_token'      => token($form2['body']),
            'id_carrera'  => 4,
            'id_sede'     => 1,
            'turno'       => 'Noche',
            'modalidad'   => 'Presencial',
            'conformidad' => 1,
        ]);
        $sinMaterias = $db->consulta(
            'SELECT id_matricula, total_materias FROM matriculas WHERE id_alumno = ? AND id_periodo = 3
              ORDER BY id_matricula DESC LIMIT 1', [$idAlumno]
        )->obtener();
        chk(
            'Sin selección inscribe todas las del curso/semestre',
            $sinMaterias !== null && (int) $sinMaterias['total_materias'] === 5,
            json_encode($sinMaterias)
        );
    }
} finally {
    // --------------------------------------------------------------- limpieza
    $db->consulta('DELETE mm FROM matricula_materias mm
        INNER JOIN matriculas m ON m.id_matricula = mm.id_matricula WHERE m.id_alumno = ?', [$idAlumno]);
    $db->consulta('DELETE FROM obligaciones_pago WHERE id_alumno = ?', [$idAlumno]);
    $db->consulta('DELETE FROM matriculas WHERE id_alumno = ?', [$idAlumno]);
    $db->consulta('DELETE FROM notificaciones WHERE id_usuario = ?', [$idUsuario]);
    $db->consulta('DELETE FROM sesiones_web WHERE id_usuario = ?', [$idUsuario]);
    $db->consulta('DELETE FROM usuario_rol WHERE id_usuario = ?', [$idUsuario]);
    $db->consulta('DELETE FROM usuarios WHERE id_usuario = ?', [$idUsuario]);
    $db->consulta('DELETE FROM alumnos WHERE id_alumno = ?', [$idAlumno]);
    $db->consulta('DELETE FROM personas WHERE id_persona = ?', [$idPersona]);
    echo "\n  (datos temporales eliminados)\n";
}

echo "\n=== RESULTADO: $ok OK / " . count($fallas) . " FALLAS ===\n";
foreach ($fallas as $f) { echo "  - $f\n"; }
exit($fallas === [] ? 0 : 1);
