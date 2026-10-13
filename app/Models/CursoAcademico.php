<?php

namespace App\Models;

use App\Core\Model;

/**
 * Division abierta de un curso (carrera + periodo + anio + semestre + seccion).
 */
class CursoAcademico extends Model
{
    protected string $tabla = 'cursos_academicos';
    protected string $clavePrimaria = 'id_curso';
    protected array $asignables = [
        'id_carrera', 'id_periodo', 'id_sede', 'id_malla', 'curso', 'semestre', 'seccion',
        'turno', 'modalidad', 'aula', 'cupo', 'matriculados', 'fecha_inicio', 'fecha_fin',
        'estado', 'observaciones', 'id_usuario_gestion',
    ];

    private const SELECT_BASE = 'SELECT cu.*, c.nombre AS carrera_nombre, c.codigo_carrera,
                    p.nombre AS periodo_nombre, s.nombre AS sede_nombre, m.nombre AS malla_nombre,
                    (SELECT COUNT(*) FROM matricula_materias mm WHERE mm.id_curso = cu.id_curso) AS inscriptos,
                    GREATEST(0, cu.cupo - cu.matriculados) AS cupos_libres
               FROM cursos_academicos cu
               INNER JOIN carreras c            ON c.id_carrera = cu.id_carrera
               INNER JOIN periodos_academicos p ON p.id_periodo = cu.id_periodo
               LEFT JOIN sedes s                ON s.id_sede = cu.id_sede
               LEFT JOIN mallas_curriculares m  ON m.id_malla = cu.id_malla';

    public function conDetalle(int $idCurso): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE cu.id_curso = ? LIMIT 1', [$idCurso])->obtener();
    }

    /** @return array<int, array> */
    public function listar(array $filtros = []): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_carrera'])) {
            $condiciones[]           = 'cu.id_carrera = :id_carrera';
            $parametros['id_carrera'] = (int) $filtros['id_carrera'];
        }
        if (!empty($filtros['id_periodo'])) {
            $condiciones[]           = 'cu.id_periodo = :id_periodo';
            $parametros['id_periodo'] = (int) $filtros['id_periodo'];
        }
        if (!empty($filtros['id_sede'])) {
            $condiciones[]        = 'cu.id_sede = :id_sede';
            $parametros['id_sede'] = (int) $filtros['id_sede'];
        }
        if (!empty($filtros['curso'])) {
            $condiciones[]       = 'cu.curso = :curso';
            $parametros['curso'] = (int) $filtros['curso'];
        }
        if (!empty($filtros['estado'])) {
            $condiciones[]       = 'cu.estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        return $this->sql(
            self::SELECT_BASE . " {$where}
              ORDER BY p.fecha_inicio DESC, c.nombre, cu.curso, cu.semestre, cu.seccion
              LIMIT 500",
            $parametros
        )->obtenerTodo();
    }

    /** Cursos abiertos de una carrera y periodo, para matricular a un alumno. */
    public function disponibles(int $idCarrera, int $idPeriodo, ?int $idSede = null): array
    {
        $condiciones = ['cu.id_carrera = ?', 'cu.id_periodo = ?', 'cu.estado = "Abierto"'];
        $parametros  = [$idCarrera, $idPeriodo];

        if ($idSede !== null && $idSede > 0) {
            $condiciones[] = '(cu.id_sede = ? OR cu.id_sede IS NULL)';
            $parametros[]  = $idSede;
        }

        return $this->sql(
            self::SELECT_BASE . ' WHERE ' . implode(' AND ', $condiciones)
            . ' ORDER BY cu.curso, cu.semestre, cu.seccion',
            $parametros
        )->obtenerTodo();
    }

    public function buscarDivision(int $idCarrera, int $idPeriodo, int $curso, int $semestre, int $idSede): ?array
    {
        return $this->sql(
            'SELECT * FROM cursos_academicos
              WHERE id_carrera = ? AND id_periodo = ? AND curso = ? AND semestre = ? AND id_sede = ?
              LIMIT 1',
            [$idCarrera, $idPeriodo, $curso, $semestre, $idSede]
        )->obtener();
    }

    /** Cuenta los inscriptos reales de la division. */
    public function sincronizarMatriculados(int $idCurso): int
    {
        $total = (int) $this->sql(
            'SELECT COUNT(DISTINCT mm.id_matricula) FROM matricula_materias mm WHERE mm.id_curso = ?',
            [$idCurso]
        )->entero();

        $this->actualizar($idCurso, ['matriculados' => $total]);

        return $total;
    }

    /** Cupos libres de la division. */
    public function cuposLibres(int $idCurso): int
    {
        $fila = $this->sql(
            'SELECT cupo, matriculados FROM cursos_academicos WHERE id_curso = ?',
            [$idCurso]
        )->obtener();

        if ($fila === null) {
            return 0;
        }

        return max(0, (int) $fila['cupo'] - (int) $fila['matriculados']);
    }

    public function estadisticas(?int $idPeriodo = null): array
    {
        $filtro = $idPeriodo !== null ? 'WHERE cu.id_periodo = ' . (int) $idPeriodo : '';

        $fila = $this->sql(
            "SELECT COUNT(*) AS total,
                    SUM(cu.estado = 'Abierto') AS abiertos,
                    COALESCE(SUM(cu.cupo),0) AS cupos,
                    COALESCE(SUM(cu.matriculados),0) AS matriculados
               FROM cursos_academicos cu {$filtro}"
        )->obtener();

        return [
            'total'        => (int) ($fila['total'] ?? 0),
            'abiertos'     => (int) ($fila['abiertos'] ?? 0),
            'cupos'        => (int) ($fila['cupos'] ?? 0),
            'matriculados' => (int) ($fila['matriculados'] ?? 0),
        ];
    }
}
