-- =====================================================================
--  SISTEMA DE GESTION ACADEMICA UNVES - EXTENSION PARA PORTAL WEB
--  Archivo : sql/02_extension_web.sql
--  Motor   : MariaDB 10.4 / MySQL 5.7+
--  Objetivo: Completar el esquema base con las tablas y columnas que
--            necesita el portal web de pagos (matriculas, aranceles,
--            examenes, tramites, auditoria y sesiones).
--  Nota    : Script IDEMPOTENTE. Puede ejecutarse varias veces sin
--            romper datos existentes.
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ---------------------------------------------------------------------
-- 0. Normalizacion de codificacion (todas las tablas base estan latin1)
-- ---------------------------------------------------------------------
ALTER DATABASE `sistema_gestion_academica`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 1. TABLA: alumnos  (persona con rol academico)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `alumnos` (
  `id_alumno`            int(11)      NOT NULL AUTO_INCREMENT,
  `id_persona`           int(11)      NOT NULL,
  `legajo`               varchar(45)  DEFAULT NULL,
  `codigo_externo`       varchar(95)  DEFAULT NULL COMMENT 'Id en el sistema central de la universidad',
  `id_carrera`           int(11)      DEFAULT NULL,
  `id_facultades`        int(11)      DEFAULT NULL,
  `id_sede`              int(11)      DEFAULT NULL,
  `id_periodo_ingreso`   int(11)      DEFAULT NULL,
  `semestre_actual`      int(11)      DEFAULT 1,
  `estado_academico`     varchar(45)  DEFAULT 'Activo' COMMENT 'Activo, Egresado, Suspendido, Retirado, Titulado',
  `modalidad`            varchar(45)  DEFAULT 'Presencial',
  `turno`                varchar(45)  DEFAULT 'Noche',
  `fecha_ingreso`        date         DEFAULT NULL,
  `promedio_general`     decimal(5,2) DEFAULT NULL,
  `creditos_aprobados`   int(11)      DEFAULT 0,
  `origen_datos`         varchar(45)  DEFAULT 'Local' COMMENT 'Local | API',
  `ultima_sincronizacion` datetime    DEFAULT NULL,
  `observaciones`        text         DEFAULT NULL,
  `estado`               varchar(20)  NOT NULL DEFAULT 'Activo',
  `creado_en`            datetime     NOT NULL DEFAULT current_timestamp(),
  `actualizado_en`       datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_alumno`),
  UNIQUE KEY `uk_alumno_persona` (`id_persona`),
  UNIQUE KEY `uk_alumno_legajo`  (`legajo`),
  UNIQUE KEY `uk_alumno_codigo`  (`codigo_externo`),
  KEY `idx_alumno_carrera` (`id_carrera`),
  KEY `idx_alumno_facultad` (`id_facultades`),
  KEY `idx_alumno_sede` (`id_sede`),
  KEY `idx_alumno_estado` (`estado_academico`),
  CONSTRAINT `fk_alumno_persona`   FOREIGN KEY (`id_persona`)    REFERENCES `personas` (`id_persona`)   ON DELETE CASCADE,
  CONSTRAINT `fk_alumno_carrera`   FOREIGN KEY (`id_carrera`)    REFERENCES `carreras` (`id_carrera`)   ON DELETE SET NULL,
  CONSTRAINT `fk_alumno_facultad`  FOREIGN KEY (`id_facultades`) REFERENCES `facultades` (`id_facultades`) ON DELETE SET NULL,
  CONSTRAINT `fk_alumno_sede`      FOREIGN KEY (`id_sede`)       REFERENCES `sedes` (`id_sede`)         ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. TABLA: matriculas
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `matriculas` (
  `id_matricula`        int(11)      NOT NULL AUTO_INCREMENT,
  `numero_matricula`    varchar(45)  NOT NULL,
  `id_alumno`           int(11)      NOT NULL,
  `id_periodo`          int(11)      NOT NULL,
  `id_carrera`          int(11)      DEFAULT NULL,
  `id_facultades`       int(11)      DEFAULT NULL,
  `id_sede`             int(11)      DEFAULT NULL,
  `semestre`            int(11)      DEFAULT NULL,
  `turno`               varchar(45)  DEFAULT NULL,
  `modalidad`           varchar(45)  DEFAULT 'Presencial',
  `id_obligacion`       int(11)      DEFAULT NULL COMMENT 'Obligacion de pago generada por la matricula',
  `id_pago`             int(11)      DEFAULT NULL,
  `monto_matricula`     decimal(12,2) DEFAULT 0.00,
  `fecha_solicitud`     datetime     NOT NULL DEFAULT current_timestamp(),
  `fecha_confirmacion`  datetime     DEFAULT NULL,
  `estado`              varchar(45)  NOT NULL DEFAULT 'Pendiente' COMMENT 'Pendiente, En proceso, Confirmada, Rechazada, Anulada',
  `documentacion_ok`    tinyint(1)   NOT NULL DEFAULT 0,
  `observaciones`       text         DEFAULT NULL,
  `id_usuario_gestion`  int(11)      DEFAULT NULL,
  `creado_en`           datetime     NOT NULL DEFAULT current_timestamp(),
  `actualizado_en`      datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_matricula`),
  UNIQUE KEY `uk_matricula_numero` (`numero_matricula`),
  UNIQUE KEY `uk_matricula_alumno_periodo` (`id_alumno`,`id_periodo`),
  KEY `idx_matricula_periodo` (`id_periodo`),
  KEY `idx_matricula_estado` (`estado`),
  CONSTRAINT `fk_matricula_alumno`  FOREIGN KEY (`id_alumno`)  REFERENCES `alumnos` (`id_alumno`) ON DELETE CASCADE,
  CONSTRAINT `fk_matricula_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE CASCADE,
  CONSTRAINT `fk_matricula_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE SET NULL,
  CONSTRAINT `fk_matricula_sede`    FOREIGN KEY (`id_sede`)    REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. TABLA: examenes  (convocatorias / mesas examinadoras)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `examenes` (
  `id_examen`          int(11)      NOT NULL AUTO_INCREMENT,
  `nombre`             varchar(145) NOT NULL,
  `materia`            varchar(145) DEFAULT NULL,
  `tipo`               varchar(45)  NOT NULL DEFAULT 'Final' COMMENT 'Final, Recuperatorio, Parcial, Suficiencia, Libre',
  `id_periodo`         int(11)      DEFAULT NULL,
  `id_carrera`         int(11)      DEFAULT NULL,
  `id_facultades`      int(11)      DEFAULT NULL,
  `id_sede`            int(11)      DEFAULT NULL,
  `id_concepto_pago`   int(11)      DEFAULT NULL,
  `monto`              decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_examen`       date         NOT NULL,
  `hora_inicio`        time         DEFAULT NULL,
  `duracion_min`       int(11)      DEFAULT 90,
  `aula`               varchar(45)  DEFAULT NULL,
  `cupo_maximo`        int(11)      DEFAULT 50,
  `inscritos`          int(11)      NOT NULL DEFAULT 0,
  `fecha_limite_insc`  date         DEFAULT NULL,
  `requiere_pago`      tinyint(1)   NOT NULL DEFAULT 1,
  `estado`             varchar(45)  NOT NULL DEFAULT 'Programado' COMMENT 'Programado, Inscripcion abierta, Cerrado, Finalizado, Cancelado',
  `creado_en`          datetime     NOT NULL DEFAULT current_timestamp(),
  `actualizado_en`     datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_examen`),
  KEY `idx_examen_periodo` (`id_periodo`),
  KEY `idx_examen_fecha` (`fecha_examen`),
  KEY `idx_examen_estado` (`estado`),
  CONSTRAINT `fk_examen_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE SET NULL,
  CONSTRAINT `fk_examen_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE SET NULL,
  CONSTRAINT `fk_examen_sede`    FOREIGN KEY (`id_sede`)    REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. TABLA: inscripciones_examen
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `inscripciones_examen` (
  `id_inscripcion`   int(11)     NOT NULL AUTO_INCREMENT,
  `id_examen`        int(11)     NOT NULL,
  `id_alumno`        int(11)     NOT NULL,
  `id_obligacion`    int(11)     DEFAULT NULL,
  `id_pago`          int(11)     DEFAULT NULL,
  `fecha_inscripcion` datetime   NOT NULL DEFAULT current_timestamp(),
  `estado`           varchar(45) NOT NULL DEFAULT 'Pendiente' COMMENT 'Pendiente, Habilitado, Rendido, Ausente, Anulado',
  `nota`             decimal(5,2) DEFAULT NULL,
  `condicion`        varchar(45) DEFAULT NULL COMMENT 'Regular, Libre',
  `observaciones`    varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_inscripcion`),
  UNIQUE KEY `uk_inscripcion_examen_alumno` (`id_examen`,`id_alumno`),
  KEY `idx_inscripcion_alumno` (`id_alumno`),
  CONSTRAINT `fk_insc_examen`  FOREIGN KEY (`id_examen`)  REFERENCES `examenes` (`id_examen`) ON DELETE CASCADE,
  CONSTRAINT `fk_insc_alumno`  FOREIGN KEY (`id_alumno`)  REFERENCES `alumnos` (`id_alumno`)  ON DELETE CASCADE,
  CONSTRAINT `fk_insc_pago`    FOREIGN KEY (`id_pago`)    REFERENCES `pagos` (`id_pago`)      ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. TABLA: carrito_items  (intencion de pago del alumno)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `carrito_items` (
  `id_item`        int(11)  NOT NULL AUTO_INCREMENT,
  `id_usuario`     int(11)  NOT NULL,
  `id_obligacion`  int(11)  NOT NULL,
  `fecha_agregado` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_item`),
  UNIQUE KEY `uk_carrito_usuario_obligacion` (`id_usuario`,`id_obligacion`),
  KEY `idx_carrito_obligacion` (`id_obligacion`),
  CONSTRAINT `fk_carrito_usuario`    FOREIGN KEY (`id_usuario`)    REFERENCES `usuarios` (`id_usuario`)         ON DELETE CASCADE,
  CONSTRAINT `fk_carrito_obligacion` FOREIGN KEY (`id_obligacion`) REFERENCES `obligaciones_pago` (`id_obligacion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. TABLA: sesiones_web  (control de sesiones activas)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sesiones_web` (
  `id_sesion`      bigint(20)   NOT NULL AUTO_INCREMENT,
  `id_usuario`     int(11)      NOT NULL,
  `token`          varchar(128) NOT NULL,
  `ip_origen`      varchar(45)  DEFAULT NULL,
  `user_agent`     varchar(255) DEFAULT NULL,
  `navegador`      varchar(95)  DEFAULT NULL,
  `plataforma`     varchar(95)  DEFAULT NULL,
  `fecha_inicio`   datetime     NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso`  datetime     NOT NULL DEFAULT current_timestamp(),
  `fecha_cierre`   datetime     DEFAULT NULL,
  `estado`         varchar(20)  NOT NULL DEFAULT 'Activa' COMMENT 'Activa, Cerrada, Expirada',
  PRIMARY KEY (`id_sesion`),
  UNIQUE KEY `uk_sesion_token` (`token`),
  KEY `idx_sesion_usuario` (`id_usuario`),
  CONSTRAINT `fk_sesion_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 7. TABLA: logs_actividad  (rastro completo de cada usuario)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `logs_actividad` (
  `id_log`      bigint(20)   NOT NULL AUTO_INCREMENT,
  `id_usuario`  int(11)      DEFAULT NULL,
  `modulo`      varchar(45)  DEFAULT NULL,
  `accion`      varchar(95)  NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `metodo_http` varchar(10)  DEFAULT NULL,
  `ruta`        varchar(255) DEFAULT NULL,
  `ip_origen`   varchar(45)  DEFAULT NULL,
  `user_agent`  varchar(255) DEFAULT NULL,
  `datos`       longtext     DEFAULT NULL,
  `nivel`       varchar(15)  NOT NULL DEFAULT 'info' COMMENT 'info, warning, error, seguridad',
  `fecha_hora`  datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_log`),
  KEY `idx_log_usuario` (`id_usuario`),
  KEY `idx_log_fecha` (`fecha_hora`),
  KEY `idx_log_modulo` (`modulo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 8. TABLA: notificaciones
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `notificaciones` (
  `id_notificacion` int(11)      NOT NULL AUTO_INCREMENT,
  `id_usuario`      int(11)      NOT NULL,
  `titulo`          varchar(145) NOT NULL,
  `mensaje`         text         NOT NULL,
  `tipo`            varchar(45)  NOT NULL DEFAULT 'info' COMMENT 'info, exito, advertencia, error, pago',
  `url`             varchar(255) DEFAULT NULL,
  `leida`           tinyint(1)   NOT NULL DEFAULT 0,
  `fecha_creacion`  datetime     NOT NULL DEFAULT current_timestamp(),
  `fecha_lectura`   datetime     DEFAULT NULL,
  PRIMARY KEY (`id_notificacion`),
  KEY `idx_notif_usuario` (`id_usuario`,`leida`),
  CONSTRAINT `fk_notif_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 9. TABLA: mensajes_contacto  (formulario web + WhatsApp)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mensajes_contacto` (
  `id_mensaje`      int(11)      NOT NULL AUTO_INCREMENT,
  `id_usuario`      int(11)      DEFAULT NULL,
  `nombre`          varchar(145) NOT NULL,
  `email`           varchar(145) DEFAULT NULL,
  `telefono`        varchar(45)  DEFAULT NULL,
  `asunto`          varchar(145) DEFAULT NULL,
  `mensaje`         text         NOT NULL,
  `canal`           varchar(45)  NOT NULL DEFAULT 'web' COMMENT 'web, whatsapp, email, presencial',
  `estado`          varchar(45)  NOT NULL DEFAULT 'Nuevo' COMMENT 'Nuevo, En revision, Respondido, Cerrado',
  `respuesta`       text         DEFAULT NULL,
  `id_usuario_gestor` int(11)    DEFAULT NULL,
  `fecha_creacion`  datetime     NOT NULL DEFAULT current_timestamp(),
  `fecha_respuesta` datetime     DEFAULT NULL,
  PRIMARY KEY (`id_mensaje`),
  KEY `idx_mensaje_estado` (`estado`),
  KEY `idx_mensaje_usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 10. TABLA: password_resets
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `password_resets` (
  `id_reset`       int(11)      NOT NULL AUTO_INCREMENT,
  `id_usuario`     int(11)      NOT NULL,
  `token`          varchar(128) NOT NULL,
  `expira_en`      datetime     NOT NULL,
  `usado`          tinyint(1)   NOT NULL DEFAULT 0,
  `ip_solicitud`   varchar(45)  DEFAULT NULL,
  `fecha_creacion` datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_reset`),
  UNIQUE KEY `uk_reset_token` (`token`),
  KEY `idx_reset_usuario` (`id_usuario`),
  CONSTRAINT `fk_reset_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 11. TABLA: configuracion  (parametros del sistema editables)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `configuracion` (
  `clave`              varchar(95)  NOT NULL,
  `valor`              text         DEFAULT NULL,
  `tipo`               varchar(20)  NOT NULL DEFAULT 'texto',
  `grupo`              varchar(45)  NOT NULL DEFAULT 'general',
  `descripcion`        varchar(255) DEFAULT NULL,
  `fecha_actualizacion` datetime    NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 12. TABLA: comprobantes
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `comprobantes` (
  `id_comprobante`   int(11)      NOT NULL AUTO_INCREMENT,
  `id_pago`          int(11)      DEFAULT NULL,
  `id_solicitud`     int(11)      DEFAULT NULL,
  `numero`           varchar(45)  NOT NULL,
  `tipo`             varchar(45)  NOT NULL DEFAULT 'Recibo' COMMENT 'Recibo, Constancia, Certificado, Factura, Titulo',
  `archivo`          varchar(255) DEFAULT NULL,
  `id_usuario`       int(11)      DEFAULT NULL,
  `fecha_generacion` datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_comprobante`),
  UNIQUE KEY `uk_comprobante_numero` (`numero`),
  KEY `idx_comprobante_pago` (`id_pago`),
  CONSTRAINT `fk_comprobante_pago` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 13. TABLA: api_sincronizaciones  (bitacora de integracion)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `api_sincronizaciones` (
  `id_sync`                bigint(20)   NOT NULL AUTO_INCREMENT,
  `origen`                 varchar(95)  NOT NULL DEFAULT 'universidad',
  `tipo_dato`              varchar(45)  NOT NULL COMMENT 'alumnos, facultades, sedes, carreras, periodos',
  `registros_recibidos`    int(11)      NOT NULL DEFAULT 0,
  `registros_nuevos`       int(11)      NOT NULL DEFAULT 0,
  `registros_actualizados` int(11)      NOT NULL DEFAULT 0,
  `registros_error`        int(11)      NOT NULL DEFAULT 0,
  `estado`                 varchar(45)  NOT NULL DEFAULT 'Exitoso' COMMENT 'Exitoso, Parcial, Fallido',
  `mensaje`                text         DEFAULT NULL,
  `detalle_errores`        longtext     DEFAULT NULL,
  `id_usuario`             int(11)      DEFAULT NULL,
  `duracion_ms`            int(11)      DEFAULT NULL,
  `fecha_inicio`           datetime     NOT NULL DEFAULT current_timestamp(),
  `fecha_fin`              datetime     DEFAULT NULL,
  PRIMARY KEY (`id_sync`),
  KEY `idx_sync_tipo` (`tipo_dato`),
  KEY `idx_sync_fecha` (`fecha_inicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 14. TABLA: plantillas_documento (tramites -> documentos)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `plantillas_documento` (
  `id_plantilla`   int(11)      NOT NULL AUTO_INCREMENT,
  `id_tipo_tramite` int(11)    DEFAULT NULL,
  `nombre`         varchar(145) NOT NULL,
  `contenido_html` longtext     NOT NULL,
  `estado`         varchar(20)  NOT NULL DEFAULT 'Activo',
  `creado_en`      datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_plantilla`),
  KEY `idx_plantilla_tramite` (`id_tipo_tramite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
--  ALTERACIONES A TABLAS EXISTENTES
-- =====================================================================

-- --- pagos: datos de pasarela, auditoria y trazabilidad ---------------
ALTER TABLE `pagos`
  ADD COLUMN IF NOT EXISTS `id_periodo`             int(11)      DEFAULT NULL AFTER `id_usuario`,
  ADD COLUMN IF NOT EXISTS `id_sede`                int(11)      DEFAULT NULL AFTER `id_periodo`,
  ADD COLUMN IF NOT EXISTS `pasarela`               varchar(45)  DEFAULT NULL COMMENT 'sandbox, bancard, pagopar, transferencia, caja' AFTER `codigo_transaccion`,
  ADD COLUMN IF NOT EXISTS `id_transaccion_pasarela` varchar(145) DEFAULT NULL AFTER `pasarela`,
  ADD COLUMN IF NOT EXISTS `moneda`                 varchar(10)  NOT NULL DEFAULT 'PYG' AFTER `monto_total`,
  ADD COLUMN IF NOT EXISTS `tipo_pago`              varchar(45)  NOT NULL DEFAULT 'Online' COMMENT 'Online, Caja, Transferencia' AFTER `moneda`,
  ADD COLUMN IF NOT EXISTS `monto_recibido`         decimal(12,2) DEFAULT NULL AFTER `tipo_pago`,
  ADD COLUMN IF NOT EXISTS `vuelto`                 decimal(12,2) DEFAULT NULL AFTER `monto_recibido`,
  ADD COLUMN IF NOT EXISTS `url_comprobante`        varchar(255) DEFAULT NULL AFTER `comprobante_ref`,
  ADD COLUMN IF NOT EXISTS `numero_comprobante`     varchar(45)  DEFAULT NULL AFTER `url_comprobante`,
  ADD COLUMN IF NOT EXISTS `observacion`            varchar(255) DEFAULT NULL AFTER `numero_comprobante`,
  ADD COLUMN IF NOT EXISTS `ip_origen`              varchar(45)  DEFAULT NULL AFTER `observacion`,
  ADD COLUMN IF NOT EXISTS `user_agent`             varchar(255) DEFAULT NULL AFTER `ip_origen`,
  ADD COLUMN IF NOT EXISTS `creado_en`              datetime     NOT NULL DEFAULT current_timestamp() AFTER `user_agent`,
  ADD COLUMN IF NOT EXISTS `actualizado_en`         datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() AFTER `creado_en`;

ALTER TABLE `pagos`
  ADD KEY IF NOT EXISTS `idx_pagos_alumno`  (`id_alumno`),
  ADD KEY IF NOT EXISTS `idx_pagos_estado`  (`estado_pago`),
  ADD KEY IF NOT EXISTS `idx_pagos_fecha`   (`fecha_pago`),
  ADD KEY IF NOT EXISTS `idx_pagos_usuario` (`id_usuario`);

-- --- obligaciones_pago: trazabilidad y saldos -------------------------
ALTER TABLE `obligaciones_pago`
  ADD COLUMN IF NOT EXISTS `monto_pagado`    decimal(12,2) NOT NULL DEFAULT 0.00 AFTER `monto_final`,
  ADD COLUMN IF NOT EXISTS `saldo`           decimal(12,2) NOT NULL DEFAULT 0.00 AFTER `monto_pagado`,
  ADD COLUMN IF NOT EXISTS `id_matricula`    int(11)      DEFAULT NULL AFTER `id_arancel`,
  ADD COLUMN IF NOT EXISTS `id_inscripcion`  int(11)      DEFAULT NULL AFTER `id_matricula`,
  ADD COLUMN IF NOT EXISTS `referencia`      varchar(45)  DEFAULT NULL AFTER `descripcion`,
  ADD COLUMN IF NOT EXISTS `prioridad`       varchar(20)  NOT NULL DEFAULT 'Normal' AFTER `estado`,
  ADD COLUMN IF NOT EXISTS `creado_en`       datetime     NOT NULL DEFAULT current_timestamp() AFTER `prioridad`;

ALTER TABLE `obligaciones_pago`
  ADD KEY IF NOT EXISTS `idx_oblig_alumno`  (`id_alumno`),
  ADD KEY IF NOT EXISTS `idx_oblig_estado`  (`estado`),
  ADD KEY IF NOT EXISTS `idx_oblig_vence`   (`fecha_vencimiento`);

-- --- solicitudes_tramite: seguimiento ---------------------------------
ALTER TABLE `solicitudes_tramite`
  ADD COLUMN IF NOT EXISTS `codigo_seguimiento` varchar(45) DEFAULT NULL AFTER `id_tipo_tramite`,
  ADD COLUMN IF NOT EXISTS `tipo_entrega`       varchar(45) NOT NULL DEFAULT 'Digital' AFTER `estado_tramite`,
  ADD COLUMN IF NOT EXISTS `fecha_estimada`     date        DEFAULT NULL AFTER `tipo_entrega`,
  ADD COLUMN IF NOT EXISTS `fecha_entrega`      datetime    DEFAULT NULL AFTER `fecha_estimada`,
  ADD COLUMN IF NOT EXISTS `id_usuario_gestion` int(11)     DEFAULT NULL AFTER `fecha_entrega`,
  ADD COLUMN IF NOT EXISTS `monto`              decimal(12,2) NOT NULL DEFAULT 0.00 AFTER `id_usuario_gestion`,
  ADD COLUMN IF NOT EXISTS `creado_en`          datetime    NOT NULL DEFAULT current_timestamp() AFTER `monto`;

ALTER TABLE `solicitudes_tramite`
  ADD UNIQUE KEY IF NOT EXISTS `uk_solicitud_codigo` (`codigo_seguimiento`);

-- --- usuarios: ultimo acceso, bloqueo y contacto ----------------------
ALTER TABLE `usuarios`
  ADD COLUMN IF NOT EXISTS `email`               varchar(145) DEFAULT NULL AFTER `user`,
  ADD COLUMN IF NOT EXISTS `ultimo_acceso`       datetime    DEFAULT NULL AFTER `estado`,
  ADD COLUMN IF NOT EXISTS `intentos_fallidos`   int(11)     NOT NULL DEFAULT 0 AFTER `ultimo_acceso`,
  ADD COLUMN IF NOT EXISTS `bloqueado_hasta`     datetime    DEFAULT NULL AFTER `intentos_fallidos`,
  ADD COLUMN IF NOT EXISTS `debe_cambiar_pass`   tinyint(1)  NOT NULL DEFAULT 0 AFTER `bloqueado_hasta`,
  ADD COLUMN IF NOT EXISTS `token_recuerdo`      varchar(128) DEFAULT NULL AFTER `debe_cambiar_pass`,
  ADD COLUMN IF NOT EXISTS `creado_en`           datetime    NOT NULL DEFAULT current_timestamp() AFTER `token_recuerdo`;

ALTER TABLE `usuarios`
  ADD UNIQUE KEY IF NOT EXISTS `uk_usuario_email` (`email`);

-- --- personas: contacto ampliado --------------------------------------
ALTER TABLE `personas`
  ADD COLUMN IF NOT EXISTS `email`        varchar(145) DEFAULT NULL AFTER `telefono`,
  ADD COLUMN IF NOT EXISTS `celular`      varchar(25)  DEFAULT NULL AFTER `email`,
  ADD COLUMN IF NOT EXISTS `sexo`         varchar(15)  DEFAULT NULL AFTER `nacionalidad`,
  ADD COLUMN IF NOT EXISTS `foto`         varchar(255) DEFAULT NULL AFTER `sexo`,
  ADD COLUMN IF NOT EXISTS `creado_en`    datetime     NOT NULL DEFAULT current_timestamp() AFTER `foto`;

-- --- facturas: relacion con alumno ------------------------------------
ALTER TABLE `facturas`
  ADD COLUMN IF NOT EXISTS `id_alumno`     int(11) DEFAULT NULL AFTER `id_pago`,
  ADD COLUMN IF NOT EXISTS `condicion_venta` varchar(45) NOT NULL DEFAULT 'Contado' AFTER `estado_factura`;

-- --- timbrados: control de numeracion ---------------------------------
ALTER TABLE `timbrados`
  ADD COLUMN IF NOT EXISTS `tipo_documento` varchar(45) NOT NULL DEFAULT 'Factura' AFTER `punto_expedicion`;

-- --- aranceles: vigencia y descripcion --------------------------------
ALTER TABLE `aranceles`
  ADD COLUMN IF NOT EXISTS `nombre`            varchar(145) DEFAULT NULL AFTER `id_periodo`,
  ADD COLUMN IF NOT EXISTS `monto_mora_diaria` decimal(12,2) NOT NULL DEFAULT 0.00 AFTER `monto_base`,
  ADD COLUMN IF NOT EXISTS `dias_gracia`       int(11)      NOT NULL DEFAULT 0 AFTER `monto_mora_diaria`,
  ADD COLUMN IF NOT EXISTS `cuotas`            int(11)      NOT NULL DEFAULT 1 AFTER `dias_gracia`;

-- --- alumno_beca: vigencia -------------------------------------------
ALTER TABLE `alumno_beca`
  ADD COLUMN IF NOT EXISTS `fecha_fin`      date         DEFAULT NULL AFTER `fecha_asignacion`,
  ADD COLUMN IF NOT EXISTS `observaciones`  varchar(255) DEFAULT NULL AFTER `estado`;

-- --- conceptos_pago: clasificacion + descripcion ampliada ------------
ALTER TABLE `conceptos_pago`
  MODIFY COLUMN `descripcion` varchar(255) DEFAULT NULL;

ALTER TABLE `conceptos_pago`
  ADD COLUMN IF NOT EXISTS `categoria`  varchar(45) NOT NULL DEFAULT 'General' COMMENT 'Matricula, Arancel, Examen, Tramite, General',
  ADD COLUMN IF NOT EXISTS `orden`      int(11)     NOT NULL DEFAULT 0 AFTER `categoria`;

ALTER TABLE `tipos_tramite`
  MODIFY COLUMN `nombre_tramite` varchar(145) DEFAULT NULL;

ALTER TABLE `tipos_tramite`
  ADD COLUMN IF NOT EXISTS `descripcion` varchar(255) DEFAULT NULL AFTER `nombre_tramite`;

-- --- solicitudes_tramite: observaciones ampliada ---------------------
ALTER TABLE `solicitudes_tramite`
  MODIFY COLUMN `documento_generado_url` varchar(255) DEFAULT NULL;

-- --- alumnos / helpers de texto largo -------------------------------
ALTER TABLE `facultades`
  MODIFY COLUMN `nombre` varchar(145) DEFAULT NULL;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  FIN DEL SCRIPT
-- =====================================================================
