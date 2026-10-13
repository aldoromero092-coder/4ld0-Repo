<?php

namespace App\Models;

use App\Core\Model;

class Carrera extends Model
{
    protected string $tabla = 'carreras';
    protected string $clavePrimaria = 'id_carrera';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['codigo_carrera', 'nombre', 'id_facultades', 'duracion_anio', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT c.*, f.nombre AS facultad_nombre, s.nombre AS sede_nombre,
                    (SELECT COUNT(*) FROM alumnos a WHERE a.id_carrera = c.id_carrera) AS total_alumnos
               FROM carreras c
               LEFT JOIN facultades f ON f.id_facultades = c.id_facultades
               LEFT JOIN sedes s      ON s.id_sede = f.id_sede
              ORDER BY f.nombre, c.nombre'
        )->obtenerTodo();
    }

    public function opciones(): array
    {
        return $this->sql(
            'SELECT c.id_carrera AS id, c.nombre, c.codigo_carrera, c.id_facultades,
                    f.nombre AS facultad, f.id_sede
               FROM carreras c
               LEFT JOIN facultades f ON f.id_facultades = c.id_facultades
              WHERE c.estado = "Activo"
              ORDER BY c.nombre'
        )->obtenerTodo();
    }
}
