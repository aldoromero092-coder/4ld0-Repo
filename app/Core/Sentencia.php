<?php

namespace App\Core;

use PDOStatement;

/**
 * Envoltorio de PDOStatement con metodos de lectura comodos.
 */
class Sentencia
{
    public function __construct(private PDOStatement $stmt)
    {
    }

    public function obtenerTodo(): array
    {
        return $this->stmt->fetchAll();
    }

    public function obtener(): ?array
    {
        $fila = $this->stmt->fetch();
        return $fila === false ? null : $fila;
    }

    public function valor(int|string|null $columna = null): mixed
    {
        if ($columna === null) {
            return $this->stmt->fetchColumn();
        }
        $fila = $this->obtener();
        return $fila[$columna] ?? null;
    }

    public function entero(): int
    {
        return (int) $this->stmt->fetchColumn();
    }

    public function decimal(): float
    {
        return (float) $this->stmt->fetchColumn();
    }

    public function lista(string $columna): array
    {
        return array_map(static fn (array $f) => $f[$columna] ?? null, $this->obtenerTodo());
    }

    /** Devuelve [clave => valor] a partir de dos columnas. */
    public function pares(string $clave, string $valor): array
    {
        $resultado = [];
        foreach ($this->obtenerTodo() as $fila) {
            $resultado[$fila[$clave]] = $fila[$valor];
        }
        return $resultado;
    }

    public function filasAfectadas(): int
    {
        return $this->stmt->rowCount();
    }

    public function stmt(): PDOStatement
    {
        return $this->stmt;
    }
}
