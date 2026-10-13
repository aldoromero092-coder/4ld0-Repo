<?php
/**
 * Parametros de conexion a la base de datos.
 * Puede sobreescribirse con variables de entorno (APP_DB_*).
 */

$entorno = static function (string $clave, string $defecto): string {
    $valor = getenv($clave);
    return ($valor === false || $valor === '') ? $defecto : (string) $valor;
};

return [
    'host'    => $entorno('APP_DB_HOST', '127.0.0.1'),
    'puerto'  => (int) $entorno('APP_DB_PORT', '3306'),
    'nombre'  => $entorno('APP_DB_NAME', 'sistema_gestion_academica'),
    'usuario' => $entorno('APP_DB_USER', 'root'),
    'clave'   => $entorno('APP_DB_PASS', ''),
    'charset' => 'utf8mb4',
    'opciones' => [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::ATTR_STRINGIFY_FETCHES  => false,
    ],
];
