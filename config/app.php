<?php
/**
 * Configuracion general de la aplicacion.
 * Sistema de Gestion Academica UNVES
 */

return [
    // --- Identidad institucional -------------------------------------
    'app_nombre'       => 'Sistema de Gestión Académica',
    'app_siglas'       => 'UNVES',
    'app_institucion'  => 'Universidad Nacional de Villarrica del Espíritu Santo',
    'app_version'      => '1.0.0',
    'app_entorno'      => 'desarrollo',   // desarrollo | produccion

    // --- Zona horaria y moneda ---------------------------------------
    'zona_horaria'     => 'America/Asuncion',
    'moneda'           => 'PYG',
    'moneda_simbolo'   => 'Gs.',
    'moneda_decimales' => 0,
    'locale'           => 'es_PY',

    // --- Contacto -----------------------------------------------------
    'whatsapp'         => '595991461220',
    'whatsapp_texto'   => 'Hola, me comunico desde el portal de pagos de la UNVES y necesito asistencia.',
    'email_contacto'   => 'pagos@unves.edu.py',
    'telefono'         => '+595 991 461 220',

    // --- Sesion y seguridad -------------------------------------------
    'sesion_nombre'       => 'unves_gestion_sid',
    'sesion_vida'         => 7200,      // segundos de inactividad permitida (2 h)
    'sesion_recuerdo_dias' => 30,       // dias de "recordarme"
    'intentos_maximos'    => 5,         // intentos fallidos antes de bloquear
    'bloqueo_minutos'     => 15,
    'clave_hash_algoritmo' => PASSWORD_BCRYPT,
    'clave_hash_costo'    => 12,

    // --- Pagos --------------------------------------------------------
    'pasarela'            => 'sandbox', // sandbox | bancard | pagopar | transferencia
    'pasarela_modo'       => 'pruebas',
    'monto_minimo_pago'   => 1000,
    'monto_maximo_pago'   => 50000000,
    'dias_gracia_mora'    => 5,
    'mora_diaria'         => 2000,
    'permitir_pago_parcial' => false,
    'comprobante_prefijo' => 'REC',

    // --- Checkout con tarjeta (entorno de pruebas) --------------------
    'tarjeta' => [
        // Planes de pago ofrecidos. En el entorno de pruebas la división
        // es siempre sin interés: el monto acreditado no cambia.
        'cuotas'          => [1, 3, 6, 9, 12],
        'marcas'          => [
            'visa'       => ['etiqueta' => 'Visa',       'prefijos' => ['4'],          'longitudes' => [13, 16, 19], 'cvv' => 3],
            'mastercard' => ['etiqueta' => 'Mastercard', 'prefijos' => ['51', '52', '53', '54', '55', '22', '23', '24', '25', '26', '27'], 'longitudes' => [16], 'cvv' => 3],
            'amex'       => ['etiqueta' => 'American Express', 'prefijos' => ['34', '37'], 'longitudes' => [15], 'cvv' => 4],
            'cabal'      => ['etiqueta' => 'Cabal',      'prefijos' => ['604', '589'], 'longitudes' => [16], 'cvv' => 3],
        ],
        // Tarjetas de prueba: el número define el resultado simulado.
        'pruebas' => [
            ['numero' => '4509000000000008', 'marca' => 'visa',       'titulo' => 'Visa aprobada',           'resultado' => 'Aprobado',   'detalle' => 'Autorización inmediata del emisor.'],
            ['numero' => '4509000000000016', 'marca' => 'visa',       'titulo' => 'Visa con fondos insuficientes', 'resultado' => 'Rechazado', 'detalle' => 'Simula un rechazo del emisor por fondos insuficientes.'],
            ['numero' => '4509000000000024', 'marca' => 'visa',       'titulo' => 'Visa vencida',            'resultado' => 'Rechazado',  'detalle' => 'Rechazo por tarjeta vencida en el emisor.'],
            ['numero' => '5526000000000020', 'marca' => 'mastercard', 'titulo' => 'Mastercard aprobada',     'resultado' => 'Aprobado',   'detalle' => 'Aprobada con verificación 3D Secure simulada.'],
            ['numero' => '5526000000000038', 'marca' => 'mastercard', 'titulo' => 'Mastercard rechazada',    'resultado' => 'Rechazado',  'detalle' => 'Rechazo genérico del emisor.'],
            ['numero' => '370000000000002',  'marca' => 'amex',       'titulo' => 'American Express aprobada', 'resultado' => 'Aprobado', 'detalle' => 'Requiere el código de seguridad de 4 dígitos.'],
        ],
    ],

    // --- Integracion con el sistema central de la universidad ---------
    'api_universidad' => [
        'habilitada' => false,
        'base_url'   => 'https://sistema.unves.edu.py/api/v1',
        'token'      => '',
        'timeout'    => 25,
        'verificar_ssl' => true,
        'reintentos' => 2,
        'endpoints'  => [
            'alumnos'    => '/alumnos',
            'facultades' => '/facultades',
            'sedes'      => '/sedes',
            'carreras'   => '/carreras',
            'periodos'   => '/periodos',
            'obligaciones' => '/alumnos/{codigo}/obligaciones',
        ],
    ],

    // --- Identidad visual ----------------------------------------------
    // Dejar vacio para que el sistema detecte automaticamente los archivos
    // generados en recursos/img/ desde el logo oficial de la universidad.
    'logo' => [
        'principal' => '',   // ej.: recursos/img/logo-unves-compacto.png
        'claro'     => '',   // variante para fondos oscuros
        'favicon'   => '',
    ],

    // --- Subidas ------------------------------------------------------
    'subidas' => [
        'max_bytes'       => 5242880, // 5 MB
        'extensiones'     => ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        'directorio'      => 'public/uploads',
    ],

    // --- Apariencia ---------------------------------------------------
    'tema' => [
        'color_primario'   => '#33356e',
        'color_secundario' => '#00afef',
        'color_acento'     => '#0f9d58',
        'color_peligro'    => '#d93025',
    ],
];
