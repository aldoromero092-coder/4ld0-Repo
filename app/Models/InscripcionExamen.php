<?php

namespace App\Models;

use App\Core\Model;

class InscripcionExamen extends Model
{
    protected string $tabla = 'inscripciones_examen';
    protected string $clavePrimaria = 'id_inscripcion';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_examen', 'id_alumno', 'id_obligacion', 'id_pago', 'fecha_inscripcion',
        'estado', 'nota', 'condicion', 'observaciones',
    ];

    private const SELECT_BASE = 'SELECT ie.*, e.nombre AS examen_nombre, e.materia, e.tipo, e.fecha_examen,
                    e.hora_inicio, e.aula, e.monto AS examen_monto, e.duracion_min,
                    per.cedula, CONCAT(per.apellidos, ", ", per.nombres) AS alumno, a.legajo,
                    c.nombre AS carrera_nombre, p.nombre AS periodo_nombre,
                    o.descripcion AS obligacion_descripcion, o.saldo AS obligacion_saldo,
                    o.estado AS obligacion_estado, o.id_obligacion,
                    pg.id_pago, pg.estado_pago, pg.numero_comprobante
               FROM inscripciones_examen ie
               INNER JOIN examenes e     ON e.id_examen = ie.id_examen
               INNER JOIN alumnos a      ON a.id_alumno = ie.id_alumno
               INNER JOIN personas per   ON per.id_persona = a.id_persona
               LEFT JOIN carreras c      ON c.id_carrera = a.id_carrera
               LEFT JOIN periodos_academicos p ON p.id_periodo = e.id_periodo
               LEFT JOIN obligaciones_pago o   ON o.id_obligacion = ie.id_obligacion
               LEFT JOIN pagos pg              ON pg.id_pago = ie.id_pago';

    public function conDetalle(int $id): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE ie.id_inscripcion = ? LIMIT 1', [$id])->obtener();
    }

    public function deAlumno(int $idAlumno, ?string $estado = null): array
    {
        $sql    = self::SELECT_BASE . ' WHERE ie.id_alumno = ?';
        $params = [$idAlumno];

        if ($estado !== null) {
            $sql     .= ' AND ie.estado = ?';
            $params[] = $estado;
        }

        return $this->sql($sql . ' ORDER BY e.fecha_examen DESC', $params)->obtenerTodo();
    }

    public function deExamen(int $idExamen): array
    {
        return $this->sql(
            self::SELECT_BASE . ' WHERE ie.id_examen = ? AND ie.estado <> "Anulado" ORDER BY per.apellidos, per.nombres',
            [$idExamen]
        )->obtenerTodo();
    }

    public function yaInscripto(int $idExamen, int $idAlumno): ?array
    {
        return $this->sql(
            'SELECT * FROM inscripciones_examen WHERE id_examen = ? AND id_alumno = ? AND estado <> "Anulado" LIMIT 1',
            [$idExamen, $idAlumno]
        )->obtener();
    }

    public function pendientesPago(int $idAlumno): array
    {
        return $this->sql(
            self::SELECT_BASE . ' WHERE ie.id_alumno = ? AND ie.estado = "Pendiente" ORDER BY e.fecha_examen',
            [$idAlumno]
        )->obtenerTodo();
    }
}
