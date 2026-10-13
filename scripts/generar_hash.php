<?php
/**
 * Generador de hashes bcrypt.
 * Uso: php scripts/generar_hash.php "miPassword"
 */
$pass = $argv[1] ?? 'Unves.2026';
echo password_hash($pass, PASSWORD_BCRYPT), PHP_EOL;
