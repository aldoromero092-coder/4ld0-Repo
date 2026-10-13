<?php

namespace App\Models;

use App\Core\Model;

class SesionWeb extends Model
{
    protected string $tabla = 'sesiones_web';
    protected string $clavePrimaria = 'id_sesion';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_usuario', 'token', 'ip_origen', 'user_agent', 'navegador', 'plataforma',
        'fecha_inicio', 'ultimo_acceso', 'fecha_cierre', 'estado',
    ];

    public function deUsuario(int $idUsuario, int $limite = 20): array
    {
        return $this->sql(
            'SELECT * FROM sesiones_web WHERE id_usuario = ? ORDER BY ultimo_acceso DESC LIMIT ' . (int) $limite,
            [$idUsuario]
        )->obtenerTodo();
    }

    public function activas(): array
    {
        return $this->sql(
            'SELECT sw.*, u.user AS usuario_login,
                    CONCAT(per.nombres, " ", per.apellidos) AS usuario_nombre, r.nombre AS rol
               FROM sesiones_web sw
               LEFT JOIN usuarios u   ON u.id_usuario = sw.id_usuario
               LEFT JOIN personas per ON per.id_persona = u.id_persona
               LEFT JOIN roles r      ON r.id_rol = u.id_rol
              WHERE sw.estado = "Activa"
              ORDER BY sw.ultimo_acceso DESC'
        )->obtenerTodo();
    }

    public function cerrarPorToken(string $tokenHash): void
    {
        $this->sql(
            'UPDATE sesiones_web SET estado = "Cerrada", fecha_cierre = NOW() WHERE token = ? AND estado = "Activa"',
            [$tokenHash]
        );
    }

    public function cerrarTodas(int $idUsuario, ?string $exceptoTokenHash = null): int
    {
        $sql    = 'UPDATE sesiones_web SET estado = "Cerrada", fecha_cierre = NOW() WHERE id_usuario = ? AND estado = "Activa"';
        $params = [$idUsuario];

        if ($exceptoTokenHash !== null) {
            $sql     .= ' AND token <> ?';
            $params[] = $exceptoTokenHash;
        }

        return $this->sql($sql, $params)->filasAfectadas();
    }

    public function limpiarAntiguas(int $dias = 90): int
    {
        return $this->sql(
            'DELETE FROM sesiones_web WHERE estado <> "Activa" AND ultimo_acceso < DATE_SUB(NOW(), INTERVAL ? DAY)',
            [$dias]
        )->filasAfectadas();
    }
}
