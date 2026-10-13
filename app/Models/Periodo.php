<?php

namespace App\Models;

use App\Core\Model;

class Periodo extends Model
{
    protected string $tabla = 'periodos_academicos';
    protected string $clavePrimaria = 'id_periodo';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'fecha_inicio', 'fecha_fin', 'estado'];

    public function actual(): ?array
    {
        return $this->primero(['estado' => 'Activo'], ['fecha_inicio' => 'DESC']);
    }

    public function listar(): array
    {
        return $this->sql(
            'SELECT p.*,
                    (SELECT COUNT(*) FROM matriculas m WHERE m.id_periodo = p.id_periodo) AS total_matriculas,
                    (SELECT COUNT(*) FROM examenes e WHERE e.id_periodo = p.id_periodo) AS total_examenes
               FROM periodos_academicos p
              ORDER BY p.fecha_inicio DESC'
        )->obtenerTodo();
    }

    public function opciones(): array
    {
        return $this->sql('SELECT id_periodo AS id, nombre, estado FROM periodos_academicos ORDER BY fecha_inicio DESC')->obtenerTodo();
    }

    /** Marca un periodo como activo y desactiva los demas. */
    public function activar(int $idPeriodo): void
    {
        $this->sql('UPDATE periodos_academicos SET estado = "Cerrado" WHERE id_periodo <> ? AND estado = "Activo"', [$idPeriodo]);
        $this->sql('UPDATE periodos_academicos SET estado = "Activo" WHERE id_periodo = ?', [$idPeriodo]);
    }
}
