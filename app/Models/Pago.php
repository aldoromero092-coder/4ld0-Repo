<?php

namespace App\Models;

use App\Core\Model;

class Pago extends Model
{
    protected string $tabla = 'pagos';
    protected string $clavePrimaria = 'id_pago';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = 'actualizado_en';

    protected array $asignables = [
        'id_alumno', 'id_metodo_pago', 'id_usuario', 'id_periodo', 'id_sede',
        'codigo_transaccion', 'pasarela', 'id_transaccion_pasarela', 'monto_total',
        'moneda', 'tipo_pago', 'monto_recibido', 'vuelto', 'fecha_pago', 'estado_pago',
        'comprobante_ref', 'url_comprobante', 'numero_comprobante', 'observacion',
        'ip_origen', 'user_agent',
    ];

    private const SELECT_BASE = 'SELECT pg.*, mp.nombre AS metodo_nombre, mp.tipo AS metodo_tipo,
                    per.cedula, CONCAT(per.apellidos, ", ", per.nombres) AS alumno,
                    per.email, per.celular, a.legajo, c.nombre AS carrera_nombre,
                    s.nombre AS sede_nombre, p.nombre AS periodo_nombre,
                    reg.nombres AS registrado_por_nombres, reg.apellidos AS registrado_por_apellidos,
                    (SELECT COUNT(*) FROM pago_detalles pd WHERE pd.id_pago = pg.id_pago) AS cantidad_items
               FROM pagos pg
               LEFT JOIN alumnos a          ON a.id_alumno = pg.id_alumno
               LEFT JOIN personas per       ON per.id_persona = a.id_persona
               LEFT JOIN carreras c         ON c.id_carrera = a.id_carrera
               LEFT JOIN sedes s            ON s.id_sede = pg.id_sede
               LEFT JOIN periodos_academicos p ON p.id_periodo = pg.id_periodo
               LEFT JOIN metodos_pago mp    ON mp.id_metodo_pago = pg.id_metodo_pago
               LEFT JOIN usuarios u         ON u.id_usuario = pg.id_usuario
               LEFT JOIN personas reg       ON reg.id_persona = u.id_persona';

    public function conDetalle(int $id): ?array
    {
        $pago = $this->sql(self::SELECT_BASE . ' WHERE pg.id_pago = ? LIMIT 1', [$id])->obtener();
        if ($pago === null) {
            return null;
        }

        $pago['items'] = $this->sql(
            'SELECT pd.*, o.descripcion, o.referencia, o.monto_final, o.estado AS estado_obligacion,
                    cp.nombre AS concepto_nombre, cp.categoria
               FROM pago_detalles pd
               INNER JOIN obligaciones_pago o ON o.id_obligacion = pd.id_obligacion
               LEFT JOIN conceptos_pago cp    ON cp.id_concepto_pago = o.id_concepto_pago
              WHERE pd.id_pago = ?',
            [$id]
        )->obtenerTodo();

        return $pago;
    }

    public function porCodigoTransaccion(string $codigo): ?array
    {
        return $this->buscarPor('codigo_transaccion', $codigo);
    }

    /** Historial paginado. */
    public function listar(array $filtros = [], int $limite = 15, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtros($filtros);
        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            self::SELECT_BASE . " {$where} ORDER BY pg.fecha_pago DESC, pg.id_pago DESC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        [$where, $parametros] = $this->filtros($filtros);
        return $this->sql(
            "SELECT COUNT(*) FROM pagos pg
               INNER JOIN alumnos a ON a.id_alumno = pg.id_alumno
               INNER JOIN personas per ON per.id_persona = a.id_persona
               LEFT JOIN metodos_pago mp ON mp.id_metodo_pago = pg.id_metodo_pago
               {$where}",
            $parametros
        )->entero();
    }

    private function filtros(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_alumno'])) {
            $condiciones[]          = 'pg.id_alumno = :id_alumno';
            $parametros['id_alumno'] = (int) $filtros['id_alumno'];
        }
        foreach (['estado_pago', 'id_metodo_pago', 'id_periodo', 'tipo_pago', 'pasarela'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "pg.`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'DATE(pg.fecha_pago) >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'DATE(pg.fecha_pago) <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }
        if (!empty($filtros['id_usuario'])) {
            $condiciones[]           = 'pg.id_usuario = :id_usuario';
            $parametros['id_usuario'] = (int) $filtros['id_usuario'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(per.cedula LIKE :buscar OR per.nombres LIKE :buscar OR per.apellidos LIKE :buscar
                                     OR pg.codigo_transaccion LIKE :buscar OR pg.numero_comprobante LIKE :buscar
                                     OR a.legajo LIKE :buscar OR pg.id_transaccion_pasarela LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    /** Siguiente numero de comprobante correlativo. */
    public function siguienteNumeroComprobante(): string
    {
        $prefijo = (string) config('app.comprobante_prefijo', 'REC');
        $anio    = date('Y');
        $total   = $this->sql(
            'SELECT COUNT(*) FROM pagos WHERE numero_comprobante LIKE ?',
            [$prefijo . '-' . $anio . '%']
        )->entero();

        return sprintf('%s-%s-%06d', $prefijo, $anio, $total + 1);
    }

    /** Estadisticas de recaudacion agrupadas por dia, mes o metodo. */
    public function recaudacion(string $agrupacion, ?string $desde = null, ?string $hasta = null): array
    {
        $expr = match ($agrupacion) {
            'mes'    => "DATE_FORMAT(pg.fecha_pago, '%Y-%m')",
            'metodo' => 'mp.nombre',
            'tipo'   => 'pg.tipo_pago',
            'sede'   => 's.nombre',
            default  => 'DATE(pg.fecha_pago)',
        };

        $condiciones = ['pg.estado_pago = "Aprobado"'];
        $parametros  = [];

        if ($desde !== null) {
            $condiciones[]       = 'DATE(pg.fecha_pago) >= ?';
            $parametros[]        = $desde;
        }
        if ($hasta !== null) {
            $condiciones[]       = 'DATE(pg.fecha_pago) <= ?';
            $parametros[]        = $hasta;
        }

        return $this->sql(
            "SELECT {$expr} AS etiqueta,
                    COUNT(*) AS cantidad,
                    COALESCE(SUM(pg.monto_total), 0) AS total
               FROM pagos pg
               LEFT JOIN metodos_pago mp ON mp.id_metodo_pago = pg.id_metodo_pago
               LEFT JOIN sedes s         ON s.id_sede = pg.id_sede
              WHERE " . implode(' AND ', $condiciones) . '
              GROUP BY etiqueta
              ORDER BY etiqueta',
            $parametros
        )->obtenerTodo();
    }

    public function totalkAprobado(?string $desde = null, ?string $hasta = null): float
    {
        $condiciones = ['estado_pago = "Aprobado"'];
        $parametros  = [];
        if ($desde !== null) {
            $condiciones[] = 'DATE(fecha_pago) >= ?';
            $parametros[]  = $desde;
        }
        if ($hasta !== null) {
            $condiciones[] = 'DATE(fecha_pago) <= ?';
            $parametros[]  = $hasta;
        }

        return (float) $this->sql(
            'SELECT COALESCE(SUM(monto_total),0) FROM pagos WHERE ' . implode(' AND ', $condiciones),
            $parametros
        )->decimal();
    }

    public function delDia(?string $fecha = null, ?int $idSede = null): array
    {
        $fecha = $fecha ?? date('Y-m-d');
        $sql   = 'SELECT pg.*, mp.nombre AS metodo_nombre,
                         CONCAT(per.apellidos, ", ", per.nombres) AS alumno, per.cedula
                    FROM pagos pg
                    INNER JOIN alumnos a    ON a.id_alumno = pg.id_alumno
                    INNER JOIN personas per ON per.id_persona = a.id_persona
                    LEFT JOIN metodos_pago mp ON mp.id_metodo_pago = pg.id_metodo_pago
                   WHERE DATE(pg.fecha_pago) = ?';
        $params = [$fecha];

        if ($idSede !== null) {
            $sql     .= ' AND pg.id_sede = ?';
            $params[] = $idSede;
        }

        return $this->sql($sql . ' ORDER BY pg.fecha_pago DESC', $params)->obtenerTodo();
    }
}
