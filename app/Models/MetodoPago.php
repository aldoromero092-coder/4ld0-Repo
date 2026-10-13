<?php

namespace App\Models;

use App\Core\Model;

class MetodoPago extends Model
{
    protected string $tabla = 'metodos_pago';
    protected string $clavePrimaria = 'id_metodo_pago';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'tipo', 'estado'];

    public function activos(): array
    {
        return $this->donde(['estado' => 'Activo'], ['nombre' => 'ASC']);
    }

    public function porTipo(string $tipo): ?array
    {
        return $this->primero(['tipo' => $tipo, 'estado' => 'Activo']);
    }
}
