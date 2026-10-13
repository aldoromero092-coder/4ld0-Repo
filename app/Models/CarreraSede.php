<?php

namespace App\Models;

use App\Core\Model;

/**
 * Oferta academica: en que sedes se dicta cada carrera.
 */
class CarreraSede extends Model
{
    protected string $tabla = 'carrera_sede';
    protected string $clavePrimaria = 'id_carrera_sede';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';
    protected array $asignables = ['id_carrera', 'id_sede', 'turnos', 'cupo', 'estado'];

    public function deCarrera(int $idCarrera): array
    {
        return $this->sql(
            'SELECT cs.*, s.nombre AS sede_nombre, s.ciudad, s.tipo
               FROM carrera_sede cs
               INNER JOIN sedes s ON s.id_sede = cs.id_sede
              WHERE cs.id_carrera = ? AND cs.estado = "Activo"
              ORDER BY s.es_central DESC, s.nombre',
            [$idCarrera]
        )->obtenerTodo();
    }

    public function deSede(int $idSede): array
    {
        return $this->sql(
            'SELECT cs.*, c.nombre AS carrera_nombre, c.codigo_carrera, c.titulo_otorgado,
                    c.duracion_anios, f.nombre AS facultad_nombre, f.siglas AS facultad_siglas
               FROM carrera_sede cs
               INNER JOIN carreras c   ON c.id_carrera = cs.id_carrera
               LEFT JOIN facultades f  ON f.id_facultades = c.id_facultades
              WHERE cs.id_sede = ? AND cs.estado = "Activo" AND c.estado = "Activo"
              ORDER BY f.nombre, c.nombre',
            [$idSede]
        )->obtenerTodo();
    }

    /** @return array<int, array> */
    public function listar(): array
    {
        return $this->sql(
            'SELECT cs.*, c.nombre AS carrera_nombre, c.codigo_carrera,
                    s.nombre AS sede_nombre, s.ciudad, f.siglas AS facultad_siglas
               FROM carrera_sede cs
               INNER JOIN carreras c  ON c.id_carrera = cs.id_carrera
               INNER JOIN sedes s     ON s.id_sede = cs.id_sede
               LEFT JOIN facultades f ON f.id_facultades = c.id_facultades
              ORDER BY s.es_central DESC, s.nombre, c.nombre'
        )->obtenerTodo();
    }

    public function sedesDeCarrera(int $idCarrera): array
    {
        return array_map(
            static fn (array $fila): int => (int) $fila['id_sede'],
            $this->deCarrera($idCarrera)
        );
    }
}
