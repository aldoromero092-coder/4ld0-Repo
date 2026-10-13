<?php

namespace App\Models;

use App\Core\Model;

class Comprobante extends Model
{
    protected string $tabla = 'comprobantes';
    protected string $clavePrimaria = 'id_comprobante';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['id_pago', 'id_solicitud', 'numero', 'tipo', 'archivo', 'id_usuario'];

    public function dePago(int $idPago): array
    {
        return $this->donde(['id_pago' => $idPago], ['id_comprobante' => 'DESC']);
    }

    public function siguienteNumero(string $tipo = 'Recibo'): string
    {
        $prefijos = ['Recibo' => 'REC', 'Constancia' => 'CON', 'Certificado' => 'CER', 'Factura' => 'FAC', 'Titulo' => 'TIT'];
        $prefijo  = $prefijos[$tipo] ?? 'DOC';
        $anio     = date('Y');

        $total = $this->sql(
            'SELECT COUNT(*) FROM comprobantes WHERE tipo = ? AND YEAR(fecha_generacion) = ?',
            [$tipo, $anio]
        )->entero();

        return sprintf('%s-%s-%06d', $prefijo, $anio, $total + 1);
    }
}
