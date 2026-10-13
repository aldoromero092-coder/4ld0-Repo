<?php

namespace App\Core;

use PDO;
use PDOException;
use RuntimeException;

/**
 * Conexion PDO unica (patron singleton) con ayudas para consultas seguras.
 */
class Database
{
    private static ?Database $instancia = null;
    private PDO $pdo;
    private int $transacciones = 0;

    private function __construct()
    {
        $cfg = require RAIZ . '/config/database.php';

        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=%s',
            $cfg['host'],
            $cfg['puerto'],
            $cfg['nombre'],
            $cfg['charset']
        );

        try {
            $this->pdo = new PDO($dsn, $cfg['usuario'], $cfg['clave'], $cfg['opciones']);
            $this->pdo->exec("SET time_zone = '-03:00'");
        } catch (PDOException $e) {
            throw new RuntimeException(
                'No se pudo conectar con la base de datos: ' . $e->getMessage(),
                (int) $e->getCode(),
                $e
            );
        }
    }

    public static function instancia(): Database
    {
        return self::$instancia ??= new self();
    }

    public function pdo(): PDO
    {
        return $this->pdo;
    }

    /**
     * Prepara y ejecuta una sentencia.
     *
     * Acepta parametros nombrados (:nombre) o posicionales (?). Los nombrados
     * se normalizan a posicionales para poder reutilizar un mismo marcador
     * varias veces (PDO con prepares nativos no lo permite).
     */
    public function consulta(string $sql, array $parametros = []): Sentencia
    {
        [$sql, $valores] = $this->normalizarParametros($sql, $parametros);

        try {
            if ($valores === []) {
                $stmt = $this->pdo->query($sql);
            } else {
                $stmt = $this->pdo->prepare($sql);
                foreach ($valores as $indice => $valor) {
                    $stmt->bindValue(
                        $indice + 1,
                        $valor,
                        match (true) {
                            is_int($valor)  => PDO::PARAM_INT,
                            is_bool($valor) => PDO::PARAM_BOOL,
                            $valor === null => PDO::PARAM_NULL,
                            default         => PDO::PARAM_STR,
                        }
                    );
                }
                $stmt->execute();
            }
        } catch (PDOException $e) {
            throw new RuntimeException(
                'Error al ejecutar la consulta: ' . $e->getMessage() . ' | SQL: ' . $sql,
                (int) $e->getCode(),
                $e
            );
        }

        return new Sentencia($stmt);
    }

    /**
     * Convierte los parametros nombrados a posicionales y devuelve el SQL
     * junto con la lista ordenada de valores.
     *
     * @return array{0: string, 1: array}
     */
    private function normalizarParametros(string $sql, array $parametros): array
    {
        if ($parametros === [] || array_is_list($parametros)) {
            return [$sql, array_values($parametros)];
        }

        $valores = [];

        $convertido = preg_replace_callback(
            '/\'(?:[^\'\\\\]|\\\\.)*\'|"(?:[^"\\\\]|\\\\.)*"|:([a-zA-Z_][a-zA-Z0-9_]*)/s',
            static function (array $coincidencia) use ($parametros, &$valores): string {
                // Si es un literal de cadena o comentario, no se toca.
                if (!isset($coincidencia[1]) || $coincidencia[1] === '') {
                    return $coincidencia[0];
                }

                $nombre = $coincidencia[1];

                // PDO acepta claves con o sin los dos puntos iniciales.
                foreach ([$nombre, ':' . $nombre] as $clave) {
                    if (array_key_exists($clave, $parametros)) {
                        $valores[] = $parametros[$clave];
                        return '?';
                    }
                }

                return $coincidencia[0];
            },
            $sql
        );

        return [$convertido ?? $sql, $valores];
    }

    public function ultimoId(): int
    {
        return (int) $this->pdo->lastInsertId();
    }

    // ---- Transacciones ----------------------------------------------
    public function iniciarTransaccion(): void
    {
        if ($this->transacciones === 0) {
            $this->pdo->beginTransaction();
        } else {
            $this->pdo->exec('SAVEPOINT sp_' . $this->transacciones);
        }
        $this->transacciones++;
    }

    public function confirmar(): void
    {
        if ($this->transacciones === 0) {
            return;
        }
        $this->transacciones--;
        if ($this->transacciones === 0) {
            $this->pdo->commit();
        }
    }

    public function revertir(): void
    {
        if ($this->transacciones === 0) {
            return;
        }
        $this->transacciones--;
        if ($this->transacciones === 0) {
            if ($this->pdo->inTransaction()) {
                $this->pdo->rollBack();
            }
        } else {
            $this->pdo->exec('ROLLBACK TO SAVEPOINT sp_' . $this->transacciones);
        }
    }

    /** Ejecuta una funcion dentro de una transaccion. */
    public function transaccion(callable $operacion): mixed
    {
        $this->iniciarTransaccion();
        try {
            $resultado = $operacion();
            $this->confirmar();
            return $resultado;
        } catch (\Throwable $e) {
            $this->revertir();
            throw $e;
        }
    }

    public function enTransaccion(): bool
    {
        return $this->transacciones > 0;
    }
}
