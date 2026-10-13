<?php

namespace App\Core;

/**
 * Modelo base. Aporta operaciones CRUD genericas sobre una tabla.
 */
abstract class Model
{
    /** Nombre de la tabla (sin prefijo de base). */
    protected string $tabla = '';

    /** Clave primaria. */
    protected string $clavePrimaria = 'id';

    /** Columnas permitidas para escritura masiva. */
    protected array $asignables = [];

    /** Nombre de la columna de creacion. Cadena vacia = no existe. */
    protected string $colCreado = 'creado_en';

    /** Nombre de la columna de actualizacion. Cadena vacia = no existe. */
    protected string $colActualizado = 'actualizado_en';

    protected function db(): Database
    {
        return Database::instancia();
    }

    public function tabla(): string
    {
        return $this->tabla;
    }

    public function clavePrimaria(): string
    {
        return $this->clavePrimaria;
    }

    // -----------------------------------------------------------------
    // Lecturas
    // -----------------------------------------------------------------

    public function buscar(int|string $id): ?array
    {
        return $this->db()
            ->consulta("SELECT * FROM `{$this->tabla}` WHERE `{$this->clavePrimaria}` = ? LIMIT 1", [$id])
            ->obtener();
    }

    public function buscarPor(string $columna, mixed $valor): ?array
    {
        return $this->db()
            ->consulta("SELECT * FROM `{$this->tabla}` WHERE `{$columna}` = ? LIMIT 1", [$valor])
            ->obtener();
    }

    public function todos(array $orden = [], ?int $limite = null): array
    {
        $sql = "SELECT * FROM `{$this->tabla}`";
        if ($orden !== []) {
            $partes = [];
            foreach ($orden as $columna => $dir) {
                $dir = strtoupper((string) $dir) === 'DESC' ? 'DESC' : 'ASC';
                $partes[] = "`{$columna}` {$dir}";
            }
            $sql .= ' ORDER BY ' . implode(', ', $partes);
        }
        if ($limite !== null) {
            $sql .= ' LIMIT ' . (int) $limite;
        }

        return $this->db()->consulta($sql)->obtenerTodo();
    }

    public function donde(
        array $condiciones,
        array $orden = [],
        ?int $limite = null,
        int $desplazamiento = 0
    ): array {
        [$where, $parametros] = $this->construirWhere($condiciones);

        $sql = "SELECT * FROM `{$this->tabla}`{$where}";
        $sql .= $this->construirOrden($orden);
        if ($limite !== null) {
            $sql .= ' LIMIT ' . (int) $limite . ' OFFSET ' . (int) $desplazamiento;
        }

        return $this->db()->consulta($sql, $parametros)->obtenerTodo();
    }

    public function primero(array $condiciones, array $orden = []): ?array
    {
        $filas = $this->donde($condiciones, $orden, 1);
        return $filas[0] ?? null;
    }

    public function contar(array $condiciones = []): int
    {
        [$where, $parametros] = $this->construirWhere($condiciones);
        return $this->db()
            ->consulta("SELECT COUNT(*) FROM `{$this->tabla}`{$where}", $parametros)
            ->entero();
    }

    public function existe(array $condiciones): bool
    {
        return $this->contar($condiciones) > 0;
    }

    /** Consulta libre con parametros. Debe usarse desde el propio modelo. */
    public function sql(string $sql, array $parametros = []): Sentencia
    {
        return $this->db()->consulta($sql, $parametros);
    }

    // -----------------------------------------------------------------
    // Escrituras
    // -----------------------------------------------------------------

    public function crear(array $datos): int
    {
        $datos = $this->filtrarAsignables($datos);
        if ($this->colCreado !== '' && !array_key_exists($this->colCreado, $datos)) {
            $datos[$this->colCreado] = date('Y-m-d H:i:s');
        }
        if ($datos === []) {
            return 0;
        }

        $columnas     = array_keys($datos);
        $marcadores   = array_map(static fn ($c) => ':' . $c, $columnas);
        $sql = sprintf(
            'INSERT INTO `%s` (`%s`) VALUES (%s)',
            $this->tabla,
            implode('`, `', $columnas),
            implode(', ', $marcadores)
        );

        $this->db()->consulta($sql, $this->parametros($datos));

        return $this->db()->ultimoId();
    }

    public function actualizar(int|string $id, array $datos): int
    {
        $datos = $this->filtrarAsignables($datos);
        if ($this->colActualizado !== '') {
            $datos[$this->colActualizado] = date('Y-m-d H:i:s');
        }
        if ($datos === []) {
            return 0;
        }

        $asignaciones = [];
        foreach (array_keys($datos) as $columna) {
            $asignaciones[] = "`{$columna}` = :{$columna}";
        }

        $sql = sprintf(
            'UPDATE `%s` SET %s WHERE `%s` = :__id',
            $this->tabla,
            implode(', ', $asignaciones),
            $this->clavePrimaria
        );

        $parametros             = $this->parametros($datos);
        $parametros['__id']     = $id;

        return $this->db()->consulta($sql, $parametros)->filasAfectadas();
    }

    public function eliminar(int|string $id): int
    {
        return $this->db()
            ->consulta("DELETE FROM `{$this->tabla}` WHERE `{$this->clavePrimaria}` = ?", [$id])
            ->filasAfectadas();
    }

    /** Inserta o actualiza segun una clave unica existente. */
    public function actualizarOCrear(array $condiciones, array $datos): int
    {
        $existente = $this->primero($condiciones);
        if ($existente !== null) {
            $this->actualizar($existente[$this->clavePrimaria], $datos);
            return (int) $existente[$this->clavePrimaria];
        }
        return $this->crear(array_merge($condiciones, $datos));
    }

    // -----------------------------------------------------------------
    // Utilidades internas
    // -----------------------------------------------------------------

    protected function filtrarAsignables(array $datos): array
    {
        if ($this->asignables === []) {
            return $datos;
        }
        return array_intersect_key($datos, array_flip($this->asignables));
    }

    protected function construirWhere(array $condiciones): array
    {
        if ($condiciones === []) {
            return ['', []];
        }

        $partes     = [];
        $parametros = [];
        $i          = 0;

        foreach ($condiciones as $columna => $valor) {
            $marcador = ':w' . $i++;

            if (is_array($valor)) {
                $operador = strtoupper((string) ($valor['op'] ?? '='));
                $crudo    = $valor['valor'] ?? null;

                switch ($operador) {
                    case 'IN':
                        $marcadores = [];
                        foreach ((array) $crudo as $k => $v) {
                            $mk            = $marcador . '_' . $k;
                            $marcadores[]  = $mk;
                            $parametros[$mk] = $v;
                        }
                        if ($marcadores === []) {
                            $partes[] = '1 = 0';
                        } else {
                            $partes[] = sprintf('`%s` IN (%s)', $columna, implode(', ', $marcadores));
                        }
                        break;
                    case 'IS NULL':
                        $partes[] = "`{$columna}` IS NULL";
                        break;
                    case 'IS NOT NULL':
                        $partes[] = "`{$columna}` IS NOT NULL";
                        break;
                    case 'LIKE':
                        $partes[] = "`{$columna}` LIKE {$marcador}";
                        $parametros[$marcador] = $crudo;
                        break;
                    default:
                        $partes[] = "`{$columna}` {$operador} {$marcador}";
                        $parametros[$marcador] = $crudo;
                }
                continue;
            }

            if ($valor === null) {
                $partes[] = "`{$columna}` IS NULL";
                continue;
            }

            $partes[]              = "`{$columna}` = {$marcador}";
            $parametros[$marcador] = $valor;
        }

        return [' WHERE ' . implode(' AND ', $partes), $parametros];
    }

    protected function construirOrden(array $orden): string
    {
        if ($orden === []) {
            return '';
        }

        $partes = [];
        foreach ($orden as $columna => $dir) {
            $dir = strtoupper((string) $dir) === 'DESC' ? 'DESC' : 'ASC';
            $partes[] = "`{$columna}` {$dir}";
        }

        return ' ORDER BY ' . implode(', ', $partes);
    }

    protected function parametros(array $datos): array
    {
        $parametros = [];
        foreach ($datos as $columna => $valor) {
            $parametros[$columna] = is_bool($valor) ? (int) $valor : $valor;
        }
        return $parametros;
    }
}
