<?php

namespace App\Models;

use App\Core\Model;

class Ciudad extends Model
{
    protected string $tabla = 'ciudades';
    protected string $clavePrimaria = 'id_ciudades';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['nombre', 'id_departamento', 'estado'];

    public function opciones(): array
    {
        return $this->sql('SELECT id_ciudades AS id, nombre FROM ciudades ORDER BY nombre')->obtenerTodo();
    }
}
