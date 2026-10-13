<?php

namespace App\Models;

use App\Core\Model;

class Factura extends Model
{
    protected string $tabla = 'facturas';
    protected string $clavePrimaria = 'id_factura';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_pago', 'id_alumno', 'id_datos_fiscales', 'id_timbrado', 'numero_factura',
        'fecha_emision', 'monto_subtotal', 'monto_iva5', 'monto_iva10', 'monto_exento',
        'monto_total', 'cdc_electronico', 'estado_factura', 'condicion_venta',
        'id_carrera', 'id_sede', 'matricula_legajo', 'fecha_ingreso', 'estado_academico',
    ];

    private const SELECT_BASE = 'SELECT f.*, per.cedula, CONCAT(per.apellidos, ", ", per.nombres) AS alumno,
                    df.ruc, df.razon_social, t.numero_timbrado,
                    CONCAT(t.establecimiento, "-", t.punto_expedicion) AS punto,
                    s.nombre AS sede_nombre, c.nombre AS carrera_nombre,
                    pg.numero_comprobante, pg.fecha_pago, pg.monto_total AS pago_monto
               FROM facturas f
               LEFT JOIN alumnos a      ON a.id_alumno = f.id_alumno
               LEFT JOIN personas per   ON per.id_persona = a.id_persona
               LEFT JOIN datos_fiscales df ON df.id_datos_fiscales = f.id_datos_fiscales
               LEFT JOIN timbrados t    ON t.id_timbrado = f.id_timbrado
               LEFT JOIN sedes s        ON s.id_sede = f.id_sede
               LEFT JOIN carreras c     ON c.id_carrera = f.id_carrera
               LEFT JOIN pagos pg       ON pg.id_pago = f.id_pago';

    public function conDetalle(int $id): ?array
    {
        $factura = $this->sql(self::SELECT_BASE . ' WHERE f.id_factura = ? LIMIT 1', [$id])->obtener();
        if ($factura === null) {
            return null;
        }

        $factura['detalles'] = $this->sql(
            'SELECT * FROM factura_detalles WHERE id_factura = ?',
            [$id]
        )->obtenerTodo();

        return $factura;
    }

    public function listar(array $filtros = [], int $limite = 20, int $desplazamiento = 0): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['estado_factura'])) {
            $condiciones[]                 = 'f.estado_factura = :estado_factura';
            $parametros['estado_factura']  = $filtros['estado_factura'];
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'DATE(f.fecha_emision) >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'DATE(f.fecha_emision) <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(f.numero_factura LIKE :buscar OR f.cdc_electronico LIKE :buscar
                                     OR per.cedula LIKE :buscar OR per.nombres LIKE :buscar OR per.apellidos LIKE :buscar
                                     OR df.ruc LIKE :buscar OR df.razon_social LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            self::SELECT_BASE . " {$where} ORDER BY f.fecha_emision DESC LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['estado_factura'])) {
            $condiciones[]                = 'estado_factura = :estado_factura';
            $parametros['estado_factura'] = $filtros['estado_factura'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);
        return $this->sql("SELECT COUNT(*) FROM facturas {$where}", $parametros)->entero();
    }

    public function delPago(int $idPago): ?array
    {
        return $this->primero(['id_pago' => $idPago]);
    }

    /** Genera el numero de factura a partir del timbrado activo. */
    public function siguienteNumero(int $idSede): array
    {
        $timbrado = (new Timbrado())->sql(
            'SELECT * FROM timbrados WHERE id_sede = ? AND estado = "Activo"
               AND (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= CURDATE())
             ORDER BY id_timbrado LIMIT 1',
            [$idSede]
        )->obtener();

        if ($timbrado === null) {
            $timbrado = (new Timbrado())->primero(['estado' => 'Activo']);
        }

        if ($timbrado === null) {
            return ['numero' => null, 'timbrado' => null];
        }

        $numero = sprintf(
            '%s-%s-%07d',
            $timbrado['establecimiento'] ?: '001',
            $timbrado['punto_expedicion'] ?: '001',
            ((int) $timbrado['numero_actual']) + 1
        );

        return ['numero' => $numero, 'timbrado' => $timbrado];
    }
}
