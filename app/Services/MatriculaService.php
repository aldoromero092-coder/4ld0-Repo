<?php

namespace App\Services;

use App\Core\Database;
use App\Core\Logger;
use App\Models\Alumno;
use App\Models\CursoAcademico;
use App\Models\Matricula;
use App\Models\MatriculaMateria;
use App\Models\Periodo;
use RuntimeException;

/**
 * Logica del proceso de matriculacion.
 */
class MatriculaService
{
    private Matricula $matriculas;
    private Alumno $alumnos;
    private Periodo $periodos;
    private ObligacionService $obligaciones;
    private NotificacionService $notificaciones;
    private VentanaService $ventanas;
    private MallaService $malla;
    private MatriculaMateria $matriculaMaterias;
    private CursoAcademico $cursos;

    public function __construct()
    {
        $this->matriculas        = new Matricula();
        $this->alumnos           = new Alumno();
        $this->periodos          = new Periodo();
        $this->obligaciones      = new ObligacionService();
        $this->notificaciones    = new NotificacionService();
        $this->ventanas          = new VentanaService();
        $this->malla             = new MallaService();
        $this->matriculaMaterias = new MatriculaMateria();
        $this->cursos            = new CursoAcademico();
    }

    public function abierta(): bool
    {
        return (bool) (int) config_dinamica('matricula_online_activa', 1);
    }

    /** Ventana de matriculacion vigente para una carrera, periodo y sede. */
    public function ventana(int $idPeriodo, int $idCarrera, ?int $idSede = null): array
    {
        return $this->ventanas->evaluar('Matricula', $idPeriodo, $idCarrera, $idSede);
    }

    /**
     * Registra la solicitud de matricula del alumno y genera su obligacion de pago.
     *
     * @param array $datos Puede incluir id_carrera, id_sede, turno, modalidad,
     *                     documentacion_ok, observaciones, id_usuario y
     *                     materias (array de id_materia seleccionados).
     * @return array{ok: bool, mensaje: string, id_matricula?: int, id_obligacion?: int, monto?: float}
     */
    public function solicitar(int $idAlumno, int $idPeriodo, array $datos = []): array
    {
        if (!$this->abierta()) {
            return ['ok' => false, 'mensaje' => 'La matriculación en línea está cerrada en este momento. Acercate a la secretaría.'];
        }

        $alumno = $this->alumnos->conDetalle($idAlumno);
        if ($alumno === null) {
            return ['ok' => false, 'mensaje' => 'No encontramos tu legajo de alumno.'];
        }

        $periodo = $this->periodos->buscar($idPeriodo);
        if ($periodo === null) {
            return ['ok' => false, 'mensaje' => 'El periodo seleccionado no existe.'];
        }
        if (strcasecmp((string) $periodo['estado'], 'Activo') !== 0) {
            return ['ok' => false, 'mensaje' => 'Solo se puede matricular en el periodo activo. Periodo actual: ' . ($this->periodos->actual()['nombre'] ?? 'ninguno') . '.'];
        }

        $idCarrera  = (int) ($datos['id_carrera'] ?? $alumno['id_carrera'] ?? 0);
        $idFacultad = (int) ($alumno['id_facultades'] ?? 0);
        $idSede     = (int) ($datos['id_sede'] ?? $alumno['id_sede'] ?? 0);

        if ($idCarrera <= 0) {
            return ['ok' => false, 'mensaje' => 'Necesitás tener una carrera asignada para matricularte.'];
        }

        // La ventana academica define si la matriculacion esta habilitada.
        $ventana = $this->ventana($idPeriodo, $idCarrera, $idSede);
        if (!$ventana['ok']) {
            return ['ok' => false, 'mensaje' => $ventana['mensaje'], 'ventana' => $ventana];
        }

        if ($this->matriculas->activaDeAlumno($idAlumno, $idPeriodo) !== null) {
            return ['ok' => false, 'mensaje' => 'Ya tenés una matrícula registrada para este periodo.'];
        }

        $plan  = $this->malla->planDeAlumno($idAlumno, $idPeriodo, $idSede);
        $malla = $plan['malla'];
        if ($malla === null) {
            return ['ok' => false, 'mensaje' => 'Tu carrera todavía no tiene una malla curricular cargada. Acercate a secretaría.'];
        }

        // Materias a inscribir: las elegidas o, si no se envio ninguna, todas
        // las del curso y semestre que le corresponden.
        $seleccion = $this->resolverMaterias($plan, $datos['materias'] ?? null);
        if ($seleccion === []) {
            return ['ok' => false, 'mensaje' => 'No hay materias disponibles para inscribir en tu curso y semestre. Verificá la malla con secretaría.'];
        }

        $idDivision = isset($plan['division']['id_curso']) ? (int) $plan['division']['id_curso'] : 0;
        if ($idDivision > 0 && $this->cursos->cuposLibres($idDivision) <= 0) {
            return ['ok' => false, 'mensaje' => 'La división asignada a tu curso y semestre ya no tiene cupos. Contactá con secretaría.'];
        }

        $numero       = $this->matriculas->siguienteNumero($idPeriodo);
        $recargo      = (float) ($ventana['recargo'] ?? 0);
        $idMatricula  = 0;
        $idObligacion = 0;
        $monto        = 0.0;

        Database::instancia()->transaccion(function () use (
            &$idMatricula, &$idObligacion, &$monto, $idAlumno, $idPeriodo, $idCarrera,
            $idFacultad, $idSede, $numero, $alumno, $datos, $malla, $plan, $seleccion, $recargo, $idDivision
        ) {
            $idMatricula = $this->matriculas->crear([
                'numero_matricula' => $numero,
                'id_alumno'        => $idAlumno,
                'id_periodo'       => $idPeriodo,
                'id_carrera'       => $idCarrera,
                'id_facultades'    => $idFacultad ?: null,
                'id_sede'          => $idSede ?: null,
                'id_malla'         => (int) $malla['id_malla'],
                'id_curso'         => $idDivision > 0 ? $idDivision : null,
                'curso'            => (int) $plan['curso'],
                'semestre'         => (int) $plan['semestre_global'],
                'turno'            => $datos['turno'] ?? $alumno['turno'] ?? 'Noche',
                'modalidad'        => $datos['modalidad'] ?? $alumno['modalidad'] ?? 'Presencial',
                'fecha_solicitud'  => date('Y-m-d H:i:s'),
                'estado'           => 'Pendiente',
                'documentacion_ok' => !empty($datos['documentacion_ok']) ? 1 : 0,
                'total_materias'   => count($seleccion),
                'total_creditos'   => array_sum(array_map(static fn (array $m): float => (float) $m['creditos'], $seleccion)),
                'observaciones'    => $datos['observaciones'] ?? null,
                'id_usuario_gestion' => $datos['id_usuario'] ?? null,
            ]);

            $this->matriculaMaterias->reemplazar($idMatricula, $seleccion);

            $idObligacion = $this->obligaciones->obligacionMatricula(
                $idAlumno,
                $idPeriodo,
                $idCarrera,
                $idMatricula,
                $numero,
                $recargo
            );

            $obligacion = Database::instancia()->consulta('SELECT monto_final FROM obligaciones_pago WHERE id_obligacion = ?', [$idObligacion])->obtener();
            $monto      = (float) ($obligacion['monto_final'] ?? 0);

            $this->matriculas->actualizar($idMatricula, [
                'id_obligacion'   => $idObligacion,
                'monto_matricula' => $monto,
            ]);

            if ($idDivision > 0) {
                $this->cursos->sincronizarMatriculados($idDivision);
            }
        });

        $this->notificaciones->enviarAAlumno(
            $idAlumno,
            'Matrícula registrada',
            'Tu solicitud de matrícula ' . $numero . ' fue registrada con ' . count($seleccion)
                . ' materia(s). Generamos una obligación de pago por ' . dinero($monto)
                . ($recargo > 0 ? ' (incluye recargo por matrícula fuera de plazo)' : '') . '.',
            'info',
            '/matriculas/detalle/' . $idMatricula
        );

        Logger::registrar('matricula_solicitada', 'Matrícula ' . $numero . ' solicitada', 'matriculas', 'info', [
            'id_matricula'  => $idMatricula,
            'id_obligacion' => $idObligacion,
            'materias'      => count($seleccion),
            'recargo'       => $recargo,
        ]);

        return [
            'ok'            => true,
            'mensaje'       => 'Matrícula registrada con ' . count($seleccion) . ' materia(s). Ya podés pagar la obligación generada.',
            'id_matricula'  => $idMatricula,
            'id_obligacion' => $idObligacion,
            'monto'         => $monto,
            'numero'        => $numero,
            'materias'      => count($seleccion),
            'creditos'      => array_sum(array_map(static fn (array $m): float => (float) $m['creditos'], $seleccion)),
            'recargo'       => $recargo,
            'ventana'       => $ventana,
        ];
    }

    /**
     * Devuelve las materias que se van a inscribir.
     *
     * @param array<int>|null $idsSeleccionados
     * @return array<int, array>
     */
    private function resolverMaterias(array $plan, ?array $idsSeleccionados): array
    {
        $disponibles = [];
        foreach ($plan['materias'] as $materia) {
            $disponibles[(int) $materia['id_materia']] = $materia;
        }

        if ($idsSeleccionados === null || $idsSeleccionados === []) {
            return array_values($disponibles);
        }

        $seleccion = [];
        foreach ($idsSeleccionados as $id) {
            $id = (int) $id;
            if (isset($disponibles[$id])) {
                $seleccion[] = $disponibles[$id];
            }
        }

        return $seleccion;
    }

    public function confirmar(int $idMatricula, ?int $idUsuario = null): array
    {
        $matricula = $this->matriculas->buscar($idMatricula);
        if ($matricula === null) {
            return ['ok' => false, 'mensaje' => 'La matrícula no existe.'];
        }
        if ($matricula['estado'] === 'Confirmada') {
            return ['ok' => false, 'mensaje' => 'La matrícula ya estaba confirmada.'];
        }

        $this->matriculas->actualizar($idMatricula, [
            'estado'              => 'Confirmada',
            'fecha_confirmacion'  => date('Y-m-d H:i:s'),
            'documentacion_ok'    => 1,
            'id_usuario_gestion'  => $idUsuario,
        ]);

        $this->notificaciones->enviarAAlumno(
            (int) $matricula['id_alumno'],
            'Matrícula confirmada',
            'Tu matrícula ' . $matricula['numero_matricula'] . ' fue confirmada por la secretaría.',
            'exito',
            '/matriculas/detalle/' . $idMatricula
        );

        Logger::auditar('matriculas', (string) $idMatricula, 'CONFIRMAR', $matricula, ['id_usuario' => $idUsuario]);

        return ['ok' => true, 'mensaje' => 'Matrícula confirmada.'];
    }

    public function rechazar(int $idMatricula, string $motivo, ?int $idUsuario = null): array
    {
        $matricula = $this->matriculas->buscar($idMatricula);
        if ($matricula === null) {
            return ['ok' => false, 'mensaje' => 'La matrícula no existe.'];
        }
        if ($matricula['estado'] === 'Confirmada') {
            return ['ok' => false, 'mensaje' => 'No se puede rechazar una matrícula ya confirmada. Anulala primero.'];
        }

        $this->matriculas->actualizar($idMatricula, [
            'estado'             => 'Rechazada',
            'observaciones'      => $motivo,
            'id_usuario_gestion' => $idUsuario,
        ]);

        if (!empty($matricula['id_obligacion'])) {
            $this->obligaciones->anular((int) $matricula['id_obligacion'], 'Matrícula rechazada: ' . $motivo);
        }

        $this->notificaciones->enviarAAlumno(
            (int) $matricula['id_alumno'],
            'Matrícula rechazada',
            'Tu matrícula ' . $matricula['numero_matricula'] . ' fue rechazada. Motivo: ' . $motivo,
            'error',
            '/matriculas/detalle/' . $idMatricula
        );

        Logger::auditar('matriculas', (string) $idMatricula, 'RECHAZAR', $matricula, ['motivo' => $motivo]);

        return ['ok' => true, 'mensaje' => 'Matrícula rechazada.'];
    }

    public function anular(int $idMatricula, string $motivo): array
    {
        $matricula = $this->matriculas->conDetalle($idMatricula);
        if ($matricula === null) {
            return ['ok' => false, 'mensaje' => 'La matrícula no existe.'];
        }
        if (($matricula['obligacion_estado'] ?? '') === 'Pagado') {
            return ['ok' => false, 'mensaje' => 'No se puede anular una matrícula cuyo pago ya fue acreditado. Solicitá la devolución en secretaría.'];
        }

        Database::instancia()->transaccion(function () use ($idMatricula, $matricula, $motivo) {
            $this->matriculas->actualizar($idMatricula, ['estado' => 'Anulada', 'observaciones' => $motivo]);

            if (!empty($matricula['id_obligacion'])) {
                $this->obligaciones->anular((int) $matricula['id_obligacion'], 'Matrícula anulada: ' . $motivo);
            }

            Logger::auditar('matriculas', (string) $idMatricula, 'ANULAR', $matricula, ['motivo' => $motivo]);
        });

        return ['ok' => true, 'mensaje' => 'Matrícula anulada.'];
    }

    public function puedeMatricularse(int $idAlumno): array
    {
        $periodo = $this->periodos->actual();

        if ($periodo === null) {
            return ['ok' => false, 'mensaje' => 'No hay ningún periodo académico activo.'];
        }
        if (!$this->abierta()) {
            return ['ok' => false, 'mensaje' => 'La matriculación en línea está cerrada.'];
        }
        if ($this->matriculas->activaDeAlumno($idAlumno, (int) $periodo['id_periodo']) !== null) {
            return ['ok' => false, 'mensaje' => 'Ya estás matriculado en el periodo ' . $periodo['nombre'] . '.', 'periodo' => $periodo];
        }

        $alumno  = $this->alumnos->conDetalle($idAlumno);
        $ventana = $this->ventana(
            (int) $periodo['id_periodo'],
            (int) ($alumno['id_carrera'] ?? 0),
            (int) ($alumno['id_sede'] ?? 0)
        );

        if (!$ventana['ok']) {
            return [
                'ok'      => false,
                'mensaje' => $ventana['mensaje'],
                'periodo' => $periodo,
                'ventana' => $ventana,
            ];
        }

        $plan = $this->malla->planDeAlumno($idAlumno, (int) $periodo['id_periodo']);

        if ($plan['malla'] === null || $plan['materias'] === []) {
            return [
                'ok'      => false,
                'mensaje' => 'Tu carrera todavía no tiene materias cargadas para el curso y semestre que te corresponden.',
                'periodo' => $periodo,
            ];
        }

        $deuda = (float) Database::instancia()->consulta(
            'SELECT COALESCE(SUM(saldo),0) FROM obligaciones_pago
              WHERE id_alumno = ? AND estado IN ("Pendiente","Vencido") AND fecha_vencimiento < CURDATE()',
            [$idAlumno]
        )->decimal();

        if ($deuda > 0) {
            return [
                'ok'      => false,
                'mensaje' => 'Tenés obligaciones vencidas por ' . dinero($deuda) . '. Regularizá tu situación para matricularte.',
                'deuda'   => $deuda,
                'periodo' => $periodo,
            ];
        }

        return [
            'ok'      => true,
            'mensaje' => 'Podés matricularte.',
            'periodo' => $periodo,
            'ventana' => $ventana,
            'plan'    => $plan,
        ];
    }

    public function estadisticas(?int $idPeriodo = null): array
    {
        return $this->matriculas->estadisticas($idPeriodo);
    }
}
