<?php

namespace App\Models;

use App\Core\Model;

/**
 * Obligacion de pago: cada deuda concreta de un alumno.
 */
class Obligacion extends Model
{
    protected string $tabla = 'obligaciones_pago';
    protected string $clavePrimaria = 'id_obligacion';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';

    protected array $asignables = [
        'id_alumno', 'id_concepto_pago', 'id_periodo', 'id_arancel', 'id_matricula',
        'id_inscripcion', 'descripcion', 'referencia', 'monto_original', 'monto_mora',
        'monto_descuento', 'monto_final', 'monto_pagado', 'saldo', 'fecha_emision',
        'fecha_vencimiento', 'estado', 'prioridad',
    ];

    /** Consulta base con todos los datos relacionados. */
    private const SELECT_BASE = 'SELECT o.*, cp.nombre AS concepto_nombre, cp.codigo AS concepto_codigo,
                    cp.categoria AS concepto_categoria, cp.categoria AS categoria,
                    p.nombre AS periodo_nombre,
                    per.cedula, per.nombres, per.apellidos, per.celular, per.telefono, per.email,
                    CONCAT(per.apellidos, ", ", per.nombres) AS alumno,
                    a.legajo, a.id_carrera, a.id_sede, c.nombre AS carrera_nombre,
                    CASE WHEN o.estado IN ("Pendiente","Vencido") AND o.fecha_vencimiento IS NOT NULL
                              AND o.fecha_vencimiento < CURDATE()
                         THEN DATEDIFF(CURDATE(), o.fecha_vencimiento) ELSE 0 END AS dias_atraso
               FROM obligaciones_pago o
               INNER JOIN alumnos a        ON a.id_alumno = o.id_alumno
               INNER JOIN personas per     ON per.id_persona = a.id_persona
               LEFT JOIN conceptos_pago cp ON cp.id_concepto_pago = o.id_concepto_pago
               LEFT JOIN periodos_academicos p ON p.id_periodo = o.id_periodo
               LEFT JOIN carreras c        ON c.id_carrera = a.id_carrera';

    public function conDetalle(int $id): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE o.id_obligacion = ? LIMIT 1', [$id])->obtener();
    }

    /**
     * Obligaciones de un alumno.
     *
     * @param string $estadoFiltro pendientes|pagadas|vencidas|todas
     */
    public function deAlumno(int $idAlumno, string $estadoFiltro = 'todas', array $opciones = []): array
    {
        $where      = ['o.id_alumno = :id_alumno'];
        $parametros = ['id_alumno' => $idAlumno];

        switch ($estadoFiltro) {
            case 'pendientes':
                $where[] = 'o.estado IN ("Pendiente","Vencido","Parcial")';
                break;
            case 'pagadas':
                $where[] = 'o.estado = "Pagado"';
                break;
            case 'vencidas':
                $where[] = 'o.estado IN ("Pendiente","Vencido") AND o.fecha_vencimiento < CURDATE()';
                break;
        }

        if (!empty($opciones['id_periodo'])) {
            $where[]                = 'o.id_periodo = :id_periodo';
            $parametros['id_periodo'] = (int) $opciones['id_periodo'];
        }
        if (!empty($opciones['id_concepto_pago'])) {
            $where[]                        = 'o.id_concepto_pago = :id_concepto_pago';
            $parametros['id_concepto_pago'] = (int) $opciones['id_concepto_pago'];
        }
        if (!empty($opciones['buscar'])) {
            $where[]              = '(o.descripcion LIKE :buscar OR o.referencia LIKE :buscar OR cp.nombre LIKE :buscar)';
            $parametros['buscar'] = '%' . $opciones['buscar'] . '%';
        }

        $sql = self::SELECT_BASE . ' WHERE ' . implode(' AND ', $where);
        $sql .= ' ORDER BY FIELD(o.estado, "Vencido", "Pendiente", "Parcial", "Pagado", "Anulado"),
                           o.fecha_vencimiento ASC, o.id_obligacion DESC';

        if (!empty($opciones['limite'])) {
            $sql .= ' LIMIT ' . (int) $opciones['limite'];
        }

        return $this->sql($sql, $parametros)->obtenerTodo();
    }

    /** Listado administrativo paginado. */
    public function listar(array $filtros = [], int $limite = 20, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtros($filtros);
        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            self::SELECT_BASE . " {$where}
              ORDER BY FIELD(o.estado, 'Vencido','Pendiente','Parcial','Pagado','Anulado'),
                       o.fecha_vencimiento ASC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        [$where, $parametros] = $this->filtros($filtros);
        return $this->sql(
            "SELECT COUNT(*) FROM obligaciones_pago o
               INNER JOIN alumnos a ON a.id_alumno = o.id_alumno
               INNER JOIN personas per ON per.id_persona = a.id_persona
               LEFT JOIN conceptos_pago cp ON cp.id_concepto_pago = o.id_concepto_pago
               {$where}",
            $parametros
        )->entero();
    }

    private function filtros(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        foreach (['id_periodo', 'id_concepto_pago', 'estado'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "o.`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }

        if (!empty($filtros['estados']) && is_array($filtros['estados'])) {
            $marcadores = [];
            foreach ($filtros['estados'] as $i => $estado) {
                $mk                  = 'est' . $i;
                $marcadores[]        = ':' . $mk;
                $parametros[$mk]     = $estado;
            }
            $condiciones[] = 'o.estado IN (' . implode(', ', $marcadores) . ')';
        }

        if (!empty($filtros['id_carrera'])) {
            $condiciones[]          = 'a.id_carrera = :id_carrera';
            $parametros['id_carrera'] = (int) $filtros['id_carrera'];
        }
        if (!empty($filtros['id_sede'])) {
            $condiciones[]       = 'a.id_sede = :id_sede';
            $parametros['id_sede'] = (int) $filtros['id_sede'];
        }
        if (!empty($filtros['vencidas'])) {
            $condiciones[] = 'o.estado IN ("Pendiente","Vencido") AND o.fecha_vencimiento < CURDATE()';
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(per.cedula LIKE :buscar OR per.nombres LIKE :buscar OR per.apellidos LIKE :buscar
                                     OR a.legajo LIKE :buscar OR o.descripcion LIKE :buscar OR o.referencia LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'o.fecha_emision >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'o.fecha_emision <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    /** Resumen de la cuenta corriente de un alumno. */
    public function resumenAlumno(int $idAlumno): array
    {
        $fila = $this->sql(
            'SELECT
                COALESCE(SUM(CASE WHEN estado IN ("Pendiente","Vencido","Parcial") THEN saldo ELSE 0 END), 0) AS pendiente,
                COALESCE(SUM(CASE WHEN estado = "Pagado" THEN monto_final ELSE 0 END), 0)                    AS pagado,
                COALESCE(SUM(CASE WHEN estado IN ("Pendiente","Vencido") AND fecha_vencimiento < CURDATE()
                                  THEN saldo ELSE 0 END), 0)                                                 AS vencido,
                COUNT(CASE WHEN estado IN ("Pendiente","Vencido","Parcial") THEN 1 END)                      AS cantidad_pendiente,
                COUNT(CASE WHEN estado IN ("Pendiente","Vencido") AND fecha_vencimiento < CURDATE() THEN 1 END) AS cantidad_vencida,
                COUNT(*)                                                                                     AS cantidad_total
               FROM obligaciones_pago WHERE id_alumno = ?',
            [$idAlumno]
        )->obtener();

        $siguiente = $this->sql(
            'SELECT id_obligacion, descripcion, saldo, fecha_vencimiento
               FROM obligaciones_pago
              WHERE id_alumno = ? AND estado IN ("Pendiente","Vencido","Parcial")
                AND fecha_vencimiento IS NOT NULL
              ORDER BY fecha_vencimiento ASC LIMIT 1',
            [$idAlumno]
        )->obtener();

        return array_merge($fila ?? [], ['siguiente_vencimiento' => $siguiente]);
    }

    /** Total recaudado vs pendiente en un rango de fechas. */
    public function totalesPeriodo(?int $idPeriodo = null): array
    {
        $sql    = 'SELECT
                     COALESCE(SUM(monto_final),0) AS facturado,
                     COALESCE(SUM(monto_pagado),0) AS cobrado,
                     COALESCE(SUM(saldo),0)       AS pendiente,
                     COUNT(*)                     AS cantidad
                   FROM obligaciones_pago WHERE estado <> "Anulado"';
        $params = [];

        if ($idPeriodo !== null) {
            $sql     .= ' AND id_periodo = ?';
            $params[] = $idPeriodo;
        }

        return $this->sql($sql, $params)->obtener() ?? [];
    }

    /** Aplica mora a todas las obligaciones vencidas. */
    public function aplicarMora(float $moraDiaria, bool $soloVencidas = true, int $diasGracia = 0): int
    {
        $filtro = $soloVencidas
            ? 'AND o.fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL ' . (int) $diasGracia . ' DAY)'
            : '';

        $filas = $this->sql(
            "SELECT o.id_obligacion, o.monto_original, o.monto_descuento, o.monto_mora,
                    DATEDIFF(CURDATE(), o.fecha_vencimiento) AS dias
               FROM obligaciones_pago o
              WHERE o.estado IN ('Pendiente','Vencido','Parcial')
                AND o.fecha_vencimiento IS NOT NULL
                {$filtro}"
        )->obtenerTodo();

        $actualizadas = 0;
        foreach ($filas as $fila) {
            $dias  = max(0, (int) $fila['dias'] - $diasGracia);
            $mora  = round($dias * $moraDiaria, 2);
            if ($mora <= (float) $fila['monto_mora']) {
                continue;
            }

            $final = (float) $fila['monto_original'] + $mora - (float) $fila['monto_descuento'];
            $this->sql(
                'UPDATE obligaciones_pago
                    SET monto_mora = ?, monto_final = ?, saldo = GREATEST(0, ? - monto_pagado), estado = "Vencido"
                  WHERE id_obligacion = ?',
                [$mora, $final, $final, $fila['id_obligacion']]
            );
            $actualizadas++;
        }

        return $actualizadas;
    }

    /** Recalcula estado y saldo luego de un pago. */
    public function recalcular(int $idObligacion): void
    {
        $this->sql(
            'UPDATE obligaciones_pago o
                SET o.monto_pagado = COALESCE((SELECT SUM(pd.monto_pagado) FROM pago_detalles pd
                                                INNER JOIN pagos pg ON pg.id_pago = pd.id_pago
                                               WHERE pd.id_obligacion = o.id_obligacion
                                                 AND pg.estado_pago = "Aprobado"), 0),
                    o.saldo = GREATEST(0, o.monto_final - COALESCE((SELECT SUM(pd.monto_pagado) FROM pago_detalles pd
                                                INNER JOIN pagos pg ON pg.id_pago = pd.id_pago
                                               WHERE pd.id_obligacion = o.id_obligacion
                                                 AND pg.estado_pago = "Aprobado"), 0))
              WHERE o.id_obligacion = ?',
            [$idObligacion]
        );

        $this->sql(
            'UPDATE obligaciones_pago
                SET estado = CASE
                        WHEN saldo <= 0        THEN "Pagado"
                        WHEN monto_pagado > 0  THEN "Parcial"
                        WHEN fecha_vencimiento IS NOT NULL AND fecha_vencimiento < CURDATE() THEN "Vencido"
                        ELSE "Pendiente" END
              WHERE id_obligacion = ? AND estado <> "Anulado"',
            [$idObligacion]
        );
    }
}
