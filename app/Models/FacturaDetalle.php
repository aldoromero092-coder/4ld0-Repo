<?php

namespace App\Models;

use App\Core\Model;

class FacturaDetalle extends Model
{
    protected string $tabla = 'factura_detalles';
    protected string $clavePrimaria = 'id_factura_detalle';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_factura', 'id_pago_detalle', 'descripcion', 'cantidad',
        'precio_unitario', 'tipo_iva', 'monto_iva', 'subtotal',
    ];

    public function deFactura(int $idFactura): array
    {
        return $this->donde(['id_factura' => $idFactura]);
    }
}
