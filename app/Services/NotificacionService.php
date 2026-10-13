<?php

namespace App\Services;

use App\Core\Database;
use App\Models\Notificacion;

/**
 * Envio de notificaciones internas del sistema.
 */
class NotificacionService
{
    private Notificacion $notificaciones;

    public function __construct()
    {
        $this->notificaciones = new Notificacion();
    }

    public function enviar(int $idUsuario, string $titulo, string $mensaje, string $tipo = 'info', ?string $url = null): int
    {
        if ($idUsuario <= 0) {
            return 0;
        }

        return $this->notificaciones->crear([
            'id_usuario' => $idUsuario,
            'titulo'     => $titulo,
            'mensaje'    => $mensaje,
            'tipo'       => $tipo,
            'url'        => $url,
            'leida'      => 0,
        ]);
    }

    /** Notifica a todos los usuarios que tengan alguno de los roles indicados. */
    public function enviarARoles(array $idsRoles, string $titulo, string $mensaje, string $tipo = 'info', ?string $url = null): int
    {
        if ($idsRoles === []) {
            return 0;
        }

        $marcadores = implode(', ', array_fill(0, count($idsRoles), '?'));
        $ids = Database::instancia()->consulta(
            "SELECT id_usuario FROM usuarios WHERE id_rol IN ({$marcadores}) AND estado = 'Activo'",
            array_map('intval', $idsRoles)
        )->lista('id_usuario');

        return $this->notificaciones->paraVarios(array_map('intval', $ids), $titulo, $mensaje, $tipo, $url);
    }

    public function enviarAAlumno(int $idAlumno, string $titulo, string $mensaje, string $tipo = 'info', ?string $url = null): int
    {
        $idUsuario = (int) Database::instancia()->consulta(
            'SELECT u.id_usuario FROM usuarios u
               INNER JOIN alumnos a ON a.id_persona = u.id_persona
              WHERE a.id_alumno = ? LIMIT 1',
            [$idAlumno]
        )->valor();

        return $this->enviar($idUsuario, $titulo, $mensaje, $tipo, $url);
    }

    public function deUsuario(int $idUsuario, int $limite = 20): array
    {
        return $this->notificaciones->deUsuario($idUsuario, $limite);
    }

    public function noLeidas(int $idUsuario): int
    {
        return $this->notificaciones->noLeidas($idUsuario);
    }

    public function marcarLeida(int $idNotificacion, int $idUsuario): void
    {
        $this->notificaciones->marcarLeida($idNotificacion, $idUsuario);
    }

    public function marcarTodas(int $idUsuario): int
    {
        return $this->notificaciones->marcarTodas($idUsuario);
    }
}
