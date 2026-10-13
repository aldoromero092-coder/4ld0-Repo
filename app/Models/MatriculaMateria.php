<?php

namespace App\Models;

use App\Core\Model;

/**
 * Materias que cursa el alumno en una matricula. Guarda una copia del
 * codigo, nombre y horas para que el historial no dependa de cambios
 * posteriores en la malla curricular.
 */
class MatriculaMateria extends Model
{
    protected string $tabla = 'matricula_materias';
    protected string $clavePrimaria = 'id_matricula_materia';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_matricula', 'id_materia', 'id_curso', 'codigo', 'nombre', 'curso', 'semestre',
        'horas', 'creditos', 'condicion', 'estado', 'nota',
    ];

    public function deMatricula(int $idMatricula): array
    {
        return $this->sql(
            'SELECT mm.*, cu.seccion, cu.aula, cu.turno AS curso_turno, s.nombre AS sede_nombre
               FROM matricula_materias mm
               LEFT JOIN cursos_academicos cu ON cu.id_curso = mm.id_curso
               LEFT JOIN sedes s              ON s.id_sede = cu.id_sede
              WHERE mm.id_matricula = ?
              ORDER BY mm.curso, mm.semestre, mm.codigo',
            [$idMatricula]
        )->obtenerTodo();
    }

    public function resumen(int $idMatricula): array
    {
        $fila = $this->sql(
            'SELECT COUNT(*) AS total_materias, COALESCE(SUM(horas),0) AS total_horas,
                    COALESCE(SUM(creditos),0) AS total_creditos
               FROM matricula_materias WHERE id_matricula = ?',
            [$idMatricula]
        )->obtener();

        return [
            'total_materias' => (int) ($fila['total_materias'] ?? 0),
            'total_horas'    => (int) ($fila['total_horas'] ?? 0),
            'total_creditos' => (float) ($fila['total_creditos'] ?? 0),
        ];
    }

    /** Historial de materias cursadas por el alumno. */
    public function deAlumno(int $idAlumno): array
    {
        return $this->sql(
            'SELECT mm.*, m.numero_matricula, pe.nombre AS periodo_nombre, pe.id_periodo
               FROM matricula_materias mm
               INNER JOIN matriculas m         ON m.id_matricula = mm.id_matricula
               INNER JOIN periodos_academicos pe ON pe.id_periodo = m.id_periodo
              WHERE m.id_alumno = ?
              ORDER BY pe.fecha_inicio DESC, mm.curso, mm.semestre, mm.codigo',
            [$idAlumno]
        )->obtenerTodo();
    }

    /** Materias aprobadas del alumno (para calcular avance curricular). */
    public function aprobadas(int $idAlumno): array
    {
        return $this->sql(
            'SELECT mm.id_materia, mm.codigo, mm.nombre, mm.creditos, mm.nota
               FROM matricula_materias mm
               INNER JOIN matriculas m ON m.id_matricula = mm.id_matricula
              WHERE m.id_alumno = ? AND mm.estado = "Aprobada"
              ORDER BY mm.curso, mm.semestre',
            [$idAlumno]
        )->obtenerTodo();
    }

    /**
     * Reemplaza las materias de una matricula.
     *
     * @param array<int, array> $materias Cada fila con id_materia, id_curso, codigo,
     *                                    nombre, curso, semestre, horas y creditos.
     */
    public function reemplazar(int $idMatricula, array $materias): int
    {
        $this->sql('DELETE FROM matricula_materias WHERE id_matricula = ?', [$idMatricula]);

        $total = 0;
        foreach ($materias as $materia) {
            $this->crear([
                'id_matricula' => $idMatricula,
                'id_materia'   => (int) $materia['id_materia'],
                'id_curso'     => !empty($materia['id_curso']) ? (int) $materia['id_curso'] : null,
                'codigo'       => (string) ($materia['codigo'] ?? ''),
                'nombre'       => (string) ($materia['nombre'] ?? ''),
                'curso'        => (int) ($materia['curso'] ?? 1),
                'semestre'     => (int) ($materia['semestre'] ?? 1),
                'horas'        => (int) ($materia['horas'] ?? 0),
                'creditos'     => (float) ($materia['creditos'] ?? 0),
                'condicion'    => (string) ($materia['condicion'] ?? 'Regular'),
                'estado'       => (string) ($materia['estado'] ?? 'Inscripto'),
            ]);
            $total++;
        }

        return $total;
    }
}
