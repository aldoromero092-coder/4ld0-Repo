<?php

namespace App\Models;

use App\Core\Model;

class Auditoria extends Model
{
    protected string $tabla = 'auditorias';
    protected string $clavePrimaria = 'id_auditoria';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_usuario', 'tabla_afectada', 'registro_id', 'accion',
        'valores_anteriores', 'valores_nuevos', 'ip_origen',
    ];

    public function listar(array $filtros = [], int $limite = 30, int $desplazamiento = 0): array
    {
        $condiciones = [];
        $parametros  = [];

        foreach (['tabla_afectada', 'accion'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "a.`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['id_usuario'])) {
            $condiciones[]           = 'a.id_usuario = :id_usuario';
            $parametros['id_usuario'] = (int) $filtros['id_usuario'];
        }
        if (!empty($filtros['registro_id'])) {
            $condiciones[]            = 'a.registro_id = :registro_id';
            $parametros['registro_id'] = $filtros['registro_id'];
        }
        if (!empty($filtros['desde'])) {
            $condiciones[]       = 'DATE(a.fecha_hora) >= :desde';
            $parametros['desde'] = $filtros['desde'];
        }
        if (!empty($filtros['hasta'])) {
            $condiciones[]       = 'DATE(a.fecha_hora) <= :hasta';
            $parametros['hasta'] = $filtros['hasta'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);

        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            "SELECT a.*, u.user AS usuario_login,
                    CONCAT(per.nombres, ' ', per.apellidos) AS usuario_nombre
               FROM auditorias a
               LEFT JOIN usuarios u    ON u.id_usuario = a.id_usuario
               LEFT JOIN personas per  ON per.id_persona = u.id_persona
               {$where}
              ORDER BY a.fecha_hora DESC, a.id_auditoria DESC
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        $condiciones = [];
        $parametros  = [];

        foreach (['tabla_afectada', 'accion'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]      = "`{$campo}` = :{$campo}";
                $parametros[$campo] = $filtros[$campo];
            }
        }
        if (!empty($filtros['id_usuario'])) {
            $condiciones[]           = 'id_usuario = :id_usuario';
            $parametros['id_usuario'] = (int) $filtros['id_usuario'];
        }

        $where = $condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones);
        return $this->sql("SELECT COUNT(*) FROM auditorias {$where}", $parametros)->entero();
    }

    public function conDetalle(int $id): ?array
    {
        return $this->sql(
            'SELECT a.*, u.user AS usuario_login,
                    CONCAT(per.nombres, " ", per.apellidos) AS usuario_nombre
               FROM auditorias a
               LEFT JOIN usuarios u ON u.id_usuario = a.id_usuario
               LEFT JOIN personas per ON per.id_persona = u.id_persona
              WHERE a.id_auditoria = ? LIMIT 1',
            [$id]
        )->obtener();
    }

    public function tablaAfectadaOpciones(): array
    {
        return $this->sql('SELECT DISTINCT tabla_afectada FROM auditorias ORDER BY tabla_afectada')->lista('tabla_afectada');
    }
}
