<?php

namespace App\Models;

use App\Core\Model;

class Tramite extends Model
{
    protected string $tabla = 'solicitudes_tramite';
    protected string $clavePrimaria = 'id_solicitud';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_alumno', 'id_pago', 'id_tipo_tramite', 'codigo_seguimiento', 'fecha_solicitud',
        'estado_tramite', 'tipo_entrega', 'fecha_estimada', 'fecha_entrega',
        'id_usuario_gestion', 'monto', 'documento_generado_url', 'observaciones',
    ];

    private const SELECT_BASE = 'SELECT st.*, tt.nombre_tramite, tt.dias_resolucion, tt.requiere_aprobacion,
                    tt.id_concepto_pago, cp.nombre AS concepto_nombre,
                    per.cedula, CONCAT(per.apellidos, ", ", per.nombres) AS alumno, per.email, per.celular,
                    a.legajo, c.nombre AS carrera_nombre,
                    o.descripcion AS obligacion_descripcion, o.saldo AS obligacion_saldo,
                    o.estado AS obligacion_estado, pg.estado_pago, pg.numero_comprobante
               FROM solicitudes_tramite st
               INNER JOIN alumnos a        ON a.id_alumno = st.id_alumno
               INNER JOIN personas per     ON per.id_persona = a.id_persona
               LEFT JOIN tipos_tramite tt  ON tt.id_tipo_tramite = st.id_tipo_tramite
               LEFT JOIN conceptos_pago cp ON cp.id_concepto_pago = tt.id_concepto_pago
               LEFT JOIN carreras c        ON c.id_carrera = a.id_carrera
               LEFT JOIN obligaciones_pago o ON o.referencia = st.codigo_seguimiento
               LEFT JOIN pagos pg            ON pg.id_pago = st.id_pago';

    public function conDetalle(int $id): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE st.id_solicitud = ? LIMIT 1', [$id])->obtener();
    }

    public function porCodigo(string $codigo): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE st.codigo_seguimiento = ? LIMIT 1', [$codigo])->obtener();
    }

    public function deAlumno(int $idAlumno): array
    {
        return $this->sql(
            self::SELECT_BASE . ' WHERE st.id_alumno = ? ORDER BY st.fecha_solicitud DESC',
            [$idAlumno]
        )->obtenerTodo();
    }

    public function listar(array $filtros = [], int $limite = 20, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtros($filtros);
        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            self::SELECT_BASE . " {$where} ORDER BY st.fecha_solicitud DESC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        [$where, $parametros] = $this->filtros($filtros);
        return $this->sql(
            "SELECT COUNT(*) FROM solicitudes_tramite st
               INNER JOIN alumnos a ON a.id_alumno = st.id_alumno
               INNER JOIN personas per ON per.id_persona = a.id_persona
               {$where}",
            $parametros
        )->entero();
    }

    private function filtros(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['estado'])) {
            $condiciones[]       = 'st.estado_tramite = :estado';
            $parametros['estado'] = $filtros['estado'];
        }
        if (!empty($filtros['id_tipo_tramite'])) {
            $condiciones[]              = 'st.id_tipo_tramite = :id_tipo_tramite';
            $parametros['id_tipo_tramite'] = (int) $filtros['id_tipo_tramite'];
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(per.cedula LIKE :buscar OR per.nombres LIKE :buscar OR per.apellidos LIKE :buscar
                                     OR st.codigo_seguimiento LIKE :buscar OR a.legajo LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    public function siguienteCodigo(): string
    {
        $total = $this->sql('SELECT COUNT(*) FROM solicitudes_tramite WHERE DATE(fecha_solicitud) = CURDATE()')->entero();

        // El contador se apoya en la cantidad del dia, por lo que hay que
        // avanzar hasta encontrar un codigo libre (fechas retroactivas o
        // solicitudes simultaneas pueden repetirlo).
        do {
            $codigo = generar_codigo('TRA', ++$total, 4);
            $existe = $this->sql(
                'SELECT COUNT(*) FROM solicitudes_tramite WHERE codigo_seguimiento = ?',
                [$codigo]
            )->entero() > 0;
        } while ($existe);

        return $codigo;
    }

    public function estadisticas(): array
    {
        $filas = $this->sql('SELECT estado_tramite, COUNT(*) AS total FROM solicitudes_tramite GROUP BY estado_tramite')->obtenerTodo();
        $out   = ['total' => 0];
        foreach ($filas as $fila) {
            $out[$fila['estado_tramite']] = (int) $fila['total'];
            $out['total']                += (int) $fila['total'];
        }
        return $out;
    }
}
