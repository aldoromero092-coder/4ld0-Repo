<?php

namespace App\Models;

use App\Core\Model;

class MensajeContacto extends Model
{
    protected string $tabla = 'mensajes_contacto';
    protected string $clavePrimaria = 'id_mensaje';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_usuario', 'nombre', 'email', 'telefono', 'asunto', 'mensaje', 'canal',
        'estado', 'respuesta', 'id_usuario_gestor', 'fecha_respuesta',
    ];

    public function listar(array $filtros = [], int $limite = 20, int $desplazamiento = 0): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['estado'])) {
            $condiciones[]        = 'm.estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }
        if (!empty($filtros['canal'])) {
            $condiciones[]       = 'm.canal = :canal';
            $parametros['canal'] = $filtros['canal'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(m.nombre LIKE :buscar OR m.email LIKE :buscar OR m.telefono LIKE :buscar
                                     OR m.asunto LIKE :buscar OR m.mensaje LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            "SELECT m.*, u.user AS usuario_login
               FROM mensajes_contacto m
               LEFT JOIN usuarios u ON u.id_usuario = m.id_usuario
               {$where}
              ORDER BY FIELD(m.estado, 'Nuevo','En revision','Respondido','Cerrado'), m.fecha_creacion DESC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['estado'])) {
            $condiciones[]        = 'estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }
        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        return $this->sql("SELECT COUNT(*) FROM mensajes_contacto {$where}", $parametros)->entero();
    }

    public function nuevos(): int
    {
        return $this->contar(['estado' => 'Nuevo']);
    }
}
