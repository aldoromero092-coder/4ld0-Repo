<?php

namespace App\Models;

use App\Core\Model;

/**
 * Plan de estudios (malla curricular) de una carrera.
 */
class Malla extends Model
{
    protected string $tabla = 'mallas_curriculares';
    protected string $clavePrimaria = 'id_malla';
    protected array $asignables = [
        'id_carrera', 'nombre', 'anio_vigencia', 'resolucion', 'total_cursos',
        'total_semestres', 'carga_horaria', 'vigente', 'observaciones', 'estado',
    ];

    /** Malla vigente de una carrera. */
    public function vigenteDeCarrera(int $idCarrera): ?array
    {
        return $this->sql(
            'SELECT * FROM mallas_curriculares
              WHERE id_carrera = ? AND estado = "Activo"
              ORDER BY vigente DESC, anio_vigencia DESC, id_malla DESC
              LIMIT 1',
            [$idCarrera]
        )->obtener();
    }

    /** @return array<int, array> */
    public function deCarrera(int $idCarrera): array
    {
        return $this->sql(
            'SELECT m.*, (SELECT COUNT(*) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = "Activo") AS total_materias
               FROM mallas_curriculares m
              WHERE m.id_carrera = ?
              ORDER BY m.vigente DESC, m.anio_vigencia DESC, m.id_malla DESC',
            [$idCarrera]
        )->obtenerTodo();
    }

    public function conDetalle(int $idMalla): ?array
    {
        return $this->sql(
            'SELECT m.*, c.nombre AS carrera_nombre, c.codigo_carrera, c.titulo_otorgado,
                    c.duracion_semestres, f.nombre AS facultad_nombre, f.id_facultades,
                    (SELECT COUNT(*) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = "Activo") AS total_materias,
                    (SELECT COALESCE(SUM(ma.horas_catedra),0) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = "Activo") AS horas_malla,
                    (SELECT COALESCE(SUM(ma.creditos),0) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = "Activo") AS creditos_malla,
                    (SELECT COUNT(DISTINCT ma.curso) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = "Activo") AS cursos_cargados
               FROM mallas_curriculares m
               INNER JOIN carreras c   ON c.id_carrera = m.id_carrera
               LEFT JOIN facultades f  ON f.id_facultades = c.id_facultades
              WHERE m.id_malla = ? LIMIT 1',
            [$idMalla]
        )->obtener();
    }

    /** @return array<int, array> */
    public function listar(array $filtros = []): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_carrera'])) {
            $condiciones[]          = 'm.id_carrera = :id_carrera';
            $parametros['id_carrera'] = (int) $filtros['id_carrera'];
        }
        if (!empty($filtros['id_facultades'])) {
            $condiciones[]             = 'c.id_facultades = :id_facultades';
            $parametros['id_facultades'] = (int) $filtros['id_facultades'];
        }
        if (!empty($filtros['estado'])) {
            $condiciones[]       = 'm.estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(c.nombre LIKE :buscar OR m.nombre LIKE :buscar OR c.codigo_carrera LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        return $this->sql(
            "SELECT m.*, c.nombre AS carrera_nombre, c.codigo_carrera, c.titulo_otorgado,
                    f.nombre AS facultad_nombre, f.siglas AS facultad_siglas,
                    (SELECT COUNT(*) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = 'Activo') AS total_materias,
                    (SELECT COALESCE(SUM(ma.horas_catedra),0) FROM materias ma WHERE ma.id_malla = m.id_malla AND ma.estado = 'Activo') AS horas_malla
               FROM mallas_curriculares m
               INNER JOIN carreras c  ON c.id_carrera = m.id_carrera
               LEFT JOIN facultades f ON f.id_facultades = c.id_facultades
               {$where}
              ORDER BY f.nombre, c.nombre, m.vigente DESC",
            $parametros
        )->obtenerTodo();
    }

    /** Resumen de materias, horas y creditos por curso y semestre. */
    public function resumen(int $idMalla): array
    {
        return $this->sql(
            'SELECT curso, semestre, semestre_global,
                    COUNT(*) AS total_materias,
                    COALESCE(SUM(horas_catedra),0) AS horas,
                    COALESCE(SUM(creditos),0) AS creditos
               FROM materias
              WHERE id_malla = ? AND estado = "Activo"
              GROUP BY curso, semestre, semestre_global
              ORDER BY curso, semestre',
            [$idMalla]
        )->obtenerTodo();
    }

    /** Recalcula los totales de la malla a partir de sus materias. */
    public function recalcular(int $idMalla): void
    {
        $fila = $this->sql(
            'SELECT COALESCE(MAX(curso),1) AS cursos, COALESCE(SUM(horas_catedra),0) AS horas
               FROM materias WHERE id_malla = ? AND estado = "Activo"',
            [$idMalla]
        )->obtener();

        $this->actualizar($idMalla, [
            'total_cursos'  => max(1, (int) ($fila['cursos'] ?? 1)),
            'carga_horaria' => (int) ($fila['horas'] ?? 0),
        ]);
    }

    /** Desmarca el resto de las mallas de la carrera y deja esta como vigente. */
    public function marcarVigente(int $idMalla): void
    {
        $malla = $this->buscar($idMalla);
        if ($malla === null) {
            return;
        }

        $this->sql('UPDATE mallas_curriculares SET vigente = 0 WHERE id_carrera = ?', [(int) $malla['id_carrera']]);
        $this->actualizar($idMalla, ['vigente' => 1]);
    }
}
