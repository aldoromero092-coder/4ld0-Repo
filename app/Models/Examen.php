<?php

namespace App\Models;

use App\Core\Model;

class Examen extends Model
{
    protected string $tabla = 'examenes';
    protected string $clavePrimaria = 'id_examen';

    protected array $asignables = [
        'nombre', 'materia', 'tipo', 'id_periodo', 'id_carrera', 'id_facultades', 'id_sede',
        'id_concepto_pago', 'monto', 'fecha_examen', 'hora_inicio', 'duracion_min', 'aula',
        'cupo_maximo', 'inscritos', 'fecha_limite_insc', 'requiere_pago', 'estado',
    ];

    private const SELECT_BASE = 'SELECT e.*, p.nombre AS periodo_nombre, c.nombre AS carrera_nombre,
                    f.nombre AS facultad_nombre, s.nombre AS sede_nombre,
                    cp.nombre AS concepto_nombre,
                    GREATEST(0, e.cupo_maximo - (SELECT COUNT(*) FROM inscripciones_examen ie
                                                  WHERE ie.id_examen = e.id_examen AND ie.estado <> "Anulado")) AS cupos_libres,
                    (SELECT COUNT(*) FROM inscripciones_examen ie
                      WHERE ie.id_examen = e.id_examen AND ie.estado <> "Anulado") AS total_inscriptos
               FROM examenes e
               LEFT JOIN periodos_academicos p ON p.id_periodo = e.id_periodo
               LEFT JOIN carreras c            ON c.id_carrera = e.id_carrera
               LEFT JOIN facultades f          ON f.id_facultades = e.id_facultades
               LEFT JOIN sedes s               ON s.id_sede = e.id_sede
               LEFT JOIN conceptos_pago cp     ON cp.id_concepto_pago = e.id_concepto_pago';

    public function conDetalle(int $id): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE e.id_examen = ? LIMIT 1', [$id])->obtener();
    }

    /** Examenes con inscripcion abierta. */
    public function disponibles(array $filtros = []): array
    {
        $condiciones = ['e.estado IN ("Programado","Inscripcion abierta")', 'e.fecha_examen >= CURDATE()'];
        $parametros  = [];

        if (!empty($filtros['id_periodo'])) {
            $condiciones[]          = 'e.id_periodo = :id_periodo';
            $parametros['id_periodo'] = (int) $filtros['id_periodo'];
        }
        if (!empty($filtros['id_carrera'])) {
            $condiciones[]          = '(e.id_carrera = :id_carrera OR e.id_carrera IS NULL)';
            $parametros['id_carrera'] = (int) $filtros['id_carrera'];
        }
        if (!empty($filtros['tipo'])) {
            $condiciones[]      = 'e.tipo = :tipo';
            $parametros['tipo'] = $filtros['tipo'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(e.nombre LIKE :buscar OR e.materia LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        return $this->sql(
            self::SELECT_BASE . ' WHERE ' . implode(' AND ', $condiciones) . ' ORDER BY e.fecha_examen, e.hora_inicio',
            $parametros
        )->obtenerTodo();
    }

    public function listar(array $filtros = [], int $limite = 20, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtros($filtros);
        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            self::SELECT_BASE . " {$where} ORDER BY e.fecha_examen DESC, e.hora_inicio
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        [$where, $parametros] = $this->filtros($filtros);
        return $this->sql('SELECT COUNT(*) FROM examenes e ' . $where, $parametros)->entero();
    }

    private function filtros(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        foreach (['estado', 'tipo', 'id_periodo', 'id_carrera', 'id_sede'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "e.`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(e.nombre LIKE :buscar OR e.materia LIKE :buscar OR e.aula LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'e.fecha_examen >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'e.fecha_examen <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    public function sincronizarInscritos(int $idExamen): void
    {
        $this->sql(
            'UPDATE examenes
                SET inscritos = (SELECT COUNT(*) FROM inscripciones_examen ie
                                  WHERE ie.id_examen = examenes.id_examen AND ie.estado <> "Anulado")
              WHERE id_examen = ?',
            [$idExamen]
        );
    }

    public function proximos(int $limite = 5): array
    {
        return $this->sql(
            self::SELECT_BASE . ' WHERE e.fecha_examen >= CURDATE() ORDER BY e.fecha_examen LIMIT ' . (int) $limite
        )->obtenerTodo();
    }

    public function tipos(): array
    {
        return $this->sql('SELECT DISTINCT tipo FROM examenes ORDER BY tipo')->lista('tipo');
    }
}
