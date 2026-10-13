<?php

namespace App\Models;

use App\Core\Model;

class AlumnoBeca extends Model
{
    protected string $tabla = 'alumno_beca';
    protected string $clavePrimaria = 'id_alumno_beca';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_alumno', 'id_beca', 'id_periodo', 'fecha_asignacion', 'fecha_fin', 'estado', 'observaciones',
    ];

    public function listar(): array
    {
        return $this->sql(
            'SELECT ab.*, b.nombre AS beca_nombre, b.porcentaje_descuento, b.monto_fijo_descuento,
                    p.cedula, CONCAT(p.apellidos, ", ", p.nombres) AS alumno, a.legajo,
                    pe.nombre AS periodo_nombre
               FROM alumno_beca ab
               INNER JOIN alumnos a   ON a.id_alumno = ab.id_alumno
               INNER JOIN personas p  ON p.id_persona = a.id_persona
               LEFT JOIN becas b      ON b.id_beca = ab.id_beca
               LEFT JOIN periodos_academicos pe ON pe.id_periodo = ab.id_periodo
              ORDER BY ab.fecha_asignacion DESC'
        )->obtenerTodo();
    }

    /** Becas activas de un alumno en un periodo concreto. */
    public function activasDeAlumno(int $idAlumno, ?int $idPeriodo = null): array
    {
        $sql = 'SELECT ab.*, b.nombre, b.porcentaje_descuento, b.monto_fijo_descuento, b.tipo
                  FROM alumno_beca ab
                  INNER JOIN becas b ON b.id_beca = ab.id_beca
                 WHERE ab.id_alumno = ? AND ab.estado = "Activo"
                   AND (ab.fecha_fin IS NULL OR ab.fecha_fin >= CURDATE())';
        $params = [$idAlumno];

        if ($idPeriodo !== null) {
            $sql     .= ' AND (ab.id_periodo = ? OR ab.id_periodo IS NULL)';
            $params[] = $idPeriodo;
        }

        return $this->sql($sql, $params)->obtenerTodo();
    }
}
