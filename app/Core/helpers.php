<?php
/**
 * Funciones auxiliares globales.
 * Sistema de Gestion Academica UNVES
 */

use App\Core\App;
use App\Core\Auth;
use App\Core\Config;
use App\Core\Csrf;
use App\Core\Database;
use App\Core\Session;
use App\Core\View;

if (!function_exists('e')) {
    /** Escapa texto para salida HTML segura. */
    function e(mixed $valor): string
    {
        return htmlspecialchars((string) ($valor ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}

if (!function_exists('url')) {
    /** Genera una URL interna de la aplicacion. */
    function url(string $ruta = '', array $parametros = []): string
    {
        return App::url($ruta, $parametros);
    }
}

if (!function_exists('recurso')) {
    /** URL absoluta hacia un archivo estatico. */
    function recurso(string $ruta): string
    {
        return App::recurso($ruta);
    }
}

if (!function_exists('config')) {
    /** Lee un valor de configuracion (config/*.php o tabla configuracion). */
    function config(string $ruta, mixed $defecto = null): mixed
    {
        return Config::obtener($ruta, $defecto);
    }
}

if (!function_exists('config_dinamica')) {
    function config_dinamica(string $clave, mixed $defecto = null): mixed
    {
        return Config::dinamico($clave, $defecto);
    }
}

if (!function_exists('csrf_campo')) {
    function csrf_campo(): string
    {
        return Csrf::campo();
    }
}

if (!function_exists('csrf_token')) {
    function csrf_token(): string
    {
        return Csrf::token();
    }
}

if (!function_exists('usuario_actual')) {
    function usuario_actual(): ?array
    {
        return Auth::usuario();
    }
}

if (!function_exists('autenticado')) {
    function autenticado(): bool
    {
        return Auth::verificado();
    }
}

if (!function_exists('flash')) {
    /** Encola un mensaje flash para la siguiente pantalla. */
    function flash(string $tipo, string $mensaje): void
    {
        Session::flash($tipo, $mensaje);
    }
}

if (!function_exists('viejo')) {
    /** Valor anterior de un formulario (tras un error de validacion). */
    function viejo(string $campo, mixed $defecto = ''): string
    {
        $valor = Session::entradaRecordada($campo, $defecto);
        return is_scalar($valor) ? (string) $valor : (string) $defecto;
    }
}

if (!function_exists('errores_validacion')) {
    function errores_validacion(): array
    {
        return Session::errores();
    }
}

if (!function_exists('activo')) {
    /** Devuelve 'activo' cuando la ruta actual coincide (para el menu). */
    function activo(string $ruta, string $clase = 'activo'): string
    {
        static $actual = null;
        if ($actual === null) {
            $actual = (App::compartido('peticion'))?->rutaRelativa() ?? '/';
        }

        $ruta = '/' . trim($ruta, '/');
        if ($ruta === '/') {
            return $actual === '/' ? $clase : '';
        }

        return str_starts_with($actual, $ruta) ? $clase : '';
    }
}

if (!function_exists('dinero')) {
    /** Formatea un monto en guaranies (o en la moneda configurada). */
    function dinero(float|int|string|null $monto, bool $conSimbolo = true, bool $conDecimales = false): string
    {
        $monto     = (float) ($monto ?? 0);
        $decimales = $conDecimales ? 2 : (int) config('app.moneda_decimales', 0);
        $texto     = number_format($monto, $decimales, ',', '.');

        return $conSimbolo ? config('app.moneda_simbolo', 'Gs.') . ' ' . $texto : $texto;
    }
}

if (!function_exists('a_numero')) {
    /** Convierte "1.234.567" o "1,5" a float. */
    function a_numero(string|int|float|null $valor): float
    {
        if (is_numeric($valor)) {
            return (float) $valor;
        }
        return (float) str_replace([' ', '.', ','], ['', '', '.'], (string) $valor);
    }
}

if (!function_exists('fecha')) {
    /** Formatea una fecha Y-m-d para mostrar. */
    function fecha(?string $valor, string $formato = 'd/m/Y'): string
    {
        if ($valor === null || $valor === '' || str_starts_with($valor, '0000')) {
            return '—';
        }
        $ts = strtotime($valor);
        return $ts === false ? '—' : date($formato, $ts);
    }
}

if (!function_exists('fecha_hora')) {
    function fecha_hora(?string $valor): string
    {
        return fecha($valor, 'd/m/Y H:i');
    }
}

if (!function_exists('fecha_larga')) {
    function fecha_larga(?string $valor): string
    {
        if ($valor === null || $valor === '') {
            return '—';
        }
        $ts = strtotime($valor);
        if ($ts === false) {
            return '—';
        }
        $meses = [1 => 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
                  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
        return date('j', $ts) . ' de ' . $meses[(int) date('n', $ts)] . ' de ' . date('Y', $ts);
    }
}

if (!function_exists('hace')) {
    /** Tiempo relativo legible: "hace 3 horas". */
    function hace(?string $valor): string
    {
        if ($valor === null || $valor === '') {
            return '—';
        }
        $ts     = strtotime($valor);
        $segundos = time() - (int) $ts;

        return match (true) {
            $segundos < 60          => 'hace instantes',
            $segundos < 3600        => 'hace ' . floor($segundos / 60) . ' min',
            $segundos < 86400       => 'hace ' . floor($segundos / 3600) . ' h',
            $segundos < 604800      => 'hace ' . floor($segundos / 86400) . ' días',
            default                 => fecha($valor),
        };
    }
}

if (!function_exists('dias_restantes')) {
    function dias_restantes(?string $fechaVencimiento): ?int
    {
        if ($fechaVencimiento === null || $fechaVencimiento === '') {
            return null;
        }
        $ts = strtotime($fechaVencimiento);
        return $ts === false ? null : (int) floor(($ts - strtotime('today')) / 86400);
    }
}

if (!function_exists('fecha_input')) {
    /** Normaliza una fecha a formato Y-m-d para inputs / base de datos. */
    function fecha_input(?string $valor): string
    {
        if ($valor === null || $valor === '') {
            return '';
        }
        $ts = strtotime(str_replace('/', '-', $valor));
        return $ts === false ? '' : date('Y-m-d', $ts);
    }
}

if (!function_exists('generar_codigo')) {
    /** Codigo unico legible: PREFIJO-FECHA-SECUENCIA. */
    function generar_codigo(string $prefijo, int|string $secuencia, int $largo = 5): string
    {
        return sprintf('%s-%s-%s', strtoupper($prefijo), date('Ymd'), str_pad((string) $secuencia, $largo, '0', STR_PAD_LEFT));
    }
}

if (!function_exists('aleatorio')) {
    function aleatorio(int $bytes = 16): string
    {
        return bin2hex(random_bytes($bytes));
    }
}

if (!function_exists('slug')) {
    function slug(string $texto): string
    {
        $texto = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $texto) ?: $texto;
        $texto = strtolower(preg_replace('/[^A-Za-z0-9]+/', '-', $texto) ?? '');
        return trim($texto, '-');
    }
}

if (!function_exists('iniciales')) {
    function iniciales(string $nombre): string
    {
        $partes = preg_split('/\s+/u', trim($nombre)) ?: [];
        $letras = '';
        foreach (array_slice(array_filter($partes), 0, 2) as $parte) {
            $letras .= mb_strtoupper(mb_substr($parte, 0, 1, 'UTF-8'), 'UTF-8');
        }
        return $letras !== '' ? $letras : 'U';
    }
}

if (!function_exists('recortar')) {
    function recortar(?string $texto, int $largo = 60): string
    {
        $texto = (string) $texto;
        return mb_strlen($texto) > $largo ? mb_substr($texto, 0, $largo - 1, 'UTF-8') . '…' : $texto;
    }
}

if (!function_exists('titulo_caso')) {
    /** 'Pendiente de pago' -> 'pendiente-de-pago' (para clases CSS). */
    function clase_estado(?string $estado): string
    {
        return strtolower(str_replace([' ', '_'], '-', (string) $estado));
    }
}

if (!function_exists('badge_estado')) {
    /** Clase CSS de color segun el estado. */
    function badge_estado(?string $estado): string
    {
        $estado = strtolower((string) $estado);
        return match (true) {
            str_contains($estado, 'pagado'), str_contains($estado, 'aprobado'), str_contains($estado, 'confirmada'),
            str_contains($estado, 'activo'), str_contains($estado, 'exitoso'), str_contains($estado, 'rendido'),
            str_contains($estado, 'habilitado'), str_contains($estado, 'respondido'), str_contains($estado, 'entregado')
                => 'exito',
            str_contains($estado, 'pendiente'), str_contains($estado, 'proceso'), str_contains($estado, 'revision'),
            str_contains($estado, 'programado'), str_contains($estado, 'nuevo'), str_contains($estado, 'parcial')
                => 'advertencia',
            str_contains($estado, 'vencido'), str_contains($estado, 'rechazado'), str_contains($estado, 'anulado'),
            str_contains($estado, 'fallido'), str_contains($estado, 'ausente'), str_contains($estado, 'bloqueado'),
            str_contains($estado, 'cerrado'), str_contains($estado, 'cancelado')
                => 'peligro',
            default => 'neutro',
        };
    }
}

if (!function_exists('whatsapp_url')) {
    /** Enlace de WhatsApp con mensaje precargado. */
    function whatsapp_url(?string $mensaje = null): string
    {
        $numero = (string) config_dinamica('whatsapp_numero', config('app.whatsapp', '595991461220'));
        $texto  = $mensaje ?? (string) config_dinamica('whatsapp_mensaje', config('app.whatsapp_texto', ''));

        return 'https://wa.me/' . preg_replace('/\D/', '', $numero)
            . ($texto !== '' ? '?text=' . rawurlencode($texto) : '');
    }
}

if (!function_exists('nombre_mes')) {
    function nombre_mes(int $mes, bool $corto = false): string
    {
        $largos = [1 => 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
        $cortos = [1 => 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

        return ($corto ? $cortos : $largos)[$mes] ?? '';
    }
}

if (!function_exists('dd')) {
    /** Volcado de depuracion. */
    function dd(mixed ...$valores): never
    {
        echo '<pre style="background:#0f172a;color:#e2e8f0;padding:1.5rem;border-radius:10px;'
            . 'font-family:ui-monospace,Consolas,monospace;font-size:13px;overflow:auto">';
        foreach ($valores as $valor) {
            var_dump($valor);
        }
        echo '</pre>';
        exit;
    }
}

if (!function_exists('logo_institucional')) {
    /**
     * Resuelve la ruta del logo institucional, sin extension fija.
     *
     * Prioridad:
     *   1. Clave `app_logo` / `app_logo_claro` guardada en la tabla `configuracion`.
     *   2. Archivos presentes en recursos/img/ (generados desde el logo oficial).
     *   3. null -> la vista usa el monograma de respaldo.
     *
     * @param bool $claro true para la variante pensada para fondos oscuros.
     * @return string|null Ruta relativa a la raiz del proyecto.
     */
    function logo_institucional(bool $claro = false): ?string
    {
        static $cache = [];

        $clave = $claro ? 'claro' : 'normal';
        if (array_key_exists($clave, $cache)) {
            return $cache[$clave];
        }

        $extensiones = ['svg', 'png', 'webp', 'jpg', 'jpeg'];

        $candidatos = [];

        // 1. Configuracion personalizada desde el panel
        $personalizado = (string) config_dinamica($claro ? 'app_logo_claro' : 'app_logo', '');
        if ($personalizado !== '') {
            $candidatos[] = $personalizado;
        }

        // 2. Variantes para fondo oscuro
        if ($claro) {
            foreach (['logo-unves-blanco', 'logo-unves-claro', 'logo-unves-negativo', 'logo-unves-light'] as $nombre) {
                foreach ($extensiones as $ext) {
                    $candidatos[] = "recursos/img/{$nombre}.{$ext}";
                }
            }
        }

        // 3. Logo institucional estandar
        foreach (['logo-unves-compacto', 'logo-unves', 'logo-oficial', 'logo'] as $nombre) {
            foreach ($extensiones as $ext) {
                $candidatos[] = "recursos/img/{$nombre}.{$ext}";
            }
        }

        foreach ($candidatos as $ruta) {
            if (is_file(App::raiz($ruta))) {
                return $cache[$clave] = $ruta;
            }
        }

        return $cache[$clave] = null;
    }
}

if (!function_exists('logo_url')) {
    /**
     * URL del logo institucional (con cache busting).
     *
     * @param bool $claro     Variante para fondos oscuros.
     * @param bool $absoluta  Devuelve la URL completa con esquema y host
     *                        (necesario en documentos que se exportan a PDF).
     */
    function logo_url(bool $claro = false, bool $absoluta = false): ?string
    {
        $ruta = logo_institucional($claro);
        if ($ruta === null) {
            return null;
        }

        $url = App::recurso($ruta);

        return $absoluta ? url_absoluta($url) : $url;
    }
}

if (!function_exists('favicon_url')) {
    /** URL del favicon: usa el archivo dedicado o, si no existe, el logo. */
    function favicon_url(): ?string
    {
        foreach (['favicon.svg', 'favicon-64.png', 'favicon.png', 'favicon.ico'] as $archivo) {
            $ruta = 'recursos/img/' . $archivo;
            if (is_file(App::raiz($ruta))) {
                return App::recurso($ruta);
            }
        }

        return logo_url();
    }
}

if (!function_exists('icono_movil_url')) {
    /** URL del icono para móviles (apple-touch-icon). */
    function icono_movil_url(): ?string
    {
        $ruta = 'recursos/img/apple-touch-icon.png';

        return is_file(App::raiz($ruta)) ? App::recurso($ruta) : logo_url();
    }
}

if (!function_exists('url_absoluta')) {
    /** Convierte una ruta interna en URL absoluta (esquema + host). */
    function url_absoluta(string $ruta): string
    {
        if (preg_match('#^https?://#i', $ruta)) {
            return $ruta;
        }

        $esquema = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host    = $_SERVER['HTTP_HOST'] ?? 'localhost';

        return $esquema . '://' . $host . '/' . ltrim($ruta, '/');
    }
}

if (!function_exists('nombre_institucional_corto')) {
    /** Marca corta usada en la interfaz: "UNVES · Villarrica". */
    function nombre_institucional_corto(): string
    {
        return (string) config('app.app_siglas', 'UNVES') . ' · Villarrica';
    }
}

if (!function_exists('monograma')) {
    /** Inicial usada como respaldo cuando no hay archivo de logo. */
    function monograma(): string
    {
        return mb_strtoupper(mb_substr((string) config('app.app_siglas', 'UNVES'), 0, 1, 'UTF-8'), 'UTF-8');
    }
}

if (!function_exists('db')) {
    function db(): Database
    {
        return Database::instancia();
    }
}

if (!function_exists('ventana_badge')) {
    /**
     * Etiqueta HTML con el estado de una ventana academica.
     *
     * @param array|null $ventana Resultado de VentanaService::evaluar().
     */
    function ventana_badge(?array $ventana): string
    {
        if ($ventana === null || empty($ventana['estado'])) {
            return '';
        }

        $clase = [
            'abierta'     => 'exito',
            'tardia'      => 'advertencia',
            'programada'  => 'info',
            'cerrada'     => 'peligro',
            'sin_ventana' => 'neutro',
        ][(string) $ventana['estado']] ?? 'neutro';

        return '<span class="badge ' . $clase . '">' . e($ventana['etiqueta'] ?? $ventana['estado']) . '</span>';
    }
}

if (!function_exists('ventana_aviso')) {
    /**
     * Banner informativo con el estado de la ventana academica y el plazo.
     *
     * @param array|null $ventana Resultado de VentanaService::evaluar().
     * @param string     $cierre  Texto que acompana al vencimiento (opcional).
     */
    function ventana_aviso(?array $ventana, string $cierre = ''): string
    {
        if ($ventana === null || empty($ventana['estado']) || ($ventana['estado'] ?? '') === 'sin_ventana') {
            return '';
        }

        $icono = [
            'abierta'    => '✅',
            'tardia'     => '⚠️',
            'programada' => '🗓️',
            'cerrada'    => '⛔',
        ][(string) $ventana['estado']] ?? 'ℹ️';

        $clase = [
            'abierta'    => 'alerta-exito',
            'tardia'     => 'alerta-advertencia',
            'programada' => 'alerta-info',
            'cerrada'    => 'alerta-error',
        ][(string) $ventana['estado']] ?? 'alerta-info';

        $detalle = '';
        if (!empty($ventana['ventana']['nombre'])) {
            $detalle .= '<span class="negrita">' . e($ventana['ventana']['nombre']) . '</span> · ';
        }
        $detalle .= e($ventana['mensaje'] ?? '');

        if ($cierre !== '') {
            $detalle .= '<br><span class="texto-sm color-suave">' . e($cierre) . '</span>';
        }

        if ((float) ($ventana['recargo'] ?? 0) > 0) {
            $detalle .= '<br><span class="texto-sm">Recargo aplicable: <span class="negrita">'
                . dinero((float) $ventana['recargo']) . '</span></span>';
        }

        return '<div class="alerta ' . $clase . '">'
            . '<span class="alerta-icono">' . $icono . '</span>'
            . '<div class="crecer">' . ventana_badge($ventana) . '<br>' . $detalle . '</div>'
            . '</div>';
    }
}
