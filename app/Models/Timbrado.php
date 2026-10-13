<?php

namespace App\Models;

use App\Core\Model;

class Timbrado extends Model
{
    protected string $tabla = 'timbrados';
    protected string $clavePrimaria = 'id_timbrado';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = [
        'id_sede', 'numero_timbrado', 'tipo_documento', 'punto_expedicion', 'establecimiento',
        'fecha_inicio_vigencia', 'fecha_fin_vigencia', 'numero_inicio', 'numero_fin',
        'numero_actual', 'estado',
    ];

    public function listar(): array
    {
        return $this->sql(
            'SELECT t.*, s.nombre AS sede_nombre,
                    CASE WHEN t.fecha_fin_vigencia IS NOT NULL AND t.fecha_fin_vigencia < CURDATE()
                         THEN "Vencido" ELSE t.estado END AS estado_real,
                    (t.numero_fin - t.numero_actual) AS disponibles
               FROM timbrados t
               LEFT JOIN sedes s ON s.id_sede = t.id_sede
              ORDER BY t.fecha_inicio_vigencia DESC'
        )->obtenerTodo();
    }

    /** Consume el siguiente numero del timbrado de forma atomica. */
    public function consumir(int $idTimbrado): ?int
    {
        $db = $this->db();
        return (int) $db->transaccion(function () use ($idTimbrado) {
            $fila = $this->sql('SELECT numero_actual, numero_fin FROM timbrados WHERE id_timbrado = ? FOR UPDATE', [$idTimbrado])->obtener();
            if ($fila === null) {
                return 0;
            }

            $siguiente = (int) $fila['numero_actual'] + 1;
            if ($siguiente > (int) $fila['numero_fin']) {
                return 0;
            }

            $this->sql('UPDATE timbrados SET numero_actual = ? WHERE id_timbrado = ?', [$siguiente, $idTimbrado]);
            return $siguiente;
        });
    }
}
