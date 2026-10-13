<?php

namespace App\Models;

use App\Core\Model;

class Arancel extends Model
{
    protected string $tabla = 'aranceles';
    protected string $clavePrimaria = 'id_arancel';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_concepto_pago', 'id_carrera', 'id_periodo', 'nombre', 'monto_base',
        'monto_mora_diaria', 'dias_gracia', 'cuotas', 'fecha_vencimiento', 'estado',
    ];

    public function listar(array $filtros = []): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_periodo'])) {
            $condiciones[]          = 'a.id_periodo = :id_periodo';
            $parametros['id_periodo'] = (int) $filtros['id_periodo'];
        }
        if (!empty($filtros['id_concepto_pago'])) {
            $condiciones[]                  = 'a.id_concepto_pago = :id_concepto_pago';
            $parametros['id_concepto_pago'] = (int) $filtros['id_concepto_pago'];
        }
        if (!empty($filtros['estado'])) {
            $condiciones[]       = 'a.estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        return $this->sql(
            "SELECT a.*, cp.nombre AS concepto_nombre, cp.codigo AS concepto_codigo, cp.categoria,
                    c.nombre AS carrera_nombre, p.nombre AS periodo_nombre,
                    (SELECT COUNT(*) FROM obligaciones_pago o WHERE o.id_arancel = a.id_arancel) AS total_obligaciones
               FROM aranceles a
               LEFT JOIN conceptos_pago cp  ON cp.id_concepto_pago = a.id_concepto_pago
               LEFT JOIN carreras c         ON c.id_carrera = a.id_carrera
               LEFT JOIN periodos_academicos p ON p.id_periodo = a.id_periodo
               {$where}
              ORDER BY p.fecha_inicio DESC, cp.orden, a.nombre",
            $parametros
        )->obtenerTodo();
    }

    /** Busca el arancel aplicable a una carrera/periodo/concepto. */
    public function vigente(int $idConcepto, ?int $idCarrera, int $idPeriodo): ?array
    {
        $fila = $this->sql(
            'SELECT * FROM aranceles
              WHERE id_concepto_pago = ? AND id_periodo = ? AND estado = "Activo"
                AND (id_carrera = ? OR id_carrera IS NULL)
              ORDER BY (id_carrera IS NULL) ASC
              LIMIT 1',
            [$idConcepto, $idPeriodo, $idCarrera]
        )->obtener();

        if ($fila === null) {
            $fila = $this->sql(
                'SELECT * FROM aranceles
                  WHERE id_concepto_pago = ? AND estado = "Activo" AND (id_carrera = ? OR id_carrera IS NULL)
                  ORDER BY (id_carrera IS NULL) ASC, fecha_vencimiento DESC
                  LIMIT 1',
                [$idConcepto, $idCarrera]
            )->obtener();
        }

        return $fila;
    }
}
