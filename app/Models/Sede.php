<?php

namespace App\Models;

use App\Core\Model;

class Sede extends Model
{
    protected string $tabla = 'sedes';
    protected string $clavePrimaria = 'id_sede';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'direccion', 'telefono', 'id_ciudades', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT s.*, c.nombre AS ciudad_nombre,
                    (SELECT COUNT(*) FROM facultades f WHERE f.id_sede = s.id_sede) AS total_facultades,
                    (SELECT COUNT(*) FROM alumnos a WHERE a.id_sede = s.id_sede) AS total_alumnos
               FROM sedes s
               LEFT JOIN ciudades c ON c.id_ciudades = s.id_ciudades
              ORDER BY s.nombre'
        )->obtenerTodo();
    }

    public function opciones(): array
    {
        return $this->sql('SELECT id_sede AS id, nombre FROM sedes WHERE estado = "Activo" ORDER BY nombre')->obtenerTodo();
    }
}
