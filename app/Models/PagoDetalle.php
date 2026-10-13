<?php

namespace App\Models;

use App\Core\Model;

class PagoDetalle extends Model
{
    protected string $tabla = 'pago_detalles';
    protected string $clavePrimaria = 'id_pago_detalle';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['id_pago', 'id_obligacion', 'monto_pagado'];

    public function dePago(int $idPago): array
    {
        return $this->sql(
            'SELECT pd.*, o.descripcion, o.referencia, cp.nombre AS concepto_nombre
               FROM pago_detalles pd
               INNER JOIN obligaciones_pago o ON o.id_obligacion = pd.id_obligacion
               LEFT JOIN conceptos_pago cp    ON cp.id_concepto_pago = o.id_concepto_pago
              WHERE pd.id_pago = ?',
            [$idPago]
        )->obtenerTodo();
    }
}
