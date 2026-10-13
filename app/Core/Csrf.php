<?php

namespace App\Core;

/**
 * Proteccion CSRF para formularios y peticiones AJAX.
 */
class Csrf
{
    public const CLAVE = '__csrf_token';

    public static function token(): string
    {
        if (empty($_SESSION[self::CLAVE])) {
            $_SESSION[self::CLAVE] = bin2hex(random_bytes(32));
        }
        return (string) $_SESSION[self::CLAVE];
    }

    public static function regenerar(): void
    {
        $_SESSION[self::CLAVE] = bin2hex(random_bytes(32));
    }

    /** Campo oculto listo para insertar en un formulario. */
    public static function campo(): string
    {
        return '<input type="hidden" name="_token" value="' . self::token() . '">';
    }

    public static function valido(?string $token): bool
    {
        if ($token === null || $token === '') {
            return false;
        }
        $esperado = $_SESSION[self::CLAVE] ?? null;
        if (!is_string($esperado) || $esperado === '') {
            return false;
        }
        return hash_equals($esperado, $token);
    }

    /**
     * Valida el token recibido por POST o por cabecera X-CSRF-Token.
     * Si no es valido responde 419 y corta la ejecucion.
     */
    public static function verificar(): void
    {
        $token = $_POST['_token'] ?? $_SERVER['HTTP_X_CSRF_TOKEN'] ?? null;

        // Cuerpos JSON (AJAX)
        if ($token === null) {
            $tipo = strtolower((string) ($_SERVER['CONTENT_TYPE'] ?? ''));
            if (str_contains($tipo, 'application/json')) {
                $crudo = file_get_contents('php://input');
                $json  = is_string($crudo) ? json_decode($crudo, true) : null;
                if (is_array($json) && isset($json['_token'])) {
                    $token = (string) $json['_token'];
                }
            }
        }

        if (is_string($token) && self::valido($token)) {
            return;
        }

        if (Request::esAjax() || Request::esperaJson()) {
            Response::json([
                'ok'      => false,
                'mensaje' => 'Token de seguridad inválido o expirado. Recargá la página.',
                'codigo'  => 419,
            ], 419);
        }

        Response::abortar(419, 'Token de seguridad inválido o expirado.');
    }
}
