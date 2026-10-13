<?php

namespace App\Models;

use App\Core\Model;

class Beca extends Model
{
    protected string $tabla = 'becas';
    protected string $clavePrimaria = 'id_beca';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'porcentaje_descuento', 'monto_fijo_descuento', 'tipo', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT b.*,
                    (SELECT COUNT(*) FROM alumno_beca ab WHERE ab.id_beca = b.id_beca AND ab.estado = "Activo") AS total_asignadas
               FROM becas b
              ORDER BY b.nombre'
        )->obtenerTodo();
    }

    public function opciones(): array
    {
        return $this->sql('SELECT id_beca AS id, nombre, porcentaje_descuento, monto_fijo_descuento, tipo FROM becas WHERE estado = "Activo" ORDER BY nombre')->obtenerTodo();
    }

    /** Calcula el descuento que aplica esta beca sobre un monto. */
    public function calcularDescuento(array $beca, float $monto): float
    {
        if (!empty($beca['porcentaje_descuento']) && (float) $beca['porcentaje_descuento'] > 0) {
            return round($monto * ((float) $beca['porcentaje_descuento'] / 100), 2);
        }
        if (!empty($beca['monto_fijo_descuento']) && (float) $beca['monto_fijo_descuento'] > 0) {
            return min($monto, (float) $beca['monto_fijo_descuento']);
        }
        return 0.0;
    }
}
