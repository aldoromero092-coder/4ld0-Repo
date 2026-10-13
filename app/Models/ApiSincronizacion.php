<?php

namespace App\Models;

use App\Core\Model;

class ApiSincronizacion extends Model
{
    protected string $tabla = 'api_sincronizaciones';
    protected string $clavePrimaria = 'id_sync';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'origen', 'tipo_dato', 'registros_recibidos', 'registros_nuevos',
        'registros_actualizados', 'registros_error', 'estado', 'mensaje',
        'detalle_errores', 'id_usuario', 'duracion_ms', 'fecha_inicio', 'fecha_fin',
    ];

    public function recientes(int $limite = 20): array
    {
        return $this->sql(
            'SELECT s.*, u.user AS usuario_login
               FROM api_sincronizaciones s
               LEFT JOIN usuarios u ON u.id_usuario = s.id_usuario
              ORDER BY s.fecha_inicio DESC
              LIMIT ' . (int) $limite
        )->obtenerTodo();
    }

    public function ultimaExitos(string $tipoDato): ?array
    {
        return $this->sql(
            'SELECT * FROM api_sincronizaciones WHERE tipo_dato = ? AND estado = "Exitoso"
              ORDER BY fecha_inicio DESC LIMIT 1',
            [$tipoDato]
        )->obtener();
    }
}
