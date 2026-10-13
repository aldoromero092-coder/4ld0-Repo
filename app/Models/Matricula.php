<?php

namespace App\Models;

use App\Core\Model;

class Matricula extends Model
{
    protected string $tabla = 'matriculas';
    protected string $clavePrimaria = 'id_matricula';

    protected array $asignables = [
        'numero_matricula', 'id_alumno', 'id_periodo', 'id_carrera', 'id_facultades',
        'id_sede', 'semestre', 'turno', 'modalidad', 'id_obligacion', 'id_pago',
        'monto_matricula', 'fecha_solicitud', 'fecha_confirmacion', 'estado',
        'documentacion_ok', 'observaciones', 'id_usuario_gestion',
        'id_malla', 'id_curso', 'curso', 'total_materias', 'total_creditos',
    ];

    private const SELECT_BASE = 'SELECT m.*, per.cedula, CONCAT(per.apellidos, ", ", per.nombres) AS alumno,
                    per.telefono, per.celular, per.email, a.legajo,
                    c.nombre AS carrera_nombre, c.codigo_carrera,
                    f.nombre AS facultad_nombre, s.nombre AS sede_nombre,
                    p.nombre AS periodo_nombre, p.fecha_inicio, p.fecha_fin,
                    o.descripcion AS obligacion_descripcion, o.monto_final AS obligacion_monto,
                    o.saldo AS obligacion_saldo, o.estado AS obligacion_estado,
                    o.fecha_vencimiento AS obligacion_vence
               FROM matriculas m
               INNER JOIN alumnos a        ON a.id_alumno = m.id_alumno
               INNER JOIN personas per     ON per.id_persona = a.id_persona
               LEFT JOIN carreras c        ON c.id_carrera = m.id_carrera
               LEFT JOIN facultades f      ON f.id_facultades = m.id_facultades
               LEFT JOIN sedes s           ON s.id_sede = m.id_sede
               LEFT JOIN periodos_academicos p ON p.id_periodo = m.id_periodo
               LEFT JOIN obligaciones_pago o   ON o.id_obligacion = m.id_obligacion';

    public function conDetalle(int $id): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE m.id_matricula = ? LIMIT 1', [$id])->obtener();
    }

    public function deAlumno(int $idAlumno, ?int $idPeriodo = null): array
    {
        $sql    = self::SELECT_BASE . ' WHERE m.id_alumno = ?';
        $params = [$idAlumno];

        if ($idPeriodo !== null) {
            $sql     .= ' AND m.id_periodo = ?';
            $params[] = $idPeriodo;
        }

        return $this->sql($sql . ' ORDER BY m.fecha_solicitud DESC', $params)->obtenerTodo();
    }

    public function activaDeAlumno(int $idAlumno, int $idPeriodo): ?array
    {
        return $this->sql(
            self::SELECT_BASE . ' WHERE m.id_alumno = ? AND m.id_periodo = ? AND m.estado <> "Anulada" LIMIT 1',
            [$idAlumno, $idPeriodo]
        )->obtener();
    }

    public function listar(array $filtros = [], int $limite = 15, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtros($filtros);
        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            self::SELECT_BASE . " {$where}
              ORDER BY m.fecha_solicitud DESC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        [$where, $parametros] = $this->filtros($filtros);
        return $this->sql(
            "SELECT COUNT(*) FROM matriculas m
               INNER JOIN alumnos a ON a.id_alumno = m.id_alumno
               INNER JOIN personas per ON per.id_persona = a.id_persona
               {$where}",
            $parametros
        )->entero();
    }

    private function filtros(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        foreach (['estado', 'id_periodo', 'id_carrera', 'id_sede'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "m.`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(per.cedula LIKE :buscar OR per.nombres LIKE :buscar OR per.apellidos LIKE :buscar
                                     OR a.legajo LIKE :buscar OR m.numero_matricula LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    public function siguienteNumero(int $idPeriodo): string
    {
        $periodo = (new Periodo())->buscar($idPeriodo);
        $etiqueta = $periodo !== null
            ? preg_replace('/[^0-9]/', '', (string) $periodo['nombre'])
            : date('Y');

        $total = $this->sql(
            'SELECT COUNT(*) FROM matriculas WHERE id_periodo = ?',
            [$idPeriodo]
        )->entero();

        return sprintf('MAT-%s-%04d', $etiqueta ?: date('Y'), $total + 1);
    }

    public function estadisticas(?int $idPeriodo = null): array
    {
        $sql    = 'SELECT estado, COUNT(*) AS total FROM matriculas';
        $params = [];

        if ($idPeriodo !== null) {
            $sql     .= ' WHERE id_periodo = ?';
            $params[] = $idPeriodo;
        }

        $filas = $this->sql($sql . ' GROUP BY estado', $params)->obtenerTodo();

        $resultado = ['total' => 0, 'Confirmada' => 0, 'Pendiente' => 0, 'Anulada' => 0, 'Rechazada' => 0];
        foreach ($filas as $fila) {
            $resultado[$fila['estado']] = (int) $fila['total'];
            $resultado['total']        += (int) $fila['total'];
        }

        return $resultado;
    }

    public function delPeriodo(?int $idPeriodo = null): array
    {
        $sql    = self::SELECT_BASE;
        $params = [];

        if ($idPeriodo !== null) {
            $sql     .= ' WHERE m.id_periodo = ?';
            $params[] = $idPeriodo;
        }

        return $this->sql($sql . ' ORDER BY m.fecha_solicitud', $params)->obtenerTodo();
    }
}
