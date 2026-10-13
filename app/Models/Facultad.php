<?php

namespace App\Models;

use App\Core\Model;

class Facultad extends Model
{
    protected string $tabla = 'facultades';
    protected string $clavePrimaria = 'id_facultades';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'id_sede', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT f.*, s.nombre AS sede_nombre,
                    (SELECT COUNT(*) FROM carreras c WHERE c.id_facultades = f.id_facultades) AS total_carreras,
                    (SELECT COUNT(*) FROM alumnos a WHERE a.id_facultades = f.id_facultades) AS total_alumnos
               FROM facultades f
               LEFT JOIN sedes s ON s.id_sede = f.id_sede
              ORDER BY f.nombre'
        )->obtenerTodo();
    }

    public function opciones(): array
    {
        return $this->sql('SELECT id_facultades AS id, nombre, id_sede FROM facultades WHERE estado = "Activo" ORDER BY nombre')->obtenerTodo();
    }
}
