<?php

namespace App\Models;

use App\Core\Model;

class Notificacion extends Model
{
    protected string $tabla = 'notificaciones';
    protected string $clavePrimaria = 'id_notificacion';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['id_usuario', 'titulo', 'mensaje', 'tipo', 'url', 'leida', 'fecha_lectura'];

    public function deUsuario(int $idUsuario, ?int $limite = null, bool $soloNoLeidas = false): array
    {
        $sql = 'SELECT * FROM notificaciones WHERE id_usuario = ?';
        if ($soloNoLeidas) {
            $sql .= ' AND leida = 0';
        }
        $sql .= ' ORDER BY fecha_creacion DESC';
        if ($limite !== null) {
            $sql .= ' LIMIT ' . (int) $limite;
        }

        return $this->sql($sql, [$idUsuario])->obtenerTodo();
    }

    public function noLeidas(int $idUsuario): int
    {
        return $this->contar(['id_usuario' => $idUsuario, 'leida' => 0]);
    }

    public function marcarLeida(int $id, int $idUsuario): void
    {
        $this->sql(
            'UPDATE notificaciones SET leida = 1, fecha_lectura = NOW() WHERE id_notificacion = ? AND id_usuario = ?',
            [$id, $idUsuario]
        );
    }

    public function marcarTodas(int $idUsuario): int
    {
        return $this->sql(
            'UPDATE notificaciones SET leida = 1, fecha_lectura = NOW() WHERE id_usuario = ? AND leida = 0',
            [$idUsuario]
        )->filasAfectadas();
    }

    /** Crea la misma notificacion para varios usuarios. */
    public function paraVarios(array $idsUsuarios, string $titulo, string $mensaje, string $tipo = 'info', ?string $url = null): int
    {
        $creadas = 0;
        foreach (array_unique($idsUsuarios) as $idUsuario) {
            $this->crear([
                'id_usuario' => (int) $idUsuario,
                'titulo'     => $titulo,
                'mensaje'    => $mensaje,
                'tipo'       => $tipo,
                'url'        => $url,
                'leida'      => 0,
            ]);
            $creadas++;
        }
        return $creadas;
    }
}
