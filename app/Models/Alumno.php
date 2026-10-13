<?php

namespace App\Models;

use App\Core\Model;

class Alumno extends Model
{
    protected string $tabla = 'alumnos';
    protected string $clavePrimaria = 'id_alumno';

    protected array $asignables = [
        'id_persona', 'legajo', 'codigo_externo', 'id_carrera', 'id_facultades',
        'id_sede', 'id_periodo_ingreso', 'semestre_actual', 'estado_academico',
        'modalidad', 'turno', 'fecha_ingreso', 'promedio_general', 'creditos_aprobados',
        'origen_datos', 'ultima_sincronizacion', 'observaciones', 'estado',
    ];

    /** Listado paginado con datos de persona, carrera y sede. */
    public function listar(array $filtros = [], int $limite = 15, int $desplazamiento = 0): array
    {
        [$where, $parametros] = $this->filtrosSql($filtros);
        $parametros['limite']         = $limite;
        $parametros['desplazamiento'] = $desplazamiento;

        return $this->sql(
            "SELECT a.*, p.cedula, p.nombres, p.apellidos, p.telefono, p.celular, p.email, p.foto,
                    c.nombre AS carrera_nombre, c.codigo_carrera,
                    f.nombre AS facultad_nombre, s.nombre AS sede_nombre
               FROM alumnos a
               INNER JOIN personas p   ON p.id_persona = a.id_persona
               LEFT JOIN carreras c    ON c.id_carrera = a.id_carrera
               LEFT JOIN facultades f  ON f.id_facultades = a.id_facultades
               LEFT JOIN sedes s       ON s.id_sede = a.id_sede
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
            "SELECT COUNT(*) FROM alumnos a INNER JOIN personas p ON p.id_persona = a.id_persona {$where}",
            $parametros
        )->entero();
    }

    private function filtrosSql(array $filtros): array
    {
        $condiciones = [];
        $parametros  = [];

        if (!empty($filtros['buscar'])) {
            $condiciones[]        = '(p.cedula LIKE :buscar OR p.nombres LIKE :buscar
                                      OR p.apellidos LIKE :buscar OR a.legajo LIKE :buscar
                                      OR a.codigo_externo LIKE :buscar)';
            $parametros['buscar'] = '%' . $filtros['buscar'] . '%';
        }
        foreach (['id_carrera', 'id_facultades', 'id_sede', 'id_periodo_ingreso'] as $campo) {
            if (!empty($filtros[$campo])) {
                $condiciones[]        = "a.`{$campo}` = :{$campo}";
                $parametros[$campo]   = (int) $filtros[$campo];
            }
        }
        if (!empty($filtros['estado_academico'])) {
            $condiciones[]                 = 'a.estado_academico = :estado_academico';
            $parametros['estado_academico'] = $filtros['estado_academico'];
        }

        return [$condiciones === [] ? '' : 'WHERE ' . implode(' AND ', $condiciones), $parametros];
    }

    public function conDetalle(int $id): ?array
    {
        return $this->sql(
            'SELECT a.*, p.cedula, p.nombres, p.apellidos, p.telefono, p.celular, p.email,
                    p.direccion, p.fecha_nac, p.sexo, p.foto, p.nacionalidad, p.id_persona,
                    p.id_ciudades, ciu.nombre AS ciudad_nombre,
                    c.nombre AS carrera_nombre, c.codigo_carrera, c.duracion_anio,
                    f.nombre AS facultad_nombre, s.nombre AS sede_nombre,
                    u.id_usuario, u.user, u.estado AS estado_usuario,
                    (SELECT COUNT(*) FROM obligaciones_pago o WHERE o.id_alumno = a.id_alumno AND o.estado IN ("Pendiente","Vencido")) AS obligaciones_pendientes,
                    (SELECT COALESCE(SUM(o.saldo),0) FROM obligaciones_pago o WHERE o.id_alumno = a.id_alumno AND o.estado IN ("Pendiente","Vencido")) AS deuda_total,
                    (SELECT COALESCE(SUM(pg.monto_total),0) FROM pagos pg WHERE pg.id_alumno = a.id_alumno AND pg.estado_pago = "Aprobado") AS total_pagado
               FROM alumnos a
               INNER JOIN personas p   ON p.id_persona = a.id_persona
               LEFT JOIN ciudades ciu  ON ciu.id_ciudades = p.id_ciudades
               LEFT JOIN carreras c    ON c.id_carrera = a.id_carrera
               LEFT JOIN facultades f  ON f.id_facultades = a.id_facultades
               LEFT JOIN sedes s       ON s.id_sede = a.id_sede
               LEFT JOIN usuarios u    ON u.id_persona = p.id_persona
              WHERE a.id_alumno = ? LIMIT 1',
            [$id]
        )->obtener();
    }

    public function porPersona(int $idPersona): ?array
    {
        return $this->buscarPor('id_persona', $idPersona);
    }

    public function porCodigoExterno(string $codigo): ?array
    {
        return $this->buscarPor('codigo_externo', $codigo);
    }

    public function porLegajo(string $legajo): ?array
    {
        return $this->buscarPor('legajo', $legajo);
    }

    /** Datos minimos para selectores y busquedas rapidas. */
    public function opciones(): array
    {
        return $this->sql(
            'SELECT a.id_alumno, a.legajo, p.cedula,
                    CONCAT(p.apellidos, ", ", p.nombres) AS nombre, c.nombre AS carrera
               FROM alumnos a
               INNER JOIN personas p ON p.id_persona = a.id_persona
               LEFT JOIN carreras c ON c.id_carrera = a.id_carrera
              WHERE a.estado = "Activo"
              ORDER BY p.apellidos, p.nombres'
        )->obtenerTodo();
    }

    public function totalesPorCarrera(): array
    {
        return $this->sql(
            'SELECT c.nombre AS carrera, COUNT(a.id_alumno) AS total
               FROM carreras c
               LEFT JOIN alumnos a ON a.id_carrera = c.id_carrera AND a.estado = "Activo"
              GROUP BY c.id_carrera, c.nombre
              ORDER BY c.nombre'
        )->obtenerTodo();
    }

    public function siguientesLegajo(string $codigoCarrera): string
    {
        $anio  = date('Y');
        $total = $this->sql(
            'SELECT COUNT(*) FROM alumnos WHERE legajo LIKE ?',
            [$anio . '-' . $codigoCarrera . '-%']
        )->entero();

        return sprintf('%s-%s-%03d', $anio, strtoupper($codigoCarrera), $total + 1);
    }
}
