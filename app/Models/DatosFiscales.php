<?php

namespace App\Models;

use App\Core\Model;

class DatosFiscales extends Model
{
    protected string $tabla = 'datos_fiscales';
    protected string $clavePrimaria = 'id_datos_fiscales';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['id_persona', 'ruc', 'razon_social', 'direccion_fiscal', 'telefono_fiscal'];

    public function dePersona(int $idPersona): ?array
    {
        return $this->buscarPor('id_persona', $idPersona);
    }

    public function listar(): array
    {
        return $this->sql(
            'SELECT df.*, per.cedula, CONCAT(per.apellidos, ", ", per.nombres) AS persona,
                    (SELECT COUNT(*) FROM facturas f WHERE f.id_datos_fiscales = df.id_datos_fiscales) AS total_facturas
               FROM datos_fiscales df
               LEFT JOIN personas per ON per.id_persona = df.id_persona
              ORDER BY df.razon_social'
        )->obtenerTodo();
    }
}
