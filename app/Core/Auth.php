<?php

namespace App\Core;

/**
 * Autenticacion, autorizacion y sesion del usuario.
 */
class Auth
{
    private static ?array $usuario = null;
    private static bool $cargado = false;

    /** Modulos habilitados por rol. */
    private const PERMISOS = [
        'Administrador' => ['*'],
        'Alumno' => [
            'panel', 'pagos', 'matriculas', 'examenes', 'tramites', 'perfil',
            'contacto', 'notificaciones',
        ],
        'Docente' => ['panel', 'examenes', 'alumnos', 'perfil', 'contacto', 'notificaciones', 'reportes'],
        'Cajero' => ['panel', 'pagos', 'alumnos', 'perfil', 'contacto', 'notificaciones', 'reportes'],
        'Secretaria' => [
            'panel', 'alumnos', 'matriculas', 'tramites', 'examenes', 'pagos',
            'academico', 'estructura', 'perfil', 'contacto', 'notificaciones', 'reportes',
        ],
        'Finanzas' => [
            'panel', 'pagos', 'aranceles', 'becas', 'reportes', 'facturacion',
            'alumnos', 'academico', 'estructura', 'perfil', 'contacto', 'notificaciones', 'auditoria',
        ],
        'Consulta' => ['panel', 'reportes', 'perfil', 'notificaciones'],
    ];

    // -----------------------------------------------------------------
    // Intento de ingreso
    // -----------------------------------------------------------------

    /**
     * @return array{ok: bool, mensaje: string, usuario?: array}
     */
    public static function intentar(string $usuarioOCorreo, string $clave, bool $recordar = false): array
    {
        $campo  = str_contains($usuarioOCorreo, '@') ? 'email' : 'user';
        $db     = Database::instancia();
        $fila   = $db->consulta(
            "SELECT u.*, r.nombre AS rol_nombre, r.descripcion AS rol_descripcion
               FROM usuarios u
               LEFT JOIN roles r ON r.id_rol = u.id_rol
              WHERE u.`{$campo}` = ? LIMIT 1",
            [$usuarioOCorreo]
        )->obtener();

        if ($fila === null) {
            Logger::seguridad('login_fallido', 'Usuario inexistente: ' . $usuarioOCorreo, ['usuario' => $usuarioOCorreo]);
            return ['ok' => false, 'mensaje' => 'Usuario o contraseña incorrectos.'];
        }

        if (strcasecmp((string) $fila['estado'], 'Activo') !== 0) {
            Logger::seguridad('login_bloqueado', 'Cuenta inactiva: ' . $usuarioOCorreo, ['id_usuario' => $fila['id_usuario']]);
            return ['ok' => false, 'mensaje' => 'Tu cuenta se encuentra inactiva. Contactá con la secretaría.'];
        }

        if (!empty($fila['bloqueado_hasta']) && strtotime((string) $fila['bloqueado_hasta']) > time()) {
            $restante = (int) ceil((strtotime((string) $fila['bloqueado_hasta']) - time()) / 60);
            return ['ok' => false, 'mensaje' => "Cuenta bloqueada temporalmente. Intentá de nuevo en {$restante} minuto(s)."];
        }

        if (!password_verify($clave, (string) $fila['pass'])) {
            self::registrarIntentoFallido((int) $fila['id_usuario'], (int) $fila['intentos_fallidos']);
            Logger::seguridad('login_fallido', 'Contraseña incorrecta para ' . $usuarioOCorreo, ['id_usuario' => $fila['id_usuario']]);
            return ['ok' => false, 'mensaje' => 'Usuario o contraseña incorrectos.'];
        }

        // Rehash automatico si cambio el costo del algoritmo
        if (password_needs_rehash((string) $fila['pass'], self::algoritmoHash(), self::opcionesHash())) {
            $db->consulta(
                'UPDATE usuarios SET pass = ? WHERE id_usuario = ?',
                [password_hash($clave, self::algoritmoHash(), self::opcionesHash()), $fila['id_usuario']]
            );
        }

        self::iniciarSesion($fila, $recordar);
        return ['ok' => true, 'mensaje' => 'Bienvenido/a', 'usuario' => $fila];
    }

    private static function registrarIntentoFallido(int $idUsuario, int $intentosPrevios): void
    {
        $intentos = $intentosPrevios + 1;
        $maximo   = (int) Config::obtener('app.intentos_maximos', 5);
        $bloqueo  = null;

        if ($intentos >= $maximo) {
            $bloqueo = date('Y-m-d H:i:s', time() + ((int) Config::obtener('app.bloqueo_minutos', 15) * 60));
            $intentos = 0;
        }

        Database::instancia()->consulta(
            'UPDATE usuarios SET intentos_fallidos = ?, bloqueado_hasta = ? WHERE id_usuario = ?',
            [$intentos, $bloqueo, $idUsuario]
        );
    }

    private static function iniciarSesion(array $fila, bool $recordar): void
    {
        Session::regenerar();
        Csrf::regenerar();

        Session::guardar('__usuario_id', (int) $fila['id_usuario']);
        Session::guardar('__usuario', [
            'id_usuario' => (int) $fila['id_usuario'],
            'user'       => $fila['user'],
            'email'      => $fila['email'],
            'id_rol'     => (int) $fila['id_rol'],
            'rol'        => $fila['rol_nombre'] ?? 'Consulta',
        ]);
        Session::guardar('__inicio_sesion', time());

        $db = Database::instancia();
        $db->consulta('UPDATE usuarios SET ultimo_acceso = NOW(), intentos_fallidos = 0, bloqueado_hasta = NULL WHERE id_usuario = ?', [(int) $fila['id_usuario']]);

        $token = bin2hex(random_bytes(32));
        $db->consulta(
            'INSERT INTO sesiones_web (id_usuario, token, ip_origen, user_agent, navegador, plataforma, estado)
             VALUES (?, ?, ?, ?, ?, ?, "Activa")',
            [
                (int) $fila['id_usuario'],
                hash('sha256', $token),
                (new Request())->ip(),
                (new Request())->userAgent(),
                (new Request())->navegador(),
                (new Request())->plataforma(),
            ]
        );
        Session::guardar('__sesion_token', $token);

        if ($recordar) {
            $dias  = (int) Config::obtener('app.sesion_recuerdo_dias', 30);
            $token = bin2hex(random_bytes(32));
            $db->consulta('UPDATE usuarios SET token_recuerdo = ? WHERE id_usuario = ?', [hash('sha256', $token), (int) $fila['id_usuario']]);
            setcookie(
                'unves_recuerdo',
                $fila['id_usuario'] . ':' . $token,
                [
                    'expires'  => time() + ($dias * 86400),
                    'path'     => '/',
                    'httponly' => true,
                    'samesite' => 'Lax',
                ]
            );
        }

        self::$usuario = null;
        self::$cargado = false;
        Logger::registrar('inicio_sesion', 'Ingreso al sistema', 'seguridad', 'info');
    }

    /** Reintenta el ingreso desde la cookie "recordarme". */
    public static function intentarRecordarme(): bool
    {
        $cookie = $_COOKIE['unves_recuerdo'] ?? null;
        if (!is_string($cookie) || !str_contains($cookie, ':')) {
            return false;
        }

        [$idUsuario, $token] = explode(':', $cookie, 2);
        $fila = Database::instancia()->consulta(
            'SELECT * FROM usuarios WHERE id_usuario = ? AND token_recuerdo = ? AND estado = "Activo" LIMIT 1',
            [(int) $idUsuario, hash('sha256', $token)]
        )->obtener();

        if ($fila === null) {
            setcookie('unves_recuerdo', '', time() - 3600, '/');
            return false;
        }

        self::iniciarSesion($fila, false);
        return true;
    }

    public static function cerrar(): void
    {
        if (self::verificado()) {
            Logger::registrar('cierre_sesion', 'Salida del sistema', 'seguridad', 'info');

            try {
                $token = Session::obtener('__sesion_token');
                if ($token !== null) {
                    Database::instancia()->consulta(
                        'UPDATE sesiones_web SET estado = "Cerrada", fecha_cierre = NOW()
                          WHERE token = ? AND estado = "Activa"',
                        [hash('sha256', (string) $token)]
                    );
                }
                Database::instancia()->consulta('UPDATE usuarios SET token_recuerdo = NULL WHERE id_usuario = ?', [self::id()]);
            } catch (\Throwable) {
                // Ignoramos fallos de limpieza
            }
        }

        setcookie('unves_recuerdo', '', time() - 3600, '/');
        Session::destruir();
        self::$usuario = null;
        self::$cargado = false;
    }

    // -----------------------------------------------------------------
    // Estado del usuario
    // -----------------------------------------------------------------

    public static function verificado(): bool
    {
        Session::iniciar();
        return !empty($_SESSION['__usuario_id']);
    }

    public static function id(): ?int
    {
        if (!self::verificado()) {
            return null;
        }
        return (int) $_SESSION['__usuario_id'];
    }

    /** Devuelve el usuario completo (con persona y alumno) en cache. */
    public static function usuario(): ?array
    {
        if (self::$cargado) {
            return self::$usuario;
        }
        self::$cargado = true;

        $id = self::id();
        if ($id === null) {
            return self::$usuario = null;
        }

        $usuario = Database::instancia()->consulta(
            'SELECT u.*, r.nombre AS rol_nombre, r.descripcion AS rol_descripcion,
                    p.cedula, p.nombres, p.apellidos, p.telefono, p.celular, p.email AS persona_email,
                    p.direccion, p.fecha_nac, p.sexo, p.foto, p.nacionalidad,
                    a.id_alumno, a.legajo, a.id_carrera, a.id_facultades, a.id_sede,
                    a.semestre_actual, a.estado_academico, a.promedio_general,
                    c.nombre AS carrera_nombre, c.codigo_carrera,
                    f.nombre AS facultad_nombre, s.nombre AS sede_nombre
               FROM usuarios u
               LEFT JOIN roles r      ON r.id_rol = u.id_rol
               LEFT JOIN personas p   ON p.id_persona = u.id_persona
               LEFT JOIN alumnos a    ON a.id_persona = p.id_persona
               LEFT JOIN carreras c   ON c.id_carrera = a.id_carrera
               LEFT JOIN facultades f ON f.id_facultades = a.id_facultades
               LEFT JOIN sedes s      ON s.id_sede = a.id_sede
              WHERE u.id_usuario = ? LIMIT 1',
            [$id]
        )->obtener();

        if ($usuario === null) {
            self::cerrar();
            return self::$usuario = null;
        }

        $usuario['id_alumno'] = isset($usuario['id_alumno']) ? (int) $usuario['id_alumno'] : null;
        $usuario['nombre_completo'] = trim(($usuario['nombres'] ?? '') . ' ' . ($usuario['apellidos'] ?? ''));
        $usuario['iniciales'] = self::iniciales($usuario['nombre_completo']);

        return self::$usuario = $usuario;
    }

    public static function rol(): string
    {
        return (string) (self::usuario()['rol_nombre'] ?? '');
    }

    public static function idRol(): int
    {
        return (int) (self::usuario()['id_rol'] ?? 0);
    }

    public static function idAlumno(): ?int
    {
        return self::usuario()['id_alumno'] ?? null;
    }

    public static function nombre(): string
    {
        return (string) (self::usuario()['nombre_completo'] ?? '');
    }

    public static function esAlumno(): bool
    {
        return self::rol() === 'Alumno';
    }

    public static function esAdministrador(): bool
    {
        return self::rol() === 'Administrador';
    }

    public static function esCajero(): bool
    {
        return in_array(self::rol(), ['Cajero', 'Finanzas', 'Administrador'], true);
    }

    public static function tieneRol(string|array $roles): bool
    {
        $roles = (array) $roles;
        return in_array(self::rol(), $roles, true);
    }

    public static function puede(string $modulo): bool
    {
        $rol       = self::rol();
        $permitido = self::PERMISOS[$rol] ?? [];

        return in_array('*', $permitido, true) || in_array($modulo, $permitido, true);
    }

    public static function modulosPermitidos(): array
    {
        return self::PERMISOS[self::rol()] ?? [];
    }

    /** Cambia la contraseña del usuario autenticado. */
    public static function cambiarClave(int $idUsuario, string $nueva): void
    {
        Database::instancia()->consulta(
            'UPDATE usuarios SET pass = ?, debe_cambiar_pass = 0, intentos_fallidos = 0, bloqueado_hasta = NULL WHERE id_usuario = ?',
            [self::hash($nueva), $idUsuario]
        );
    }

    /** Algoritmo de hash configurado. */
    public static function algoritmoHash(): string
    {
        $algoritmo = Config::obtener('app.clave_hash_algoritmo', PASSWORD_BCRYPT);
        return is_string($algoritmo) && in_array($algoritmo, [PASSWORD_BCRYPT, PASSWORD_ARGON2I, PASSWORD_ARGON2ID, '2y'], true)
            ? (string) $algoritmo
            : PASSWORD_BCRYPT;
    }

    /** Opciones de coste del algoritmo de hash. */
    public static function opcionesHash(): array
    {
        return ['cost' => max(4, min(15, (int) Config::obtener('app.clave_hash_costo', 12)))];
    }

    /** Genera el hash de una contraseña usando la configuracion vigente. */
    public static function hash(string $clave): string
    {
        return password_hash($clave, self::algoritmoHash(), self::opcionesHash());
    }

    private static function iniciales(string $nombre): string
    {
        $partes = preg_split('/\s+/u', trim($nombre)) ?: [];
        $letras = '';
        foreach (array_slice($partes, 0, 2) as $parte) {
            $letras .= mb_strtoupper(mb_substr($parte, 0, 1, 'UTF-8'), 'UTF-8');
        }
        return $letras !== '' ? $letras : 'U';
    }
}
