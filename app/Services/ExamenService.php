<?php

namespace App\Services;

use App\Core\Database;
use App\Core\Logger;
use App\Models\Examen;
use App\Models\InscripcionExamen;
use RuntimeException;

/**
 * Logica de inscripcion y gestion de examenes.
 */
class ExamenService
{
    private Examen $examenes;
    private InscripcionExamen $inscripciones;
    private ObligacionService $obligaciones;
    private NotificacionService $notificaciones;

    public function __construct()
    {
        $this->examenes       = new Examen();
        $this->inscripciones  = new InscripcionExamen();
        $this->obligaciones   = new ObligacionService();
        $this->notificaciones = new NotificacionService();
    }

    public function disponibles(int $idAlumno): array
    {
        $alumno = Database::instancia()->consulta('SELECT id_carrera FROM alumnos WHERE id_alumno = ?', [$idAlumno])->obtener();
        $periodo = (new \App\Models\Periodo())->actual();

        $examenes = $this->examenes->disponibles([
            'id_carrera' => $alumno['id_carrera'] ?? null,
            'id_periodo' => $periodo['id_periodo'] ?? null,
        ]);

        // Marcar los que ya estan inscriptos y el estado de la ventana de examenes
        $ventanas = new VentanaService();

        foreach ($examenes as &$examen) {
            $examen['ya_inscripto'] = $this->inscripciones->yaInscripto((int) $examen['id_examen'], $idAlumno) !== null;
            $examen['inscripcion_abierta'] = $this->dentroDePlazo($examen);
            $examen['cupo_disponible']     = ((int) $examen['cupos_libres']) > 0;

            $estado = $ventanas->evaluar(
                'Examen',
                isset($examen['id_periodo']) ? (int) $examen['id_periodo'] : null,
                isset($examen['id_carrera']) ? (int) $examen['id_carrera'] : null,
                isset($examen['id_sede']) ? (int) $examen['id_sede'] : null,
                (float) $examen['monto']
            );

            $examen['ventana']         = $estado;
            $examen['ventana_estado']  = $estado['estado'];
            $examen['ventana_etiqueta'] = $estado['etiqueta'];
            $examen['ventana_mensaje'] = $estado['mensaje'];
            $examen['ventana_cierre']  = $estado['fecha_cierre'];
            $examen['recargo']         = $estado['recargo'];
            $examen['monto_con_recargo'] = round((float) $examen['monto'] + $estado['recargo'], 2);
            $examen['puede_inscribirse'] = $examen['inscripcion_abierta']
                && $examen['cupo_disponible']
                && !$examen['ya_inscripto']
                && $estado['ok'];
        }
        unset($examen);

        return $examenes;
    }

    /** Estado de la ventana de examenes para un periodo, carrera y sede. */
    public function ventana(?int $idPeriodo, ?int $idCarrera = null, ?int $idSede = null): array
    {
        return (new VentanaService())->evaluar('Examen', $idPeriodo, $idCarrera, $idSede);
    }

    public function dentroDePlazo(array $examen): bool
    {
        if (strcasecmp((string) $examen['estado'], 'Inscripcion abierta') !== 0 && strcasecmp((string) $examen['estado'], 'Programado') !== 0) {
            return false;
        }
        if (!empty($examen['fecha_limite_insc']) && strtotime((string) $examen['fecha_limite_insc']) < strtotime('today')) {
            return false;
        }
        return true;
    }

    /**
     * Inscribe al alumno en un examen y genera la obligacion de pago.
     *
     * @return array{ok: bool, mensaje: string, id_inscripcion?: int, id_obligacion?: int, monto?: float}
     */
    public function inscribir(int $idAlumno, int $idExamen, array $datos = []): array
    {
        $examen = $this->examenes->conDetalle($idExamen);
        if ($examen === null) {
            return ['ok' => false, 'mensaje' => 'El examen seleccionado no existe.'];
        }
        if (!$this->dentroDePlazo($examen)) {
            return ['ok' => false, 'mensaje' => 'El plazo de inscripción para este examen está cerrado.'];
        }
        if ((int) $examen['cupos_libres'] <= 0) {
            return ['ok' => false, 'mensaje' => 'No quedan cupos disponibles para este examen.'];
        }
        if ($this->inscripciones->yaInscripto($idExamen, $idAlumno) !== null) {
            return ['ok' => false, 'mensaje' => 'Ya estás inscripto en este examen.'];
        }

        // La ventana de examenes define el plazo de inscripcion y de pago.
        $ventana = (new VentanaService())->evaluar(
            'Examen',
            isset($examen['id_periodo']) ? (int) $examen['id_periodo'] : null,
            isset($examen['id_carrera']) ? (int) $examen['id_carrera'] : null,
            isset($examen['id_sede']) ? (int) $examen['id_sede'] : null,
            (float) $examen['monto']
        );

        if (!$ventana['ok']) {
            return ['ok' => false, 'mensaje' => $ventana['mensaje'], 'ventana' => $ventana];
        }

        $recargo = (float) ($ventana['recargo'] ?? 0);

        // Impedir choque de horarios el mismo dia
        $choque = Database::instancia()->consulta(
            'SELECT e.nombre, e.fecha_examen, e.hora_inicio
               FROM inscripciones_examen ie
               INNER JOIN examenes e ON e.id_examen = ie.id_examen
              WHERE ie.id_alumno = ? AND ie.estado <> "Anulado" AND e.fecha_examen = ?',
            [$idAlumno, $examen['fecha_examen']]
        )->obtener();

        if ($choque !== null && empty($datos['permitir_choque'])) {
            return [
                'ok'      => false,
                'mensaje' => 'Ya tenés otro examen el mismo día (' . $choque['nombre'] . ' a las ' . substr((string) $choque['hora_inicio'], 0, 5) . '). Verificá antes de inscribirte.',
            ];
        }

        $idInscripcion = 0;
        $idObligacion  = 0;
        $monto         = (float) $examen['monto'];

        Database::instancia()->transaccion(function () use (
            &$idInscripcion, &$idObligacion, $idAlumno, $examen, $idExamen, $datos, $monto, $recargo
        ) {
            $idInscripcion = $this->inscripciones->crear([
                'id_examen'         => $idExamen,
                'id_alumno'         => $idAlumno,
                'fecha_inscripcion' => date('Y-m-d H:i:s'),
                'estado'            => (int) $examen['requiere_pago'] === 1 && $monto > 0 ? 'Pendiente' : 'Habilitado',
                'condicion'         => $datos['condicion'] ?? 'Regular',
                'observaciones'     => $datos['observaciones'] ?? null,
            ]);

            if ((int) $examen['requiere_pago'] === 1 && $monto > 0) {
                $idObligacion = $this->obligaciones->obligacionExamen(
                    $idAlumno,
                    $examen,
                    $idInscripcion,
                    isset($examen['id_periodo']) ? (int) $examen['id_periodo'] : null,
                    $recargo
                );

                $fila = Database::instancia()->consulta('SELECT monto_final FROM obligaciones_pago WHERE id_obligacion = ?', [$idObligacion])->obtener();
                $monto = (float) ($fila['monto_final'] ?? $monto);

                $this->inscripciones->actualizar($idInscripcion, ['id_obligacion' => $idObligacion]);
            }

            $this->examenes->sincronizarInscritos($idExamen);
        });

        $this->notificaciones->enviarAAlumno(
            $idAlumno,
            'Inscripción a examen registrada',
            'Te inscribiste en "' . $examen['nombre'] . '". '
                . ($idObligacion > 0 ? 'Generamos una obligación de pago por ' . dinero($monto)
                    . ($recargo > 0 ? ' (incluye recargo por inscripción fuera de plazo)' : '') . '.' : 'Tu inscripción quedó habilitada.')
                . ' Podés abonarla hasta el ' . fecha((string) ($ventana['fecha_cierre'] ?? date('Y-m-d'))) . '.',
            'info',
            '/examenes/mis-inscripciones'
        );

        Logger::registrar('inscripcion_examen', 'Inscripción al examen #' . $idExamen, 'examenes', 'info', [
            'id_inscripcion' => $idInscripcion,
            'id_obligacion'  => $idObligacion,
            'recargo'        => $recargo,
        ]);

        return [
            'ok'             => true,
            'mensaje'        => $idObligacion > 0
                ? 'Inscripción registrada. Ya podés pagar el derecho de examen hasta el '
                    . fecha((string) ($ventana['fecha_cierre'] ?? date('Y-m-d'))) . '.'
                : 'Inscripción registrada correctamente.',
            'id_inscripcion' => $idInscripcion,
            'id_obligacion'  => $idObligacion,
            'monto'          => $monto,
            'recargo'        => $recargo,
            'ventana'        => $ventana,
        ];
    }

    public function cancelar(int $idInscripcion, int $idAlumno, string $motivo = ''): array
    {
        $inscripcion = $this->inscripciones->conDetalle($idInscripcion);
        if ($inscripcion === null || (int) $inscripcion['id_alumno'] !== $idAlumno) {
            return ['ok' => false, 'mensaje' => 'No encontramos esa inscripción.'];
        }
        if (in_array($inscripcion['estado'], ['Rendido', 'Anulado'], true)) {
            return ['ok' => false, 'mensaje' => 'Esta inscripción ya no puede cancelarse.'];
        }
        if ($inscripcion['estado_pago'] === 'Aprobado') {
            return ['ok' => false, 'mensaje' => 'Ya pagaste este examen. Para cancelar la inscripción contactá con la secretaría.'];
        }

        Database::instancia()->transaccion(function () use ($idInscripcion, $inscripcion, $motivo) {
            $this->inscripciones->actualizar($idInscripcion, [
                'estado'        => 'Anulado',
                'observaciones' => $motivo !== '' ? $motivo : 'Cancelada por el alumno',
            ]);

            if (!empty($inscripcion['id_obligacion'])) {
                $this->obligaciones->anular((int) $inscripcion['id_obligacion'], 'Inscripción a examen cancelada');
            }

            $this->examenes->sincronizarInscritos((int) $inscripcion['id_examen']);
        });

        Logger::registrar('inscripcion_examen_cancelada', 'Inscripción #' . $idInscripcion . ' cancelada', 'examenes', 'warning');

        return ['ok' => true, 'mensaje' => 'Inscripción cancelada.'];
    }

    public function registrarNotas(int $idExamen, array $notas, ?int $idUsuario = null): array
    {
        $examen = $this->examenes->buscar($idExamen);
        if ($examen === null) {
            return ['ok' => false, 'mensaje' => 'El examen no existe.'];
        }

        $actualizadas = 0;

        Database::instancia()->transaccion(function () use ($notas, &$actualizadas) {
            foreach ($notas as $idInscripcion => $nota) {
                if ($nota === '' || $nota === null) {
                    continue;
                }
                $valor = (float) str_replace(',', '.', (string) $nota);
                $estado = $valor >= 2 ? 'Rendido' : 'Ausente';

                $this->inscripciones->actualizar((int) $idInscripcion, [
                    'nota'   => $valor,
                    'estado' => $estado,
                ]);
                $actualizadas++;

                $inscripcion = $this->inscripciones->buscar((int) $idInscripcion);
                if ($inscripcion !== null) {
                    $this->notificaciones->enviarAAlumno(
                        (int) $inscripcion['id_alumno'],
                        'Calificación registrada',
                        'Se registró tu nota del examen: ' . number_format($valor, 1, ',', '.') . ' (' . $estado . ').',
                        $valor >= 2 ? 'exito' : 'advertencia',
                        '/examenes/mis-inscripciones'
                    );
                }
            }
        });

        Logger::registrar('notas_registradas', $actualizadas . ' nota(s) registradas en el examen #' . $idExamen, 'examenes', 'info', ['id_usuario' => $idUsuario]);

        return ['ok' => true, 'mensaje' => $actualizadas . ' calificación(es) guardada(s).'];
    }

    public function estadisticas(): array
    {
        $db = Database::instancia();

        return [
            'programados' => $db->consulta('SELECT COUNT(*) FROM examenes WHERE fecha_examen >= CURDATE()')->entero(),
            'inscripciones' => $db->consulta('SELECT COUNT(*) FROM inscripciones_examen WHERE estado <> "Anulado"')->entero(),
            'pendientes_pago' => $db->consulta('SELECT COUNT(*) FROM inscripciones_examen WHERE estado = "Pendiente"')->entero(),
            'rendidos' => $db->consulta('SELECT COUNT(*) FROM inscripciones_examen WHERE estado = "Rendido"')->entero(),
        ];
    }
}
