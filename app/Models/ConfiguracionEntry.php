<?php

namespace App\Models;

use App\Core\Model;

class ConfiguracionEntry extends Model
{
    protected string $tabla = 'configuracion';
    protected string $clavePrimaria = 'clave';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['clave', 'valor', 'tipo', 'grupo', 'descripcion'];

    public function todosAgrupados(): array
    {
        $filas = $this->sql('SELECT * FROM configuracion ORDER BY grupo, clave')->obtenerTodo();
        $grupos = [];
        foreach ($filas as $fila) {
            $grupos[$fila['grupo']][] = $fila;
        }
        return $grupos;
    }

    public function guardarValor(string $clave, ?string $valor): void
    {
        $this->sql(
            'INSERT INTO configuracion (clave, valor, fecha_actualizacion) VALUES (?, ?, NOW())
             ON DUPLICATE KEY UPDATE valor = VALUES(valor), fecha_actualizacion = NOW()',
            [$clave, $valor]
        );
    }

    public function valor(string $clave, mixed $defecto = null): mixed
    {
        $fila = $this->buscar($clave);
        return $fila === null ? $defecto : $fila['valor'];
    }
}
