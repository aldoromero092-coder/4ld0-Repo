<?php

namespace App\Core;

/**
 * Contexto global de la aplicacion: rutas, entorno y carga de vistas.
 */
class App
{
    private static ?string $urlBase = null;
    private static array $contexto = [];

    /** Ruta absoluta del proyecto. */
    public static function raiz(string $sub = ''): string
    {
        return RAIZ . ($sub !== '' ? '/' . ltrim($sub, '/') : '');
    }

    /**
     * Prefijo de URL donde esta montada la aplicacion.
     * En XAMPP suele ser /SistemaUnvesGestion
     */
    public static function urlBase(): string
    {
        if (self::$urlBase !== null) {
            return self::$urlBase;
        }

        $script = str_replace('\\', '/', (string) ($_SERVER['SCRIPT_NAME'] ?? ''));
        $dir    = rtrim(str_replace('/index.php', '', $script), '/');

        // Si el script esta dentro de /public, subimos un nivel.
        if (str_ends_with($dir, '/public')) {
            $dir = substr($dir, 0, -7);
        }

        self::$urlBase = $dir === '/' ? '' : $dir;
        return self::$urlBase;
    }

    public static function url(string $ruta = '', array $parametros = []): string
    {
        $ruta = '/' . ltrim($ruta, '/');
        $url  = self::urlBase() . ($ruta === '/' ? '/' : rtrim($ruta, '/'));

        if ($parametros !== []) {
            $url .= (str_contains($url, '?') ? '&' : '?') . http_build_query($parametros);
        }

        return $url;
    }

    /** URL de un recurso estatico publico. */
    public static function recurso(string $ruta): string
    {
        $absoluta = self::raiz($ruta);
        $version  = is_file($absoluta) ? '?v=' . filemtime($absoluta) : '';
        return self::urlBase() . '/' . ltrim($ruta, '/') . $version;
    }

    public static function entorno(): string
    {
        return (string) Config::obtener('app.app_entorno', 'produccion');
    }

    public static function enDesarrollo(): bool
    {
        return self::entorno() === 'desarrollo';
    }

    // ---- Contexto compartido entre controlador y vista -----------------
    public static function compartir(string $clave, mixed $valor): void
    {
        self::$contexto[$clave] = $valor;
    }

    public static function compartido(?string $clave = null, mixed $defecto = null): mixed
    {
        if ($clave === null) {
            return self::$contexto;
        }
        return self::$contexto[$clave] ?? $defecto;
    }

    /** Nombre del modulo activo (se usa para cargar css/js del modulo). */
    public static function moduloActivo(): string
    {
        return (string) (self::$contexto['modulo'] ?? '');
    }
}
