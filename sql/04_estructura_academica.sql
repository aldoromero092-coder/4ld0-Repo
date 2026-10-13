-- =====================================================================
--  SISTEMA DE GESTION ACADEMICA UNVES - ESTRUCTURA ACADEMICA
--  Archivo : sql/04_estructura_academica.sql
--  Motor   : MariaDB 10.4 / MySQL 5.7+
--  Objetivo: Mallas curriculares, materias (carrera/curso/semestre),
--            cursos abiertos por periodo y ventanas academicas con las
--            fechas que habilitan matriculacion, inscripcion a examenes
--            y pagos.
--  Nota    : Script IDEMPOTENTE. Puede ejecutarse varias veces sin
--            romper datos existentes.
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. TABLA: mallas_curriculares  (plan de estudios de cada carrera)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mallas_curriculares` (
  `id_malla`        int(11)      NOT NULL AUTO_INCREMENT,
  `id_carrera`      int(11)      NOT NULL,
  `nombre`          varchar(145) NOT NULL COMMENT 'Ej.: Plan 2015 - Ingenieria en Informatica',
  `anio_vigencia`   int(11)      DEFAULT NULL,
  `resolucion`      varchar(95)  DEFAULT NULL COMMENT 'Resolucion del Consejo Superior Universitario',
  `total_cursos`    int(11)      NOT NULL DEFAULT 5 COMMENT 'Anios de la carrera',
  `total_semestres` int(11)      NOT NULL DEFAULT 2 COMMENT 'Semestres por curso',
  `carga_horaria`   int(11)      NOT NULL DEFAULT 0 COMMENT 'Horas reloj totales',
  `vigente`         tinyint(1)   NOT NULL DEFAULT 1,
  `observaciones`   text          DEFAULT NULL,
  `estado`          varchar(20)  NOT NULL DEFAULT 'Activo',
  `creado_en`       datetime     NOT NULL DEFAULT current_timestamp(),
  `actualizado_en`  datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_malla`),
  UNIQUE KEY `uk_malla_carrera_nombre` (`id_carrera`,`nombre`),
  KEY `idx_malla_carrera` (`id_carrera`,`vigente`),
  CONSTRAINT `fk_malla_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. TABLA: materias  (asignaturas de la malla por curso y semestre)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `materias` (
  `id_materia`     int(11)      NOT NULL AUTO_INCREMENT,
  `id_malla`       int(11)      NOT NULL,
  `id_carrera`     int(11)      NOT NULL COMMENT 'Redundante a proposito: permite listar sin unir la malla',
  `codigo`         varchar(20)  NOT NULL,
  `nombre`         varchar(145) NOT NULL,
  `curso`          int(11)      NOT NULL DEFAULT 1 COMMENT 'Anio de la carrera: 1 a N',
  `semestre`       int(11)      NOT NULL DEFAULT 1 COMMENT 'Semestre dentro del curso: 1 o 2',
  `semestre_global` int(11)     NOT NULL DEFAULT 1 COMMENT 'Semestre corrido: curso*2-1 / curso*2',
  `horas_catedra`  int(11)      NOT NULL DEFAULT 0,
  `creditos`       decimal(5,2) NOT NULL DEFAULT 0.00,
  `tipo`           varchar(20)  NOT NULL DEFAULT 'Obligatoria' COMMENT 'Obligatoria, Electiva, Optativa',
  `prerequisito`   varchar(145) DEFAULT NULL,
  `orden`          int(11)      NOT NULL DEFAULT 0,
  `estado`         varchar(20)  NOT NULL DEFAULT 'Activo',
  `creado_en`      datetime     NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_materia`),
  UNIQUE KEY `uk_materia_malla_codigo` (`id_malla`,`codigo`),
  KEY `idx_materia_ubicacion` (`id_carrera`,`curso`,`semestre`),
  KEY `idx_materia_global` (`id_carrera`,`semestre_global`),
  CONSTRAINT `fk_materia_malla` FOREIGN KEY (`id_malla`) REFERENCES `mallas_curriculares` (`id_malla`) ON DELETE CASCADE,
  CONSTRAINT `fk_materia_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. TABLA: carrera_sede  (oferta academica de cada sede)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `carrera_sede` (
  `id_carrera_sede` int(11)     NOT NULL AUTO_INCREMENT,
  `id_carrera`      int(11)     NOT NULL,
  `id_sede`         int(11)     NOT NULL,
  `turnos`          varchar(95) NOT NULL DEFAULT 'Noche' COMMENT 'Lista separada por comas: Manana,Tarde,Noche',
  `cupo`            int(11)     NOT NULL DEFAULT 0 COMMENT '0 = sin cupo definido',
  `estado`          varchar(20) NOT NULL DEFAULT 'Activo',
  `creado_en`       datetime    NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_carrera_sede`),
  UNIQUE KEY `uk_carrera_sede` (`id_carrera`,`id_sede`),
  CONSTRAINT `fk_cs_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  CONSTRAINT `fk_cs_sede`    FOREIGN KEY (`id_sede`)    REFERENCES `sedes` (`id_sede`)       ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. TABLA: cursos_academicos  (divisiones abiertas en un periodo)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cursos_academicos` (
  `id_curso`     int(11)     NOT NULL AUTO_INCREMENT,
  `id_carrera`   int(11)     NOT NULL,
  `id_periodo`   int(11)     NOT NULL,
  `id_sede`      int(11)     DEFAULT NULL,
  `id_malla`     int(11)     DEFAULT NULL,
  `curso`        int(11)     NOT NULL DEFAULT 1 COMMENT 'Anio de la carrera',
  `semestre`     int(11)     NOT NULL DEFAULT 1 COMMENT 'Semestre de la malla',
  `seccion`      varchar(10) NOT NULL DEFAULT 'A',
  `turno`        varchar(45) NOT NULL DEFAULT 'Noche',
  `modalidad`    varchar(45) NOT NULL DEFAULT 'Presencial',
  `aula`         varchar(45) DEFAULT NULL,
  `cupo`         int(11)     NOT NULL DEFAULT 40,
  `matriculados` int(11)     NOT NULL DEFAULT 0,
  `fecha_inicio` date        DEFAULT NULL,
  `fecha_fin`    date        DEFAULT NULL,
  `estado`       varchar(20) NOT NULL DEFAULT 'Abierto' COMMENT 'Planificado, Abierto, Cerrado, Cancelado',
  `observaciones` varchar(255) DEFAULT NULL,
  `id_usuario_gestion` int(11) DEFAULT NULL,
  `creado_en`    datetime    NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime  NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_curso`),
  UNIQUE KEY `uk_curso_division` (`id_carrera`,`id_periodo`,`curso`,`semestre`,`seccion`,`id_sede`),
  KEY `idx_curso_periodo` (`id_periodo`,`estado`),
  CONSTRAINT `fk_curso_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  CONSTRAINT `fk_curso_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE CASCADE,
  CONSTRAINT `fk_curso_sede`    FOREIGN KEY (`id_sede`)    REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL,
  CONSTRAINT `fk_curso_malla`   FOREIGN KEY (`id_malla`)   REFERENCES `mallas_curriculares` (`id_malla`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. TABLA: ventanas_academicas
--    Definen DESDE y HASTA cuando se puede hacer cada tramite online.
--    Si no hay ventana para una combinacion, la accion queda cerrada.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ventanas_academicas` (
  `id_ventana`     int(11)      NOT NULL AUTO_INCREMENT,
  `nombre`         varchar(145) NOT NULL,
  `tipo`           varchar(30)  NOT NULL COMMENT 'Matricula, Examen, Arancel, Tramite, General',
  `id_periodo`     int(11)      DEFAULT NULL COMMENT 'NULL = todos los periodos',
  `id_carrera`     int(11)      DEFAULT NULL COMMENT 'NULL = todas las carreras',
  `id_sede`        int(11)      DEFAULT NULL COMMENT 'NULL = todas las sedes',
  `fecha_apertura` date         NOT NULL,
  `hora_apertura`  time         DEFAULT '00:00:00',
  `fecha_cierre`   date         NOT NULL,
  `hora_cierre`    time         DEFAULT '23:59:59',
  `permite_pago_tardio` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_limite_pago`   date     DEFAULT NULL COMMENT 'Solo si permite_pago_tardio = 1',
  `recargo_tardio` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Porcentaje sobre el monto',
  `monto_recargo`  decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Recargo fijo en guaranies',
  `aviso`          varchar(255) DEFAULT NULL COMMENT 'Mensaje que ve el alumno',
  `estado`         varchar(20)  NOT NULL DEFAULT 'Activo' COMMENT 'Activo, Inactivo',
  `observaciones`  varchar(255) DEFAULT NULL,
  `id_usuario_gestion` int(11)  DEFAULT NULL,
  `creado_en`      datetime     NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime     NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_ventana`),
  KEY `idx_ventana_busqueda` (`tipo`,`id_periodo`,`estado`),
  KEY `idx_ventana_fechas` (`fecha_apertura`,`fecha_cierre`),
  CONSTRAINT `fk_ventana_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE CASCADE,
  CONSTRAINT `fk_ventana_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  CONSTRAINT `fk_ventana_sede`    FOREIGN KEY (`id_sede`)    REFERENCES `sedes` (`id_sede`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. TABLA: matricula_materias  (materias que cursa el alumno)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `matricula_materias` (
  `id_matricula_materia` int(11)     NOT NULL AUTO_INCREMENT,
  `id_matricula`         int(11)     NOT NULL,
  `id_materia`           int(11)     NOT NULL,
  `id_curso`             int(11)     DEFAULT NULL,
  `codigo`               varchar(20) DEFAULT NULL,
  `nombre`               varchar(145) DEFAULT NULL COMMENT 'Copia historica: la malla puede cambiar',
  `curso`                int(11)     NOT NULL DEFAULT 1,
  `semestre`             int(11)     NOT NULL DEFAULT 1,
  `horas`                int(11)     NOT NULL DEFAULT 0,
  `creditos`             decimal(5,2) NOT NULL DEFAULT 0.00,
  `condicion`            varchar(20) NOT NULL DEFAULT 'Regular' COMMENT 'Regular, Libre, Recursante',
  `estado`               varchar(20) NOT NULL DEFAULT 'Inscripto' COMMENT 'Inscripto, Aprobada, Reprobada, Retirada',
  `nota`                 decimal(5,2) DEFAULT NULL,
  `creado_en`            datetime    NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_matricula_materia`),
  UNIQUE KEY `uk_matricula_materia` (`id_matricula`,`id_materia`),
  KEY `idx_mm_materia` (`id_materia`),
  CONSTRAINT `fk_mm_matricula` FOREIGN KEY (`id_matricula`) REFERENCES `matriculas` (`id_matricula`) ON DELETE CASCADE,
  CONSTRAINT `fk_mm_materia`   FOREIGN KEY (`id_materia`)   REFERENCES `materias` (`id_materia`) ON DELETE CASCADE,
  CONSTRAINT `fk_mm_curso`     FOREIGN KEY (`id_curso`)     REFERENCES `cursos_academicos` (`id_curso`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
--  ALTERACIONES A TABLAS EXISTENTES
-- =====================================================================

-- --- facultades: tipo de unidad academica y datos de contacto ---------
ALTER TABLE `facultades`
  ADD COLUMN IF NOT EXISTS `tipo`        varchar(20)  NOT NULL DEFAULT 'Facultad' COMMENT 'Facultad o Escuela' AFTER `nombre`,
  ADD COLUMN IF NOT EXISTS `siglas`      varchar(20)  DEFAULT NULL AFTER `tipo`,
  ADD COLUMN IF NOT EXISTS `decano`      varchar(145) DEFAULT NULL AFTER `siglas`,
  ADD COLUMN IF NOT EXISTS `email`       varchar(145) DEFAULT NULL AFTER `decano`,
  ADD COLUMN IF NOT EXISTS `telefono`    varchar(45)  DEFAULT NULL AFTER `email`,
  ADD COLUMN IF NOT EXISTS `sitio_web`   varchar(255) DEFAULT NULL AFTER `telefono`;

-- --- sedes: ubicacion y contacto -------------------------------------
ALTER TABLE `sedes`
  ADD COLUMN IF NOT EXISTS `direccion`  varchar(200) DEFAULT NULL AFTER `nombre`,
  ADD COLUMN IF NOT EXISTS `ciudad`     varchar(95)  DEFAULT NULL AFTER `direccion`,
  ADD COLUMN IF NOT EXISTS `telefono`   varchar(45)  DEFAULT NULL AFTER `ciudad`,
  ADD COLUMN IF NOT EXISTS `email`      varchar(145) DEFAULT NULL AFTER `telefono`,
  ADD COLUMN IF NOT EXISTS `es_central` tinyint(1)   NOT NULL DEFAULT 0 AFTER `email`,
  ADD COLUMN IF NOT EXISTS `tipo`       varchar(45)  DEFAULT 'Campus' AFTER `es_central`;

-- --- carreras: datos academicos del programa -------------------------
ALTER TABLE `carreras`
  ADD COLUMN IF NOT EXISTS `titulo_otorgado`    varchar(145) DEFAULT NULL AFTER `nombre`,
  ADD COLUMN IF NOT EXISTS `duracion_anios`     int(11)      DEFAULT NULL AFTER `duracion_anio`,
  ADD COLUMN IF NOT EXISTS `duracion_semestres` int(11)      DEFAULT NULL AFTER `duracion_anios`,
  ADD COLUMN IF NOT EXISTS `carga_horaria`      int(11)      DEFAULT NULL AFTER `duracion_semestres`,
  ADD COLUMN IF NOT EXISTS `resolucion`         varchar(95)  DEFAULT NULL AFTER `carga_horaria`,
  ADD COLUMN IF NOT EXISTS `area`               varchar(95)  DEFAULT NULL AFTER `resolucion`,
  ADD COLUMN IF NOT EXISTS `malla_url`          varchar(255) DEFAULT NULL AFTER `area`;

-- --- matriculas: enlace con la malla y los cursos abiertos -----------
ALTER TABLE `matriculas`
  ADD COLUMN IF NOT EXISTS `id_malla`       int(11)      DEFAULT NULL AFTER `id_sede`,
  ADD COLUMN IF NOT EXISTS `id_curso`       int(11)      DEFAULT NULL AFTER `id_malla`,
  ADD COLUMN IF NOT EXISTS `curso`          int(11)      DEFAULT NULL AFTER `semestre`,
  ADD COLUMN IF NOT EXISTS `total_materias` int(11)      NOT NULL DEFAULT 0 AFTER `monto_matricula`,
  ADD COLUMN IF NOT EXISTS `total_creditos` decimal(6,2) NOT NULL DEFAULT 0.00 AFTER `total_materias`;

ALTER TABLE `matriculas`
  ADD KEY IF NOT EXISTS `idx_matricula_malla` (`id_malla`),
  ADD KEY IF NOT EXISTS `idx_matricula_curso` (`id_curso`);

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  FIN DEL SCRIPT
-- =====================================================================
