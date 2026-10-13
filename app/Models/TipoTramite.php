<?php

namespace App\Models;

use App\Core\Model;

class TipoTramite extends Model
{
    protected string $tabla = 'tipos_tramite';
    protected string $clavePrimaria = 'id_tipo_tramite';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_concepto_pago', 'nombre_tramite', 'descripcion', 'dias_resolucion', 'requiere_aprobacion', 'estado',
    ];

    public function listar(): array
    {
        return $this->sql(
            'SELECT t.*, cp.nombre AS concepto_nombre, cp.codigo AS concepto_codigo,
                    (SELECT MIN(a.monto_base) FROM aranceles a WHERE a.id_concepto_pago = cp.id_concepto_pago AND a.estado = "Activo") AS monto,
                    (SELECT COUNT(*) FROM solicitudes_tramite s WHERE s.id_tipo_tramite = t.id_tipo_tramite) AS total_solicitudes
               FROM tipos_tramite t
               LEFT JOIN conceptos_pago cp ON cp.id_concepto_pago = t.id_concepto_pago
              ORDER BY t.nombre_tramite'
        )->obtenerTodo();
    }

    public function activos(): array
    {
        return $this->sql(
            'SELECT t.*, cp.nombre AS concepto_nombre,
                    (SELECT MIN(a.monto_base) FROM aranceles a WHERE a.id_concepto_pago = cp.id_concepto_pago AND a.estado = "Activo") AS monto
               FROM tipos_tramite t
               LEFT JOIN conceptos_pago cp ON cp.id_concepto_pago = t.id_concepto_pago
              WHERE t.estado = "Activo"
              ORDER BY t.nombre_tramite'
        )->obtenerTodo();
    }
}
