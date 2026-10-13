<?php
/**
 * TEMPORAL: valida el codificador QR leyendo la matriz generada.
 *
 * Reconstruye el mapa de módulos funcionales, extrae los códigos en el mismo
 * orden zigzag, deshace la máscara, verifica que los síndromes de Reed-Solomon
 * sean cero y recupera el texto original.
 *
 * Uso: php scripts/tmp_probe_qr.php
 */

define('RAIZ', dirname(__DIR__));
define('INICIO_APP', microtime(true));
require RAIZ . '/app/Core/autoload.php';
require RAIZ . '/app/Core/helpers.php';
\App\Core\Config::cargar();

$servicio = new \App\Services\QrService();

/** Réplica de los patrones funcionales para poder leer la matriz. */
function mapaFuncion(int $version, int $tamano): array
{
    $f = array_fill(0, $tamano, array_fill(0, $tamano, false));

    foreach ([[0, 0], [$tamano - 7, 0], [0, $tamano - 7]] as [$fb, $cb]) {
        for ($fila = -1; $fila <= 7; $fila++) {
            for ($col = -1; $col <= 7; $col++) {
                $y = $fb + $fila;
                $x = $cb + $col;
                if ($y >= 0 && $y < $tamano && $x >= 0 && $x < $tamano) {
                    $f[$y][$x] = true;
                }
            }
        }
    }

    for ($i = 8; $i < $tamano - 8; $i++) {
        $f[6][$i] = true;
        $f[$i][6] = true;
    }

    $centros = [1 => [], 2 => [6, 18], 3 => [6, 22], 4 => [6, 26], 5 => [6, 30],
                6 => [6, 34], 7 => [6, 22, 38], 8 => [6, 24, 42], 9 => [6, 26, 46]][$version];

    foreach ($centros as $fila) {
        foreach ($centros as $col) {
            if ($f[$fila][$col]) { continue; }
            for ($df = -2; $df <= 2; $df++) {
                for ($dc = -2; $dc <= 2; $dc++) {
                    $f[$fila + $df][$col + $dc] = true;
                }
            }
        }
    }

    for ($i = 0; $i < 9; $i++) {
        $f[8][$i] = true;
        $f[$i][8] = true;
    }
    for ($i = 0; $i < 8; $i++) {
        $f[8][$tamano - 1 - $i] = true;
        $f[$tamano - 1 - $i][8] = true;
    }
    $f[$tamano - 8][8] = true;

    if ($version >= 7) {
        for ($i = 0; $i < 18; $i++) {
            $f[intdiv($i, 3)][$tamano - 11 + $i % 3] = true;
            $f[$tamano - 11 + $i % 3][intdiv($i, 3)] = true;
        }
    }

    return $f;
}

/** Lee la información de formato y deduce el nivel y la máscara. */
function mascaraDesdeFormato(array $m, int $tamano): int
{
    $bits = 0;
    for ($i = 0; $i <= 5; $i++) { $bits |= ($m[$i][8] ? 1 : 0) << $i; }
    $bits |= ($m[7][8] ? 1 : 0) << 6;
    $bits |= ($m[8][8] ? 1 : 0) << 7;
    $bits |= ($m[8][7] ? 1 : 0) << 8;
    for ($i = 9; $i < 15; $i++) { $bits |= ($m[8][14 - $i] ? 1 : 0) << $i; }

    $bits ^= 0x5412;

    for ($mascara = 0; $mascara < 8; $mascara++) {
        // Nivel M -> bits de formato 00
        $datos = (0 << 3) | $mascara;
        $resto = $datos;
        for ($i = 0; $i < 10; $i++) {
            $resto = ($resto << 1) ^ ((($resto >> 9) & 1) * 0x537);
        }
        if ((($datos << 10) | $resto) === $bits) {
            return $mascara;
        }
    }

    return -1;
}

function extraerCodigos(array $m, array $f, int $tamano, int $mascara): array
{
    $bits  = '';
    $total = $tamano * $tamano;

    for ($derecha = $tamano - 1; $derecha >= 1; $derecha -= 2) {
        if ($derecha === 6) { $derecha = 5; }
        $arriba = (($derecha + 1) & 2) === 0;

        for ($v = 0; $v < $tamano; $v++) {
            for ($j = 0; $j < 2; $j++) {
                $x = $derecha - $j;
                $y = $arriba ? $tamano - 1 - $v : $v;
                if ($f[$y][$x]) { continue; }

                $valor = $m[$y][$x];
                switch ($mascara) {
                    case 0: $inv = ($y + $x) % 2 === 0; break;
                    case 1: $inv = $y % 2 === 0; break;
                    case 2: $inv = $x % 3 === 0; break;
                    case 3: $inv = ($y + $x) % 3 === 0; break;
                    case 4: $inv = (intdiv($y, 2) + intdiv($x, 3)) % 2 === 0; break;
                    case 5: $inv = (($y * $x) % 2) + (($y * $x) % 3) === 0; break;
                    case 6: $inv = ((($y * $x) % 2) + (($y * $x) % 3)) % 2 === 0; break;
                    default: $inv = ((($y + $x) % 2) + (($y * $x) % 3)) % 2 === 0;
                }
                if ($inv) { $valor = !$valor; }

                $bits .= $valor ? '1' : '0';
            }
        }
    }

    $codigos = [];
    for ($i = 0; $i + 8 <= strlen($bits); $i += 8) {
        $codigos[] = (int) bindec(substr($bits, $i, 8));
    }

    return $codigos;
}

function gfMul(int $a, int $b): int
{
    if ($a === 0 || $b === 0) { return 0; }
    static $exp = null, $log = null;
    if ($exp === null) {
        $exp = []; $log = []; $x = 1;
        for ($i = 0; $i < 255; $i++) { $exp[$i] = $x; $log[$x] = $i; $x <<= 1; if ($x & 0x100) { $x ^= 0x11D; } }
    }

    return $exp[($log[$a] + $log[$b]) % 255];
}

/** Verifica que los síndromes de un bloque (datos + ECC) sean todos cero. */
function sindromesCero(array $bloque, int $ecc): bool
{
    for ($i = 0; $i < $ecc; $i++) {
        $raiz = 1;
        for ($k = 0; $k < $i; $k++) { $raiz = gfMul($raiz, 0x02); }

        $acumulado = 0;
        foreach ($bloque as $codigo) {
            $acumulado = gfMul($acumulado, $raiz) ^ $codigo;
        }
        if ($acumulado !== 0) {
            return false;
        }
    }

    return true;
}

$bloques = [
    1 => [10, [[16, 1]]],
    2 => [16, [[28, 1]]],
    3 => [26, [[44, 1]]],
    4 => [18, [[32, 2]]],
    5 => [24, [[43, 2]]],
    6 => [16, [[27, 4]]],
    7 => [18, [[31, 4]]],
    8 => [22, [[38, 2], [39, 2]]],
    9 => [22, [[36, 3], [37, 2]]],
];

$pruebas = [
    'https://unves.edu.py/pagos/qr/UNVES-00000012',
    'UNVES-00000012|150000|PYG',
    'A',
    str_repeat('X', 180),
    'Matrícula 2026 - Ingeniería en Informática - Lucía Villalba',
];

$ok = 0;
$fallas = [];

foreach ($pruebas as $texto) {
    $qr     = $servicio->generar($texto);
    $tamano = $qr['tamano'];
    $matriz = $qr['matriz'];
    $f      = mapaFuncion($qr['version'], $tamano);

    $mascara = mascaraDesdeFormato($matriz, $tamano);
    if ($mascara < 0) {
        $fallas[] = "formato no reconocido (len " . strlen($texto) . ")";
        continue;
    }

    $codigos = extraerCodigos($matriz, $f, $tamano, $mascara);
    [$ecc, $grupos] = $bloques[$qr['version']];

    $datosEsperados = 0;
    foreach ($grupos as [$porBloque, $cantidad]) { $datosEsperados += $porBloque * $cantidad; }

    if (count($codigos) < $datosEsperados + $ecc * count($grupos)) {
        $fallas[] = "faltan códigos (len " . strlen($texto) . "): " . count($codigos);
        continue;
    }

    // Desentrelazado
    $bloquesDatos = [];
    foreach ($grupos as [$porBloque, $cantidad]) {
        for ($i = 0; $i < $cantidad; $i++) { $bloquesDatos[] = []; }
    }
    // Reconstrucción por longitudes conocidas (relleno de huecos al desentrelazar)
    $tamanos = [];
    foreach ($grupos as [$porBloque, $cantidad]) {
        for ($i = 0; $i < $cantidad; $i++) { $tamanos[] = $porBloque; }
    }
    $maxDatos = max($tamanos);
    $indice   = 0;
    for ($i = 0; $i < $maxDatos; $i++) {
        foreach ($tamanos as $b => $largo) {
            if ($i < $largo) { $bloquesDatos[$b][$i] = $codigos[$indice++]; }
        }
    }
    $eccBloques = array_fill(0, count($tamanos), []);
    for ($i = 0; $i < $ecc; $i++) {
        foreach ($tamanos as $b => $largo) { $eccBloques[$b][$i] = $codigos[$indice++]; }
    }

    $todoCero = true;
    foreach ($bloquesDatos as $b => $bloque) {
        if (!sindromesCero(array_merge($bloque, $eccBloques[$b]), $ecc)) { $todoCero = false; }
    }

    // Recuperar el texto del primer bloque (modo byte, longitud 8 bits)
    $bytes = '';
    foreach ($bloquesDatos as $b => $bloque) {
        foreach ($bloque as $codigo) { $bytes .= str_pad(decbin($codigo), 8, '0', STR_PAD_LEFT); }
    }
    $modo   = substr($bytes, 0, 4);
    $largo  = (int) bindec(substr($bytes, 4, 8));
    $leido  = '';
    for ($i = 0; $i < $largo; $i++) {
        $leido .= chr((int) bindec(substr($bytes, 12 + $i * 8, 8)));
    }

    $etiqueta = 'v' . $qr['version'] . ' len ' . strlen($texto) . ' mask ' . $mascara;

    if ($modo !== '0100') { $fallas[] = "modo incorrecto ($etiqueta): $modo"; continue; }
    if ($leido !== $texto) { $fallas[] = "texto distinto ($etiqueta)"; continue; }
    if (!$todoCero) { $fallas[] = "síndromes RS distintos de cero ($etiqueta)"; continue; }

    $ok++;
    echo "  OK    [$etiqueta] síndromes RS en cero y texto recuperado\n";
}

// Verificación visual mínima del SVG
$svg = $servicio->svg('UNVES-00000012');
$okSvg = str_starts_with($svg, '<svg') && str_contains($svg, '</svg>') && substr_count($svg, 'M') > 100;
if ($okSvg) { $ok++; echo "  OK    [SVG] se genera con módulos\n"; }
else { $fallas[] = 'SVG mal formado'; }

echo "\n=== RESULTADO: $ok OK / " . count($fallas) . " FALLAS ===\n";
foreach ($fallas as $f2) { echo "  - $f2\n"; }
exit($fallas === [] ? 0 : 1);
