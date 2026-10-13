<?php

namespace App\Core;

/**
 * Enrutador HTTP con soporte de parametros, middleware y grupos.
 */
class Router
{
    private array $rutas = [];
    private string $prefijo = '';
    private array $middlewareGrupo = [];

    public function get(string $ruta, mixed $accion, array $middleware = []): void
    {
        $this->registrar('GET', $ruta, $accion, $middleware);
    }

    public function post(string $ruta, mixed $accion, array $middleware = []): void
    {
        $this->registrar('POST', $ruta, $accion, $middleware);
    }

    public function put(string $ruta, mixed $accion, array $middleware = []): void
    {
        $this->registrar('PUT', $ruta, $accion, $middleware);
    }

    public function delete(string $ruta, mixed $accion, array $middleware = []): void
    {
        $this->registrar('DELETE', $ruta, $accion, $middleware);
    }

    /** Agrupa rutas con un prefijo y middleware comun. */
    public function grupo(string $prefijo, array $middleware, callable $definicion): void
    {
        $prefijoAnterior        = $this->prefijo;
        $middlewareAnterior     = $this->middlewareGrupo;

        $this->prefijo         = rtrim($prefijoAnterior . '/' . trim($prefijo, '/'), '/');
        $this->middlewareGrupo = array_merge($middlewareAnterior, $middleware);

        $definicion($this);

        $this->prefijo         = $prefijoAnterior;
        $this->middlewareGrupo = $middlewareAnterior;
    }

    private function registrar(string $metodo, string $ruta, mixed $accion, array $middleware): void
    {
        $completa = $this->prefijo . '/' . trim($ruta, '/');
        $completa = '/' . trim($completa, '/');
        if ($completa === '//') {
            $completa = '/';
        }

        $this->rutas[$metodo][] = [
            'ruta'       => $completa,
            'patron'     => $this->compilar($completa),
            'accion'     => $accion,
            'middleware' => array_merge($this->middlewareGrupo, $middleware),
        ];
    }

    /** Convierte /pagos/comprobante/{id} en una expresion regular. */
    private function compilar(string $ruta): string
    {
        $patron = '';
        $offset = 0;

        if (preg_match_all('/\{(\w+)(?::([^}]+))?\}/', $ruta, $coincidencias, PREG_OFFSET_CAPTURE) > 0) {
            foreach ($coincidencias[0] as $i => $encontrado) {
                [$texto, $posicion] = $encontrado;

                // Parte literal previa al parametro
                $patron .= preg_quote(substr($ruta, $offset, $posicion - $offset), '#');

                $nombre  = $coincidencias[1][$i][0];
                $regla   = $coincidencias[2][$i][0] !== '' ? $coincidencias[2][$i][0] : '[^/]+';
                $patron .= '(?P<' . $nombre . '>' . $regla . ')';

                $offset = $posicion + strlen($texto);
            }
        }

        $patron .= preg_quote(substr($ruta, $offset), '#');

        return '#^' . $patron . '$#u';
    }

    // -----------------------------------------------------------------
    // Despacho
    // -----------------------------------------------------------------

    public function despachar(): void
    {
        $peticion = App::compartido('peticion') ?? Request::capturar();
        $metodo   = $peticion->metodo();
        $ruta     = $peticion->rutaRelativa();

        $coincidencias = $this->rutas[$metodo] ?? [];
        $rutaExiste    = false;

        foreach ($coincidencias as $definicion) {
            if (!preg_match($definicion['patron'], $ruta, $coincidenciasRegex)) {
                continue;
            }
            $rutaExiste = true;

            foreach ($coincidenciasRegex as $clave => $valor) {
                if (is_string($clave)) {
                    $peticion->asignar($clave, $valor);
                }
            }

            $this->ejecutarMiddleware($definicion['middleware'], $peticion);
            $this->ejecutarAccion($definicion['accion'], $peticion);
            return;
        }

        // ¿Existe la ruta con otro metodo? -> 405
        foreach ($this->rutas as $otroMetodo => $lista) {
            if ($otroMetodo === $metodo) {
                continue;
            }
            foreach ($lista as $definicion) {
                if (preg_match($definicion['patron'], $ruta)) {
                    Response::abortar(405, 'El método HTTP ' . $metodo . ' no está permitido para esta ruta.');
                }
            }
        }

        Response::abortar(404, 'La página solicitada no existe.');
    }

    private function ejecutarMiddleware(array $middleware, Request $peticion): void
    {
        foreach ($middleware as $mw) {
            if (is_callable($mw)) {
                $resultado = $mw($peticion);
                if ($resultado === false) {
                    return;
                }
                continue;
            }

            $this->ejecutarMiddlewareNombrado((string) $mw, $peticion);
        }
    }

    private function ejecutarMiddlewareNombrado(string $nombre, Request $peticion): void
    {
        $partes  = explode(':', $nombre, 2);
        $clave   = array_shift($partes);
        $arg     = $partes[0] ?? null;

        switch ($clave) {
            case 'auth':
                if (!Auth::verificado()) {
                    if (Request::esAjax() || Request::esperaJson()) {
                        Response::error('Tu sesión expiró. Volvé a iniciar sesión.', 401);
                    }
                    Session::flash('advertencia', 'Necesitás iniciar sesión para continuar.');
                    Session::guardar('__url_intentada', $peticion->rutaRelativa());
                    Response::redirigir('/login');
                }
                if (Auth::usuario() === null) {
                    Response::abortar(403, 'No pudimos cargar tu perfil de usuario.');
                }
                break;

            case 'invitado':
                if (Auth::verificado()) {
                    Response::redirigir('/panel');
                }
                break;

            case 'rol':
                $roles = explode('|', (string) $arg);
                if (!Auth::tieneRol($roles)) {
                    Logger::seguridad('acceso_denegado', 'Intento de acceso sin permisos a ' . $peticion->rutaRelativa());
                    Response::abortar(403, 'No tenés permisos para acceder a esta sección.');
                }
                break;

            case 'modulo':
                if (!Auth::puede((string) $arg)) {
                    Logger::seguridad('acceso_denegado', 'Modulo restringido: ' . $arg);
                    Response::abortar(403, 'No tenés permisos para acceder a este módulo.');
                }
                break;

            case 'csrf':
                Csrf::verificar();
                break;

            case 'alumno':
                if (Auth::esAlumno() && Auth::idAlumno() === null) {
                    Response::abortar(403, 'Tu usuario no tiene un legajo de alumno asociado. Contactá con la secretaría.');
                }
                break;

            default:
                Response::abortar(500, 'Middleware desconocido: ' . $clave);
        }
    }

    private function ejecutarAccion(mixed $accion, Request $peticion): void
    {
        if (is_callable($accion)) {
            $accion($peticion);
            return;
        }

        if (is_string($accion) && str_contains($accion, '@')) {
            [$clase, $metodo] = explode('@', $accion, 2);

            if (!class_exists($clase)) {
                Response::abortar(500, 'Controlador no encontrado: ' . $clase);
            }

            $controlador = new $clase();

            if (!method_exists($controlador, $metodo)) {
                Response::abortar(500, 'Acción no encontrada: ' . $clase . '::' . $metodo);
            }

            $controlador->{$metodo}($peticion);
            return;
        }

        Response::abortar(500, 'Definición de ruta inválida.');
    }

    public function rutas(): array
    {
        return $this->rutas;
    }
}
