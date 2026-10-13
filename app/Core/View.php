<?php

namespace App\Core;

/**
 * Motor de plantillas sencillo basado en PHP.
 *
 * Convencion de vistas:
 *   'auth/login'   -> modulos/auth/vistas/login.php
 *   'panel/index'  -> modulos/panel/vistas/index.php
 *   'errores/404'  -> app/Views/errores/404.php   (vistas compartidas)
 */
class View
{
    private static array $globales = [];

    public static function compartir(string $clave, mixed $valor): void
    {
        self::$globales[$clave] = $valor;
    }

    public static function compartidos(): array
    {
        return self::$globales;
    }

    /** Resuelve la ruta fisica de una vista. */
    public static function ubicar(string $vista): ?string
    {
        $vista = trim(str_replace('\\', '/', $vista), '/');
        if (str_contains($vista, '..')) {
            return null;
        }

        $candidatos = [];

        if (str_contains($vista, '/')) {
            [$primero, $resto] = explode('/', $vista, 2);
            $candidatos[] = App::raiz("modulos/{$primero}/vistas/{$resto}.php");
            $candidatos[] = App::raiz("modulos/{$primero}/{$resto}.php");
        }

        $candidatos[] = App::raiz("app/Views/{$vista}.php");
        $candidatos[] = App::raiz("modulos/{$vista}.php");

        foreach ($candidatos as $candidato) {
            if (is_file($candidato)) {
                return $candidato;
            }
        }

        return null;
    }

    /**
     * Renderiza una vista dentro de un layout.
     *
     * @param string      $vista   Vista a mostrar.
     * @param array       $datos   Variables disponibles en la vista.
     * @param string|null $layout  Layout contenedor (null = sin layout).
     */
    public static function render(string $vista, array $datos = [], ?string $layout = 'principal'): void
    {
        $archivo = self::ubicar($vista);
        if ($archivo === null) {
            Response::abortar(500, 'No se encontró la vista solicitada: ' . $vista);
        }

        $datos = array_merge(self::$globales, $datos);

        // El contenido de la vista se captura para inyectarlo en el layout.
        $contenido = self::capturar($archivo, $datos);

        if ($layout === null) {
            echo $contenido;
            return;
        }

        $archivoLayout = App::raiz("app/Views/layouts/{$layout}.php");
        if (!is_file($archivoLayout)) {
            echo $contenido;
            return;
        }

        $datos['contenido'] = $contenido;
        echo self::capturar($archivoLayout, $datos);
    }

    /** Igual que render() pero devuelve el HTML como cadena. */
    public static function html(string $vista, array $datos = []): string
    {
        $archivo = self::ubicar($vista);
        if ($archivo === null) {
            return '';
        }
        return self::capturar($archivo, array_merge(self::$globales, $datos));
    }

    /** Incluye una vista parcial (sin layout). */
    public static function parcial(string $vista, array $datos = []): void
    {
        echo self::html($vista, $datos);
    }

    private static function capturar(string $archivo, array $datos): string
    {
        extract($datos, EXTR_SKIP);
        ob_start();
        try {
            require $archivo;
        } catch (\Throwable $e) {
            ob_end_clean();
            throw $e;
        }
        return (string) ob_get_clean();
    }

    /**
     * Devuelve true si existe un css/js propio del modulo, para incluirlo
     * automaticamente en el layout.
     */
    public static function tieneRecursoModulo(string $modulo, string $extension): bool
    {
        return is_file(App::raiz("modulos/{$modulo}/{$extension}/{$modulo}." . $extension));
    }
}
