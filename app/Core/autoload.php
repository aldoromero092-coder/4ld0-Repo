<?php
/**
 * Cargador automatico de clases (estilo PSR-4 simplificado).
 *
 *   App\Core\Database      ->  app/Core/Database.php
 *   App\Models\Usuario     ->  app/Models/Usuario.php
 *   Modulos\Pagos\PagosController -> modulos/pagos/PagosController.php
 */

spl_autoload_register(static function (string $clase): void {
    $clase = ltrim($clase, '\\');

    // ---- Espacio de nombres de la aplicacion ------------------------
    if (strncmp($clase, 'App\\', 4) === 0) {
        $ruta = RAIZ . '/app/' . str_replace('\\', '/', substr($clase, 4)) . '.php';
        if (is_file($ruta)) {
            require_once $ruta;
        }
        return;
    }

    // ---- Espacio de nombres de los modulos --------------------------
    if (strncmp($clase, 'Modulos\\', 8) === 0) {
        $partes     = explode('\\', $clase);
        $modulo     = strtolower($partes[1] ?? '');
        $claseCorta = end($partes);
        $candidatos = [
            RAIZ . '/modulos/' . $modulo . '/' . $claseCorta . '.php',
            RAIZ . '/modulos/' . $modulo . '/php/' . $claseCorta . '.php',
        ];
        foreach ($candidatos as $ruta) {
            if (is_file($ruta)) {
                require_once $ruta;
                return;
            }
        }
    }
});

/*
 * Alias cortos de las clases del nucleo para usarlos comodamente
 * dentro de las vistas (que no tienen sentencias "use").
 */
foreach ([
    'Session'      => \App\Core\Session::class,
    'Auth'         => \App\Core\Auth::class,
    'Config'       => \App\Core\Config::class,
    'App'          => \App\Core\App::class,
    'View'         => \App\Core\View::class,
    'Csrf'         => \App\Core\Csrf::class,
    'Database'     => \App\Core\Database::class,
    'Logger'       => \App\Core\Logger::class,
    'ValidatorCfg' => \App\Core\Validator::class,
] as $alias => $clase) {
    if (!class_exists($alias, false)) {
        class_alias($clase, $alias);
    }
}
