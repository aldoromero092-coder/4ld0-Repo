<?php

namespace App\Services;

use App\Core\Database;
use App\Models\Alumno;
use App\Models\CursoAcademico;
use App\Models\Malla;
use App\Models\Materia;
use App\Models\MatriculaMateria;
use App\Models\Periodo;

/**
 * Traduce la malla curricular de una carrera al plan de estudios concreto
 * de un alumno: en que curso y semestre esta, que materias le corresponden
 * y con que division las cursa.
 */
class MallaService
{
    private Malla $mallas;
    private Materia $materias;
    private CursoAcademico $cursos;
    private MatriculaMateria $matriculaMaterias;
    private Alumno $alumnos;
    private Periodo $periodos;

    public function __construct()
    {
        $this->mallas           = new Malla();
        $this->materias         = new Materia();
        $this->cursos           = new CursoAcademico();
        $this->matriculaMaterias = new MatriculaMateria();
        $this->alumnos          = new Alumno();
        $this->periodos         = new Periodo();
    }

    /** Curso (año de la carrera) al que corresponde un semestre corrido. */
    public static function cursoDeSemestre(int $semestreGlobal): int
    {
        return max(1, (int) ceil($semestreGlobal / 2));
    }

    /** Semestre dentro del curso (1 o 2) para un semestre corrido. */
    public static function semestreEnCurso(int $semestreGlobal): int
    {
        return max(1, (($semestreGlobal - 1) % 2) + 1);
    }

    /**
     * Plan de estudios del alumno para un periodo.
     *
     * Si ya tiene una matricula registrada en ese periodo se devuelven las
     * materias efectivamente inscriptas; si no, las que le corresponden por
     * malla segun su curso y semestre actual.
     *
     * @return array{
     *   alumno: array, malla: ?array, curso: int, semestre: int,
     *   semestre_global: int, materias: array, cursos: array, division: ?array,
     *   total_horas: int, total_creditos: float, aprobadas: int,
     *   id_periodo: int, id_sede: int, id_matricula: int, inscritas: bool
     * }
     */
    public function planDeAlumno(int $idAlumno, ?int $idPeriodo = null, ?int $idSede = null): array
    {
        $alumno = $this->alumnos->conDetalle($idAlumno);
        if ($alumno === null) {
            return $this->planVacio();
        }

        $idCarrera = (int) ($alumno['id_carrera'] ?? 0);
        $idSede    = $idSede ?? (int) ($alumno['id_sede'] ?? 0);
        $idPeriodo = $idPeriodo ?? (int) ($this->periodos->actual()['id_periodo'] ?? 0);
        $malla     = $idCarrera > 0 ? $this->mallas->vigenteDeCarrera($idCarrera) : null;

        if ($malla === null) {
            return $this->planVacio($alumno, $idPeriodo, $idSede);
        }

        $semestreGlobal = max(1, (int) ($alumno['semestre_actual'] ?? 1));
        $curso          = self::cursoDeSemestre($semestreGlobal);
        $semestre       = self::semestreEnCurso($semestreGlobal);

        // Si ya se matriculo en el periodo, se muestran sus materias reales.
        $matricula = $idPeriodo > 0 ? Database::instancia()->consulta(
            'SELECT id_matricula, curso, semestre, id_malla, id_curso
               FROM matriculas
              WHERE id_alumno = ? AND id_periodo = ? AND estado <> "Anulada"
              ORDER BY id_matricula DESC LIMIT 1',
            [$idAlumno, $idPeriodo]
        )->obtener() : null;

        $inscritas = false;
        if ($matricula !== null) {
            $registradas = $this->matriculaMaterias->deMatricula((int) $matricula['id_matricula']);
            if ($registradas !== []) {
                $materias  = $registradas;
                $inscritas = true;
                $curso     = (int) ($matricula['curso'] ?? $curso);
                $semestre  = (int) ($matricula['semestre'] ?? $semestre);
            }
        }

        if (!isset($materias)) {
            $materias = $this->materias->deCarreraCurso($idCarrera, $curso, $semestre);
        }

        $cursos   = $idPeriodo > 0 ? $this->cursos->disponibles($idCarrera, $idPeriodo, $idSede) : [];
        $division = null;
        foreach ($cursos as $abierto) {
            if ((int) $abierto['curso'] === $curso && (int) $abierto['semestre'] === $semestre) {
                $division = $abierto;
                break;
            }
        }

        foreach ($materias as &$materia) {
            if (!$inscritas) {
                $materia['id_curso'] = $division['id_curso'] ?? null;
                $materia['aula']     = $division['aula'] ?? null;
                $materia['turno']    = $division['turno'] ?? ($alumno['turno'] ?? null);
                $materia['seccion']  = $division['seccion'] ?? null;
            }

            // Normalizacion: la malla usa horas_catedra/semestre_global y
            // matricula_materias usa horas/semestre (dentro del curso).
            $materia['horas_catedra'] = (int) ($materia['horas_catedra'] ?? $materia['horas'] ?? 0);
            $materia['horas']         = $materia['horas_catedra'];
            $materia['creditos']      = (float) ($materia['creditos'] ?? 0);
            $materia['curso']         = (int) ($materia['curso'] ?? $curso);
            $materia['semestre_global'] = (int) ($materia['semestre_global'] ?? 0);
            $materia['semestre']      = $materia['semestre_global'] > 0
                ? self::semestreEnCurso($materia['semestre_global'])
                : (int) ($materia['semestre'] ?? $semestre);
        }
        unset($materia);

        return [
            'alumno'          => $alumno,
            'malla'           => $malla,
            'curso'           => $curso,
            'semestre'        => $semestre,
            'semestre_global' => $semestreGlobal,
            'materias'        => $materias,
            'cursos'          => $cursos,
            'division'        => $division,
            'total_horas'     => array_sum(array_map(static fn (array $m): int => (int) $m['horas_catedra'], $materias)),
            'total_creditos'  => array_sum(array_map(static fn (array $m): float => (float) $m['creditos'], $materias)),
            'aprobadas'       => count($this->matriculaMaterias->aprobadas($idAlumno)),
            'id_periodo'      => $idPeriodo,
            'id_sede'         => $idSede,
            'id_matricula'    => (int) ($matricula['id_matricula'] ?? 0),
            'inscritas'       => $inscritas,
        ];
    }

    /** Programas de la malla del alumno ordenados por curso y semestre. */
    public function mallaCompleta(int $idCarrera): array
    {
        $malla = $this->mallas->vigenteDeCarrera($idCarrera);

        return $malla === null
            ? ['malla' => null, 'cursos' => [], 'total_materias' => 0]
            : [
                'malla'          => $malla,
                'cursos'         => $this->materias->agrupadas((int) $malla['id_malla']),
                'total_materias' => $this->materias->deMalla((int) $malla['id_malla']) === []
                    ? 0
                    : count($this->materias->deMalla((int) $malla['id_malla'])),
            ];
    }

    /** Avance del alumno sobre la malla vigente. */
    public function avance(int $idAlumno): array
    {
        $alumno = $this->alumnos->conDetalle($idAlumno);
        if ($alumno === null || (int) ($alumno['id_carrera'] ?? 0) === 0) {
            return ['total' => 0, 'aprobadas' => 0, 'porcentaje' => 0.0, 'creditos' => 0.0, 'creditos_total' => 0.0];
        }

        $idCarrera = (int) $alumno['id_carrera'];
        $malla     = $this->mallas->vigenteDeCarrera($idCarrera);
        $total     = $malla !== null ? count($this->materias->deMalla((int) $malla['id_malla'])) : 0;
        $aprobadas = $this->matriculaMaterias->aprobadas($idAlumno);

        $creditos      = array_sum(array_map(static fn (array $m): float => (float) $m['creditos'], $aprobadas));
        $creditosTotal = 0.0;
        if ($malla !== null) {
            foreach ($this->materias->deMalla((int) $malla['id_malla']) as $materia) {
                $creditosTotal += (float) $materia['creditos'];
            }
        }

        return [
            'total'          => $total,
            'aprobadas'      => count($aprobadas),
            'porcentaje'     => $total > 0 ? round(count($aprobadas) * 100 / $total, 1) : 0.0,
            'creditos'       => round($creditos, 2),
            'creditos_total' => round($creditosTotal, 2),
        ];
    }

    /** @return array<string, mixed> */
    private function planVacio(?array $alumno = null, int $idPeriodo = 0, int $idSede = 0): array
    {
        return [
            'alumno'          => $alumno ?? [],
            'malla'           => null,
            'curso'           => 1,
            'semestre'        => 1,
            'semestre_global' => 1,
            'materias'        => [],
            'cursos'          => [],
            'division'        => null,
            'total_horas'     => 0,
            'total_creditos'  => 0.0,
            'aprobadas'       => 0,
            'id_periodo'      => $idPeriodo,
            'id_sede'         => $idSede,
            'id_matricula'    => 0,
            'inscritas'       => false,
        ];
    }
}
