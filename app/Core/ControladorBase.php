<?php

namespace App\Core;

use App\Core\Database;

/**
 * Controlador base con utilidades compartidas por todos los modulos.
 */
abstract class ControladorBase
{
    protected Request $peticion;
    protected string $modulo = '';

    public function __construct()
    {
        App::compartir('peticion', App::compartido('peticion') ?? Request::capturar());
        $this->peticion = App::compartido('peticion');
    }

    // ---- Render -------------------------------------------------------
    protected function vista(string $vista, array $datos = [], ?string $layout = 'principal'): void
    {
        $this->prepararContexto($datos);
        View::render($vista, $datos, $layout);
    }

    protected function vistaCruda(string $vista, array $datos = []): void
    {
        $this->prepararContexto($datos);
        View::render($vista, $datos, null);
    }

    private function prepararContexto(array &$datos): void
    {
        $modulo = $this->modulo !== '' ? $this->modulo : (explode('/', $this->vistaActual())[0] ?: '');
        App::compartir('modulo', $modulo);

        $datos['modulo']  = $modulo;
        $datos['usuario'] = $datos['usuario'] ?? Auth::usuario();
        $datos['flash']   = $datos['flash'] ?? Session::obtenerFlash();

        if (!isset($datos['notificaciones'])) {
            $datos['notificaciones'] = 0;
            $idUsuario = Auth::id();
            if ($idUsuario !== null) {
                try {
                    $datos['notificaciones'] = (int) Database::instancia()
                        ->consulta('SELECT COUNT(*) FROM notificaciones WHERE id_usuario = ? AND leida = 0', [$idUsuario])
                        ->entero();
                } catch (\Throwable) {
                    // Si falla no bloqueamos el render
                }
            }
        }

        foreach (App::compartido() as $clave => $valor) {
            $datos[$clave] = $datos[$clave] ?? $valor;
        }
    }

    private function vistaActual(): string
    {
        return ltrim($this->peticion->rutaRelativa(), '/');
    }

    // ---- Respuestas rapidas -------------------------------------------
    protected function json(array $datos, int $codigo = 200): never
    {
        Response::json($datos, $codigo);
    }

    protected function ok(string $mensaje = 'Operación realizada con éxito.', array $datos = []): never
    {
        Response::exito($mensaje, $datos);
    }

    protected function error(string $mensaje = 'Ocurrió un error.', int $codigo = 400, array $datos = []): never
    {
        Response::error($mensaje, $codigo, $datos);
    }

    protected function redirigir(string $ruta): never
    {
        Response::redirigir($ruta);
    }

    protected function volver(): never
    {
        Response::volver();
    }

    /** Redirige de vuelta con los errores de validacion en sesion. */
    protected function volverConErrores(array $errores, array $entrada = [], ?string $destino = null): never
    {
        Session::recordarErrores($errores);
        if ($entrada !== []) {
            Session::recordarEntrada($entrada);
        }
        $destino = $destino ?? ($_SERVER['HTTP_REFERER'] ?? '/');
        Response::redirigir($destino);
    }

    protected function volverConExito(string $mensaje, ?string $destino = null): never
    {
        Session::flash('exito', $mensaje);
        Response::redirigir($destino ?? ($_SERVER['HTTP_REFERER'] ?? '/'));
    }

    // ---- Helpers -------------------------------------------------------
    protected function exigirPost(): void
    {
        if (!$this->peticion->esPost()) {
            Response::abortar(405, 'Esta acción requiere el método POST.');
        }
    }

    protected function validar(array $reglas): Validator
    {
        return Validator::crear($this->peticion->todo(), $reglas)->validar();
    }

    protected function pagina(int $defecto = 1): int
    {
        return max(1, $this->peticion->entero('pagina', $defecto));
    }

    protected function porPagina(int $defecto = 15, int $maximo = 100): int
    {
        return min($maximo, max(5, $this->peticion->entero('por_pagina', $defecto)));
    }
}
