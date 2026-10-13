<?php

namespace App\Core;

/**
 * Acceso centralizado a la configuracion (config/*.php).
 * Soporta notacion con puntos: Config::obtener('app.whatsapp').
 */
class Config
{
    private static ?array $datos = null;
    private static array $cargados = [];

    /** Carga (una sola vez) todos los archivos de configuracion. */
    public static function cargar(): void
    {
        if (self::$datos !== null) {
            return;
        }

        self::$datos = [];
        foreach (glob(RAIZ . '/config/*.php') ?: [] as $archivo) {
            $nombre = basename($archivo, '.php');
            $valor  = require $archivo;
            if (is_array($valor)) {
                self::$datos[$nombre] = $valor;
            }
        }

        self::cargarDesdeBase();
    }

    /**
     * Sobreescribe la configuracion con los valores guardados en la tabla
     * `configuracion`. Se ignora silenciosamente si la base no responde
     * todavia (por ejemplo durante la instalacion).
     */
    private static function cargarDesdeBase(): void
    {
        try {
            $filas = Database::instancia()
                ->consulta('SELECT clave, valor, tipo FROM configuracion')
                ->obtenerTodo();
        } catch (\Throwable) {
            return;
        }

        foreach ($filas as $fila) {
            $clave = (string) $fila['clave'];
            $valor = $fila['valor'];

            if ($valor !== null) {
                $valor = match ($fila['tipo']) {
                    'numero'   => (int) $valor,
                    'decimal'  => (float) $valor,
                    'booleano' => (bool) (int) $valor,
                    default    => $valor,
                };
            }

            self::establecer('dinamico.' . $clave, $valor);
        }
    }

    public static function obtener(string $ruta, mixed $defecto = null): mixed
    {
        self::cargar();

        $nodo = self::$datos;
        foreach (explode('.', $ruta) as $clave) {
            if (!is_array($nodo) || !array_key_exists($clave, $nodo)) {
                return $defecto;
            }
            $nodo = $nodo[$clave];
        }

        return $nodo;
    }

    public static function establecer(string $ruta, mixed $valor): void
    {
        self::cargar();

        $partes = explode('.', $ruta);
        $nodo   = &self::$datos;
        foreach ($partes as $clave) {
            if (!isset($nodo[$clave]) || !is_array($nodo[$clave])) {
                $nodo[$clave] = [];
            }
            $nodo = &$nodo[$clave];
        }
        $nodo = $valor;
    }

    public static function existe(string $ruta): bool
    {
        return self::obtener($ruta, '__NO_EXISTE__') !== '__NO_EXISTE__';
    }

    /** Lee un parametro dinamico guardado en la tabla `configuracion`. */
    public static function dinamico(string $clave, mixed $defecto = null): mixed
    {
        return self::obtener('dinamico.' . $clave, $defecto);
    }

    public static function todo(): array
    {
        self::cargar();
        return self::$datos;
    }
}
