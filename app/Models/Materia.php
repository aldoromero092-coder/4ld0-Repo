<?php

namespace App\Models;

use App\Core\Model;

/**
 * Asignatura de una malla curricular, ubicada por carrera, curso y semestre.
 */
class Materia extends Model
{
    protected string $tabla = 'materias';
    protected string $clavePrimaria = 'id_materia';
    protected array $asignables = [
        'id_malla', 'id_carrera', 'codigo', 'nombre', 'curso', 'semestre', 'semestre_global',
        'horas_catedra', 'creditos', 'tipo', 'prerequisito', 'orden', 'estado',
    ];

    public function conDetalle(int $idMateria): ?array
    {
        return $this->sql(
            'SELECT ma.*, m.nombre AS malla_nombre, c.nombre AS carrera_nombre, c.codigo_carrera
               FROM materias ma
               INNER JOIN mallas_curriculares m ON m.id_malla = ma.id_malla
               INNER JOIN carreras c ON c.id_carrera = ma.id_carrera
              WHERE ma.id_materia = ? LIMIT 1',
            [$idMateria]
        )->obtener();
    }

    /** @return array<int, array> */
    public function deMalla(int $idMalla, ?int $curso = null, ?int $semestre = null, bool $soloActivas = true): array
    {
        $condiciones = ['ma.id_malla = ?'];
        $parametros  = [$idMalla];

        if ($curso !== null) {
            $condiciones[] = 'ma.curso = ?';
            $parametros[]  = $curso;
        }
        if ($semestre !== null) {
            $condiciones[] = 'ma.semestre = ?';
            $parametros[]  = $semestre;
        }
        if ($soloActivas) {
            $condiciones[] = 'ma.estado = "Activo"';
        }

        return $this->sql(
            'SELECT ma.* FROM materias ma WHERE ' . implode(' AND ', $condiciones)
            . ' ORDER BY ma.curso, ma.semestre, ma.orden, ma.codigo',
            $parametros
        )->obtenerTodo();
    }

    /** Materias de la malla vigente de la carrera para un curso y semestre. */
    public function deCarreraCurso(int $idCarrera, int $curso, ?int $semestre = null): array
    {
        $condiciones = ['ma.id_carrera = ?', 'ma.curso = ?', 'ma.estado = "Activo"'];
        $parametros  = [$idCarrera, $curso];

        if ($semestre !== null) {
            $condiciones[] = 'ma.semestre = ?';
            $parametros[]  = $semestre;
        }

        return $this->sql(
            'SELECT ma.* FROM materias ma
              INNER JOIN mallas_curriculares m ON m.id_malla = ma.id_malla AND m.estado = "Activo"
             WHERE ' . implode(' AND ', $condiciones)
            . ' ORDER BY ma.curso, ma.semestre, ma.orden, ma.codigo',
            $parametros
        )->obtenerTodo();
    }

    /** Materias de la carrera hasta un semestre corrido (historial del alumno). */
    public function hastaSemestre(int $idCarrera, int $semestreGlobal): array
    {
        return $this->sql(
            'SELECT ma.*, m.nombre AS malla_nombre
               FROM materias ma
               INNER JOIN mallas_curriculares m ON m.id_malla = ma.id_malla AND m.estado = "Activo"
              WHERE ma.id_carrera = ? AND ma.estado = "Activo" AND ma.semestre_global <= ?
              ORDER BY ma.semestre_global, ma.orden',
            [$idCarrera, $semestreGlobal]
        )->obtenerTodo();
    }

    /**
     * Materias agrupadas por curso y semestre.
     *
     * @return array<int, array<int, array>>
     */
    public function agrupadas(int $idMalla): array
    {
        $grupos = [];
        foreach ($this->deMalla($idMalla) as $materia) {
            $grupos[(int) $materia['curso']][(int) $materia['semestre']][] = $materia;
        }

        return $grupos;
    }

    /** @return array<int, array> */
    public function listar(array $filtros = []): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_carrera'])) {
            $condiciones[]           = 'ma.id_carrera = :id_carrera';
            $parametros['id_carrera'] = (int) $filtros['id_carrera'];
        }
        if (!empty($filtros['id_malla'])) {
            $condiciones[]         = 'ma.id_malla = :id_malla';
            $parametros['id_malla'] = (int) $filtros['id_malla'];
        }
        if (!empty($filtros['curso'])) {
            $condiciones[]       = 'ma.curso = :curso';
            $parametros['curso'] = (int) $filtros['curso'];
        }
        if (!empty($filtros['semestre'])) {
            $condiciones[]          = 'ma.semestre = :semestre';
            $parametros['semestre'] = (int) $filtros['semestre'];
        }
        if (!empty($filtros['estado'])) {
            $condiciones[]       = 'ma.estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(ma.nombre LIKE :buscar OR ma.codigo LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        return $this->sql(
            "SELECT ma.*, c.nombre AS carrera_nombre, c.codigo_carrera, m.nombre AS malla_nombre,
                    (SELECT COUNT(*) FROM matricula_materias mm WHERE mm.id_materia = ma.id_materia) AS veces_cursada
               FROM materias ma
               INNER JOIN carreras c ON c.id_carrera = ma.id_carrera
               INNER JOIN mallas_curriculares m ON m.id_malla = ma.id_malla
               {$where}
              ORDER BY c.nombre, ma.curso, ma.semestre, ma.orden
              LIMIT 500",
            $parametros
        )->obtenerTodo();
    }

    public function codigoEnUso(int $idMalla, string $codigo, int $excluir = 0): bool
    {
        return (int) $this->sql(
            'SELECT COUNT(*) FROM materias WHERE id_malla = ? AND codigo = ? AND id_materia <> ?',
            [$idMalla, $codigo, $excluir]
        )->entero() > 0;
    }

    public function siguienteOrden(int $idMalla, int $curso, int $semestre): int
    {
        return (int) $this->sql(
            'SELECT COALESCE(MAX(orden),0) + 1 FROM materias WHERE id_malla = ? AND curso = ? AND semestre = ?',
            [$idMalla, $curso, $semestre]
        )->entero();
    }
}
