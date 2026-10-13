<?php

namespace App\Models;

use App\Core\Model;

class Rol extends Model
{
    protected string $tabla = 'roles';
    protected string $clavePrimaria = 'id_rol';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'descripcion', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT r.*,
                    (SELECT COUNT(*) FROM usuarios u WHERE u.id_rol = r.id_rol) AS total_usuarios
               FROM roles r
              ORDER BY r.id_rol'
        )->obtenerTodo();
    }
}
