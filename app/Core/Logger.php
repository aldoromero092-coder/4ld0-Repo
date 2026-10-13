<?php

namespace App\Core;

/**
 * Registro de auditoria: guarda cada accion relevante del sistema.
 */
class Logger
{
    public static function registrar(
        string $accion,
        string $descripcion = '',
        string $modulo = '',
        string $nivel = 'info',
        array $datos = []
    ): void {
        try {
            $idUsuario = Auth::id();

            Database::instancia()->consulta(
                'INSERT INTO logs_actividad
                   (id_usuario, modulo, accion, descripcion, metodo_http, ruta,
                    ip_origen, user_agent, datos, nivel, fecha_hora)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())',
                [
                    $idUsuario,
                    $modulo !== '' ? $modulo : (App::moduloActivo() ?: null),
                    substr($accion, 0, 95),
                    $descripcion !== '' ? substr($descripcion, 0, 255) : null,
                    $_SERVER['REQUEST_METHOD'] ?? 'CLI',
                    substr((string) ($_SERVER['REQUEST_URI'] ?? 'cli'), 0, 255),
                    self::ip(),
                    substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255),
                    $datos === [] ? null : json_encode($datos, JSON_UNESCAPED_UNICODE),
                    $nivel,
                ]
            );
        } catch (\Throwable $e) {
            // La auditoria nunca debe interrumpir la operacion del usuario.
            error_log('[auditoria] ' . $e->getMessage());
        }
    }

    public static function seguridad(string $accion, string $descripcion = '', array $datos = []): void
    {
        self::registrar($accion, $descripcion, 'seguridad', 'seguridad', $datos);
    }

    public static function error(string $accion, string $descripcion = '', array $datos = []): void
    {
        self::registrar($accion, $descripcion, '', 'error', $datos);
    }

    /** Guarda cambios en la tabla `auditorias` (valores antes/despues). */
    public static function auditar(
        string $tabla,
        string $registroId,
        string $accion,
        ?array $anteriores = null,
        ?array $nuevos = null
    ): void {
        try {
            Database::instancia()->consulta(
                'INSERT INTO auditorias
                   (id_usuario, tabla_afectada, registro_id, accion,
                    valores_anteriores, valores_nuevos, ip_origen, fecha_hora)
                 VALUES (?, ?, ?, ?, ?, ?, ?, NOW())',
                [
                    Auth::id(),
                    $tabla,
                    $registroId,
                    strtoupper($accion),
                    $anteriores === null ? null : json_encode($anteriores, JSON_UNESCAPED_UNICODE),
                    $nuevos === null ? null : json_encode($nuevos, JSON_UNESCAPED_UNICODE),
                    self::ip(),
                ]
            );
        } catch (\Throwable $e) {
            error_log('[auditoria] ' . $e->getMessage());
        }
    }

    private static function ip(): string
    {
        foreach (['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'REMOTE_ADDR'] as $cabecera) {
            if (!empty($_SERVER[$cabecera])) {
                return substr(trim(explode(',', (string) $_SERVER[$cabecera])[0]), 0, 45);
            }
        }
        return '0.0.0.0';
    }
}
