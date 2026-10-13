<?php

namespace App\Core;

/**
 * Respuestas HTTP: vistas, JSON, redirecciones y errores.
 */
class Response
{
    private static int $codigo = 200;
    private static array $cabeceras = [];

    public static function codigo(int $codigo): void
    {
        self::$codigo = $codigo;
        http_response_code($codigo);
    }

    public static function cabecera(string $nombre, string $valor): void
    {
        self::$cabeceras[$nombre] = $valor;
        header($nombre . ': ' . $valor);
    }

    // ---- Redirecciones -------------------------------------------------
    public static function redirigir(string $ruta, int $codigo = 302): never
    {
        $destino = str_starts_with($ruta, 'http') ? $ruta : App::url($ruta);
        header('Location: ' . $destino, true, $codigo);
        exit;
    }

    public static function volver(string $defecto = '/'): never
    {
        $referencia = $_SERVER['HTTP_REFERER'] ?? '';
        self::redirigir($referencia !== '' ? $referencia : $defecto);
    }

    // ---- JSON ----------------------------------------------------------
    public static function json(array $datos, int $codigo = 200): never
    {
        if (!headers_sent()) {
            http_response_code($codigo);
            header('Content-Type: application/json; charset=utf-8');
            header('X-Content-Type-Options: nosniff');
        }
        echo json_encode($datos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public static function exito(string $mensaje = 'Operación realizada con éxito.', array $datos = []): never
    {
        self::json(array_merge(['ok' => true, 'mensaje' => $mensaje], $datos));
    }

    public static function error(string $mensaje = 'Ocurrió un error.', int $codigo = 400, array $datos = []): never
    {
        self::json(array_merge(['ok' => false, 'mensaje' => $mensaje, 'codigo' => $codigo], $datos), $codigo);
    }

    // ---- Errores -------------------------------------------------------
    public static function abortar(int $codigo, string $mensaje = ''): never
    {
        if (!headers_sent()) {
            http_response_code($codigo);
        }

        $titulos = [
            400 => 'Solicitud incorrecta',
            401 => 'Sesión requerida',
            403 => 'Acceso denegado',
            404 => 'Página no encontrada',
            419 => 'Sesión expirada',
            429 => 'Demasiadas solicitudes',
            500 => 'Error interno del servidor',
        ];
        $titulo = $titulos[$codigo] ?? 'Error';

        if (Request::esperaJson() || Request::esAjax()) {
            self::json(['ok' => false, 'mensaje' => $mensaje ?: $titulo, 'codigo' => $codigo], $codigo);
        }

        $vista = App::raiz('app/Views/errores/' . $codigo . '.php');
        if (is_file($vista)) {
            $datos = ['titulo' => $titulo, 'mensaje' => $mensaje, 'codigo' => $codigo];
            extract($datos, EXTR_SKIP);
            require $vista;
            exit;
        }

        echo '<!doctype html><html lang="es"><head><meta charset="utf-8">';
        echo '<meta name="viewport" content="width=device-width,initial-scale=1">';
        echo '<title>' . htmlspecialchars($titulo) . '</title>';
        echo '<style>body{font-family:system-ui,Segoe UI,sans-serif;background:#f1f5f9;display:flex;'
            . 'align-items:center;justify-content:center;min-height:100vh;margin:0}'
            . '.c{background:#fff;padding:2.5rem 3rem;border-radius:16px;box-shadow:0 10px 40px rgba(2,32,71,.12);'
            . 'text-align:center;max-width:520px}h1{font-size:3rem;margin:0;color:#33356e}'
            . 'p{color:#475569}a{margin-top:1rem;display:inline-block;background:#33356e;color:#fff;'
            . 'padding:.7rem 1.6rem;border-radius:10px;text-decoration:none}</style></head><body><div class="c">'
            . '<h1>' . $codigo . '</h1><p>' . htmlspecialchars($mensaje ?: $titulo) . '</p>'
            . '<a href="' . App::url('/') . '">Volver al inicio</a></div></body></html>';
        exit;
    }

    /** Fuerza la descarga de un archivo de texto/HTML. */
    public static function descargar(string $contenido, string $nombre, string $mime = 'text/html'): never
    {
        header('Content-Type: ' . $mime . '; charset=utf-8');
        header('Content-Disposition: attachment; filename="' . $nombre . '"');
        header('Content-Length: ' . strlen($contenido));
        echo $contenido;
        exit;
    }
}
