<?php

namespace App\Models;

use App\Core\Model;

class PasswordReset extends Model
{
    protected string $tabla = 'password_resets';
    protected string $clavePrimaria = 'id_reset';
    protected string $colCreado = '';
    protected string $colActualizado = '';
    protected array $asignables = ['id_usuario', 'token', 'expira_en', 'usado', 'ip_solicitud'];

    public function crearToken(int $idUsuario, int $minutosVida = 60, string $ip = ''): string
    {
        $token = bin2hex(random_bytes(32));

        $this->sql('UPDATE password_resets SET usado = 1 WHERE id_usuario = ? AND usado = 0', [$idUsuario]);
        $this->sql(
            'INSERT INTO password_resets (id_usuario, token, expira_en, usado, ip_solicitud)
             VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE), 0, ?)',
            [$idUsuario, hash('sha256', $token), $minutosVida, $ip]
        );

        return $token;
    }

    public function valido(string $token): ?array
    {
        return $this->sql(
            'SELECT * FROM password_resets
              WHERE token = ? AND usado = 0 AND expira_en > NOW()
              LIMIT 1',
            [hash('sha256', $token)]
        )->obtener();
    }

    public function consumir(string $token): void
    {
        $this->sql('UPDATE password_resets SET usado = 1 WHERE token = ?', [hash('sha256', $token)]);
    }

    public function limpiar(): int
    {
        return $this->sql('DELETE FROM password_resets WHERE expira_en < DATE_SUB(NOW(), INTERVAL 1 DAY)')->filasAfectadas();
    }
}
