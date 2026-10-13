<?php

namespace App\Services;

use App\Core\Database;
use App\Core\Logger;
use App\Models\DatosFiscales;
use App\Models\Factura;
use App\Models\FacturaDetalle;
use App\Models\Timbrado;

/**
 * Emision de facturas legales a partir de los pagos registrados.
 */
class FacturaService
{
    private Factura $facturas;
    private FacturaDetalle $detalles;
    private Timbrado $timbrados;
    private DatosFiscales $datosFiscales;

    public function __construct()
    {
        $this->facturas      = new Factura();
        $this->detalles      = new FacturaDetalle();
        $this->timbrados     = new Timbrado();
        $this->datosFiscales = new DatosFiscales();
    }

    /**
     * Emite la factura de un pago aprobado. Si el alumno no tiene datos
     * fiscales se emite a su nombre con RUC generico.
     */
    public function emitirDesdePago(int $idPago, ?int $idDatosFiscales = null): ?int
    {
        if ($this->facturas->delPago($idPago) !== null) {
            return null; // ya facturado
        }

        $pago = Database::instancia()->consulta(
            'SELECT pg.*, a.id_persona, a.id_carrera, a.legajo, a.id_sede, per.nombres, per.apellidos,
                    p.nombre AS periodo_nombre
               FROM pagos pg
               INNER JOIN alumnos a    ON a.id_alumno = pg.id_alumno
               INNER JOIN personas per ON per.id_persona = a.id_persona
               LEFT JOIN periodos_academicos p ON p.id_periodo = pg.id_periodo
              WHERE pg.id_pago = ?',
            [$idPago]
        )->obtener();

        if ($pago === null || $pago['estado_pago'] !== 'Aprobado') {
            return null;
        }

        $idSede   = (int) ($pago['id_sede'] ?? 1);
        $resultado = $this->facturas->siguienteNumero($idSede);

        if ($resultado['timbrado'] === null) {
            Logger::error('factura_sin_timbrado', 'No hay timbrado activo para emitir la factura del pago ' . $idPago);
            return null;
        }

        $timbrado = $resultado['timbrado'];

        // Si no se informan datos fiscales usamos los del alumno como consumidor final
        if ($idDatosFiscales === null) {
            $existente = $this->datosFiscales->dePersona((int) $pago['id_persona']);
            $idDatosFiscales = $existente !== null
                ? (int) $existente['id_datos_fiscales']
                : (int) $this->datosFiscales->crear([
                    'id_persona'       => (int) $pago['id_persona'],
                    'ruc'              => 'X',
                    'razon_social'     => trim($pago['nombres'] . ' ' . $pago['apellidos']),
                    'direccion_fiscal' => null,
                    'telefono_fiscal'  => null,
                ]);
        }

        $montoTotal = (float) $pago['monto_total'];
        $ivaIncluido = round($montoTotal - ($montoTotal / 1.10), 2);
        $gravado     = round($montoTotal - $ivaIncluido, 2);

        $idFactura = Database::instancia()->transaccion(function () use (
            $pago, $idSede, $resultado, $timbrado, $idDatosFiscales,
            $montoTotal, $ivaIncluido, $gravado
        ) {
            $numero = $resultado['numero'];
            $idFactura = $this->facturas->crear([
                'id_pago'            => (int) $pago['id_pago'],
                'id_alumno'          => (int) $pago['id_alumno'],
                'id_datos_fiscales'  => $idDatosFiscales,
                'id_timbrado'        => (int) $timbrado['id_timbrado'],
                'numero_factura'     => $numero,
                'fecha_emision'      => date('Y-m-d H:i:s'),
                'monto_subtotal'     => $gravado,
                'monto_iva5'         => 0,
                'monto_iva10'        => $ivaIncluido,
                'monto_exento'       => 0,
                'monto_total'        => $montoTotal,
                'cdc_electronico'    => null,
                'estado_factura'     => 'Emitida',
                'condicion_venta'    => 'Contado',
                'id_carrera'         => $pago['id_carrera'] ?? null,
                'id_sede'            => $idSede,
                'matricula_legajo'   => $pago['legajo'] ?? null,
            ]);

            foreach ($this->detallesDePago((int) $pago['id_pago']) as $detalle) {
                $this->detalles->crear([
                    'id_factura'       => $idFactura,
                    'id_pago_detalle'  => (int) $detalle['id_pago_detalle'],
                    'descripcion'      => recortar($detalle['concepto_nombre'] . ' - ' . $detalle['descripcion'], 145),
                    'cantidad'         => 1,
                    'precio_unitario'  => (float) $detalle['monto_pagado'],
                    'tipo_iva'         => '10%',
                    'monto_iva'        => round((float) $detalle['monto_pagado'] - ((float) $detalle['monto_pagado'] / 1.10), 2),
                    'subtotal'         => (float) $detalle['monto_pagado'],
                ]);
            }

            $this->timbrados->consumir((int) $timbrado['id_timbrado']);

            return $idFactura;
        });

        Logger::registrar('factura_emitida', 'Factura ' . $resultado['numero'] . ' emitida para el pago #' . $pago['id_pago'], 'facturacion', 'info');

        return $idFactura;
    }

    /** Emite manualmente una factura para un pago (desde el modulo de facturacion). */
    public function emitir(int $idPago, ?int $idDatosFiscales = null): array
    {
        $pago = Database::instancia()->consulta('SELECT * FROM pagos WHERE id_pago = ?', [$idPago])->obtener();

        if ($pago === null) {
            return ['ok' => false, 'mensaje' => 'El pago no existe.'];
        }
        if ($pago['estado_pago'] !== 'Aprobado') {
            return ['ok' => false, 'mensaje' => 'Solo se pueden facturar pagos aprobados.'];
        }
        if ($this->facturas->delPago($idPago) !== null) {
            return ['ok' => false, 'mensaje' => 'Este pago ya tiene una factura emitida.'];
        }

        $idFactura = $this->emitirDesdePago($idPago, $idDatosFiscales);

        if ($idFactura === null) {
            return ['ok' => false, 'mensaje' => 'No se pudo emitir la factura. Verificá que exista un timbrado vigente.'];
        }

        return ['ok' => true, 'mensaje' => 'Factura emitida correctamente.', 'id_factura' => $idFactura];
    }

    public function anular(int $idFactura, string $motivo): array
    {
        $factura = $this->facturas->buscar($idFactura);
        if ($factura === null) {
            return ['ok' => false, 'mensaje' => 'La factura no existe.'];
        }
        if ($factura['estado_factura'] === 'Anulada') {
            return ['ok' => false, 'mensaje' => 'La factura ya estaba anulada.'];
        }

        $this->facturas->actualizar($idFactura, ['estado_factura' => 'Anulada']);
        Logger::auditar('facturas', (string) $idFactura, 'ANULAR', $factura, ['motivo' => $motivo]);

        return ['ok' => true, 'mensaje' => 'Factura anulada.'];
    }

    private function detallesDePago(int $idPago): array
    {
        return Database::instancia()->consulta(
            'SELECT pd.*, cp.nombre AS concepto_nombre, o.descripcion
               FROM pago_detalles pd
               INNER JOIN obligaciones_pago o ON o.id_obligacion = pd.id_obligacion
               LEFT JOIN conceptos_pago cp ON cp.id_concepto_pago = o.id_concepto_pago
              WHERE pd.id_pago = ?',
            [$idPago]
        )->obtenerTodo();
    }

    public function totalFacturado(?string $desde = null, ?string $hasta = null): float
    {
        $condiciones = ['estado_factura = "Emitida"'];
        $parametros  = [];

        if ($desde !== null) {
            $condiciones[] = 'DATE(fecha_emision) >= ?';
            $parametros[]  = $desde;
        }
        if ($hasta !== null) {
            $condiciones[] = 'DATE(fecha_emision) <= ?';
            $parametros[]  = $hasta;
        }

        return (float) $this->facturas->sql(
            'SELECT COALESCE(SUM(monto_total),0) FROM facturas WHERE ' . implode(' AND ', $condiciones),
            $parametros
        )->decimal();
    }
}
