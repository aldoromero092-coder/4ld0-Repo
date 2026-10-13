<?php

namespace App\Models;

use App\Core\Model;

class ConceptoPago extends Model
{
    protected string $tabla = 'conceptos_pago';
    protected string $clavePrimaria = 'id_concepto_pago';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['codigo', 'nombre', 'descripcion', 'es_recurrente', 'categoria', 'orden', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT c.*,
                    (SELECT COUNT(*) FROM aranceles a WHERE a.id_concepto_pago = c.id_concepto_pago) AS total_aranceles
               FROM conceptos_pago c
              ORDER BY c.categoria, c.orden, c.nombre'
        )->obtenerTodo();
    }

    public function opciones(?string $categoria = null): array
    {
        $sql        = 'SELECT id_concepto_pago AS id, codigo, nombre, categoria, es_recurrente,
                              (SELECT MIN(a.monto_base) FROM aranceles a WHERE a.id_concepto_pago = c.id_concepto_pago AND a.estado = "Activo") AS monto
                         FROM conceptos_pago c
                        WHERE c.estado = "Activo"';
        $parametros = [];

        if ($categoria !== null) {
            $sql               .= ' AND c.categoria = ?';
            $parametros[]       = $categoria;
        }

        return $this->sql($sql . ' ORDER BY c.orden, c.nombre', $parametros)->obtenerTodo();
    }

    public function porCodigo(string $codigo): ?array
    {
        return $this->buscarPor('codigo', $codigo);
    }
}
