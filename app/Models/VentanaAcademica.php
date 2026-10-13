<?php

namespace App\Models;

use App\Core\Model;

/**
 * Ventana academica: define desde y hasta cuando se puede matricular,
 * inscribirse a examenes o pagar cada concepto, por periodo, carrera y sede.
 */
class VentanaAcademica extends Model
{
    /** Tipos soportados por el sistema. */
    public const TIPOS = [
        'Matricula' => 'Matriculación',
        'Examen'    => 'Inscripción y pago de exámenes',
        'Arancel'   => 'Pago de aranceles',
        'Tramite'   => 'Trámites y documentos',
        'General'   => 'General',
    ];

    protected string $tabla = 'ventanas_academicas';
    protected string $clavePrimaria = 'id_ventana';
    protected array $asignables = [
        'nombre', 'tipo', 'id_periodo', 'id_carrera', 'id_sede', 'fecha_apertura', 'hora_apertura',
        'fecha_cierre', 'hora_cierre', 'permite_pago_tardio', 'fecha_limite_pago', 'recargo_tardio',
        'monto_recargo', 'aviso', 'estado', 'observaciones', 'id_usuario_gestion',
    ];

    private const SELECT_BASE = 'SELECT v.*, p.nombre AS periodo_nombre, c.nombre AS carrera_nombre,
                    c.codigo_carrera, s.nombre AS sede_nombre
               FROM ventanas_academicas v
               LEFT JOIN periodos_academicos p ON p.id_periodo = v.id_periodo
               LEFT JOIN carreras c            ON c.id_carrera = v.id_carrera
               LEFT JOIN sedes s               ON s.id_sede = v.id_sede';

    public function conDetalle(int $idVentana): ?array
    {
        return $this->sql(self::SELECT_BASE . ' WHERE v.id_ventana = ? LIMIT 1', [$idVentana])->obtener();
    }

    /**
     * Ventana que gobierna una operacion concreta.
     *
     * Se elige la mas especifica (carrera y sede antes que "todas") y, entre
     * iguales, la que cierra mas tarde.
     */
    public function vigente(string $tipo, ?int $idPeriodo, ?int $idCarrera, ?int $idSede = null): ?array
    {
        $condiciones = ['v.tipo = ?', 'v.estado = "Activo"', '(v.id_periodo = ? OR v.id_periodo IS NULL)'];
        $parametros  = [$tipo, $idPeriodo];

        if ($idCarrera !== null && $idCarrera > 0) {
            $condiciones[] = '(v.id_carrera = ? OR v.id_carrera IS NULL)';
            $parametros[]  = $idCarrera;
        } else {
            $condiciones[] = 'v.id_carrera IS NULL';
        }

        if ($idSede !== null && $idSede > 0) {
            $condiciones[] = '(v.id_sede = ? OR v.id_sede IS NULL)';
            $parametros[]  = $idSede;
        } else {
            $condiciones[] = 'v.id_sede IS NULL';
        }

        return $this->sql(
            self::SELECT_BASE . ' WHERE ' . implode(' AND ', $condiciones)
            . ' ORDER BY (v.id_carrera IS NULL) ASC, (v.id_sede IS NULL) ASC,
                         (v.id_periodo IS NULL) ASC, v.fecha_cierre DESC, v.id_ventana DESC
              LIMIT 1',
            $parametros
        )->obtener();
    }

    /** @return array<int, array> */
    public function listar(array $filtros = []): array
    {
        $condiciones = [];
        $parametros  = [];

        foreach (['tipo' => 'v.tipo', 'estado' => 'v.estado'] as $clave => $columna) {
            if (!empty($filtros[$clave])) {
                $condiciones[]       = $columna . ' = :' . $clave;
                $parametros[$clave]  = $filtros[$clave];
            }
        }
        foreach (['id_periodo' => 'v.id_periodo', 'id_carrera' => 'v.id_carrera', 'id_sede' => 'v.id_sede'] as $clave => $columna) {
            if (!empty($filtros[$clave])) {
                $condiciones[]       = $columna . ' = :' . $clave;
                $parametros[$clave]  = (int) $filtros[$clave];
            }
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = 'v.nombre LIKE :buscar';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        return $this->sql(
            self::SELECT_BASE . " {$where}
              ORDER BY v.fecha_apertura DESC, v.tipo, v.nombre
              LIMIT 300",
            $parametros
        )->obtenerTodo();
    }

    /** Ventanas abiertas hoy (o por abrir) para mostrar en el panel. */
    public function abiertas(?int $idCarrera = null, ?int $idSede = null): array
    {
        $condiciones = ['v.estado = "Activo"', 'v.fecha_cierre >= CURDATE()'];
        $parametros  = [];

        if ($idCarrera !== null && $idCarrera > 0) {
            $condiciones[] = '(v.id_carrera = ? OR v.id_carrera IS NULL)';
            $parametros[]  = $idCarrera;
        }
        if ($idSede !== null && $idSede > 0) {
            $condiciones[] = '(v.id_sede = ? OR v.id_sede IS NULL)';
            $parametros[]  = $idSede;
        }

        return $this->sql(
            self::SELECT_BASE . ' WHERE ' . implode(' AND ', $condiciones)
            . ' ORDER BY v.fecha_cierre ASC, v.tipo',
            $parametros
        )->obtenerTodo();
    }

    public function proximas(int $limite = 5): array
    {
        return $this->sql(
            self::SELECT_BASE . ' WHERE v.estado = "Activo" AND v.fecha_cierre >= CURDATE()
              ORDER BY v.fecha_apertura ASC, v.fecha_cierre ASC
              LIMIT ' . (int) $limite
        )->obtenerTodo();
    }

    public function estadisticas(): array
    {
        $fila = $this->sql(
            'SELECT COUNT(*) AS total,
                    SUM(fecha_cierre >= CURDATE() AND fecha_apertura <= CURDATE()) AS vigentes,
                    SUM(fecha_apertura > CURDATE()) AS programadas
               FROM ventanas_academicas WHERE estado = "Activo"'
        )->obtener();

        return [
            'total'      => (int) ($fila['total'] ?? 0),
            'vigentes'   => (int) ($fila['vigentes'] ?? 0),
            'programadas' => (int) ($fila['programadas'] ?? 0),
        ];
    }

    /** Monto del recargo que corresponde aplicar fuera del plazo ordinario. */
    public function calcularRecargo(array $ventana, float $monto): float
    {
        $porcentaje = (float) ($ventana['recargo_tardio'] ?? 0);
        $fijo       = (float) ($ventana['monto_recargo'] ?? 0);

        return round(($monto * $porcentaje / 100) + $fijo, 2);
    }
}
