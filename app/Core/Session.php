<?php

namespace App\Core;

/**
 * Manejo de la sesion con proteccion contra fijacion de sesion.
 */
class Session
{
    private static bool $iniciada = false;

    public static function iniciar(): void
    {
        if (self::$iniciada || session_status() === PHP_SESSION_ACTIVE) {
            self::$iniciada = true;
            return;
        }

        $vida = (int) Config::obtener('app.sesion_vida', 7200);

        session_name((string) Config::obtener('app.sesion_nombre', 'unves_sid'));
        session_set_cookie_params([
            'lifetime' => 0,
            'path'     => '/',
            'httponly' => true,
            'samesite' => 'Lax',
            'secure'   => !empty($_SERVER['HTTPS']),
        ]);
        session_start();

        // Expiración por inactividad
        $ultimo = $_SESSION['__ultimo_movimiento'] ?? null;
        if ($ultimo !== null && (time() - (int) $ultimo) > $vida) {
            $usuario = $_SESSION['__usuario_id'] ?? null;
            self::destruir();
            self::iniciar();
            self::flash('advertencia', 'Tu sesión expiró por inactividad. Volvé a ingresar.');
            if ($usuario !== null) {
                $_SESSION['__sesion_expirada'] = true;
            }
        }
        $_SESSION['__ultimo_movimiento'] = time();

        self::$iniciada = true;
    }

    public static function obtener(string $clave, mixed $defecto = null): mixed
    {
        return $_SESSION[$clave] ?? $defecto;
    }

    public static function guardar(string $clave, mixed $valor): void
    {
        $_SESSION[$clave] = $valor;
    }

    public static function existe(string $clave): bool
    {
        return isset($_SESSION[$clave]);
    }

    public static function olvidar(string ...$claves): void
    {
        foreach ($claves as $clave) {
            unset($_SESSION[$clave]);
        }
    }

    public static function destruir(): void
    {
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], (bool) $params['secure'], (bool) $params['httponly']);
        }
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_destroy();
        }
        self::$iniciada = false;
    }

    /** Regenera el identificador de sesion (evita fijacion de sesion). */
    public static function regenerar(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_regenerate_id(true);
        }
    }

    // ---- Mensajes flash ----------------------------------------------
    public static function flash(string $tipo, string $mensaje): void
    {
        $_SESSION['__flash'][] = ['tipo' => $tipo, 'mensaje' => $mensaje];
    }

    public static function obtenerFlash(): array
    {
        $mensajes = $_SESSION['__flash'] ?? [];
        unset($_SESSION['__flash']);
        return $mensajes;
    }

    // ---- Datos temporales de formulario -----------------------------
    public static function recordarEntrada(array $datos): void
    {
        unset($datos['pass'], $datos['password'], $datos['clave'], $datos['_token']);
        $_SESSION['__entrada'] = $datos;
    }

    public static function entradaRecordada(?string $campo = null, mixed $defecto = null): mixed
    {
        if ($campo === null) {
            $datos = $_SESSION['__entrada'] ?? [];
            unset($_SESSION['__entrada']);
            return $datos;
        }

        return $_SESSION['__entrada'][$campo] ?? $defecto;
    }

    public static function recordarErrores(array $errores): void
    {
        $_SESSION['__errores'] = $errores;
    }

    public static function errores(): array
    {
        $errores = $_SESSION['__errores'] ?? [];
        unset($_SESSION['__errores']);
        return $errores;
    }
}
