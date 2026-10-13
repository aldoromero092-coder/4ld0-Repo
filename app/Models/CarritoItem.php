<?php

namespace App\Models;

use App\Core\Model;

class CarritoItem extends Model
{
    protected string $tabla = 'carrito_items';
    protected string $clavePrimaria = 'id_item';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['id_usuario', 'id_obligacion'];

    /** Contenido del carrito con el detalle de cada obligacion. */
    public function deUsuario(int $idUsuario): array
    {
        return $this->sql(
            'SELECT ci.id_item, ci.fecha_agregado, o.*, cp.nombre AS concepto_nombre,
                    cp.categoria AS concepto_categoria, p.nombre AS periodo_nombre,
                    a.legajo, c.nombre AS carrera_nombre
               FROM carrito_items ci
               INNER JOIN obligaciones_pago o ON o.id_obligacion = ci.id_obligacion
               LEFT JOIN conceptos_pago cp    ON cp.id_concepto_pago = o.id_concepto_pago
               LEFT JOIN periodos_academicos p ON p.id_periodo = o.id_periodo
               INNER JOIN alumnos a           ON a.id_alumno = o.id_alumno
               LEFT JOIN carreras c           ON c.id_carrera = a.id_carrera
              WHERE ci.id_usuario = ?
              ORDER BY ci.fecha_agregado',
            [$idUsuario]
        )->obtenerTodo();
    }

    public function total(int $idUsuario): float
    {
        return (float) $this->sql(
            'SELECT COALESCE(SUM(o.saldo),0)
               FROM carrito_items ci
               INNER JOIN obligaciones_pago o ON o.id_obligacion = ci.id_obligacion
              WHERE ci.id_usuario = ? AND o.estado IN ("Pendiente","Vencido","Parcial")',
            [$idUsuario]
        )->decimal();
    }

    public function cantidad(int $idUsuario): int
    {
        return parent::contar(['id_usuario' => $idUsuario]);
    }

    public function agregar(int $idUsuario, int $idObligacion): bool
    {
        try {
            $this->sql(
                'INSERT IGNORE INTO carrito_items (id_usuario, id_obligacion, fecha_agregado) VALUES (?, ?, NOW())',
                [$idUsuario, $idObligacion]
            );
            return true;
        } catch (\Throwable) {
            return false;
        }
    }

    public function quitar(int $idUsuario, int $idObligacion): int
    {
        return $this->sql(
            'DELETE FROM carrito_items WHERE id_usuario = ? AND id_obligacion = ?',
            [$idUsuario, $idObligacion]
        )->filasAfectadas();
    }

    public function vaciar(int $idUsuario): int
    {
        return $this->sql('DELETE FROM carrito_items WHERE id_usuario = ?', [$idUsuario])->filasAfectadas();
    }

    public function yaEsta(int $idUsuario, int $idObligacion): bool
    {
        return $this->contar(['id_usuario' => $idUsuario, 'id_obligacion' => $idObligacion]) > 0;
    }
}
