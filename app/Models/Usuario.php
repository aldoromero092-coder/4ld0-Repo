<?php

namespace App\Models;

use App\Core\Model;

class Usuario extends Model
{
    protected string $tabla = 'usuarios';
    protected string $clavePrimaria = 'id_usuario';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';
    protected array $asignables = [
        'user', 'email', 'id_persona', 'pass', 'estado', 'id_rol', 'sucursal_cod',
        'claveprimaria', 'sucursal', 'facultad', 'ultimo_acceso', 'intentos_fallidos',
        'bloqueado_hasta', 'debe_cambiar_pass', 'token_recuerdo',
    ];

    /** Listado paginado con datos de la persona y su rol. */
    public function listar(array $filtros = [], int $limite = 15, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtrosSql($filtros);

        $parametros['limite']       = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            "SELECT u.*, r.nombre AS rol_nombre,
                    p.cedula, p.nombres, p.apellidos, p.telefono, p.email AS persona_email
               FROM usuarios u
               LEFT JOIN roles r    ON r.id_rol = u.id_rol
               LEFT JOIN personas p ON p.id_persona = u.id_persona
               {$where}
              ORDER BY p.apellidos, p.nombres
              LIMIT :limite OFFSET :desplazamiento",
            $parametros
        )->obtenerTodo();
    }

    public function contarListado(array $filtros = []): int
    {
        [$where, $parametros] = $this->filtrosSql($filtros);
        return $this->sql(
            "SELECT COUNT(*) FROM usuarios u LEFT JOIN personas p ON p.id_persona = u.id_persona {$where}",
            $parametros
        )->entero();
    }

    private function filtrosSql(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['buscar'])) {
            $condiciones[]              = '(u.user LIKE :buscar OR u.email LIKE :buscar OR p.cedula LIKE :buscar
                                            OR p.nombres LIKE :buscar OR p.apellidos LIKE :buscar)';
            $parametros['buscar']       = '%' . $filtros['buscar'] . '%';
        }
        if (!empty($filtros['id_rol'])) {
            $condiciones[]        = 'u.id_rol = :id_rol';
            $parametros['id_rol'] = (int) $filtros['id_rol'];
        }
        if (!empty($filtros['estado'])) {
            $condiciones[]       = 'u.estado = :estado';
            $parametros['estado'] = $filtros['estado'];
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    public function conDetalle(int $id): ?array
    {
        return $this->sql(
            'SELECT u.*, r.nombre AS rol_nombre, r.descripcion AS rol_descripcion,
                    p.cedula, p.nombres, p.apellidos, p.telefono, p.celular, p.email AS persona_email,
                    p.direccion, p.fecha_nac, p.sexo, p.foto, p.nacionalidad, p.id_ciudades,
                    p.id_persona, a.id_alumno, a.legajo, a.id_carrera,
                    c.nombre AS carrera_nombre, fac.nombre AS facultad_nombre, s.nombre AS sede_nombre
               FROM usuarios u
               LEFT JOIN roles r        ON r.id_rol = u.id_rol
               LEFT JOIN personas p     ON p.id_persona = u.id_persona
               LEFT JOIN alumnos a      ON a.id_persona = p.id_persona
               LEFT JOIN carreras c     ON c.id_carrera = a.id_carrera
               LEFT JOIN facultades fac ON fac.id_facultades = a.id_facultades
               LEFT JOIN sedes s        ON s.id_sede = a.id_sede
              WHERE u.id_usuario = ? LIMIT 1',
            [$id]
        )->obtener();
    }

    public function porUser(string $user): ?array
    {
        return $this->buscarPor('user', $user);
    }

    public function porEmail(string $email): ?array
    {
        return $this->buscarPor('email', $email);
    }

    public function totalesPorRol(): array
    {
        return $this->sql(
            'SELECT r.nombre AS rol, COUNT(u.id_usuario) AS total
               FROM roles r
               LEFT JOIN usuarios u ON u.id_rol = r.id_rol AND u.estado = "Activo"
              GROUP BY r.id_rol, r.nombre
              ORDER BY r.id_rol'
        )->obtenerTodo();
    }
}
