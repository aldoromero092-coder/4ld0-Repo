<?php
/**
 * Definicion del menu lateral.
 * Cada item declara el modulo requerido para ser visible.
 */

return [
    'principal' => [
        'titulo' => null,
        'items'  => [
            ['ruta' => '/panel', 'titulo' => 'Panel principal', 'icono' => '🏠', 'modulos' => ['panel']],
        ],
    ],

    'academico' => [
        'titulo' => 'Mi actividad académica',
        'items'  => [
            ['ruta' => '/matriculas', 'titulo' => 'Mis matrículas', 'icono' => '🎓', 'modulos' => ['matriculas'], 'roles' => ['Alumno']],
            ['ruta' => '/examenes', 'titulo' => 'Exámenes', 'icono' => '📝', 'modulos' => ['examenes']],
            ['ruta' => '/tramites', 'titulo' => 'Trámites y documentos', 'icono' => '📄', 'modulos' => ['tramites']],
        ],
    ],

    'finanzas' => [
        'titulo' => 'Mis finanzas',
        'items'  => [
            ['ruta' => '/pagos/pendientes', 'titulo' => 'Pagos pendientes', 'icono' => '⏳', 'modulos' => ['pagos'], 'insignia' => 'pendientes'],
            ['ruta' => '/pagos/historial', 'titulo' => 'Historial de pagos', 'icono' => '📜', 'modulos' => ['pagos']],
            ['ruta' => '/pagos/carrito', 'titulo' => 'Carrito de pago', 'icono' => '🛒', 'modulos' => ['pagos'], 'roles' => ['Alumno'], 'insignia' => 'carrito'],
        ],
    ],

    'gestion' => [
        'titulo' => 'Gestión académica',
        'items'  => [
            ['ruta' => '/alumnos', 'titulo' => 'Alumnos', 'icono' => '👥', 'modulos' => ['alumnos'], 'roles' => ['Administrador', 'Secretaria', 'Cajero', 'Finanzas', 'Docente']],
            ['ruta' => '/matriculas/admin', 'titulo' => 'Gestión de matrículas', 'icono' => '🗂️', 'modulos' => ['matriculas'], 'roles' => ['Administrador', 'Secretaria', 'Finanzas']],
            ['ruta' => '/examenes/admin', 'titulo' => 'Gestión de exámenes', 'icono' => '📋', 'modulos' => ['examenes'], 'roles' => ['Administrador', 'Secretaria', 'Docente']],
            ['ruta' => '/tramites/admin', 'titulo' => 'Gestión de trámites', 'icono' => '🗃️', 'modulos' => ['tramites'], 'roles' => ['Administrador', 'Secretaria']],
            ['ruta' => '/academico', 'titulo' => 'Facultades, sedes y carreras', 'icono' => '🏛️', 'modulos' => ['academico'], 'roles' => ['Administrador', 'Secretaria', 'Finanzas']],
            ['ruta' => '/estructura', 'titulo' => 'Mallas, cursos y ventanas', 'icono' => '📚', 'modulos' => ['estructura'], 'roles' => ['Administrador', 'Secretaria', 'Finanzas']],
        ],
    ],

    'caja' => [
        'titulo' => 'Cobranzas',
        'items'  => [
            ['ruta' => '/caja', 'titulo' => 'Ventanilla de caja', 'icono' => '💳', 'modulos' => ['pagos'], 'roles' => ['Administrador', 'Cajero', 'Finanzas', 'Secretaria']],
            ['ruta' => '/caja/arqueo', 'titulo' => 'Arqueo de caja', 'icono' => '🧾', 'modulos' => ['pagos'], 'roles' => ['Administrador', 'Cajero', 'Finanzas']],
            ['ruta' => '/aranceles', 'titulo' => 'Aranceles y conceptos', 'icono' => '💰', 'modulos' => ['aranceles'], 'roles' => ['Administrador', 'Finanzas']],
            ['ruta' => '/becas', 'titulo' => 'Becas y descuentos', 'icono' => '🎁', 'modulos' => ['becas'], 'roles' => ['Administrador', 'Finanzas', 'Secretaria']],
            ['ruta' => '/facturacion', 'titulo' => 'Facturación', 'icono' => '🧮', 'modulos' => ['facturacion'], 'roles' => ['Administrador', 'Finanzas']],
        ],
    ],

    'informes' => [
        'titulo' => 'Informes y control',
        'items'  => [
            ['ruta' => '/reportes', 'titulo' => 'Reportes', 'icono' => '📊', 'modulos' => ['reportes'], 'roles' => ['Administrador', 'Finanzas', 'Secretaria', 'Cajero', 'Docente']],
            ['ruta' => '/auditoria', 'titulo' => 'Auditoría y actividad', 'icono' => '🔍', 'modulos' => ['auditoria'], 'roles' => ['Administrador', 'Finanzas']],
            ['ruta' => '/mensajes', 'titulo' => 'Mensajes de contacto', 'icono' => '✉️', 'modulos' => ['contacto'], 'roles' => ['Administrador', 'Secretaria', 'Finanzas'], 'insignia' => 'mensajes'],
        ],
    ],

    'administracion' => [
        'titulo' => 'Administración',
        'items'  => [
            ['ruta' => '/usuarios', 'titulo' => 'Usuarios y roles', 'icono' => '🔐', 'modulos' => ['*'], 'roles' => ['Administrador']],
            ['ruta' => '/integracion', 'titulo' => 'Integración con el sistema central', 'icono' => '🔗', 'modulos' => ['*'], 'roles' => ['Administrador', 'Secretaria']],
            ['ruta' => '/configuracion', 'titulo' => 'Configuración', 'icono' => '⚙️', 'modulos' => ['*'], 'roles' => ['Administrador']],
        ],
    ],

    'cuenta' => [
        'titulo' => 'Mi cuenta',
        'items'  => [
            ['ruta' => '/perfil', 'titulo' => 'Mi perfil', 'icono' => '👤', 'modulos' => ['perfil']],
            ['ruta' => '/notificaciones', 'titulo' => 'Notificaciones', 'icono' => '🔔', 'modulos' => ['notificaciones'], 'insignia' => 'notificaciones'],
            ['ruta' => '/contacto', 'titulo' => 'Ayuda y contacto', 'icono' => '💬', 'modulos' => ['contacto']],
        ],
    ],
];
