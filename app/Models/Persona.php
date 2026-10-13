<?php

namespace App\Models;

use App\Core\Model;

class Persona extends Model
{
    protected string $tabla = 'personas';
    protected string $clavePrimaria = 'id_persona';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';
    protected array $asignables = [
        'cedula', 'nombres', 'apellidos', 'telefono', 'email', 'celular', 'direccion',
        'id_ciudades', 'fecha_nac', 'estado', 'nacionalidad', 'sexo', 'foto',
    ];

    public function porCedula(string $cedula): ?array
    {
        return $this->buscarPor('cedula', $cedula);
    }

    public function buscarPorNombre(string $texto, int $limite = 20): array
    {
        return $this->sql(
            'SELECT p.*, c.nombre AS ciudad_nombre
               FROM personas p
               LEFT JOIN ciudades c ON c.id_ciudades = p.id_ciudades
              WHERE p.cedula LIKE :t OR p.nombres LIKE :t OR p.apellidos LIKE :t
              ORDER BY p.apellidos, p.nombres
              LIMIT ' . (int) $limite,
            ['t' => '%' . $texto . '%']
        )->obtenerTodo();
    }
}
