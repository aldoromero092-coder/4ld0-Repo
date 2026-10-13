<?php

namespace App\Core;

/**
 * Abstraccion de la peticion HTTP entrante.
 */
class Request
{
    private array $post;
    private array $get;
    private array $archivos;
    private array $atributos = [];

    public function __construct()
    {
        $this->post     = $_POST;
        $this->get      = $_GET;
        $this->archivos = $_FILES;

        // Cuerpos JSON (AJAX con Content-Type: application/json)
        $tipo = strtolower((string) ($_SERVER['CONTENT_TYPE'] ?? ''));
        if (str_contains($tipo, 'application/json')) {
            $crudo = file_get_contents('php://input');
            if (is_string($crudo) && $crudo !== '') {
                $json = json_decode($crudo, true);
                if (is_array($json)) {
                    $this->post = array_merge($json, $this->post);
                }
            }
        }
    }

    public static function capturar(): self
    {
        return new self();
    }

    // ---- Metodos basicos --------------------------------------------
    public function metodo(): string
    {
        $metodo = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');

        // Soporte de _method oculto para PUT/DELETE desde formularios
        if ($metodo === 'POST' && isset($this->post['_method'])) {
            $metodo = strtoupper((string) $this->post['_method']);
        }

        return $metodo;
    }

    public function esPost(): bool
    {
        return $this->metodo() === 'POST';
    }

    public function esGet(): bool
    {
        return $this->metodo() === 'GET';
    }

    public function uri(): string
    {
        $uri = (string) ($_SERVER['REQUEST_URI'] ?? '/');
        $pos = strpos($uri, '?');
        return $pos === false ? $uri : substr($uri, 0, $pos);
    }

    public function rutaRelativa(): string
    {
        $base = App::urlBase();
        $uri  = $this->uri();

        if ($base !== '' && strncmp($uri, $base, strlen($base)) === 0) {
            $uri = substr($uri, strlen($base));
        }

        $uri = '/' . trim(rawurldecode($uri), '/');

        // Acceso explicito al controlador frontal -> raiz
        if ($uri === '/index.php') {
            return '/';
        }

        return $uri === '/' ? '/' : rtrim($uri, '/');
    }

    // ---- Entradas -----------------------------------------------------
    public function todo(): array
    {
        return array_merge($this->get, $this->post);
    }

    public function entrada(string $clave, mixed $defecto = null): mixed
    {
        return $this->post[$clave] ?? $this->get[$clave] ?? $defecto;
    }

    public function texto(string $clave, string $defecto = ''): string
    {
        $valor = $this->entrada($clave, $defecto);
        if (is_array($valor)) {
            return $defecto;
        }
        return trim((string) $valor);
    }

    public function entero(string $clave, int $defecto = 0): int
    {
        $valor = $this->entrada($clave);
        return $valor === null || $valor === '' ? $defecto : (int) $valor;
    }

    public function decimal(string $clave, float $defecto = 0.0): float
    {
        $valor = $this->entrada($clave);
        if ($valor === null || $valor === '') {
            return $defecto;
        }
        return (float) str_replace([' ', '.', ','], ['', '', '.'], (string) $valor);
    }

    public function booleano(string $clave, bool $defecto = false): bool
    {
        $valor = $this->entrada($clave);
        if ($valor === null) {
            return $defecto;
        }
        return in_array(strtolower((string) $valor), ['1', 'true', 'on', 'si', 'sí', 'yes'], true);
    }

    public function arreglo(string $clave, array $defecto = []): array
    {
        $valor = $this->entrada($clave, $defecto);
        return is_array($valor) ? $valor : $defecto;
    }

    public function solo(array $claves): array
    {
        $resultado = [];
        foreach ($claves as $clave) {
            $resultado[$clave] = $this->entrada($clave);
        }
        return $resultado;
    }

    public function tiene(string $clave): bool
    {
        return isset($this->post[$clave]) || isset($this->get[$clave]);
    }

    // ---- Archivos -----------------------------------------------------
    public function archivo(string $clave): ?array
    {
        $archivo = $this->archivos[$clave] ?? null;
        if ($archivo === null || ($archivo['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
            return null;
        }
        return $archivo;
    }

    // ---- Contexto de la peticion --------------------------------------
    public function ip(): string
    {
        foreach (['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'REMOTE_ADDR'] as $cabecera) {
            if (!empty($_SERVER[$cabecera])) {
                $valor = explode(',', (string) $_SERVER[$cabecera])[0];
                return substr(trim($valor), 0, 45);
            }
        }
        return '0.0.0.0';
    }

    public function userAgent(): string
    {
        return substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255);
    }

    public function navegador(): string
    {
        $ua = strtolower($this->userAgent());
        return match (true) {
            str_contains($ua, 'edg/')                        => 'Edge',
            str_contains($ua, 'opr/') || str_contains($ua, 'opera') => 'Opera',
            str_contains($ua, 'chrome')                      => 'Chrome',
            str_contains($ua, 'firefox')                     => 'Firefox',
            str_contains($ua, 'safari')                      => 'Safari',
            default                                          => 'Desconocido',
        };
    }

    public function plataforma(): string
    {
        $ua = strtolower($this->userAgent());
        return match (true) {
            str_contains($ua, 'android')                     => 'Android',
            str_contains($ua, 'iphone') || str_contains($ua, 'ipad') => 'iOS',
            str_contains($ua, 'windows')                     => 'Windows',
            str_contains($ua, 'mac os')                      => 'macOS',
            str_contains($ua, 'linux')                       => 'Linux',
            default                                          => 'Desconocida',
        };
    }

    public static function esAjax(): bool
    {
        return strtolower((string) ($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '')) === 'xmlhttprequest';
    }

    public static function esperaJson(): bool
    {
        $accept = strtolower((string) ($_SERVER['HTTP_ACCEPT'] ?? ''));
        $tipo   = strtolower((string) ($_SERVER['CONTENT_TYPE'] ?? ''));
        return str_contains($accept, 'application/json') || str_contains($tipo, 'application/json');
    }

    public static function esMovil(): bool
    {
        $ua = strtolower((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''));
        return (bool) preg_match('/android|iphone|ipad|ipod|mobile|windows phone|blackberry/', $ua);
    }

    // ---- Atributos internos (parametros de ruta) ----------------------
    public function asignar(string $clave, mixed $valor): void
    {
        $this->atributos[$clave] = $valor;
    }

    public function atributo(string $clave, mixed $defecto = null): mixed
    {
        return $this->atributos[$clave] ?? $defecto;
    }

    public function atributos(): array
    {
        return $this->atributos;
    }
}
