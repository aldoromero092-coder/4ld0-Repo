<?php

namespace App\Models;

use App\Core\Model;

class LogActividad extends Model
{
    protected string $tabla = 'logs_actividad';
    protected string $clavePrimaria = 'id_log';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_usuario', 'modulo', 'accion', 'descripcion', 'metodo_http', 'ruta',
        'ip_origen', 'user_agent', 'datos', 'nivel',
    ];

    public function listar(array $filtros = [], int $limite = 30, int $desplazamiento = 0): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_usuario'])) {
            $condiciones[]           = 'l.id_usuario = :id_usuario';
            $parametros['id_usuario'] = (int) $filtros['id_usuario'];
        }
        foreach (['modulo', 'nivel'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "l.`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(l.accion LIKE :buscar OR l.descripcion LIKE :buscar OR l.ip_origen LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'DATE(l.fecha_hora) >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'DATE(l.fecha_hora) <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            "SELECT l.*, u.user AS usuario_login,
                    CONCAT(per.nombres, ' ', per.apellidos) AS usuario_nombre, r.nombre AS rol
               FROM logs_actividad l
               LEFT JOIN usuarios u ON u.id_usuario = l.id_usuario
               LEFT JOIN personas per ON per.id_persona = u.id_persona
               LEFT JOIN roles r ON r.id_rol = u.id_rol
               {$where}
              ORDER BY l.fecha_hora DESC, l.id_log DESC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['id_usuario'])) {
            $condiciones[]           = 'id_usuario = :id_usuario';
            $parametros['id_usuario'] = (int) $filtros['id_usuario'];
        }
        foreach (['modulo', 'nivel'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'DATE(fecha_hora) >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'DATE(fecha_hora) <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);
        return $this->sql("SELECT COUNT(*) FROM logs_actividad {$where}", $parametros)->entero();
    }

    public function porModulo(int $dias = 30): array
    {
        return $this->sql(
            'SELECT modulo, COUNT(*) AS total
               FROM logs_actividad
              WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL ? DAY)
              GROUP BY modulo ORDER BY total DESC',
            [$dias]
        )->obtenerTodo();
    }

    public function limpiar(int $dias = 180): int
    {
        return $this->sql(
            'DELETE FROM logs_actividad WHERE fecha_hora < DATE_SUB(NOW(), INTERVAL ? DAY)',
            [$dias]
        )->filasAfectadas();
    }
}
