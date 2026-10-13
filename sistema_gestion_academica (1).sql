-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-10-2026 a las 18:58:34
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.5.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistema_gestion_academica`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumnos`
--

CREATE TABLE `alumnos` (
  `id_alumno` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `legajo` varchar(45) DEFAULT NULL,
  `codigo_externo` varchar(95) DEFAULT NULL COMMENT 'Id en el sistema central de la universidad',
  `id_carrera` int(11) DEFAULT NULL,
  `id_facultades` int(11) DEFAULT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `id_periodo_ingreso` int(11) DEFAULT NULL,
  `semestre_actual` int(11) DEFAULT 1,
  `estado_academico` varchar(45) DEFAULT 'Activo' COMMENT 'Activo, Egresado, Suspendido, Retirado, Titulado',
  `modalidad` varchar(45) DEFAULT 'Presencial',
  `turno` varchar(45) DEFAULT 'Noche',
  `fecha_ingreso` date DEFAULT NULL,
  `promedio_general` decimal(5,2) DEFAULT NULL,
  `creditos_aprobados` int(11) DEFAULT 0,
  `origen_datos` varchar(45) DEFAULT 'Local' COMMENT 'Local | API',
  `ultima_sincronizacion` datetime DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'Activo',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `alumnos`
--

INSERT INTO `alumnos` (`id_alumno`, `id_persona`, `legajo`, `codigo_externo`, `id_carrera`, `id_facultades`, `id_sede`, `id_periodo_ingreso`, `semestre_actual`, `estado_academico`, `modalidad`, `turno`, `fecha_ingreso`, `promedio_general`, `creditos_aprobados`, `origen_datos`, `ultima_sincronizacion`, `observaciones`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 2, '2023-ISI-001', 'EXT-1001', 4, 6, 1, 1, 8, 'Activo', 'Presencial', 'Noche', '2023-02-06', 4.15, 180, 'Local', NULL, NULL, 'Activo', '2026-10-13 10:32:58', '2026-10-13 12:06:38'),
(2, 3, '2022-CON-014', 'EXT-1002', 2, 1, 1, 1, 10, 'Activo', 'Presencial', 'Noche', '2022-02-07', 4.42, 220, 'Local', NULL, NULL, 'Activo', '2026-10-13 10:32:58', '2026-10-13 10:32:58'),
(3, 7, '2024-ISI-033', 'EXT-1003', 4, 6, 1, 2, 6, 'Activo', 'Presencial', 'Tarde', '2024-02-05', 3.85, 120, 'Local', NULL, NULL, 'Activo', '2026-10-13 10:32:58', '2026-10-13 12:06:38'),
(4, 8, '2025-ADM-052', 'EXT-1004', 1, 1, 1, 3, 3, 'Activo', 'Presencial', 'Noche', '2025-07-21', 3.60, 60, 'Local', NULL, NULL, 'Activo', '2026-10-13 10:32:58', '2026-10-13 10:32:58'),
(5, 9, '2024-ISI-070', 'EXT-2070', 4, 6, 1, 2, 6, 'Activo', 'Presencial', 'Noche', '2024-02-05', 4.28, 152, 'API', '2026-10-13 11:51:01', 'Registro traido desde el sistema central de la universidad.', 'Activo', '2026-10-13 11:51:01', '2026-10-13 12:06:38'),
(8, 12, '2026-INFO-001', NULL, 4, 6, 1, NULL, 1, 'Activo', 'Presencial', 'Noche', NULL, NULL, 0, 'Local', NULL, NULL, 'Activo', '2026-10-13 12:45:08', '2026-10-13 12:45:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno_beca`
--

CREATE TABLE `alumno_beca` (
  `id_alumno_beca` int(11) NOT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `id_beca` int(11) DEFAULT NULL,
  `id_periodo` int(11) DEFAULT NULL,
  `fecha_asignacion` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `observaciones` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `alumno_beca`
--

INSERT INTO `alumno_beca` (`id_alumno_beca`, `id_alumno`, `id_beca`, `id_periodo`, `fecha_asignacion`, `fecha_fin`, `estado`, `observaciones`) VALUES
(1, 4, 1, 3, '2026-07-20', '2026-12-18', 'Activo', 'Beca Excelencia Academica 50%'),
(2, 5, 2, 3, '2026-07-15', '2026-12-18', 'Activo', 'Beca Deportiva 30% por representar a la UNVES en los Juegos Universitarios.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `api_sincronizaciones`
--

CREATE TABLE `api_sincronizaciones` (
  `id_sync` bigint(20) NOT NULL,
  `origen` varchar(95) NOT NULL DEFAULT 'universidad',
  `tipo_dato` varchar(45) NOT NULL COMMENT 'alumnos, facultades, sedes, carreras, periodos',
  `registros_recibidos` int(11) NOT NULL DEFAULT 0,
  `registros_nuevos` int(11) NOT NULL DEFAULT 0,
  `registros_actualizados` int(11) NOT NULL DEFAULT 0,
  `registros_error` int(11) NOT NULL DEFAULT 0,
  `estado` varchar(45) NOT NULL DEFAULT 'Exitoso' COMMENT 'Exitoso, Parcial, Fallido',
  `mensaje` text DEFAULT NULL,
  `detalle_errores` longtext DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `duracion_ms` int(11) DEFAULT NULL,
  `fecha_inicio` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_fin` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `aranceles`
--

CREATE TABLE `aranceles` (
  `id_arancel` int(11) NOT NULL,
  `id_concepto_pago` int(11) DEFAULT NULL,
  `id_carrera` int(11) DEFAULT NULL,
  `id_periodo` int(11) DEFAULT NULL,
  `nombre` varchar(145) DEFAULT NULL,
  `monto_base` decimal(12,2) DEFAULT NULL,
  `monto_mora_diaria` decimal(12,2) NOT NULL DEFAULT 0.00,
  `dias_gracia` int(11) NOT NULL DEFAULT 0,
  `cuotas` int(11) NOT NULL DEFAULT 1,
  `fecha_vencimiento` date DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `aranceles`
--

INSERT INTO `aranceles` (`id_arancel`, `id_concepto_pago`, `id_carrera`, `id_periodo`, `nombre`, `monto_base`, `monto_mora_diaria`, `dias_gracia`, `cuotas`, `fecha_vencimiento`, `estado`) VALUES
(1, 1, NULL, 3, 'Matricula general 2026-2', 850000.00, 5000.00, 5, 1, '2026-08-15', 'Activo'),
(2, 2, NULL, 3, 'Reinscripcion 2026-2', 650000.00, 5000.00, 5, 1, '2026-08-15', 'Activo'),
(3, 3, 4, 3, 'Arancel mensual Ingeniería en Informática', 720000.00, 3000.00, 5, 6, '2026-10-10', 'Activo'),
(4, 3, 1, 3, 'Arancel mensual Administracion', 680000.00, 3000.00, 5, 6, '2026-10-10', 'Activo'),
(5, 3, 2, 3, 'Arancel mensual Contabilidad', 680000.00, 3000.00, 5, 6, '2026-10-10', 'Activo'),
(6, 3, 15, 3, 'Arancel mensual Enfermería', 780000.00, 3000.00, 5, 6, '2026-10-10', 'Activo'),
(7, 3, 11, 3, 'Arancel mensual Derecho', 700000.00, 3000.00, 5, 6, '2026-10-10', 'Activo'),
(8, 6, NULL, 3, 'Examen final 2026-2', 150000.00, 0.00, 0, 1, '2026-11-20', 'Activo'),
(9, 7, NULL, 3, 'Examen recuperatorio 2026-2', 180000.00, 0.00, 0, 1, '2026-11-27', 'Activo'),
(10, 9, NULL, 3, 'Constancia de estudios', 80000.00, 0.00, 0, 1, NULL, 'Activo'),
(11, 10, NULL, 3, 'Certificado de calificaciones', 120000.00, 0.00, 0, 1, NULL, 'Activo'),
(12, 13, NULL, 3, 'Kit universitario 2026', 250000.00, 0.00, 0, 1, '2026-09-30', 'Activo'),
(13, 4, 4, 3, 'Arancel mensual Ingeniería en Informática', 300000.00, 0.00, 0, 1, '2026-09-30', 'Activo'),
(14, 12, NULL, 3, 'Duplicado de credencial', 100000.00, 0.00, 0, 1, NULL, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditorias`
--

CREATE TABLE `auditorias` (
  `id_auditoria` bigint(20) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tabla_afectada` varchar(145) DEFAULT NULL,
  `registro_id` varchar(45) DEFAULT NULL,
  `accion` varchar(10) DEFAULT NULL,
  `valores_anteriores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`valores_anteriores`)),
  `valores_nuevos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`valores_nuevos`)),
  `ip_origen` varchar(45) DEFAULT NULL,
  `fecha_hora` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `auditorias`
--

INSERT INTO `auditorias` (`id_auditoria`, `id_usuario`, `tabla_afectada`, `registro_id`, `accion`, `valores_anteriores`, `valores_nuevos`, `ip_origen`, `fecha_hora`) VALUES
(1, 9, 'solicitudes_tramite', '3', 'ESTADO', '{\"id_solicitud\":3,\"id_alumno\":5,\"id_pago\":15,\"id_tipo_tramite\":1,\"codigo_seguimiento\":\"TRA-20261013-0001\",\"fecha_solicitud\":\"2026-10-03 09:15:00\",\"estado_tramite\":\"En proceso\",\"tipo_entrega\":\"Digital\",\"fecha_estimada\":\"2026-10-15\",\"fecha_entrega\":null,\"id_usuario_gestion\":null,\"monto\":\"80000.00\",\"creado_en\":\"2026-10-03 09:15:00\",\"documento_generado_url\":null,\"observaciones\":\"Constancia para presentar en el banco.\"}', '{\"estado_tramite\":\"Entregado\",\"id_usuario_gestion\":9,\"fecha_entrega\":\"2026-10-13 11:51:01\",\"observaciones\":\"Constancia entregada en ventanilla de secretaria.\"}', '0.0.0.0', '2026-10-13 11:51:01'),
(2, 9, 'solicitudes_tramite', '4', 'ESTADO', '{\"id_solicitud\":4,\"id_alumno\":5,\"id_pago\":17,\"id_tipo_tramite\":2,\"codigo_seguimiento\":\"TRA-20261013-0002\",\"fecha_solicitud\":\"2026-10-09 16:40:00\",\"estado_tramite\":\"En proceso\",\"tipo_entrega\":\"Digital\",\"fecha_estimada\":\"2026-10-16\",\"fecha_entrega\":null,\"id_usuario_gestion\":null,\"monto\":\"120000.00\",\"creado_en\":\"2026-10-09 16:40:00\",\"documento_generado_url\":null,\"observaciones\":\"Certificado para postulacion a una pasantia.\"}', '{\"estado_tramite\":\"Listo para retirar\",\"id_usuario_gestion\":9,\"observaciones\":\"Listo para retirar en Registro Academico.\"}', '0.0.0.0', '2026-10-13 11:51:01'),
(3, 9, 'solicitudes_tramite', '5', 'ESTADO', '{\"id_solicitud\":5,\"id_alumno\":5,\"id_pago\":null,\"id_tipo_tramite\":7,\"codigo_seguimiento\":\"TRA-20261013-0003\",\"fecha_solicitud\":\"2026-10-13 11:51:01\",\"estado_tramite\":\"Pendiente\",\"tipo_entrega\":\"Digital\",\"fecha_estimada\":\"2026-10-23\",\"fecha_entrega\":null,\"id_usuario_gestion\":null,\"monto\":\"0.00\",\"creado_en\":\"2026-10-13 11:51:01\",\"documento_generado_url\":null,\"observaciones\":\"Solicito evaluar el cambio a Ingenieria Industrial.\"}', '{\"estado_tramite\":\"En proceso\",\"id_usuario_gestion\":9}', '0.0.0.0', '2026-10-13 11:51:01'),
(4, 9, 'obligaciones_pago', '28', 'ANULAR', '{\"id_obligacion\":28,\"id_alumno\":5,\"id_concepto_pago\":13,\"id_periodo\":3,\"id_arancel\":12,\"id_matricula\":null,\"id_inscripcion\":null,\"descripcion\":\"Kit universitario 2026\",\"referencia\":\"KIT-2026\",\"monto_original\":\"250000.00\",\"monto_mora\":\"0.00\",\"monto_descuento\":\"0.00\",\"monto_final\":\"250000.00\",\"monto_pagado\":\"0.00\",\"saldo\":\"250000.00\",\"fecha_emision\":\"2026-08-01\",\"fecha_vencimiento\":\"2026-09-30\",\"estado\":\"Vencido\",\"prioridad\":\"Normal\",\"creado_en\":\"2026-08-01 09:00:00\"}', '{\"motivo\":\"El alumno ya contaba con el kit del ano anterior.\"}', '0.0.0.0', '2026-10-13 11:51:01'),
(5, 9, 'alumnos', '5', 'ACTUALIZAR', '{\"telefono\":\"+595 991 000 000\",\"direccion\":\"Sin registrar\"}', '{\"telefono\":\"+595 991 234 567\",\"direccion\":\"Barrio San Blas, calle Mcal. Estigarribia 1245, Villarrica\"}', '0.0.0.0', '2026-10-13 11:51:01'),
(6, NULL, 'pagos', '19', 'ANULAR', '{\"id_pago\":19,\"id_alumno\":5,\"id_metodo_pago\":1,\"id_usuario\":null,\"id_periodo\":2,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-325BDFFC\",\"pasarela\":\"caja\",\"id_transaccion_pasarela\":\"SBX-20261013171137-0A01A6\",\"monto_total\":\"150000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Caja\",\"monto_recibido\":\"150000.00\",\"vuelto\":\"0.00\",\"fecha_pago\":\"2026-10-13 17:11:37\",\"estado_pago\":\"Aprobado\",\"comprobante_ref\":\"TX-20261013-325BDFFC\",\"url_comprobante\":\"\\/SistemaUnvesGestion\\/pagos\\/comprobante\\/19\",\"numero_comprobante\":\"REC-2026-000018\",\"observacion\":\"Cobro en ventanilla\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 17:11:37\",\"actualizado_en\":\"2026-10-13 17:11:37\",\"metodo_nombre\":\"Efectivo\",\"metodo_tipo\":\"Contado\",\"cedula\":\"5234891-6\",\"alumno\":\"Villalba Rios, Lucia Fernanda\",\"email\":\"lucia.villalba@unves.edu.py\",\"celular\":\"0991 234 567\",\"legajo\":\"2024-ISI-070\",\"carrera_nombre\":\"Ingenieria en Informatica\",\"sede_nombre\":\"Campus Central - Villarrica\",\"periodo_nombre\":\"2026 - Primer Semestre\",\"registrado_por_nombres\":null,\"registrado_por_apellidos\":null,\"cantidad_items\":1,\"items\":[{\"id_pago_detalle\":24,\"id_pago\":19,\"id_obligacion\":31,\"monto_pagado\":\"150000.00\",\"descripcion\":\"Final - Prueba periodo cerrado\",\"referencia\":\"EXA-TEST\",\"monto_final\":\"150000.00\",\"estado_obligacion\":\"Pagado\",\"concepto_nombre\":\"Examen final\",\"categoria\":\"Examen\"}]}', '{\"motivo\":\"Prueba automatica\",\"id_usuario\":null}', '0.0.0.0', '2026-10-13 12:11:37'),
(7, 1, 'materias', '4', 'IMPORTAR', NULL, '{\"creadas\":0,\"actualizadas\":3}', '::1', '2026-10-13 12:16:48'),
(8, 1, 'ventanas_academicas', '11', 'CREAR', NULL, '{\"nombre\":\"PRUEBA Ventana automatizada\",\"tipo\":\"Arancel\",\"id_periodo\":4,\"id_carrera\":null,\"id_sede\":null,\"fecha_apertura\":\"2027-02-01\",\"hora_apertura\":\"00:00\",\"fecha_cierre\":\"2027-07-16\",\"hora_cierre\":\"23:59\",\"permite_pago_tardio\":1,\"fecha_limite_pago\":\"2027-08-31\",\"recargo_tardio\":8,\"monto_recargo\":0,\"aviso\":null,\"estado\":\"Activo\",\"observaciones\":null,\"id_usuario_gestion\":1}', '::1', '2026-10-13 12:16:48'),
(9, 1, 'mallas_curriculares', '26', 'CREAR', NULL, '{\"id_carrera\":14,\"nombre\":\"PRUEBA Malla Nutricion 2027\",\"anio_vigencia\":2027,\"resolucion\":null,\"total_cursos\":5,\"total_semestres\":2,\"carga_horaria\":0,\"vigente\":1,\"observaciones\":null,\"estado\":\"Activo\"}', '::1', '2026-10-13 12:16:49'),
(10, 1, 'sedes', '7', 'CREAR', NULL, '{\"nombre\":\"Sede ZZ174508\",\"direccion\":\"Calle Falsa 123\",\"telefono\":\"+595 900 000 000\",\"id_ciudades\":1,\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:08'),
(11, 1, 'facultades', '13', 'CREAR', NULL, '{\"nombre\":\"Facultad ZZ174508\",\"id_sede\":1,\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:08'),
(12, 1, 'carreras', '26', 'CREAR', NULL, '{\"codigo_carrera\":\"508\",\"nombre\":\"Carrera ZZ174508\",\"id_facultades\":1,\"duracion_anio\":5,\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:08'),
(13, 1, 'periodos_academicos', '5', 'CREAR', NULL, '{\"nombre\":\"Periodo ZZ174508\",\"fecha_inicio\":\"2027-11-17\",\"fecha_fin\":\"2028-04-15\",\"estado\":\"Planificado\"}', '::1', '2026-10-13 12:45:08'),
(14, 1, 'conceptos_pago', '15', 'CREAR', NULL, '{\"codigo\":\"508Z\",\"nombre\":\"Concepto ZZ174508\",\"descripcion\":\"Generado por prueba automatica\",\"es_recurrente\":0,\"categoria\":\"General\",\"orden\":90,\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:08'),
(15, 1, 'aranceles', '15', 'CREAR', NULL, '{\"id_concepto_pago\":15,\"id_carrera\":null,\"id_periodo\":5,\"nombre\":\"Arancel ZZ174508\",\"monto_base\":150000,\"monto_mora_diaria\":1000,\"dias_gracia\":3,\"cuotas\":1,\"fecha_vencimiento\":\"2026-11-12\",\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:08'),
(16, 1, 'becas', '6', 'CREAR', NULL, '{\"nombre\":\"Beca ZZ174508\",\"porcentaje_descuento\":15,\"monto_fijo_descuento\":0,\"tipo\":\"Porcentaje\",\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:08'),
(17, 1, 'facturas', '20', 'CREAR', NULL, '{\"id_pago\":6,\"origen\":\"facturacion\"}', '::1', '2026-10-13 12:45:09'),
(18, 1, 'timbrados', '3', 'CREAR', NULL, '{\"id_sede\":1,\"numero_timbrado\":\"T174508\",\"tipo_documento\":\"Factura\",\"punto_expedicion\":\"003\",\"establecimiento\":\"001\",\"fecha_inicio_vigencia\":\"2026-01-01\",\"fecha_fin_vigencia\":\"2026-12-31\",\"numero_inicio\":1,\"numero_fin\":1000,\"numero_actual\":0,\"estado\":\"Activo\"}', '::1', '2026-10-13 12:45:09'),
(19, 1, 'configuracion', 'multiple', 'ACTUALIZAR', '{\"app_siglas\":\"UNVES\",\"contacto_email\":\"pagos@unves.edu.py\",\"pasarela_activa\":\"sandbox\",\"whatsapp_numero\":\"595991461220\"}', '{\"app_siglas\":\"UNVES\",\"contacto_email\":\"pagos@unves.edu.py\",\"pasarela_activa\":\"sandbox\",\"whatsapp_numero\":\"595991461220\"}', '::1', '2026-10-13 12:45:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `becas`
--

CREATE TABLE `becas` (
  `id_beca` int(11) NOT NULL,
  `nombre` varchar(95) DEFAULT NULL,
  `porcentaje_descuento` decimal(5,2) DEFAULT NULL,
  `monto_fijo_descuento` decimal(12,2) DEFAULT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `becas`
--

INSERT INTO `becas` (`id_beca`, `nombre`, `porcentaje_descuento`, `monto_fijo_descuento`, `tipo`, `estado`) VALUES
(1, 'Beca Excelencia Academica', 50.00, NULL, 'Porcentaje', 'Activo'),
(2, 'Beca Deportiva', 30.00, NULL, 'Porcentaje', 'Activo'),
(3, 'Beca Hermanos', 20.00, NULL, 'Porcentaje', 'Activo'),
(4, 'Beca de Ayuda Social', NULL, 150000.00, 'Monto fijo', 'Activo'),
(5, 'Beca Excelencia Total', 100.00, NULL, 'Porcentaje', 'Activo'),
(6, 'Beca ZZ174508', 15.00, 0.00, 'Porcentaje', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carreras`
--

CREATE TABLE `carreras` (
  `id_carrera` int(11) NOT NULL,
  `codigo_carrera` varchar(45) NOT NULL,
  `nombre` varchar(145) NOT NULL,
  `titulo_otorgado` varchar(145) DEFAULT NULL,
  `id_facultades` int(11) DEFAULT NULL,
  `duracion_anio` int(11) DEFAULT NULL,
  `duracion_anios` int(11) DEFAULT NULL,
  `duracion_semestres` int(11) DEFAULT NULL,
  `carga_horaria` int(11) DEFAULT NULL,
  `resolucion` varchar(95) DEFAULT NULL,
  `area` varchar(95) DEFAULT NULL,
  `malla_url` varchar(255) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `carreras`
--

INSERT INTO `carreras` (`id_carrera`, `codigo_carrera`, `nombre`, `titulo_otorgado`, `id_facultades`, `duracion_anio`, `duracion_anios`, `duracion_semestres`, `carga_horaria`, `resolucion`, `area`, `malla_url`, `estado`) VALUES
(1, 'ADM', 'Licenciatura en Administración de Empresa', 'Licenciado/a en Administración de Empresa', 1, NULL, NULL, NULL, NULL, NULL, 'Ciencias Empresariales', NULL, 'Activo'),
(2, 'CONT', 'Licenciatura en Ciencias Contables y Auditoría', 'Contador/a Público/a', 1, 5, 5, 10, NULL, NULL, 'Ciencias Empresariales', NULL, 'Activo'),
(3, 'EDU', 'Licenciatura en Ciencias de la Educación', 'Licenciado/a en Ciencias de la Educación', 5, 4, 4, 8, 5040, NULL, 'Ciencias de la Educación', NULL, 'Activo'),
(4, 'INFO', 'Ingeniería en Informática', 'Ingeniero/a en Informática', 6, 6, 6, 12, NULL, NULL, 'Ingeniería', NULL, 'Activo'),
(5, 'IELE', 'Ingeniería Eléctrica', 'Ingeniero/a Electricista', 6, 5, 5, 10, NULL, NULL, 'Ingeniería', NULL, 'Activo'),
(6, 'IAM', 'Ingeniería Ambiental', 'Ingeniero/a Ambiental', 2, NULL, NULL, NULL, NULL, NULL, 'Ingeniería', NULL, 'Activo'),
(7, 'ARQ', 'Arquitectura', 'Arquitecto/a', 2, NULL, NULL, NULL, NULL, NULL, 'Arquitectura', NULL, 'Activo'),
(8, 'COM', 'Licenciatura en Ciencias de la Comunicación', 'Licenciado/a en Ciencias de la Comunicación', 5, 4, 4, 8, 5040, NULL, 'Comunicación', NULL, 'Activo'),
(9, 'GE', 'Licenciatura en Gestión Educativa', 'Licenciado/a en Gestión Educativa', 5, 4, 4, 8, 5040, NULL, 'Ciencias de la Educación', NULL, 'Activo'),
(10, 'ING', 'Licenciatura en Inglés', 'Licenciado/a en Lengua Inglesa', 5, 4, 4, 8, 5040, NULL, 'Idiomas', NULL, 'Activo'),
(11, 'DER', 'Derecho', 'Abogado/a', 4, NULL, NULL, NULL, NULL, NULL, 'Ciencias Jurídicas', NULL, 'Activo'),
(12, 'IQ', 'Ingeniería Química', 'Ingeniero/a Químico/a', 7, NULL, NULL, NULL, NULL, NULL, 'Ciencias Químicas', NULL, 'Activo'),
(13, 'PSI', 'Licenciatura en Psicología', 'Licenciado/a en Psicología', 3, NULL, NULL, NULL, NULL, NULL, 'Ciencias de la Salud', NULL, 'Activo'),
(14, 'NUT', 'Licenciatura en Nutrición', 'Licenciado/a en Nutrición', 3, NULL, NULL, NULL, NULL, NULL, 'Ciencias de la Salud', NULL, 'Activo'),
(15, 'ENF', 'Licenciatura en Enfermería', 'Licenciado/a en Enfermería', 3, NULL, NULL, NULL, NULL, NULL, 'Ciencias de la Salud', NULL, 'Activo'),
(16, 'AGRO', 'Ingeniería en Agroindustria', 'Ingeniero/a en Agroindustria', 8, 5, 5, 10, NULL, NULL, 'Ciencias Agrarias', NULL, 'Activo'),
(17, 'ZOO', 'Ingeniería en Zootecnia', 'Ingeniero/a en Zootecnia', 8, 5, 5, 10, NULL, NULL, 'Ciencias Agrarias', NULL, 'Activo'),
(18, 'GP', 'Licenciatura en Gestión Pública', 'Licenciado/a en Gestión Pública', 9, 4, 4, 8, 5040, NULL, 'Gestión Pública', NULL, 'Activo'),
(19, 'GHT', 'Licenciatura en Gastronomía, Hotelería y Turismo', 'Licenciado/a en Gastronomía, Hotelería y Turismo', 11, NULL, NULL, NULL, NULL, NULL, 'Gastronomía y Turismo', NULL, 'Activo'),
(20, 'IPADR', 'Ingeniería en Producción Agropecuaria y Desarrollo Rural', 'Ingeniero/a en Producción Agropecuaria', 9, NULL, NULL, NULL, NULL, NULL, 'Ciencias Agrarias', NULL, 'Activo'),
(21, 'MUS', 'Licenciatura en Música', 'Licenciado/a en Música', 10, 4, 4, 8, 5040, NULL, 'Artes', NULL, 'Activo'),
(22, 'HT', 'Licenciatura en Hotelería y Turismo', 'Licenciado/a en Hotelería y Turismo', 11, NULL, NULL, NULL, NULL, NULL, 'Gastronomía y Turismo', NULL, 'Activo'),
(23, 'GAS', 'Licenciatura en Gastronomía', 'Licenciado/a en Gastronomía', 11, NULL, NULL, NULL, NULL, NULL, 'Gastronomía y Turismo', NULL, 'Activo'),
(24, 'POS-ES', 'Especialización en Didáctica Superior Universitaria', 'Especialista en Didáctica Superior Universitaria', 12, NULL, NULL, NULL, NULL, NULL, 'Posgrado', NULL, 'Activo'),
(25, 'POS-MA', 'Maestría en Didáctica Superior Universitaria', 'Magíster en Didáctica Superior Universitaria', 12, NULL, NULL, NULL, NULL, NULL, 'Posgrado', NULL, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrera_sede`
--

CREATE TABLE `carrera_sede` (
  `id_carrera_sede` int(11) NOT NULL,
  `id_carrera` int(11) NOT NULL,
  `id_sede` int(11) NOT NULL,
  `turnos` varchar(95) NOT NULL DEFAULT 'Noche' COMMENT 'Lista separada por comas: Manana,Tarde,Noche',
  `cupo` int(11) NOT NULL DEFAULT 0 COMMENT '0 = sin cupo definido',
  `estado` varchar(20) NOT NULL DEFAULT 'Activo',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `carrera_sede`
--

INSERT INTO `carrera_sede` (`id_carrera_sede`, `id_carrera`, `id_sede`, `turnos`, `cupo`, `estado`, `creado_en`) VALUES
(1, 1, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(2, 1, 4, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(3, 1, 5, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(4, 1, 6, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(5, 2, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(6, 2, 2, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(7, 2, 4, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(8, 2, 5, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(9, 3, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(10, 3, 3, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(11, 3, 4, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(12, 3, 6, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(13, 4, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(14, 5, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(15, 6, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(16, 7, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(17, 8, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(18, 9, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(19, 10, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(20, 11, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(21, 12, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(22, 13, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(23, 14, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(24, 15, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(25, 15, 6, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(26, 16, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(27, 17, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(28, 18, 5, 'Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(29, 19, 2, 'Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(30, 20, 5, 'Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(31, 21, 1, 'Mañana,Tarde,Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(32, 22, 1, 'Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(33, 23, 1, 'Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(34, 24, 1, 'Noche', 0, 'Activo', '2026-10-13 12:06:38'),
(35, 25, 1, 'Noche', 0, 'Activo', '2026-10-13 12:06:38');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito_items`
--

CREATE TABLE `carrito_items` (
  `id_item` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_obligacion` int(11) NOT NULL,
  `fecha_agregado` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudades`
--

CREATE TABLE `ciudades` (
  `id_ciudades` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `id_departamento` int(11) DEFAULT NULL,
  `estado` varchar(15) DEFAULT 'Activo'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `ciudades`
--

INSERT INTO `ciudades` (`id_ciudades`, `nombre`, `id_departamento`, `estado`) VALUES
(1, 'Villarrica', NULL, 'Activo'),
(2, 'Asuncion', NULL, 'Activo'),
(3, 'Encarnacion', NULL, 'Activo'),
(4, 'Ciudad del Este', NULL, 'Activo'),
(5, 'Coronel Oviedo', NULL, 'Activo'),
(6, 'Caaguazu', NULL, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobantes`
--

CREATE TABLE `comprobantes` (
  `id_comprobante` int(11) NOT NULL,
  `id_pago` int(11) DEFAULT NULL,
  `id_solicitud` int(11) DEFAULT NULL,
  `numero` varchar(45) NOT NULL,
  `tipo` varchar(45) NOT NULL DEFAULT 'Recibo' COMMENT 'Recibo, Constancia, Certificado, Factura, Titulo',
  `archivo` varchar(255) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_generacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `comprobantes`
--

INSERT INTO `comprobantes` (`id_comprobante`, `id_pago`, `id_solicitud`, `numero`, `tipo`, `archivo`, `id_usuario`, `fecha_generacion`) VALUES
(1, 7, NULL, 'REC-2026-000007', 'Recibo', NULL, 9, '2025-07-18 10:00:00'),
(2, 8, NULL, 'REC-2026-000008', 'Recibo', NULL, 9, '2025-08-07 10:00:00'),
(3, 9, NULL, 'REC-2026-000009', 'Recibo', NULL, 9, '2026-01-28 10:00:00'),
(4, 10, NULL, 'REC-2026-000010', 'Recibo', NULL, 9, '2026-06-20 10:00:00'),
(5, 11, NULL, 'REC-2026-000011', 'Recibo', NULL, 9, '2026-07-23 10:00:00'),
(6, 12, NULL, 'REC-2026-000012', 'Recibo', NULL, 9, '2026-08-05 10:00:00'),
(7, 13, NULL, 'REC-2026-000013', 'Recibo', NULL, 9, '2026-09-08 10:00:00'),
(8, 14, NULL, 'REC-2026-000014', 'Recibo', NULL, 9, '2026-10-02 10:00:00'),
(9, 15, NULL, 'REC-2026-000015', 'Recibo', NULL, 9, '2026-10-05 10:00:00'),
(10, 16, NULL, 'REC-2026-000016', 'Recibo', NULL, 9, '2026-10-08 10:00:00'),
(11, 17, NULL, 'REC-2026-000017', 'Recibo', NULL, 9, '2026-10-11 10:00:00'),
(13, 20, NULL, 'REC-2026-000018', 'Recibo', NULL, 9, '2026-10-13 12:17:23'),
(14, 21, NULL, 'REC-2026-000019', 'Recibo', NULL, 3, '2026-10-13 12:22:00'),
(19, 34, NULL, 'REC-2026-000020', 'Recibo', NULL, 3, '2026-10-13 12:44:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `conceptos_pago`
--

CREATE TABLE `conceptos_pago` (
  `id_concepto_pago` int(11) NOT NULL,
  `codigo` varchar(45) DEFAULT NULL,
  `nombre` varchar(145) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `es_recurrente` tinyint(1) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `categoria` varchar(45) NOT NULL DEFAULT 'General' COMMENT 'Matricula, Arancel, Examen, Tramite, General',
  `orden` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `conceptos_pago`
--

INSERT INTO `conceptos_pago` (`id_concepto_pago`, `codigo`, `nombre`, `descripcion`, `es_recurrente`, `estado`, `categoria`, `orden`) VALUES
(1, 'MAT', 'Matrícula ordinaria', 'Matriculación por periodo', 1, 'Activo', 'Matricula', 1),
(2, 'MAT-RE', 'Matrícula de reinscripción', 'Reinscripcion de alumnos regulares', 1, 'Activo', 'Matricula', 2),
(3, 'ARA', 'Arancel mensual', 'Cuota mensual de carrera', 1, 'Activo', 'Arancel', 3),
(4, 'LAB', 'Uso de laboratorio', 'Derecho de laboratorio', 1, 'Activo', 'Arancel', 4),
(5, 'EXA-INI', 'Examen de ingreso', 'Examen de admision', 0, 'Activo', 'Examen', 5),
(6, 'EXA-FIN', 'Examen final', 'Derecho a mesa final', 1, 'Activo', 'Examen', 6),
(7, 'EXA-REC', 'Examen recuperatorio', 'Derecho a recuperatorio', 1, 'Activo', 'Examen', 7),
(8, 'EXA-TIT', 'Examen de titulación', 'Defensa de tesis', 0, 'Activo', 'Examen', 8),
(9, 'TRA-CON', 'Constancia de estudios', 'Constancia de alumno regular', 0, 'Activo', 'Tramite', 9),
(10, 'TRA-NOT', 'Certificado de calificaciones', 'Analitico parcial', 0, 'Activo', 'Tramite', 10),
(11, 'TRA-TIT', 'Título profesional', 'Emision de titulo', 0, 'Activo', 'Tramite', 11),
(12, 'TRA-DUP', 'Duplicado de documentos', 'Segunda emision', 0, 'Activo', 'Tramite', 12),
(13, 'KIT', 'Kit universitario', 'Credencial y materiales', 1, 'Activo', 'General', 13),
(14, 'MUL', 'Multa por mora', 'Recargo por atraso', 0, 'Activo', 'General', 14);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `clave` varchar(95) NOT NULL,
  `valor` text DEFAULT NULL,
  `tipo` varchar(20) NOT NULL DEFAULT 'texto',
  `grupo` varchar(45) NOT NULL DEFAULT 'general',
  `descripcion` varchar(255) DEFAULT NULL,
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`clave`, `valor`, `tipo`, `grupo`, `descripcion`, `fecha_actualizacion`) VALUES
('api_sync_automatica', '0', 'booleano', 'integracion', 'Sincronizacion programada', '2026-10-13 11:03:38'),
('api_universidad_token', '', 'texto', 'integracion', 'Token Bearer de la API', '2026-10-13 10:57:08'),
('api_universidad_url', '', 'texto', 'integracion', 'Endpoint del sistema central', '2026-10-13 10:57:08'),
('app_favicon', '', 'texto', 'general', 'Icono de la pestana del navegador', '2026-10-13 11:27:45'),
('app_institucion', 'Universidad Nacional de Villarrica del Espiritu Santo', 'texto', 'general', 'Razon social', '2026-10-13 11:00:57'),
('app_logo', '', 'texto', 'general', 'Ruta del logo institucional (vacio = deteccion automatica)', '2026-10-13 11:27:45'),
('app_logo_claro', '', 'texto', 'general', 'Variante del logo para fondos oscuros', '2026-10-13 11:27:45'),
('app_moneda', 'PYG', 'texto', 'pagos', 'Moneda del sistema', '2026-10-13 10:32:58'),
('app_moneda_simbolo', 'Gs.', 'texto', 'pagos', 'Simbolo de moneda', '2026-10-13 10:32:58'),
('app_nombre', 'Sistema de Gestion Academica', 'texto', 'general', 'Nombre mostrado del sistema', '2026-10-13 10:32:58'),
('app_ruc', '80012345-6', 'texto', 'general', 'RUC institucional', '2026-10-13 10:32:58'),
('app_siglas', 'UNVES', 'texto', 'general', 'Siglas de la universidad', '2026-10-13 12:45:09'),
('app_zona_horaria', 'America/Asuncion', 'texto', 'general', 'Zona horaria', '2026-10-13 10:32:58'),
('contacto_email', 'pagos@unves.edu.py', 'texto', 'contacto', 'Correo de atencion', '2026-10-13 12:45:09'),
('contacto_telefono', '+595 991 461 220', 'texto', 'contacto', 'Telefono de atencion', '2026-10-13 10:32:58'),
('dias_gracia_defecto', '5', 'numero', 'pagos', 'Dias de gracia antes de aplicar mora', '2026-10-13 10:32:58'),
('iva_general', '10', 'numero', 'facturacion', 'Porcentaje de IVA general', '2026-10-13 11:00:57'),
('matricula_online_activa', '1', 'booleano', 'matriculas', 'Permitir matricula por web', '2026-10-13 11:03:21'),
('mora_diaria_defecto', '2000', 'numero', 'pagos', 'Mora diaria por defecto (Gs)', '2026-10-13 10:32:58'),
('pasarela_activa', 'sandbox', 'texto', 'pagos', 'Pasarela de pago activa', '2026-10-13 12:45:09'),
('pasarela_modo', 'pruebas', 'texto', 'pagos', 'pruebas | produccion', '2026-10-13 11:00:57'),
('whatsapp_mensaje', 'Hola, me comunico desde el portal de pagos de la UNVES.', 'texto', 'contacto', 'Mensaje precargado', '2026-10-13 10:32:58'),
('whatsapp_numero', '595991461220', 'texto', 'contacto', 'WhatsApp de atencion', '2026-10-13 12:45:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cursos_academicos`
--

CREATE TABLE `cursos_academicos` (
  `id_curso` int(11) NOT NULL,
  `id_carrera` int(11) NOT NULL,
  `id_periodo` int(11) NOT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `id_malla` int(11) DEFAULT NULL,
  `curso` int(11) NOT NULL DEFAULT 1 COMMENT 'Anio de la carrera',
  `semestre` int(11) NOT NULL DEFAULT 1 COMMENT 'Semestre de la malla',
  `seccion` varchar(10) NOT NULL DEFAULT 'A',
  `turno` varchar(45) NOT NULL DEFAULT 'Noche',
  `modalidad` varchar(45) NOT NULL DEFAULT 'Presencial',
  `aula` varchar(45) DEFAULT NULL,
  `cupo` int(11) NOT NULL DEFAULT 40,
  `matriculados` int(11) NOT NULL DEFAULT 0,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'Abierto' COMMENT 'Planificado, Abierto, Cerrado, Cancelado',
  `observaciones` varchar(255) DEFAULT NULL,
  `id_usuario_gestion` int(11) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cursos_academicos`
--

INSERT INTO `cursos_academicos` (`id_curso`, `id_carrera`, `id_periodo`, `id_sede`, `id_malla`, `curso`, `semestre`, `seccion`, `turno`, `modalidad`, `aula`, `cupo`, `matriculados`, `fecha_inicio`, `fecha_fin`, `estado`, `observaciones`, `id_usuario_gestion`, `creado_en`, `actualizado_en`) VALUES
(1, 1, 3, 1, 1, 1, 1, 'A', 'Noche', 'Presencial', 'Aula 03', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(2, 1, 3, 1, 1, 1, 2, 'A', 'Noche', 'Presencial', 'Aula 04', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(3, 1, 3, 1, 1, 2, 1, 'A', 'Noche', 'Presencial', 'Aula 05', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(4, 1, 3, 1, 1, 2, 2, 'A', 'Noche', 'Presencial', 'Aula 06', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(5, 2, 3, 1, 2, 1, 1, 'A', 'Noche', 'Presencial', 'Aula 03', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(6, 2, 3, 1, 2, 1, 2, 'A', 'Noche', 'Presencial', 'Aula 04', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(7, 2, 3, 1, 2, 2, 1, 'A', 'Noche', 'Presencial', 'Aula 05', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(8, 2, 3, 1, 2, 2, 2, 'A', 'Noche', 'Presencial', 'Aula 06', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(9, 4, 3, 1, 4, 1, 1, 'A', 'Noche', 'Presencial', 'Aula 03', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(10, 4, 3, 1, 4, 1, 2, 'A', 'Noche', 'Presencial', 'Aula 04', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(11, 4, 3, 1, 4, 2, 1, 'A', 'Noche', 'Presencial', 'Aula 05', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(12, 4, 3, 1, 4, 2, 2, 'A', 'Noche', 'Presencial', 'Aula 06', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(13, 4, 3, 1, 4, 3, 1, 'A', 'Noche', 'Presencial', 'Aula 07', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(14, 4, 3, 1, 4, 3, 2, 'A', 'Noche', 'Presencial', 'Aula 08', 40, 1, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:25:54'),
(15, 4, 3, 1, 4, 4, 1, 'A', 'Noche', 'Presencial', 'Aula 09', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(16, 4, 3, 1, 4, 4, 2, 'A', 'Noche', 'Presencial', 'Aula 10', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(17, 4, 3, 1, 4, 5, 1, 'A', 'Noche', 'Presencial', 'Aula 11', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(18, 4, 3, 1, 4, 5, 2, 'A', 'Noche', 'Presencial', 'Aula 12', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(19, 4, 3, 1, 4, 6, 1, 'A', 'Noche', 'Presencial', 'Aula 13', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(20, 4, 3, 1, 4, 6, 2, 'A', 'Noche', 'Presencial', 'Aula 14', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(21, 11, 3, 1, 11, 1, 1, 'A', 'Noche', 'Presencial', 'Aula 03', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(22, 11, 3, 1, 11, 1, 2, 'A', 'Noche', 'Presencial', 'Aula 04', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(23, 11, 3, 1, 11, 2, 1, 'A', 'Noche', 'Presencial', 'Aula 05', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(24, 11, 3, 1, 11, 2, 2, 'A', 'Noche', 'Presencial', 'Aula 06', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(35, 15, 3, 1, 15, 1, 1, 'A', 'Noche', 'Presencial', 'Aula 03', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:18:39', '2026-10-13 12:18:39'),
(36, 15, 3, 1, 15, 1, 2, 'A', 'Noche', 'Presencial', 'Aula 04', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:18:39', '2026-10-13 12:18:39'),
(37, 15, 3, 1, 15, 2, 1, 'A', 'Noche', 'Presencial', 'Aula 05', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:18:39', '2026-10-13 12:18:39'),
(38, 15, 3, 1, 15, 2, 2, 'A', 'Noche', 'Presencial', 'Aula 06', 40, 0, NULL, NULL, 'Abierto', NULL, NULL, '2026-10-13 12:18:39', '2026-10-13 12:18:39');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_fiscales`
--

CREATE TABLE `datos_fiscales` (
  `id_datos_fiscales` int(11) NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  `ruc` varchar(45) DEFAULT NULL,
  `razon_social` varchar(145) DEFAULT NULL,
  `direccion_fiscal` varchar(145) DEFAULT NULL,
  `telefono_fiscal` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `datos_fiscales`
--

INSERT INTO `datos_fiscales` (`id_datos_fiscales`, `id_persona`, `ruc`, `razon_social`, `direccion_fiscal`, `telefono_fiscal`) VALUES
(1, 9, 'X', 'Lucia Fernanda Villalba Rios', NULL, NULL),
(2, 3, 'X', 'Maria Fernanda Lopez Ramirez', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes`
--

CREATE TABLE `examenes` (
  `id_examen` int(11) NOT NULL,
  `nombre` varchar(145) NOT NULL,
  `materia` varchar(145) DEFAULT NULL,
  `tipo` varchar(45) NOT NULL DEFAULT 'Final' COMMENT 'Final, Recuperatorio, Parcial, Suficiencia, Libre',
  `id_periodo` int(11) DEFAULT NULL,
  `id_carrera` int(11) DEFAULT NULL,
  `id_facultades` int(11) DEFAULT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `id_concepto_pago` int(11) DEFAULT NULL,
  `monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_examen` date NOT NULL,
  `hora_inicio` time DEFAULT NULL,
  `duracion_min` int(11) DEFAULT 90,
  `aula` varchar(45) DEFAULT NULL,
  `cupo_maximo` int(11) DEFAULT 50,
  `inscritos` int(11) NOT NULL DEFAULT 0,
  `fecha_limite_insc` date DEFAULT NULL,
  `requiere_pago` tinyint(1) NOT NULL DEFAULT 1,
  `estado` varchar(45) NOT NULL DEFAULT 'Programado' COMMENT 'Programado, Inscripcion abierta, Cerrado, Finalizado, Cancelado',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `examenes`
--

INSERT INTO `examenes` (`id_examen`, `nombre`, `materia`, `tipo`, `id_periodo`, `id_carrera`, `id_facultades`, `id_sede`, `id_concepto_pago`, `monto`, `fecha_examen`, `hora_inicio`, `duracion_min`, `aula`, `cupo_maximo`, `inscritos`, `fecha_limite_insc`, `requiere_pago`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 'Mesa Final - Programacion Web', 'Programacion Web', 'Final', 3, 4, 2, 1, 6, 150000.00, '2026-11-10', '18:00:00', 90, 'Aula 12', 40, 2, '2026-11-05', 1, 'Inscripcion abierta', '2026-10-13 10:32:58', '2026-10-13 12:21:59'),
(2, 'Mesa Final - Base de Datos II', 'Base de Datos II', 'Final', 3, 4, 2, 1, 6, 150000.00, '2026-11-12', '18:00:00', 90, 'Aula 12', 40, 2, '2026-11-06', 1, 'Inscripcion abierta', '2026-10-13 10:32:58', '2026-10-13 12:44:37'),
(3, 'Mesa Final - Contabilidad IV', 'Contabilidad IV', 'Final', 3, 2, 1, 1, 6, 150000.00, '2026-11-17', '19:00:00', 90, 'Aula 05', 35, 1, '2026-11-11', 1, 'Inscripcion abierta', '2026-10-13 10:32:58', '2026-10-13 11:45:43'),
(4, 'Recuperatorio - Algoritmos', 'Algoritmos y Estructuras', 'Recuperatorio', 3, 4, 2, 1, 7, 180000.00, '2026-11-24', '18:30:00', 90, 'Aula 08', 30, 0, '2026-11-18', 1, 'Inscripcion abierta', '2026-10-13 10:32:58', '2026-10-13 11:03:04'),
(5, 'Mesa Final - Derecho Civil', 'Derecho Civil', 'Final', 3, 11, 4, 2, 6, 150000.00, '2026-11-19', '18:00:00', 90, 'Aula 21', 45, 0, '2026-11-13', 1, 'Inscripcion abierta', '2026-10-13 10:32:58', '2026-10-13 12:06:38'),
(6, 'Suficiencia - Ingles Tecnico', 'Ingles Tecnico', 'Suficiencia', 3, 4, 2, 1, 6, 200000.00, '2026-12-01', '09:00:00', 120, 'Aula Magna', 60, 0, '2026-11-25', 1, 'Programado', '2026-10-13 10:32:58', '2026-10-13 10:32:58'),
(7, 'Mesa Final - Analisis de Sistemas', 'Analisis de Sistemas', 'Final', 2, 4, 2, 1, 6, 140000.00, '2026-06-25', '18:00:00', 90, 'Aula 09', 30, 1, '2026-06-20', 1, 'Finalizado', '2026-06-01 08:00:00', '2026-10-13 11:51:01'),
(8, 'Examen ZZ174508', 'Materia ZZ174508', 'Final', 3, 4, NULL, 1, 6, 150000.00, '2026-11-02', '18:00:00', 90, 'Aula Test', 30, 0, '2026-10-28', 1, 'Inscripcion abierta', '2026-10-13 12:45:09', '2026-10-13 12:45:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `id_factura` int(11) NOT NULL,
  `id_pago` int(11) DEFAULT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `id_datos_fiscales` int(11) DEFAULT NULL,
  `id_timbrado` int(11) DEFAULT NULL,
  `numero_factura` varchar(45) DEFAULT NULL,
  `fecha_emision` datetime DEFAULT NULL,
  `monto_subtotal` decimal(12,2) DEFAULT NULL,
  `monto_iva5` decimal(12,2) DEFAULT NULL,
  `monto_iva10` decimal(12,2) DEFAULT NULL,
  `monto_exento` decimal(12,2) DEFAULT NULL,
  `monto_total` decimal(12,2) DEFAULT NULL,
  `cdc_electronico` varchar(95) DEFAULT NULL,
  `estado_factura` varchar(45) DEFAULT NULL,
  `condicion_venta` varchar(45) NOT NULL DEFAULT 'Contado',
  `id_carrera` int(11) DEFAULT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `matricula_legajo` varchar(45) DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `estado_academico` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `facturas`
--

INSERT INTO `facturas` (`id_factura`, `id_pago`, `id_alumno`, `id_datos_fiscales`, `id_timbrado`, `numero_factura`, `fecha_emision`, `monto_subtotal`, `monto_iva5`, `monto_iva10`, `monto_exento`, `monto_total`, `cdc_electronico`, `estado_factura`, `condicion_venta`, `id_carrera`, `id_sede`, `matricula_legajo`, `fecha_ingreso`, `estado_academico`) VALUES
(1, 7, 5, 1, 1, '001-001-0000002', '2025-07-18 10:00:00', 709090.91, 0.00, 70909.09, 0.00, 780000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(2, 8, 5, 1, 1, '001-001-0000003', '2025-08-07 10:00:00', 590909.09, 0.00, 59090.91, 0.00, 650000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(3, 9, 5, 1, 1, '001-001-0000004', '2026-01-28 10:00:00', 745454.55, 0.00, 74545.45, 0.00, 820000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(4, 10, 5, 1, 1, '001-001-0000005', '2026-06-20 10:00:00', 127272.73, 0.00, 12727.27, 0.00, 140000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(5, 11, 5, 1, 1, '001-001-0000006', '2026-07-23 10:00:00', 540909.09, 0.00, 54090.91, 0.00, 595000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(6, 12, 5, 1, 1, '001-001-0000007', '2026-08-05 10:00:00', 458181.82, 0.00, 45818.18, 0.00, 504000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(7, 13, 5, 1, 1, '001-001-0000008', '2026-09-08 10:00:00', 458181.82, 0.00, 45818.18, 0.00, 504000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(8, 14, 5, 1, 1, '001-001-0000009', '2026-10-02 10:00:00', 458181.82, 0.00, 45818.18, 0.00, 504000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(9, 15, 5, 1, 1, '001-001-0000010', '2026-10-05 10:00:00', 72727.27, 0.00, 7272.73, 0.00, 80000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(10, 16, 5, 1, 1, '001-001-0000011', '2026-10-08 10:00:00', 274545.45, 0.00, 27454.55, 0.00, 302000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(11, 17, 5, 1, 1, '001-001-0000012', '2026-10-11 10:00:00', 109090.91, 0.00, 10909.09, 0.00, 120000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(13, 20, 5, 1, 1, '001-001-0000014', '2026-10-13 12:17:23', 287272.73, 0.00, 28727.27, 0.00, 316000.00, NULL, 'Emitida', 'Contado', 4, 1, '2024-ISI-070', NULL, NULL),
(14, 21, 2, 2, 1, '001-001-0000015', '2026-10-13 12:22:00', 827272.73, 0.00, 82727.27, 0.00, 910000.00, NULL, 'Emitida', 'Contado', 2, 1, '2022-CON-014', NULL, NULL),
(19, 34, 2, 2, 1, '001-001-0000020', '2026-10-13 12:44:37', 245454.55, 0.00, 24545.45, 0.00, 270000.00, NULL, 'Emitida', 'Contado', 2, 1, '2022-CON-014', NULL, NULL),
(20, 6, 2, 2, 1, '001-001-0000021', '2026-10-13 12:45:09', 618181.82, 0.00, 61818.18, 0.00, 680000.00, NULL, 'Emitida', 'Contado', 2, 1, '2022-CON-014', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_detalles`
--

CREATE TABLE `factura_detalles` (
  `id_factura_detalle` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `id_pago_detalle` int(11) DEFAULT NULL,
  `descripcion` varchar(145) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_unitario` decimal(12,2) DEFAULT NULL,
  `tipo_iva` varchar(10) DEFAULT NULL,
  `monto_iva` decimal(12,2) DEFAULT NULL,
  `subtotal` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `factura_detalles`
--

INSERT INTO `factura_detalles` (`id_factura_detalle`, `id_factura`, `id_pago_detalle`, `descripcion`, `cantidad`, `precio_unitario`, `tipo_iva`, `monto_iva`, `subtotal`) VALUES
(1, 1, 7, 'Matricula ordinaria - Matricula 2025-2', 1, 780000.00, '10%', 70909.09, 780000.00),
(2, 2, 8, 'Arancel mensual - Arancel Agosto 2025', 1, 650000.00, '10%', 59090.91, 650000.00),
(3, 3, 9, 'Matricula ordinaria - Matricula 2026-1', 1, 820000.00, '10%', 74545.45, 820000.00),
(4, 4, 10, 'Examen final - Final - Analisis de Sistemas', 1, 140000.00, '10%', 12727.27, 140000.00),
(5, 5, 11, 'Matricula ordinaria - Matrícula Matricula general 2026-2', 1, 595000.00, '10%', 54090.91, 595000.00),
(6, 6, 12, 'Arancel mensual - Arancel Julio 2026', 1, 504000.00, '10%', 45818.18, 504000.00),
(7, 7, 13, 'Arancel mensual - Arancel Agosto 2026', 1, 504000.00, '10%', 45818.18, 504000.00),
(8, 8, 14, 'Arancel mensual - Arancel Septiembre 2026', 1, 504000.00, '10%', 45818.18, 504000.00),
(9, 9, 15, 'Constancia de estudios - Constancia de alumno regular', 1, 80000.00, '10%', 7272.73, 80000.00),
(10, 10, 16, 'Arancel mensual - Arancel Octubre 2026', 1, 302000.00, '10%', 27454.55, 302000.00),
(11, 11, 17, 'Certificado de calificaciones - Certificado de calificaciones', 1, 120000.00, '10%', 10909.09, 120000.00),
(13, 13, 25, 'Uso de laboratorio - Laboratorio Ing. Sistemas 2026', 1, 316000.00, '10%', 28727.27, 316000.00),
(14, 14, 26, 'Arancel mensual - Arancel Octubre 2026', 1, 680000.00, '10%', 61818.18, 680000.00),
(15, 14, 27, 'Examen final - Final - Programacion Web', 1, 150000.00, '10%', 13636.36, 150000.00),
(16, 14, 28, 'Constancia de estudios - Constancia de alumno regular', 1, 80000.00, '10%', 7272.73, 80000.00),
(21, 19, 43, 'Examen final - Final - Base de Datos II', 1, 150000.00, '10%', 13636.36, 150000.00),
(22, 19, 44, 'Certificado de calificaciones - Certificado de calificaciones', 1, 120000.00, '10%', 10909.09, 120000.00),
(23, 20, 6, 'Arancel mensual - Arancel Septiembre 2026', 1, 680000.00, '10%', 61818.18, 680000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facultades`
--

CREATE TABLE `facultades` (
  `id_facultades` int(11) NOT NULL,
  `nombre` varchar(145) DEFAULT NULL,
  `tipo` varchar(20) NOT NULL DEFAULT 'Facultad' COMMENT 'Facultad o Escuela',
  `siglas` varchar(20) DEFAULT NULL,
  `decano` varchar(145) DEFAULT NULL,
  `email` varchar(145) DEFAULT NULL,
  `telefono` varchar(45) DEFAULT NULL,
  `sitio_web` varchar(255) DEFAULT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `facultades`
--

INSERT INTO `facultades` (`id_facultades`, `nombre`, `tipo`, `siglas`, `decano`, `email`, `telefono`, `sitio_web`, `id_sede`, `estado`) VALUES
(1, 'Ciencias Económicas', 'Facultad', 'FCE', NULL, NULL, NULL, 'https://unves.edu.py', 1, 'Activo'),
(2, 'Ingeniería y Arquitectura', 'Facultad', 'FIA', NULL, NULL, NULL, 'https://unves.edu.py', 1, 'Activo'),
(3, 'Ciencias de la Salud', 'Facultad', 'FCS', NULL, NULL, NULL, 'https://unves.edu.py', 1, 'Activo'),
(4, 'Ciencias Jurídicas, Políticas y Sociales', 'Facultad', 'FCJP', NULL, NULL, NULL, 'https://unves.edu.py', 2, 'Activo'),
(5, 'Filosofía y Ciencias Humanas', 'Facultad', 'FFCH', NULL, NULL, NULL, 'https://unves.edu.py', 3, 'Activo'),
(6, 'Politécnica', 'Facultad', 'FPOL', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo'),
(7, 'Ciencias Físicas, Químicas y Matemáticas', 'Facultad', 'FFQM', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo'),
(8, 'Ciencias Agrarias', 'Facultad', 'FCA', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo'),
(9, 'Facultad de Ciencias', 'Facultad', 'FC', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo'),
(10, 'Escuela de Arte', 'Escuela', 'EA', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo'),
(11, 'Escuela de Gastronomía', 'Escuela', 'EG', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo'),
(12, 'Escuela de Posgrado', 'Escuela', 'EP', NULL, NULL, NULL, 'https://unves.edu.py', NULL, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gateway_logs`
--

CREATE TABLE `gateway_logs` (
  `id_log` bigint(20) NOT NULL,
  `id_pago` int(11) DEFAULT NULL,
  `pasarela_nombre` varchar(45) DEFAULT NULL,
  `evento` varchar(45) DEFAULT NULL,
  `request_payload` text DEFAULT NULL,
  `response_payload` text DEFAULT NULL,
  `codigo_respuesta` varchar(45) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `gateway_logs`
--

INSERT INTO `gateway_logs` (`id_log`, `id_pago`, `pasarela_nombre`, `evento`, `request_payload`, `response_payload`, `codigo_respuesta`, `fecha_registro`) VALUES
(1, 7, 'sandbox', 'iniciar', '{\"id_pago\":7,\"id_alumno\":5,\"id_metodo_pago\":7,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-0BB9E36F\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"780000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Pago de matricula 2025-2\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-034A6F\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/7\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"780000.00\",\"moneda\":\"PYG\"}}', 'OK', '2025-07-18 10:00:00'),
(2, 8, 'transferencia', 'iniciar', '{\"id_pago\":8,\"id_alumno\":5,\"id_metodo_pago\":2,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-CC286453\",\"pasarela\":\"transferencia\",\"id_transaccion_pasarela\":null,\"monto_total\":\"650000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel Agosto 2025 por transferencia\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"UNVES-00000008\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/resultado\\/8\",\"token\":null,\"mensaje\":\"Usá la referencia UNVES-00000008 al realizar la transferencia.\",\"datos\":{\"referencia\":\"UNVES-00000008\",\"banco\":\"Banco Continental\",\"cuenta\":\"000-1234567-890\",\"titular\":\"Universidad Nacional de Villarrica del Espíritu Santo\",\"ruc\":\"80012345-6\",\"instrucciones\":\"Adjuntá el comprobante en la sección \\\"Mis pagos\\\" para acreditar la operación en un plazo de 24 a 48 horas hábiles.\"}}', 'OK', '2025-08-07 10:00:00'),
(3, 9, 'sandbox', 'iniciar', '{\"id_pago\":9,\"id_alumno\":5,\"id_metodo_pago\":7,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-6EE0B8D0\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"820000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Pago de matricula 2026-1\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-761131\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/9\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"820000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-01-28 10:00:00'),
(4, 10, 'sandbox', 'iniciar', '{\"id_pago\":10,\"id_alumno\":5,\"id_metodo_pago\":5,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-D0825370\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"140000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Derecho de examen final\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-C3FDEF\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/10\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"140000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-06-20 10:00:00'),
(5, 11, 'sandbox', 'iniciar', '{\"id_pago\":11,\"id_alumno\":5,\"id_metodo_pago\":7,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-E17E323C\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"595000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Pago de matricula 2026-2\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-89F9F7\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/11\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"595000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-07-23 10:00:00'),
(6, 12, 'transferencia', 'iniciar', '{\"id_pago\":12,\"id_alumno\":5,\"id_metodo_pago\":2,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-0440C559\",\"pasarela\":\"transferencia\",\"id_transaccion_pasarela\":null,\"monto_total\":\"504000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel Julio 2026 por transferencia\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"UNVES-00000012\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/resultado\\/12\",\"token\":null,\"mensaje\":\"Usá la referencia UNVES-00000012 al realizar la transferencia.\",\"datos\":{\"referencia\":\"UNVES-00000012\",\"banco\":\"Banco Continental\",\"cuenta\":\"000-1234567-890\",\"titular\":\"Universidad Nacional de Villarrica del Espíritu Santo\",\"ruc\":\"80012345-6\",\"instrucciones\":\"Adjuntá el comprobante en la sección \\\"Mis pagos\\\" para acreditar la operación en un plazo de 24 a 48 horas hábiles.\"}}', 'OK', '2026-08-05 10:00:00'),
(7, 13, 'sandbox', 'iniciar', '{\"id_pago\":13,\"id_alumno\":5,\"id_metodo_pago\":5,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-A3C6456E\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"504000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel Agosto 2026 con Tigo Money\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-E3C001\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/13\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"504000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-09-08 10:00:00'),
(8, 14, 'sandbox', 'iniciar', '{\"id_pago\":14,\"id_alumno\":5,\"id_metodo_pago\":3,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-2101675D\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"504000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel Septiembre 2026 con tarjeta\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-9DA145\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/14\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"504000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-10-02 10:00:00'),
(9, 15, 'sandbox', 'iniciar', '{\"id_pago\":15,\"id_alumno\":5,\"id_metodo_pago\":7,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-99CD1526\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"80000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel de constancia de alumno regular\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-F00AFF\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/15\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"80000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-10-05 10:00:00'),
(10, 17, 'sandbox', 'iniciar', '{\"id_pago\":17,\"id_alumno\":5,\"id_metodo_pago\":4,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-447B8140\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"120000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 11:51:01\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel del certificado de calificaciones\",\"ip_origen\":null,\"user_agent\":\"\",\"creado_en\":\"2026-10-13 11:51:01\",\"actualizado_en\":\"2026-10-13 11:51:01\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013115101-05E2CC\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/17\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"120000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-10-11 10:00:00'),
(13, 20, 'sandbox', 'iniciar', '{\"id_pago\":20,\"id_alumno\":5,\"id_metodo_pago\":7,\"id_usuario\":9,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-1F66026F\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"316000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 12:17:18\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Laboratorio Ing. Sistemas 2026\",\"ip_origen\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/155.0.0.0 Safari\\/537.36\",\"creado_en\":\"2026-10-13 12:17:18\",\"actualizado_en\":\"2026-10-13 12:17:18\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013121718-BEFC9E\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/20\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"316000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-10-13 12:17:18'),
(14, 20, 'sandbox', 'confirmacion', '{\"accion\":\"aprobar\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013121718-BEFC9E\",\"estado\":\"Aprobado\",\"monto\":316000,\"mensaje\":\"Operación aprobada por la pasarela.\",\"datos\":{\"tarjeta\":\"0000\",\"autorizacion\":\"63C0A733\",\"cuotas\":1,\"modo\":\"sandbox\"}}', 'OK', '2026-10-13 12:17:23'),
(15, 21, 'sandbox', 'iniciar', '{\"id_pago\":21,\"id_alumno\":2,\"id_metodo_pago\":7,\"id_usuario\":3,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-3F8A19E0\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"910000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 12:21:59\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Arancel Octubre 2026 + Final - Programacion Web + Constancia de alumno regular\",\"ip_origen\":\"::1\",\"user_agent\":\"\",\"creado_en\":\"2026-10-13 12:21:59\",\"actualizado_en\":\"2026-10-13 12:21:59\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013122159-CD23FE\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/21\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"910000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-10-13 12:21:59'),
(16, 21, 'sandbox', 'confirmacion', '{\"accion\":\"aprobar\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013122159-CD23FE\",\"estado\":\"Aprobado\",\"monto\":910000,\"mensaje\":\"Operación aprobada por la pasarela.\",\"datos\":{\"tarjeta\":null,\"autorizacion\":\"E2FE3007\",\"cuotas\":1,\"modo\":\"sandbox\"}}', 'OK', '2026-10-13 12:21:59'),
(41, 34, 'sandbox', 'iniciar', '{\"id_pago\":34,\"id_alumno\":2,\"id_metodo_pago\":7,\"id_usuario\":3,\"id_periodo\":3,\"id_sede\":1,\"codigo_transaccion\":\"TX-20261013-76BF6A46\",\"pasarela\":\"sandbox\",\"id_transaccion_pasarela\":null,\"monto_total\":\"270000.00\",\"moneda\":\"PYG\",\"tipo_pago\":\"Online\",\"monto_recibido\":null,\"vuelto\":null,\"fecha_pago\":\"2026-10-13 12:44:37\",\"estado_pago\":\"Pendiente\",\"comprobante_ref\":null,\"url_comprobante\":null,\"numero_comprobante\":null,\"observacion\":\"Final - Base de Datos II + Certificado de calificaciones\",\"ip_origen\":\"::1\",\"user_agent\":\"\",\"creado_en\":\"2026-10-13 12:44:37\",\"actualizado_en\":\"2026-10-13 12:44:37\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-20261013124437-006048\",\"url_pago\":\"\\/SistemaUnvesGestion\\/pagos\\/pasarela\\/34\",\"token\":null,\"mensaje\":\"Transacción de prueba iniciada.\",\"datos\":{\"modo\":\"pruebas\",\"monto\":\"270000.00\",\"moneda\":\"PYG\"}}', 'OK', '2026-10-13 12:44:37'),
(42, 34, 'sandbox', 'confirmacion', '{\"accion\":\"aprobar\"}', '{\"ok\":true,\"id_transaccion\":\"SBX-34\",\"estado\":\"Aprobado\",\"monto\":270000,\"mensaje\":\"Operación aprobada por la pasarela.\",\"datos\":{\"tarjeta\":null,\"autorizacion\":\"F552AF88\",\"cuotas\":1,\"modo\":\"sandbox\"}}', 'OK', '2026-10-13 12:44:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inscripciones_examen`
--

CREATE TABLE `inscripciones_examen` (
  `id_inscripcion` int(11) NOT NULL,
  `id_examen` int(11) NOT NULL,
  `id_alumno` int(11) NOT NULL,
  `id_obligacion` int(11) DEFAULT NULL,
  `id_pago` int(11) DEFAULT NULL,
  `fecha_inscripcion` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` varchar(45) NOT NULL DEFAULT 'Pendiente' COMMENT 'Pendiente, Habilitado, Rendido, Ausente, Anulado',
  `nota` decimal(5,2) DEFAULT NULL,
  `condicion` varchar(45) DEFAULT NULL COMMENT 'Regular, Libre',
  `observaciones` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `inscripciones_examen`
--

INSERT INTO `inscripciones_examen` (`id_inscripcion`, `id_examen`, `id_alumno`, `id_obligacion`, `id_pago`, `fecha_inscripcion`, `estado`, `nota`, `condicion`, `observaciones`) VALUES
(1, 7, 5, 18, 10, '2026-06-15 11:20:00', 'Rendido', 4.50, 'Regular', 'Mesa final del primer semestre 2026.'),
(2, 1, 5, 29, NULL, '2026-10-13 11:51:01', 'Pendiente', NULL, 'Regular', NULL),
(3, 2, 5, 30, NULL, '2026-10-13 11:51:01', 'Pendiente', NULL, 'Regular', NULL),
(4, 1, 2, 32, 21, '2026-10-13 12:21:59', 'Habilitado', NULL, 'Regular', ''),
(5, 2, 2, 50, 34, '2026-10-13 12:44:37', 'Habilitado', NULL, 'Regular', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logs_actividad`
--

CREATE TABLE `logs_actividad` (
  `id_log` bigint(20) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `modulo` varchar(45) DEFAULT NULL,
  `accion` varchar(95) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `metodo_http` varchar(10) DEFAULT NULL,
  `ruta` varchar(255) DEFAULT NULL,
  `ip_origen` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `datos` longtext DEFAULT NULL,
  `nivel` varchar(15) NOT NULL DEFAULT 'info' COMMENT 'info, warning, error, seguridad',
  `fecha_hora` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `logs_actividad`
--

INSERT INTO `logs_actividad` (`id_log`, `id_usuario`, `modulo`, `accion`, `descripcion`, `metodo_http`, `ruta`, `ip_origen`, `user_agent`, `datos`, `nivel`, `fecha_hora`) VALUES
(1, 1, 'sistema', 'instalacion', 'Instalacion del portal web y carga de datos semilla', NULL, NULL, NULL, NULL, NULL, 'info', '2026-10-13 10:32:58'),
(2, 1, 'sistema', 'instalacion', 'Instalacion del portal web y carga de datos semilla', NULL, NULL, NULL, NULL, NULL, 'info', '2026-10-13 11:51:01'),
(3, 9, 'pagos', 'obligacion_creada', 'Obligación #14 por Gs. 595.000 (Matrícula Matricula general 2026-2)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":595000}', 'info', '2026-10-13 11:51:01'),
(4, 9, 'matriculas', 'matricula_solicitada', 'Matrícula MAT-2026-0005 solicitada', 'CLI', 'cli', '0.0.0.0', '', '{\"id_matricula\":7,\"id_obligacion\":14}', 'info', '2026-10-13 11:51:01'),
(5, 9, 'pagos', 'obligacion_creada', 'Obligación #15 por Gs. 780.000 (Matricula 2025-2)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":780000}', 'info', '2026-10-13 11:51:01'),
(6, 9, 'pagos', 'obligacion_creada', 'Obligación #16 por Gs. 650.000 (Arancel Agosto 2025)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":650000}', 'info', '2026-10-13 11:51:01'),
(7, 9, 'pagos', 'obligacion_creada', 'Obligación #17 por Gs. 820.000 (Matricula 2026-1)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":820000}', 'info', '2026-10-13 11:51:01'),
(8, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 780.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":7,\"obligaciones\":[15]}', 'info', '2026-10-13 11:51:01'),
(9, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000002 emitida para el pago #7', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(10, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 780.000 (comprobante REC-2026-000007)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":7,\"comprobante\":\"REC-2026-000007\"}', 'info', '2026-10-13 11:51:01'),
(11, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 650.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":8,\"obligaciones\":[16]}', 'info', '2026-10-13 11:51:01'),
(12, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000003 emitida para el pago #8', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(13, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 650.000 (comprobante REC-2026-000008)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":8,\"comprobante\":\"REC-2026-000008\"}', 'info', '2026-10-13 11:51:01'),
(14, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 820.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":9,\"obligaciones\":[17]}', 'info', '2026-10-13 11:51:01'),
(15, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000004 emitida para el pago #9', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(16, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 820.000 (comprobante REC-2026-000009)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":9,\"comprobante\":\"REC-2026-000009\"}', 'info', '2026-10-13 11:51:01'),
(17, 9, 'pagos', 'obligacion_creada', 'Obligación #18 por Gs. 140.000 (Final - Analisis de Sistemas)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":140000}', 'info', '2026-10-13 11:51:01'),
(18, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 140.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":10,\"obligaciones\":[18]}', 'info', '2026-10-13 11:51:01'),
(19, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000005 emitida para el pago #10', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(20, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 140.000 (comprobante REC-2026-000010)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":10,\"comprobante\":\"REC-2026-000010\"}', 'info', '2026-10-13 11:51:01'),
(21, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 595.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":11,\"obligaciones\":[14]}', 'info', '2026-10-13 11:51:01'),
(22, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000006 emitida para el pago #11', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(23, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 595.000 (comprobante REC-2026-000011)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":11,\"comprobante\":\"REC-2026-000011\"}', 'info', '2026-10-13 11:51:01'),
(24, 9, 'pagos', 'obligacion_creada', 'Obligación #19 por Gs. 504.000 (Arancel Julio 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":504000}', 'info', '2026-10-13 11:51:01'),
(25, 9, 'pagos', 'obligacion_creada', 'Obligación #20 por Gs. 504.000 (Arancel Agosto 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":504000}', 'info', '2026-10-13 11:51:01'),
(26, 9, 'pagos', 'obligacion_creada', 'Obligación #21 por Gs. 504.000 (Arancel Septiembre 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":504000}', 'info', '2026-10-13 11:51:01'),
(27, 9, 'pagos', 'obligacion_creada', 'Obligación #22 por Gs. 504.000 (Arancel Octubre 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":504000}', 'info', '2026-10-13 11:51:01'),
(28, 9, 'pagos', 'obligacion_creada', 'Obligación #23 por Gs. 504.000 (Arancel Noviembre 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":504000}', 'info', '2026-10-13 11:51:01'),
(29, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 504.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":12,\"obligaciones\":[19]}', 'info', '2026-10-13 11:51:01'),
(30, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000007 emitida para el pago #12', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(31, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 504.000 (comprobante REC-2026-000012)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":12,\"comprobante\":\"REC-2026-000012\"}', 'info', '2026-10-13 11:51:01'),
(32, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 504.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":13,\"obligaciones\":[20]}', 'info', '2026-10-13 11:51:01'),
(33, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000008 emitida para el pago #13', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(34, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 504.000 (comprobante REC-2026-000013)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":13,\"comprobante\":\"REC-2026-000013\"}', 'info', '2026-10-13 11:51:01'),
(35, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 504.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":14,\"obligaciones\":[21]}', 'info', '2026-10-13 11:51:01'),
(36, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000009 emitida para el pago #14', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(37, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 504.000 (comprobante REC-2026-000014)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":14,\"comprobante\":\"REC-2026-000014\"}', 'info', '2026-10-13 11:51:01'),
(38, 9, 'pagos', 'obligacion_creada', 'Obligación #24 por Gs. 80.000 (Constancia de alumno regular)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":80000}', 'info', '2026-10-13 11:51:01'),
(39, 9, 'tramites', 'tramite_solicitado', 'Trámite TRA-20261013-0001 solicitado', 'CLI', 'cli', '0.0.0.0', '', '{\"id_solicitud\":3}', 'info', '2026-10-13 11:51:01'),
(40, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 80.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":15,\"obligaciones\":[24]}', 'info', '2026-10-13 11:51:01'),
(41, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000010 emitida para el pago #15', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(42, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 80.000 (comprobante REC-2026-000015)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":15,\"comprobante\":\"REC-2026-000015\"}', 'info', '2026-10-13 11:51:01'),
(43, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000011 emitida para el pago #16', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(44, 9, 'pagos', 'obligacion_creada', 'Obligación #25 por Gs. 120.000 (Certificado de calificaciones)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":120000}', 'info', '2026-10-13 11:51:01'),
(45, 9, 'tramites', 'tramite_solicitado', 'Trámite TRA-20261013-0002 solicitado', 'CLI', 'cli', '0.0.0.0', '', '{\"id_solicitud\":4}', 'info', '2026-10-13 11:51:01'),
(46, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 120.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":17,\"obligaciones\":[25]}', 'info', '2026-10-13 11:51:01'),
(47, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000012 emitida para el pago #17', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(48, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 120.000 (comprobante REC-2026-000017)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":17,\"comprobante\":\"REC-2026-000017\"}', 'info', '2026-10-13 11:51:01'),
(49, 9, 'tramites', 'tramite_solicitado', 'Trámite TRA-20261013-0003 solicitado', 'CLI', 'cli', '0.0.0.0', '', '{\"id_solicitud\":5}', 'info', '2026-10-13 11:51:01'),
(50, 9, 'pagos', 'obligacion_creada', 'Obligación #26 por Gs. 100.000 (Duplicado de credencial)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":100000}', 'info', '2026-10-13 11:51:01'),
(51, 9, 'tramites', 'tramite_solicitado', 'Trámite TRA-20261013-0004 solicitado', 'CLI', 'cli', '0.0.0.0', '', '{\"id_solicitud\":6}', 'info', '2026-10-13 11:51:01'),
(52, 9, 'pagos', 'obligacion_creada', 'Obligación #27 por Gs. 300.000 (Laboratorio Ing. Sistemas 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":300000}', 'info', '2026-10-13 11:51:01'),
(53, 9, 'pagos', 'obligacion_creada', 'Obligación #28 por Gs. 250.000 (Kit universitario 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":250000}', 'info', '2026-10-13 11:51:01'),
(54, 9, 'pagos', 'obligacion_creada', 'Obligación #29 por Gs. 150.000 (Final - Programacion Web)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000}', 'info', '2026-10-13 11:51:01'),
(55, 9, 'examenes', 'inscripcion_examen', 'Inscripción al examen #1', 'CLI', 'cli', '0.0.0.0', '', '{\"id_inscripcion\":2,\"id_obligacion\":29}', 'info', '2026-10-13 11:51:01'),
(56, 9, 'pagos', 'obligacion_creada', 'Obligación #30 por Gs. 150.000 (Final - Base de Datos II)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000}', 'info', '2026-10-13 11:51:01'),
(57, 9, 'examenes', 'inscripcion_examen', 'Inscripción al examen #2', 'CLI', 'cli', '0.0.0.0', '', '{\"id_inscripcion\":3,\"id_obligacion\":30}', 'info', '2026-10-13 11:51:01'),
(58, 9, 'auth', 'sesion_iniciada', 'Inicio de sesion desde el portal web', 'CLI', 'cli', '0.0.0.0', '', '{\"origen\":\"demo\"}', 'info', '2026-10-13 11:51:01'),
(59, 9, 'perfil', 'perfil_actualizado', 'El alumno actualizo su numero de celular', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 11:51:01'),
(60, NULL, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 1.422.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":18,\"obligaciones\":[22,23,26,27,29,30]}', 'info', '2026-10-13 12:11:10'),
(61, NULL, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":19,\"obligaciones\":[31]}', 'info', '2026-10-13 12:11:37'),
(62, NULL, 'facturacion', 'factura_emitida', 'Factura 001-001-0000013 emitida para el pago #19', 'CLI', 'cli', '0.0.0.0', '', NULL, 'info', '2026-10-13 12:11:37'),
(63, NULL, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 150.000 (comprobante REC-2026-000018)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":19,\"comprobante\":\"REC-2026-000018\"}', 'info', '2026-10-13 12:11:37'),
(64, NULL, 'pagos', 'pago_anulado', 'Pago #19 anulado. Motivo: Prueba automatica', 'CLI', 'cli', '0.0.0.0', '', NULL, 'seguridad', '2026-10-13 12:11:37'),
(65, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:16:27'),
(66, 1, 'alumnos', 'alumnos_exportados', '5 alumnos exportados a CSV', 'GET', '/SistemaUnvesGestion/alumnos/exportar', '::1', '', NULL, 'info', '2026-10-13 12:16:28'),
(67, 1, 'seguridad', 'cierre_sesion', 'Salida del sistema', 'POST', '/SistemaUnvesGestion/logout', '::1', '', NULL, 'info', '2026-10-13 12:16:28'),
(68, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', 'curl/8.21.0', NULL, 'info', '2026-10-13 12:16:35'),
(69, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:16:48'),
(70, 1, 'estructura', 'malla_importada', 'Importación malla #4 (6º curso, semestre 1): 0 creadas, 3 actualizadas.', 'POST', '/SistemaUnvesGestion/estructura/materias/importar', '::1', '', NULL, 'info', '2026-10-13 12:16:48'),
(71, 1, 'estructura', 'ventana_creada', 'Ventana «PRUEBA Ventana automatizada» (Arancel) creada.', 'POST', '/SistemaUnvesGestion/estructura/ventanas/guardar', '::1', '', NULL, 'info', '2026-10-13 12:16:48'),
(72, 1, 'estructura', 'cursos_generados', '6 divisiones generadas para la malla Plan de estudios vigente - Licenciatura en Enfermeria', 'POST', '/SistemaUnvesGestion/estructura/cursos/generar', '::1', '', NULL, 'info', '2026-10-13 12:16:48'),
(73, 1, 'estructura', 'malla_creada', 'Se creó la malla «PRUEBA Malla Nutricion 2027».', 'POST', '/SistemaUnvesGestion/estructura/mallas/guardar', '::1', '', NULL, 'info', '2026-10-13 12:16:49'),
(74, 12, 'seguridad', 'cierre_sesion', 'Salida del sistema', 'GET', '/SistemaUnvesGestion/logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', NULL, 'info', '2026-10-13 12:17:04'),
(75, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', NULL, 'info', '2026-10-13 12:17:05'),
(76, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 316.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '{\"id_pago\":20,\"obligaciones\":[27]}', 'info', '2026-10-13 12:17:18'),
(77, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000014 emitida para el pago #20', 'POST', '/SistemaUnvesGestion/pagos/pasarela/20/confirmar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', NULL, 'info', '2026-10-13 12:17:23'),
(78, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 316.000 (comprobante REC-2026-000018)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/20/confirmar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '{\"id_pago\":20,\"comprobante\":\"REC-2026-000018\"}', 'info', '2026-10-13 12:17:23'),
(79, 1, 'sistema', 'instalacion', 'Instalacion del portal web y carga de datos semilla', NULL, NULL, NULL, NULL, NULL, 'info', '2026-10-13 12:18:28'),
(80, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:21:54'),
(81, 1, 'alumnos', 'alumnos_exportados', '5 alumnos exportados a CSV', 'GET', '/SistemaUnvesGestion/alumnos/exportar', '::1', '', NULL, 'info', '2026-10-13 12:21:55'),
(82, 1, 'seguridad', 'cierre_sesion', 'Salida del sistema', 'POST', '/SistemaUnvesGestion/logout', '::1', '', NULL, 'info', '2026-10-13 12:21:56'),
(83, 3, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:21:59'),
(84, 3, 'pagos', 'obligacion_creada', 'Obligación #32 por Gs. 150.000 (Final - Programacion Web)', 'POST', '/SistemaUnvesGestion/examenes/inscribir', '::1', '', '{\"id_alumno\":2,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:21:59'),
(85, 3, 'examenes', 'inscripcion_examen', 'Inscripción al examen #1', 'POST', '/SistemaUnvesGestion/examenes/inscribir', '::1', '', '{\"id_inscripcion\":4,\"id_obligacion\":32,\"recargo\":0}', 'info', '2026-10-13 12:21:59'),
(86, 3, 'pagos', 'obligacion_creada', 'Obligación #33 por Gs. 80.000 (Constancia de alumno regular)', 'POST', '/SistemaUnvesGestion/tramites/solicitar', '::1', '', '{\"id_alumno\":2,\"monto\":80000,\"recargo\":0}', 'info', '2026-10-13 12:21:59'),
(87, 3, 'tramites', 'tramite_solicitado', 'Trámite TRA-20261013-0005 solicitado', 'POST', '/SistemaUnvesGestion/tramites/solicitar', '::1', '', '{\"id_solicitud\":7}', 'info', '2026-10-13 12:21:59'),
(88, 3, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 910.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":21,\"obligaciones\":[9,32,33]}', 'info', '2026-10-13 12:21:59'),
(89, 3, 'facturacion', 'factura_emitida', 'Factura 001-001-0000015 emitida para el pago #21', 'POST', '/SistemaUnvesGestion/pagos/pasarela/21/confirmar', '::1', '', NULL, 'info', '2026-10-13 12:22:00'),
(90, 3, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 910.000 (comprobante REC-2026-000019)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/21/confirmar', '::1', '', '{\"id_pago\":21,\"comprobante\":\"REC-2026-000019\"}', 'info', '2026-10-13 12:22:00'),
(91, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', 'curl/8.21.0', NULL, 'info', '2026-10-13 12:24:24'),
(92, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', 'curl/8.21.0', NULL, 'info', '2026-10-13 12:24:30'),
(93, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', 'curl/8.21.0', NULL, 'info', '2026-10-13 12:24:34'),
(94, 10, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:25:34'),
(95, 10, 'pagos', 'obligacion_creada', 'Obligación #34 por Gs. 850.000 (Matrícula Matricula general 2026-2)', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_alumno\":6,\"monto\":850000,\"recargo\":0}', 'info', '2026-10-13 12:25:34'),
(96, 10, 'matriculas', 'matricula_solicitada', 'Matrícula MAT-2026-0006 solicitada', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_matricula\":8,\"id_obligacion\":34,\"materias\":5,\"recargo\":0}', 'info', '2026-10-13 12:25:34'),
(97, 10, 'pagos', 'obligacion_creada', 'Obligación #35 por Gs. 850.000 (Matrícula Matricula general 2026-2)', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_alumno\":6,\"monto\":850000,\"recargo\":0}', 'info', '2026-10-13 12:25:34'),
(98, 10, 'matriculas', 'matricula_solicitada', 'Matrícula MAT-2026-0006 solicitada', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_matricula\":9,\"id_obligacion\":35,\"materias\":5,\"recargo\":0}', 'info', '2026-10-13 12:25:34'),
(99, 11, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:25:54'),
(100, 11, 'pagos', 'obligacion_creada', 'Obligación #36 por Gs. 850.000 (Matrícula Matricula general 2026-2)', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_alumno\":7,\"monto\":850000,\"recargo\":0}', 'info', '2026-10-13 12:25:54'),
(101, 11, 'matriculas', 'matricula_solicitada', 'Matrícula MAT-2026-0006 solicitada', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_matricula\":10,\"id_obligacion\":36,\"materias\":5,\"recargo\":0}', 'info', '2026-10-13 12:25:54'),
(102, 11, 'pagos', 'obligacion_creada', 'Obligación #37 por Gs. 850.000 (Matrícula Matricula general 2026-2)', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_alumno\":7,\"monto\":850000,\"recargo\":0}', 'info', '2026-10-13 12:25:54'),
(103, 11, 'matriculas', 'matricula_solicitada', 'Matrícula MAT-2026-0006 solicitada', 'POST', '/SistemaUnvesGestion/matriculas/solicitar', '::1', '', '{\"id_matricula\":11,\"id_obligacion\":37,\"materias\":5,\"recargo\":0}', 'info', '2026-10-13 12:25:54'),
(104, NULL, 'pagos', 'obligacion_creada', 'Obligación #38 por Gs. 150.000 (Prueba de checkout con tarjeta)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:35:04'),
(105, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:35:04'),
(106, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 202.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":22,\"obligaciones\":[22]}', 'info', '2026-10-13 12:35:04'),
(107, 9, 'seguridad', 'tarjeta_rechazada_local', 'Datos de tarjeta inválidos en el pago #22', 'POST', '/SistemaUnvesGestion/pagos/pasarela/22/confirmar', '::1', '', NULL, 'seguridad', '2026-10-13 12:35:04'),
(108, 9, 'pagos', 'pago_rechazado', 'Pago #22 rechazado. Simula un rechazo del emisor por fondos insuficientes.', 'POST', '/SistemaUnvesGestion/pagos/pasarela/22/confirmar', '::1', '', NULL, 'warning', '2026-10-13 12:35:04'),
(109, NULL, 'pagos', 'obligacion_creada', 'Obligación #39 por Gs. 150.000 (Prueba de checkout con tarjeta)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:36:13'),
(110, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:36:13'),
(111, 9, NULL, 'checkout_fallido', 'El carrito está vacío.', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', NULL, 'error', '2026-10-13 12:36:13'),
(112, NULL, 'pagos', 'obligacion_creada', 'Obligación #40 por Gs. 150.000 (Prueba de checkout con tarjeta)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:37:06'),
(113, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:37:06'),
(114, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":23,\"obligaciones\":[40]}', 'info', '2026-10-13 12:37:07'),
(115, 9, 'seguridad', 'tarjeta_rechazada_local', 'Datos de tarjeta inválidos en el pago #23', 'POST', '/SistemaUnvesGestion/pagos/pasarela/23/confirmar', '::1', '', NULL, 'seguridad', '2026-10-13 12:37:07'),
(116, 9, 'pagos', 'pago_rechazado', 'Pago #23 rechazado. Simula un rechazo del emisor por fondos insuficientes.', 'POST', '/SistemaUnvesGestion/pagos/pasarela/23/confirmar', '::1', '', NULL, 'warning', '2026-10-13 12:37:07'),
(117, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":24,\"obligaciones\":[40]}', 'info', '2026-10-13 12:37:07'),
(118, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000016 emitida para el pago #24', 'POST', '/SistemaUnvesGestion/pagos/pasarela/24/confirmar', '::1', '', NULL, 'info', '2026-10-13 12:37:07'),
(119, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 150.000 (comprobante REC-2026-000020)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/24/confirmar', '::1', '', '{\"id_pago\":24,\"comprobante\":\"REC-2026-000020\"}', 'info', '2026-10-13 12:37:07'),
(120, NULL, 'pagos', 'obligacion_creada', 'Obligación #41 por Gs. 75.000 (Prueba de transferencia)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":75000,\"recargo\":0}', 'info', '2026-10-13 12:37:07'),
(121, NULL, 'pagos', 'obligacion_creada', 'Obligación #42 por Gs. 60.000 (Prueba de billetera)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":60000,\"recargo\":0}', 'info', '2026-10-13 12:37:07'),
(122, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 135.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":25,\"obligaciones\":[41,42]}', 'info', '2026-10-13 12:37:07'),
(123, NULL, 'pagos', 'obligacion_creada', 'Obligación #43 por Gs. 150.000 (Prueba de checkout con tarjeta)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:37:45'),
(124, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:37:45'),
(125, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":26,\"obligaciones\":[43]}', 'info', '2026-10-13 12:37:45'),
(126, 9, 'seguridad', 'tarjeta_rechazada_local', 'Datos de tarjeta inválidos en el pago #26', 'POST', '/SistemaUnvesGestion/pagos/pasarela/26/confirmar', '::1', '', NULL, 'seguridad', '2026-10-13 12:37:45'),
(127, 9, 'pagos', 'pago_rechazado', 'Pago #26 rechazado. Simula un rechazo del emisor por fondos insuficientes.', 'POST', '/SistemaUnvesGestion/pagos/pasarela/26/confirmar', '::1', '', NULL, 'warning', '2026-10-13 12:37:46'),
(128, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":27,\"obligaciones\":[43]}', 'info', '2026-10-13 12:37:46'),
(129, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000017 emitida para el pago #27', 'POST', '/SistemaUnvesGestion/pagos/pasarela/27/confirmar', '::1', '', NULL, 'info', '2026-10-13 12:37:46'),
(130, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 150.000 (comprobante REC-2026-000020)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/27/confirmar', '::1', '', '{\"id_pago\":27,\"comprobante\":\"REC-2026-000020\"}', 'info', '2026-10-13 12:37:46'),
(131, NULL, 'pagos', 'obligacion_creada', 'Obligación #44 por Gs. 75.000 (Prueba de transferencia)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":75000,\"recargo\":0}', 'info', '2026-10-13 12:37:46'),
(132, NULL, 'pagos', 'obligacion_creada', 'Obligación #45 por Gs. 60.000 (Prueba de billetera)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":60000,\"recargo\":0}', 'info', '2026-10-13 12:37:46'),
(133, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 135.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":28,\"obligaciones\":[44,45]}', 'info', '2026-10-13 12:37:46'),
(134, NULL, 'pagos', 'obligacion_creada', 'Obligación #46 por Gs. 150.000 (Prueba de checkout con tarjeta)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:37:59'),
(135, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:37:59'),
(136, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":29,\"obligaciones\":[46]}', 'info', '2026-10-13 12:37:59'),
(137, 9, 'seguridad', 'tarjeta_rechazada_local', 'Datos de tarjeta inválidos en el pago #29', 'POST', '/SistemaUnvesGestion/pagos/pasarela/29/confirmar', '::1', '', NULL, 'seguridad', '2026-10-13 12:37:59'),
(138, 9, 'pagos', 'pago_rechazado', 'Pago #29 rechazado. Simula un rechazo del emisor por fondos insuficientes.', 'POST', '/SistemaUnvesGestion/pagos/pasarela/29/confirmar', '::1', '', NULL, 'warning', '2026-10-13 12:37:59'),
(139, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 150.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":30,\"obligaciones\":[46]}', 'info', '2026-10-13 12:37:59'),
(140, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000018 emitida para el pago #30', 'POST', '/SistemaUnvesGestion/pagos/pasarela/30/confirmar', '::1', '', NULL, 'info', '2026-10-13 12:38:00'),
(141, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 150.000 (comprobante REC-2026-000020)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/30/confirmar', '::1', '', '{\"id_pago\":30,\"comprobante\":\"REC-2026-000020\"}', 'info', '2026-10-13 12:38:00'),
(142, NULL, 'pagos', 'obligacion_creada', 'Obligación #47 por Gs. 75.000 (Prueba de transferencia)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":75000,\"recargo\":0}', 'info', '2026-10-13 12:38:00'),
(143, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 75.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":31,\"obligaciones\":[47]}', 'info', '2026-10-13 12:38:00'),
(144, NULL, 'pagos', 'obligacion_creada', 'Obligación #48 por Gs. 60.000 (Prueba de billetera)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":60000,\"recargo\":0}', 'info', '2026-10-13 12:38:00'),
(145, 9, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 60.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":32,\"obligaciones\":[48]}', 'info', '2026-10-13 12:38:00'),
(146, NULL, 'pagos', 'obligacion_creada', 'Obligación #49 por Gs. 504.000 (Arancel Noviembre 2026)', 'CLI', 'cli', '0.0.0.0', '', '{\"id_alumno\":5,\"monto\":504000,\"recargo\":0}', 'info', '2026-10-13 12:38:26'),
(147, NULL, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 504.000', 'CLI', 'cli', '0.0.0.0', '', '{\"id_pago\":33,\"obligaciones\":[49]}', 'info', '2026-10-13 12:38:26'),
(148, 1, 'seguridad', 'cierre_sesion', 'Salida del sistema', 'GET', '/SistemaUnvesGestion/logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', NULL, 'info', '2026-10-13 12:38:33'),
(149, 9, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', NULL, 'info', '2026-10-13 12:38:34'),
(150, 9, 'facturacion', 'factura_emitida', 'Factura 001-001-0000019 emitida para el pago #33', 'POST', '/SistemaUnvesGestion/pagos/pasarela/33/confirmar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', NULL, 'info', '2026-10-13 12:40:22'),
(151, 9, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 504.000 (comprobante REC-2026-000020)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/33/confirmar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', '{\"id_pago\":33,\"comprobante\":\"REC-2026-000020\"}', 'info', '2026-10-13 12:40:22'),
(152, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:42:56'),
(153, 1, 'alumnos', 'alumnos_exportados', '5 alumnos exportados a CSV', 'GET', '/SistemaUnvesGestion/alumnos/exportar', '::1', '', NULL, 'info', '2026-10-13 12:42:57'),
(154, 1, 'seguridad', 'cierre_sesion', 'Salida del sistema', 'POST', '/SistemaUnvesGestion/logout', '::1', '', NULL, 'info', '2026-10-13 12:42:58'),
(155, 3, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:44:37'),
(156, 3, 'pagos', 'obligacion_creada', 'Obligación #50 por Gs. 150.000 (Final - Base de Datos II)', 'POST', '/SistemaUnvesGestion/examenes/inscribir', '::1', '', '{\"id_alumno\":2,\"monto\":150000,\"recargo\":0}', 'info', '2026-10-13 12:44:37'),
(157, 3, 'examenes', 'inscripcion_examen', 'Inscripción al examen #2', 'POST', '/SistemaUnvesGestion/examenes/inscribir', '::1', '', '{\"id_inscripcion\":5,\"id_obligacion\":50,\"recargo\":0}', 'info', '2026-10-13 12:44:37'),
(158, 3, 'pagos', 'obligacion_creada', 'Obligación #51 por Gs. 120.000 (Certificado de calificaciones)', 'POST', '/SistemaUnvesGestion/tramites/solicitar', '::1', '', '{\"id_alumno\":2,\"monto\":120000,\"recargo\":0}', 'info', '2026-10-13 12:44:37'),
(159, 3, 'tramites', 'tramite_solicitado', 'Trámite TRA-20261013-0006 solicitado', 'POST', '/SistemaUnvesGestion/tramites/solicitar', '::1', '', '{\"id_solicitud\":8}', 'info', '2026-10-13 12:44:37'),
(160, 3, 'pagos', 'pago_iniciado', 'Intención de pago creada por Gs. 270.000', 'POST', '/SistemaUnvesGestion/pagos/checkout', '::1', '', '{\"id_pago\":34,\"obligaciones\":[50,51]}', 'info', '2026-10-13 12:44:37'),
(161, 3, 'facturacion', 'factura_emitida', 'Factura 001-001-0000020 emitida para el pago #34', 'POST', '/SistemaUnvesGestion/pagos/pasarela/34/confirmar', '::1', '', NULL, 'info', '2026-10-13 12:44:37'),
(162, 3, 'pagos', 'pago_aprobado', 'Pago aprobado por Gs. 270.000 (comprobante REC-2026-000020)', 'POST', '/SistemaUnvesGestion/pagos/pasarela/34/confirmar', '::1', '', '{\"id_pago\":34,\"comprobante\":\"REC-2026-000020\"}', 'info', '2026-10-13 12:44:37'),
(163, 1, 'seguridad', 'inicio_sesion', 'Ingreso al sistema', 'POST', '/SistemaUnvesGestion/login', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(164, 1, 'alumnos', 'alumno_creado', 'Alta de alumno 2026-INFO-001 (ID 8)', 'POST', '/SistemaUnvesGestion/alumnos/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(165, 1, 'academico', 'sede_creada', 'Se creó la sede Sede ZZ174508.', 'POST', '/SistemaUnvesGestion/academico/sedes/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(166, 1, 'academico', 'facultad_creada', 'Se creó la facultad Facultad ZZ174508.', 'POST', '/SistemaUnvesGestion/academico/facultades/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(167, 1, 'academico', 'carrera_creada', 'Se creó la carrera Carrera ZZ174508.', 'POST', '/SistemaUnvesGestion/academico/carreras/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(168, 1, 'academico', 'periodo_creado', 'Se creó el periodo Periodo ZZ174508.', 'POST', '/SistemaUnvesGestion/academico/periodos/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(169, 1, 'aranceles', 'concepto_creado', 'Se creó el concepto de pago Concepto ZZ174508 (508Z).', 'POST', '/SistemaUnvesGestion/aranceles/conceptos/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(170, 1, 'aranceles', 'arancel_creado', 'Se creó el arancel Arancel ZZ174508 por Gs. 150.000.', 'POST', '/SistemaUnvesGestion/aranceles/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(171, 1, 'becas', 'beca_creada', 'Se creó la beca Beca ZZ174508.', 'POST', '/SistemaUnvesGestion/becas/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:08'),
(172, 1, 'usuarios', 'usuario_creado', 'Alta de usuario prb174508 (ID 12)', 'POST', '/SistemaUnvesGestion/usuarios/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(173, 1, 'tramites', 'tipo_tramite_creado', 'Tipo de trámite #8 creado', 'POST', '/SistemaUnvesGestion/tramites/admin/tipos/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(174, 1, 'examenes', 'examen_creado', 'Examen #8 creado: Examen ZZ174508', 'POST', '/SistemaUnvesGestion/examenes/admin/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(175, 1, 'facturacion', 'factura_emitida', 'Factura 001-001-0000021 emitida para el pago #6', 'POST', '/SistemaUnvesGestion/facturacion/emitir', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(176, 1, 'facturacion', 'factura_emitida_manual', 'Factura #20 emitida desde el módulo de facturación para el pago #6', 'POST', '/SistemaUnvesGestion/facturacion/emitir', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(177, 1, 'facturacion', 'timbrado_creado', 'Timbrado T174508 registrado', 'POST', '/SistemaUnvesGestion/facturacion/timbrados/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(178, 1, 'configuracion', 'configuracion_actualizada', 'Se actualizaron 4 parámetro(s) de configuración', 'POST', '/SistemaUnvesGestion/configuracion/guardar', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(179, 1, 'api', 'prueba_api', 'Prueba de conexión con el sistema central: FALLÓ — La API del sistema central no está configurada.', 'GET', '/SistemaUnvesGestion/integracion/probando', '::1', '', NULL, 'error', '2026-10-13 12:45:09'),
(180, 1, 'contacto', 'mensaje_contacto', 'Nueva consulta web de Visitante Prueba (visitante174508@test.local): Consulta ZZ174508', 'POST', '/SistemaUnvesGestion/contacto', '::1', '', NULL, 'info', '2026-10-13 12:45:09'),
(181, 9, 'seguridad', 'cierre_sesion', 'Salida del sistema', 'GET', '/SistemaUnvesGestion/logout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', NULL, 'info', '2026-10-13 12:51:38');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mallas_curriculares`
--

CREATE TABLE `mallas_curriculares` (
  `id_malla` int(11) NOT NULL,
  `id_carrera` int(11) NOT NULL,
  `nombre` varchar(145) NOT NULL COMMENT 'Ej.: Plan 2015 - Ingenieria en Informatica',
  `anio_vigencia` int(11) DEFAULT NULL,
  `resolucion` varchar(95) DEFAULT NULL COMMENT 'Resolucion del Consejo Superior Universitario',
  `total_cursos` int(11) NOT NULL DEFAULT 5 COMMENT 'Anios de la carrera',
  `total_semestres` int(11) NOT NULL DEFAULT 2 COMMENT 'Semestres por curso',
  `carga_horaria` int(11) NOT NULL DEFAULT 0 COMMENT 'Horas reloj totales',
  `vigente` tinyint(1) NOT NULL DEFAULT 1,
  `observaciones` text DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'Activo',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mallas_curriculares`
--

INSERT INTO `mallas_curriculares` (`id_malla`, `id_carrera`, `nombre`, `anio_vigencia`, `resolucion`, `total_cursos`, `total_semestres`, `carga_horaria`, `vigente`, `observaciones`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 1, 'Plan de estudios vigente - Licenciatura en Administración de Empresa', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(2, 2, 'Plan de estudios vigente - Licenciatura en Ciencias Contables y Auditoría', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(3, 3, 'Plan de estudios vigente - Licenciatura en Ciencias de la Educación', 2015, NULL, 4, 2, 5040, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(4, 4, 'Plan 2015 - Ingeniería en Informática', 2015, NULL, 6, 2, 5040, 1, 'Malla cargada desde la información pública de la UNVES.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(5, 5, 'Plan 2015 - Ingeniería Eléctrica', 2015, NULL, 5, 2, 5274, 1, 'Malla cargada desde la información pública de la UNVES.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(6, 6, 'Plan de estudios vigente - Ingeniería Ambiental', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(7, 7, 'Plan de estudios vigente - Arquitectura', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(8, 8, 'Plan de estudios vigente - Licenciatura en Ciencias de la Comunicación', 2015, NULL, 4, 2, 5040, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(9, 9, 'Plan de estudios vigente - Licenciatura en Gestión Educativa', 2015, NULL, 4, 2, 5040, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(10, 10, 'Plan de estudios vigente - Licenciatura en Inglés', 2015, NULL, 4, 2, 5040, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(11, 11, 'Plan de estudios vigente - Derecho', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(12, 12, 'Plan de estudios vigente - Ingeniería Química', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(13, 13, 'Plan de estudios vigente - Licenciatura en Psicología', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(14, 14, 'Plan de estudios vigente - Licenciatura en Nutrición', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(15, 15, 'Plan de estudios vigente - Licenciatura en Enfermería', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(16, 16, 'Plan de estudios vigente - Ingeniería en Agroindustria', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(17, 17, 'Plan de estudios vigente - Ingeniería en Zootecnia', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(18, 18, 'Plan de estudios vigente - Licenciatura en Gestión Pública', 2015, NULL, 4, 2, 5040, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(19, 19, 'Plan de estudios vigente - Licenciatura en Gastronomía, Hotelería y Turismo', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(20, 20, 'Plan de estudios vigente - Ingeniería en Producción Agropecuaria y Desarrollo Rural', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(21, 21, 'Plan de estudios vigente - Licenciatura en Música', 2015, NULL, 4, 2, 5040, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(22, 22, 'Plan de estudios vigente - Licenciatura en Hotelería y Turismo', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(23, 23, 'Plan de estudios vigente - Licenciatura en Gastronomía', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(24, 24, 'Plan de estudios vigente - Especialización en Didáctica Superior Universitaria', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28'),
(25, 25, 'Plan de estudios vigente - Maestría en Didáctica Superior Universitaria', 2015, NULL, 5, 2, 0, 1, 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.', 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materias`
--

CREATE TABLE `materias` (
  `id_materia` int(11) NOT NULL,
  `id_malla` int(11) NOT NULL,
  `id_carrera` int(11) NOT NULL COMMENT 'Redundante a proposito: permite listar sin unir la malla',
  `codigo` varchar(20) NOT NULL,
  `nombre` varchar(145) NOT NULL,
  `curso` int(11) NOT NULL DEFAULT 1 COMMENT 'Anio de la carrera: 1 a N',
  `semestre` int(11) NOT NULL DEFAULT 1 COMMENT 'Semestre dentro del curso: 1 o 2',
  `semestre_global` int(11) NOT NULL DEFAULT 1 COMMENT 'Semestre corrido: curso*2-1 / curso*2',
  `horas_catedra` int(11) NOT NULL DEFAULT 0,
  `creditos` decimal(5,2) NOT NULL DEFAULT 0.00,
  `tipo` varchar(20) NOT NULL DEFAULT 'Obligatoria' COMMENT 'Obligatoria, Electiva, Optativa',
  `prerequisito` varchar(145) DEFAULT NULL,
  `orden` int(11) NOT NULL DEFAULT 0,
  `estado` varchar(20) NOT NULL DEFAULT 'Activo',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `materias`
--

INSERT INTO `materias` (`id_materia`, `id_malla`, `id_carrera`, `codigo`, `nombre`, `curso`, `semestre`, `semestre_global`, `horas_catedra`, `creditos`, `tipo`, `prerequisito`, `orden`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 4, 4, 'ISI01', 'Matemática I', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 1, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(2, 4, 4, 'ISI02', 'Computación I', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 2, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(3, 4, 4, 'ISI03', 'Informática I', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 3, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(4, 4, 4, 'ISI04', 'Algoritmia I', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 4, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(5, 4, 4, 'ISI05', 'Inglés', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 5, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(6, 4, 4, 'ISI06', 'Matemática II', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 6, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(7, 4, 4, 'ISI07', 'Computación II', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 7, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(8, 4, 4, 'ISI08', 'Informática II', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 8, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(9, 4, 4, 'ISI09', 'Algoritmia II', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 9, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(10, 4, 4, 'ISI10', 'Programación I', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 10, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(11, 4, 4, 'ISI11', 'Matemática III', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 11, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(12, 4, 4, 'ISI12', 'Computación III', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 12, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(13, 4, 4, 'ISI13', 'Programación II', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 13, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(14, 4, 4, 'ISI14', 'Lenguaje I', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 14, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(15, 4, 4, 'ISI15', 'Física I', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 15, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(16, 4, 4, 'ISI16', 'Matemática IV', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 16, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(17, 4, 4, 'ISI17', 'Computación IV', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 17, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(18, 4, 4, 'ISI18', 'Programación III', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 18, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(19, 4, 4, 'ISI19', 'Lenguajes II', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 19, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(20, 4, 4, 'ISI20', 'Física II', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 20, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(21, 4, 4, 'ISI21', 'Matemática V', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 21, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(22, 4, 4, 'ISI22', 'Programación IV', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 22, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(23, 4, 4, 'ISI23', 'Análisis y Diseño de Sistemas', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 23, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(24, 4, 4, 'ISI24', 'Lenguajes III', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 24, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(25, 4, 4, 'ISI25', 'Administración I', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 25, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(26, 4, 4, 'ISI26', 'Matemática VI', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 26, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(27, 4, 4, 'ISI27', 'Programación V', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 27, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(28, 4, 4, 'ISI28', 'Redes I', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 28, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(29, 4, 4, 'ISI29', 'Estadística y Probabilidades', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 29, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(30, 4, 4, 'ISI30', 'Metodología de la Investigación I', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 30, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(31, 4, 4, 'ISI31', 'Computación V', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 31, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(32, 4, 4, 'ISI32', 'Informática III', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 32, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(33, 4, 4, 'ISI33', 'Investigación Operativa I', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 33, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(34, 4, 4, 'ISI34', 'Metodología de la Investigación II', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 34, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(35, 4, 4, 'ISI35', 'Proyecto I', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 35, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(36, 4, 4, 'ISI36', 'Computación VI', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 36, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(37, 4, 4, 'ISI37', 'Informática IV', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 37, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(38, 4, 4, 'ISI38', 'Investigación Operativa II', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 38, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(39, 4, 4, 'ISI39', 'Electrónica Digital I', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 39, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(40, 4, 4, 'ISI40', 'Proyecto II', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 40, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(41, 4, 4, 'ISI41', 'Redes II', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 41, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(42, 4, 4, 'ISI42', 'Administración II', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 42, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(43, 4, 4, 'ISI43', 'Ingeniería de Software I', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 43, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(44, 4, 4, 'ISI44', 'Electrónica Digital II', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 44, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(45, 4, 4, 'ISI45', 'Adm. de Sistemas de Información', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 45, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(46, 4, 4, 'ISI46', 'Sistemas Distribuidos', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 46, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(47, 4, 4, 'ISI47', 'Simulación de Sistemas de Control', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 47, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(48, 4, 4, 'ISI48', 'Ingeniería de Software II', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 48, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(49, 4, 4, 'ISI49', 'Modelos y Sistemas de Optimización', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 49, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(50, 4, 4, 'ISI50', 'Informática V', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 50, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(51, 4, 4, 'ISI51', 'Cibernética', 6, 1, 11, 90, 3.00, 'Obligatoria', NULL, 51, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(52, 4, 4, 'ISI52', 'Informática VI', 6, 1, 11, 90, 3.00, 'Obligatoria', NULL, 52, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(53, 4, 4, 'ISI53', 'Inteligencia Artificial', 6, 1, 11, 90, 3.00, 'Obligatoria', NULL, 53, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:16:48'),
(54, 4, 4, 'ISI56', 'Auditoria Informática', 6, 2, 12, 90, 3.00, 'Obligatoria', NULL, 54, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(55, 4, 4, 'ISI57', 'Foros Informáticos', 6, 2, 12, 90, 3.00, 'Obligatoria', NULL, 55, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(56, 4, 4, 'ISI58', 'Trabajo de Tesis II', 6, 2, 12, 90, 3.00, 'Obligatoria', NULL, 56, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(57, 5, 5, 'IE01', 'Algebra Lineal y Vectorial', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 1, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(58, 5, 5, 'IE02', 'Geometría Analítica', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 2, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(59, 5, 5, 'IE03', 'Calculo I', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 3, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(60, 5, 5, 'IE04', 'Idioma', 1, 1, 1, 72, 2.40, 'Obligatoria', NULL, 4, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(61, 5, 5, 'IE05', 'Química', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 5, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(62, 5, 5, 'IE06', 'Dibujo Técnico', 1, 1, 1, 90, 3.00, 'Obligatoria', NULL, 6, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(63, 5, 5, 'IE07', 'Calculo II', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 7, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(64, 5, 5, 'IE08', 'Física I', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 8, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(65, 5, 5, 'IE09', 'Física II', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 9, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(66, 5, 5, 'IE10', 'Informática Avanzada Para Ingeniería', 1, 2, 2, 72, 2.40, 'Obligatoria', NULL, 10, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(67, 5, 5, 'IE11', 'Seguridad en Ingeniería Eléctrica', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 11, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(68, 5, 5, 'IE12', 'Electrotecnia I', 1, 2, 2, 90, 3.00, 'Obligatoria', NULL, 12, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(69, 5, 5, 'IE13', 'Calculo III', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 13, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(70, 5, 5, 'IE14', 'Física III', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 14, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(71, 5, 5, 'IE15', 'Estadística', 2, 1, 3, 72, 2.40, 'Obligatoria', NULL, 15, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(72, 5, 5, 'IE16', 'Circuitos Eléctricos I', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 16, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(73, 5, 5, 'IE17', 'Resistencia de Materiales', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 17, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(74, 5, 5, 'IE18', 'Electrotecnia II', 2, 1, 3, 90, 3.00, 'Obligatoria', NULL, 18, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(75, 5, 5, 'IE19', 'Calculo IV', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 19, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(76, 5, 5, 'IE20', 'Física IV', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 20, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(77, 5, 5, 'IE21', 'Física V', 2, 2, 4, 72, 2.40, 'Obligatoria', NULL, 21, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(78, 5, 5, 'IE22', 'Circuitos Eléctricos II', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 22, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(79, 5, 5, 'IE23', 'Reglamentos de B.T. y M.T.', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 23, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(80, 5, 5, 'IE24', 'Electrónica I', 2, 2, 4, 90, 3.00, 'Obligatoria', NULL, 24, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(81, 5, 5, 'IE25', 'Calculo V', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 25, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(82, 5, 5, 'IE26', 'Física VI', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 26, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(83, 5, 5, 'IE27', 'Electrónica II', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 27, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(84, 5, 5, 'IE28', 'Medidas Eléctricas y Magnéticas', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 28, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(85, 5, 5, 'IE29', 'Instalación Eléctrica I', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 29, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(86, 5, 5, 'IE30', 'Conversión de la Energía I', 3, 1, 5, 90, 3.00, 'Obligatoria', NULL, 30, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(87, 5, 5, 'IE31', 'Calculo VI', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 31, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(88, 5, 5, 'IE32', 'Física VII', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 32, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(89, 5, 5, 'IE33', 'Instrumentación Industrial', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 33, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(90, 5, 5, 'IE34', 'Instalación Eléctrica II Industrial', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 34, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(91, 5, 5, 'IE35', 'Automatización y Control Industrial', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 35, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(92, 5, 5, 'IE36', 'Electrónica Digital', 3, 2, 6, 90, 3.00, 'Obligatoria', NULL, 36, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(93, 5, 5, 'IE37', 'Física VIII', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 37, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(94, 5, 5, 'IE38', 'Conversión de la Energía II Conversión de la Energía Eléctrica II', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 38, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(95, 5, 5, 'IE39', 'Electrónica de Potencia I', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 39, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(96, 5, 5, 'IE40', 'Medición de la Energía Eléctrica', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 40, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(97, 5, 5, 'IE41', 'Instalación Eléctrica III M.T.', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 41, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(98, 5, 5, 'IE42', 'Sistemas Neumáticos Industriales', 4, 1, 7, 90, 3.00, 'Obligatoria', NULL, 42, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(99, 5, 5, 'IE43', 'Metodología de la Investigación I', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 43, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(100, 5, 5, 'IE44', 'Sistemas de Potencia I', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 44, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(101, 5, 5, 'IE45', 'Mantenimientos Industriales', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 45, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(102, 5, 5, 'IE46', 'Electrónica de Potencia II', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 46, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(103, 5, 5, 'IE47', 'Distribución de la Energía Eléctrica', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 47, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(104, 5, 5, 'IE48', 'Planean. y Control de la Calidad de Producción', 4, 2, 8, 90, 3.00, 'Obligatoria', NULL, 48, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(105, 5, 5, 'IE49', 'Generación de Energía Eléctrica', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 49, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(106, 5, 5, 'IE50', 'Redes Eléctricas', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 50, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(107, 5, 5, 'IE51', 'Sistemas de Potencia II', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 51, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(108, 5, 5, 'IE52', 'Administración y Organización de Empresa', 5, 1, 9, 72, 2.40, 'Obligatoria', NULL, 52, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(109, 5, 5, 'IE53', 'Metodología de la Investigación II', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 53, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(110, 5, 5, 'IE54', 'Subestaciones Transformadoras', 5, 1, 9, 90, 3.00, 'Obligatoria', NULL, 54, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38'),
(111, 5, 5, 'IE55', 'Factibilidad de Sistemas Eléctricos', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 55, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(112, 5, 5, 'IE56', 'Protección de Sistemas Eléctricos', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 56, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(113, 5, 5, 'IE57', 'Ética Profesional', 5, 2, 10, 72, 2.40, 'Obligatoria', NULL, 57, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(114, 5, 5, 'IE58', 'Operación de Energía Eléctrica', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 58, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(115, 5, 5, 'IE59', 'Administración de Recursos Humanos', 5, 2, 10, 72, 2.40, 'Obligatoria', NULL, 59, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(116, 5, 5, 'IE60', 'Proyecto de Grado I', 5, 2, 10, 90, 3.00, 'Obligatoria', NULL, 60, 'Activo', '2026-10-13 12:06:38', '2026-10-13 12:06:38');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `matriculas`
--

CREATE TABLE `matriculas` (
  `id_matricula` int(11) NOT NULL,
  `numero_matricula` varchar(45) NOT NULL,
  `id_alumno` int(11) NOT NULL,
  `id_periodo` int(11) NOT NULL,
  `id_carrera` int(11) DEFAULT NULL,
  `id_facultades` int(11) DEFAULT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `id_malla` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `semestre` int(11) DEFAULT NULL,
  `curso` int(11) DEFAULT NULL,
  `turno` varchar(45) DEFAULT NULL,
  `modalidad` varchar(45) DEFAULT 'Presencial',
  `id_obligacion` int(11) DEFAULT NULL COMMENT 'Obligacion de pago generada por la matricula',
  `id_pago` int(11) DEFAULT NULL,
  `monto_matricula` decimal(12,2) DEFAULT 0.00,
  `total_materias` int(11) NOT NULL DEFAULT 0,
  `total_creditos` decimal(6,2) NOT NULL DEFAULT 0.00,
  `fecha_solicitud` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_confirmacion` datetime DEFAULT NULL,
  `estado` varchar(45) NOT NULL DEFAULT 'Pendiente' COMMENT 'Pendiente, En proceso, Confirmada, Rechazada, Anulada',
  `documentacion_ok` tinyint(1) NOT NULL DEFAULT 0,
  `observaciones` text DEFAULT NULL,
  `id_usuario_gestion` int(11) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `matriculas`
--

INSERT INTO `matriculas` (`id_matricula`, `numero_matricula`, `id_alumno`, `id_periodo`, `id_carrera`, `id_facultades`, `id_sede`, `id_malla`, `id_curso`, `semestre`, `curso`, `turno`, `modalidad`, `id_obligacion`, `id_pago`, `monto_matricula`, `total_materias`, `total_creditos`, `fecha_solicitud`, `fecha_confirmacion`, `estado`, `documentacion_ok`, `observaciones`, `id_usuario_gestion`, `creado_en`, `actualizado_en`) VALUES
(1, 'MAT-2026-2-0001', 1, 3, 4, 6, 1, NULL, NULL, 8, NULL, 'Noche', 'Presencial', NULL, NULL, 850000.00, 0, 0.00, '2026-07-21 09:15:00', '2026-07-22 10:00:00', 'Confirmada', 1, NULL, NULL, '2026-10-13 10:32:58', '2026-10-13 12:06:38'),
(2, 'MAT-2026-2-0002', 2, 3, 2, 1, 1, NULL, NULL, 10, NULL, 'Noche', 'Presencial', NULL, NULL, 850000.00, 0, 0.00, '2026-07-22 14:30:00', '2026-07-23 08:45:00', 'Confirmada', 1, NULL, NULL, '2026-10-13 10:32:58', '2026-10-13 11:02:34'),
(3, 'MAT-2026-2-0003', 3, 3, 4, 6, 1, NULL, NULL, 6, NULL, 'Tarde', 'Presencial', NULL, NULL, 850000.00, 0, 0.00, '2026-08-03 11:05:00', NULL, 'Pendiente', 0, NULL, NULL, '2026-10-13 10:32:58', '2026-10-13 12:06:38'),
(4, 'MAT-2026-2-0004', 4, 3, 1, 1, 1, NULL, NULL, 3, NULL, 'Noche', 'Presencial', NULL, NULL, 850000.00, 0, 0.00, '2026-08-10 16:40:00', NULL, 'Pendiente', 0, NULL, NULL, '2026-10-13 10:32:58', '2026-10-13 11:03:08'),
(5, 'MAT-2025-2-0070', 5, 1, 4, 6, 1, NULL, NULL, 4, NULL, 'Noche', 'Presencial', NULL, NULL, 780000.00, 0, 0.00, '2025-07-16 09:40:00', '2025-07-18 10:15:00', 'Confirmada', 1, NULL, NULL, '2025-07-16 09:40:00', '2026-10-13 12:06:38'),
(6, 'MAT-2026-1-0070', 5, 2, 4, 6, 1, NULL, NULL, 5, NULL, 'Noche', 'Presencial', NULL, NULL, 820000.00, 0, 0.00, '2026-01-26 14:10:00', '2026-01-28 09:30:00', 'Confirmada', 1, NULL, NULL, '2026-01-26 14:10:00', '2026-10-13 12:06:38'),
(7, 'MAT-2026-0005', 5, 3, 4, 6, 1, NULL, NULL, 6, NULL, 'Noche', 'Presencial', 14, 11, 595000.00, 0, 0.00, '2026-10-13 11:51:01', '2026-10-13 11:51:01', 'Confirmada', 1, 'Solicitud en linea desde el portal de pagos.', NULL, '2026-10-13 11:51:01', '2026-10-13 12:06:38');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `matricula_materias`
--

CREATE TABLE `matricula_materias` (
  `id_matricula_materia` int(11) NOT NULL,
  `id_matricula` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `codigo` varchar(20) DEFAULT NULL,
  `nombre` varchar(145) DEFAULT NULL COMMENT 'Copia historica: la malla puede cambiar',
  `curso` int(11) NOT NULL DEFAULT 1,
  `semestre` int(11) NOT NULL DEFAULT 1,
  `horas` int(11) NOT NULL DEFAULT 0,
  `creditos` decimal(5,2) NOT NULL DEFAULT 0.00,
  `condicion` varchar(20) NOT NULL DEFAULT 'Regular' COMMENT 'Regular, Libre, Recursante',
  `estado` varchar(20) NOT NULL DEFAULT 'Inscripto' COMMENT 'Inscripto, Aprobada, Reprobada, Retirada',
  `nota` decimal(5,2) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes_contacto`
--

CREATE TABLE `mensajes_contacto` (
  `id_mensaje` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `nombre` varchar(145) NOT NULL,
  `email` varchar(145) DEFAULT NULL,
  `telefono` varchar(45) DEFAULT NULL,
  `asunto` varchar(145) DEFAULT NULL,
  `mensaje` text NOT NULL,
  `canal` varchar(45) NOT NULL DEFAULT 'web' COMMENT 'web, whatsapp, email, presencial',
  `estado` varchar(45) NOT NULL DEFAULT 'Nuevo' COMMENT 'Nuevo, En revision, Respondido, Cerrado',
  `respuesta` text DEFAULT NULL,
  `id_usuario_gestor` int(11) DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_respuesta` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mensajes_contacto`
--

INSERT INTO `mensajes_contacto` (`id_mensaje`, `id_usuario`, `nombre`, `email`, `telefono`, `asunto`, `mensaje`, `canal`, `estado`, `respuesta`, `id_usuario_gestor`, `fecha_creacion`, `fecha_respuesta`) VALUES
(1, 9, 'Lucia Fernanda Villalba Rios', 'lucia.villalba@unves.edu.py', '+595 991 234 567', 'Consulta sobre el arancel de laboratorio', 'Buenas tardes, queria saber si el arancel de laboratorio se puede pagar en cuotas.', 'whatsapp', 'Respondido', 'El arancel de laboratorio se puede abonar en hasta 2 cuotas en la ventanilla de caja. Ya cargamos el plan en tu cuenta.', 6, '2026-10-09 11:51:01', '2026-10-10 11:51:01'),
(2, 1, 'Visitante Prueba', 'visitante174508@test.local', NULL, 'Consulta ZZ174508', 'Mensaje generado por la prueba automatica.', 'web', 'Nuevo', NULL, NULL, '2026-10-13 12:45:09', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodos_pago`
--

CREATE TABLE `metodos_pago` (
  `id_metodo_pago` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `metodos_pago`
--

INSERT INTO `metodos_pago` (`id_metodo_pago`, `nombre`, `tipo`, `estado`) VALUES
(1, 'Efectivo', 'Contado', 'Activo'),
(2, 'Transferencia bancaria', 'Transferencia', 'Activo'),
(3, 'Tarjeta de credito', 'Credito', 'Activo'),
(4, 'Tarjeta de debito', 'Debito', 'Activo'),
(5, 'Tigo Money', 'Billetera electronica', 'Activo'),
(6, 'Personal Pay', 'Billetera electronica', 'Activo'),
(7, 'Pago QR / Web', 'Online', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id_notificacion` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `titulo` varchar(145) NOT NULL,
  `mensaje` text NOT NULL,
  `tipo` varchar(45) NOT NULL DEFAULT 'info' COMMENT 'info, exito, advertencia, error, pago',
  `url` varchar(255) DEFAULT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_lectura` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `notificaciones`
--

INSERT INTO `notificaciones` (`id_notificacion`, `id_usuario`, `titulo`, `mensaje`, `tipo`, `url`, `leida`, `fecha_creacion`, `fecha_lectura`) VALUES
(1, 9, 'Matrícula registrada', 'Tu solicitud de matrícula MAT-2026-0005 fue registrada. Generamos una obligación de pago por Gs. 595.000.', 'info', '/matriculas/detalle/7', 0, '2026-10-13 11:51:01', NULL),
(26, 9, 'Solicitud registrada', 'Registramos tu solicitud \"Constancia de alumno regular\" con el código TRA-20261013-0001. Debés abonar Gs. 80.000 para que la procesemos.', 'info', '/tramites/detalle/3', 0, '2026-10-13 11:51:01', NULL),
(30, 9, 'Actualización de tu trámite', 'Tu trámite fue entregado. ¡Gracias!', 'exito', '/tramites/detalle/3', 0, '2026-10-13 11:51:01', NULL),
(31, 9, 'Solicitud registrada', 'Registramos tu solicitud \"Certificado de calificaciones\" con el código TRA-20261013-0002. Debés abonar Gs. 120.000 para que la procesemos.', 'info', '/tramites/detalle/4', 0, '2026-10-13 11:51:01', NULL),
(35, 9, 'Actualización de tu trámite', 'Tu documento está listo. Podés retirarlo en la secretaría.', 'exito', '/tramites/detalle/4', 0, '2026-10-13 11:51:01', NULL),
(36, 9, 'Solicitud registrada', 'Registramos tu solicitud \"Cambio de carrera\" con el código TRA-20261013-0003. La procesaremos en 10 día(s) hábil(es).', 'info', '/tramites/detalle/5', 0, '2026-10-13 11:51:01', NULL),
(37, 9, 'Actualización de tu trámite', 'Tu trámite está siendo procesado.', 'exito', '/tramites/detalle/5', 0, '2026-10-13 11:51:01', NULL),
(38, 9, 'Solicitud registrada', 'Registramos tu solicitud \"Duplicado de credencial\" con el código TRA-20261013-0004. Debés abonar Gs. 100.000 para que la procesemos.', 'info', '/tramites/detalle/6', 0, '2026-10-13 11:51:01', NULL),
(39, 9, 'Inscripción a examen registrada', 'Te inscribiste en \"Mesa Final - Programacion Web\". Generamos una obligación de pago por Gs. 150.000.', 'info', '/examenes/mis-inscripciones', 0, '2026-10-13 11:51:01', NULL),
(40, 9, 'Inscripción a examen registrada', 'Te inscribiste en \"Mesa Final - Base de Datos II\". Generamos una obligación de pago por Gs. 150.000.', 'info', '/examenes/mis-inscripciones', 0, '2026-10-13 11:51:01', NULL),
(41, 9, 'Bienvenida al portal de pagos', 'Hola Lucia, ya podés consultar tus obligaciones, pagar en linea y descargar tus comprobantes.', 'info', '/panel', 1, '2026-10-13 11:51:01', '2026-10-13 11:51:01'),
(42, 9, 'Beca Deportiva asignada', 'Se te otorgo la Beca Deportiva del 30% sobre matriculas y aranceles del periodo 2026 - Segundo Semestre.', 'exito', '/mi-perfil', 1, '2026-10-13 11:51:01', '2026-10-13 11:51:01'),
(43, 9, 'Nuevo arancel disponible', 'Ya esta disponible el arancel de noviembre 2026 por Gs. 504.000 con tu beca aplicada.', 'info', '/pagos/pendientes', 0, '2026-10-13 11:51:01', NULL),
(44, 9, 'Arancel de laboratorio vencido', 'El arancel de laboratorio vencio el 30/09/2026 y ya acumula mora. Regularizalo para evitar bloqueos.', 'advertencia', '/pagos/pendientes', 0, '2026-10-13 11:51:01', NULL),
(45, 9, 'Constancia de alumno regular', 'Tu constancia de alumno regular fue generada y entregada en secretaria.', 'exito', '/tramites', 1, '2026-10-13 11:51:01', '2026-10-13 11:51:01'),
(46, 9, 'Certificado listo para retirar', 'Tu certificado de calificaciones esta listo. Podés retirarlo en Registro Academico.', 'exito', '/tramites', 0, '2026-10-13 11:51:01', NULL),
(50, 9, 'Pago anulado', 'El comprobante REC-2026-000018 fue anulado. Motivo: Prueba automatica', 'advertencia', '/pagos/historial', 0, '2026-10-13 12:11:37', NULL),
(51, 9, 'Pago confirmado', 'Registramos tu pago de Gs. 316.000 (comprobante REC-2026-000018). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/20', 0, '2026-10-13 12:17:23', NULL),
(52, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 316.000 con el comprobante REC-2026-000018.', 'pago', '/pagos/detalle/20', 0, '2026-10-13 12:17:23', NULL),
(53, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 316.000 con el comprobante REC-2026-000018.', 'pago', '/pagos/detalle/20', 0, '2026-10-13 12:17:23', NULL),
(54, 3, 'Inscripción a examen registrada', 'Te inscribiste en \"Mesa Final - Programacion Web\". Generamos una obligación de pago por Gs. 150.000. Podés abonarla hasta el 25/11/2026.', 'info', '/examenes/mis-inscripciones', 0, '2026-10-13 12:21:59', NULL),
(55, 3, 'Solicitud registrada', 'Registramos tu solicitud \"Constancia de alumno regular\" con el código TRA-20261013-0005. Debés abonar Gs. 80.000 para que la procesemos.', 'info', '/tramites/detalle/7', 0, '2026-10-13 12:21:59', NULL),
(56, 3, 'Pago confirmado', 'Registramos tu pago de Gs. 910.000 (comprobante REC-2026-000019). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/21', 0, '2026-10-13 12:22:00', NULL),
(57, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 910.000 con el comprobante REC-2026-000019.', 'pago', '/pagos/detalle/21', 0, '2026-10-13 12:22:00', NULL),
(58, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 910.000 con el comprobante REC-2026-000019.', 'pago', '/pagos/detalle/21', 0, '2026-10-13 12:22:00', NULL),
(63, 9, 'Pago rechazado', 'No pudimos procesar tu pago por Gs. 202.000. Simula un rechazo del emisor por fondos insuficientes.', 'error', '/pagos/pendientes', 0, '2026-10-13 12:35:04', NULL),
(64, 9, 'Pago rechazado', 'No pudimos procesar tu pago por Gs. 150.000. Simula un rechazo del emisor por fondos insuficientes.', 'error', '/pagos/pendientes', 0, '2026-10-13 12:37:07', NULL),
(65, 9, 'Pago confirmado', 'Registramos tu pago de Gs. 150.000 (comprobante REC-2026-000020). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/24', 0, '2026-10-13 12:37:07', NULL),
(66, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 150.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/24', 0, '2026-10-13 12:37:07', NULL),
(67, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 150.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/24', 0, '2026-10-13 12:37:07', NULL),
(68, 9, 'Pago rechazado', 'No pudimos procesar tu pago por Gs. 150.000. Simula un rechazo del emisor por fondos insuficientes.', 'error', '/pagos/pendientes', 0, '2026-10-13 12:37:46', NULL),
(69, 9, 'Pago confirmado', 'Registramos tu pago de Gs. 150.000 (comprobante REC-2026-000020). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/27', 0, '2026-10-13 12:37:46', NULL),
(70, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 150.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/27', 0, '2026-10-13 12:37:46', NULL),
(71, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 150.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/27', 0, '2026-10-13 12:37:46', NULL),
(72, 9, 'Pago rechazado', 'No pudimos procesar tu pago por Gs. 150.000. Simula un rechazo del emisor por fondos insuficientes.', 'error', '/pagos/pendientes', 0, '2026-10-13 12:37:59', NULL),
(73, 9, 'Pago confirmado', 'Registramos tu pago de Gs. 150.000 (comprobante REC-2026-000020). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/30', 0, '2026-10-13 12:38:00', NULL),
(74, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 150.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/30', 0, '2026-10-13 12:38:00', NULL),
(75, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 150.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/30', 0, '2026-10-13 12:38:00', NULL),
(76, 9, 'Pago confirmado', 'Registramos tu pago de Gs. 504.000 (comprobante REC-2026-000020). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/33', 0, '2026-10-13 12:40:22', NULL),
(77, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 504.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/33', 0, '2026-10-13 12:40:22', NULL),
(78, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 504.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/33', 0, '2026-10-13 12:40:22', NULL),
(79, 3, 'Inscripción a examen registrada', 'Te inscribiste en \"Mesa Final - Base de Datos II\". Generamos una obligación de pago por Gs. 150.000. Podés abonarla hasta el 25/11/2026.', 'info', '/examenes/mis-inscripciones', 0, '2026-10-13 12:44:37', NULL),
(80, 3, 'Solicitud registrada', 'Registramos tu solicitud \"Certificado de calificaciones\" con el código TRA-20261013-0006. Debés abonar Gs. 120.000 para que la procesemos.', 'info', '/tramites/detalle/8', 0, '2026-10-13 12:44:37', NULL),
(81, 3, 'Pago confirmado', 'Registramos tu pago de Gs. 270.000 (comprobante REC-2026-000020). Ya podés descargar el comprobante.', 'exito', '/pagos/detalle/34', 0, '2026-10-13 12:44:37', NULL),
(82, 1, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 270.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/34', 0, '2026-10-13 12:44:37', NULL),
(83, 4, 'Nuevo pago registrado', 'Se acreditó un pago de Gs. 270.000 con el comprobante REC-2026-000020.', 'pago', '/pagos/detalle/34', 0, '2026-10-13 12:44:37', NULL),
(84, 1, 'Nuevo mensaje de contacto', 'Visitante Prueba (visitante174508@test.local) consulta: Consulta ZZ174508', 'info', '/mensajes/detalle/2', 0, '2026-10-13 12:45:09', NULL),
(85, 6, 'Nuevo mensaje de contacto', 'Visitante Prueba (visitante174508@test.local) consulta: Consulta ZZ174508', 'info', '/mensajes/detalle/2', 0, '2026-10-13 12:45:09', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obligaciones_pago`
--

CREATE TABLE `obligaciones_pago` (
  `id_obligacion` int(11) NOT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `id_concepto_pago` int(11) DEFAULT NULL,
  `id_periodo` int(11) DEFAULT NULL,
  `id_arancel` int(11) DEFAULT NULL,
  `id_matricula` int(11) DEFAULT NULL,
  `id_inscripcion` int(11) DEFAULT NULL,
  `descripcion` varchar(145) DEFAULT NULL,
  `referencia` varchar(45) DEFAULT NULL,
  `monto_original` decimal(12,2) DEFAULT NULL,
  `monto_mora` decimal(12,2) DEFAULT NULL,
  `monto_descuento` decimal(12,2) DEFAULT NULL,
  `monto_final` decimal(12,2) DEFAULT NULL,
  `monto_pagado` decimal(12,2) NOT NULL DEFAULT 0.00,
  `saldo` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_emision` date DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `prioridad` varchar(20) NOT NULL DEFAULT 'Normal',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `obligaciones_pago`
--

INSERT INTO `obligaciones_pago` (`id_obligacion`, `id_alumno`, `id_concepto_pago`, `id_periodo`, `id_arancel`, `id_matricula`, `id_inscripcion`, `descripcion`, `referencia`, `monto_original`, `monto_mora`, `monto_descuento`, `monto_final`, `monto_pagado`, `saldo`, `fecha_emision`, `fecha_vencimiento`, `estado`, `prioridad`, `creado_en`) VALUES
(1, 1, 1, 3, 1, 1, NULL, 'Matricula 2026-2', 'MAT-2026-2-0001', 850000.00, 0.00, 0.00, 850000.00, 850000.00, 0.00, '2026-07-21', '2026-08-15', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(2, 1, 3, 3, 3, NULL, NULL, 'Arancel Julio 2026', 'ARA-2026-07', 720000.00, 0.00, 0.00, 720000.00, 720000.00, 0.00, '2026-07-25', '2026-08-10', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(3, 1, 3, 3, 3, NULL, NULL, 'Arancel Agosto 2026', 'ARA-2026-08', 720000.00, 0.00, 0.00, 720000.00, 720000.00, 0.00, '2026-08-01', '2026-09-10', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(4, 1, 3, 3, 3, NULL, NULL, 'Arancel Septiembre 2026', 'ARA-2026-09', 720000.00, 0.00, 0.00, 720000.00, 720000.00, 0.00, '2026-09-01', '2026-10-10', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(5, 1, 3, 3, 3, NULL, NULL, 'Arancel Octubre 2026', 'ARA-2026-10', 720000.00, 0.00, 0.00, 720000.00, 0.00, 720000.00, '2026-10-01', '2026-11-10', 'Pendiente', 'Normal', '2026-10-13 10:33:10'),
(6, 1, 4, 3, 13, NULL, NULL, 'Laboratorio Ing. Sistemas 2026', 'LAB-2026', 300000.00, 0.00, 0.00, 300000.00, 0.00, 300000.00, '2026-08-01', '2026-09-30', 'Vencido', 'Alta', '2026-10-13 10:33:10'),
(7, 2, 1, 3, 1, 2, NULL, 'Matricula 2026-2', 'MAT-2026-2-0002', 850000.00, 0.00, 0.00, 850000.00, 850000.00, 0.00, '2026-07-22', '2026-08-15', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(8, 2, 3, 3, 5, NULL, NULL, 'Arancel Septiembre 2026', 'ARA-2026-09', 680000.00, 0.00, 0.00, 680000.00, 680000.00, 0.00, '2026-09-01', '2026-10-10', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(9, 2, 3, 3, 5, NULL, NULL, 'Arancel Octubre 2026', 'ARA-2026-10', 680000.00, 0.00, 0.00, 680000.00, 680000.00, 0.00, '2026-10-01', '2026-11-10', 'Pagado', 'Normal', '2026-10-13 10:33:10'),
(10, 3, 1, 3, 1, 3, NULL, 'Matricula 2026-2', 'MAT-2026-2-0003', 850000.00, 25000.00, 0.00, 875000.00, 0.00, 875000.00, '2026-08-03', '2026-08-15', 'Vencido', 'Alta', '2026-10-13 10:33:10'),
(11, 3, 3, 3, 3, NULL, NULL, 'Arancel Octubre 2026', 'ARA-2026-10', 720000.00, 0.00, 0.00, 720000.00, 0.00, 720000.00, '2026-10-01', '2026-11-10', 'Pendiente', 'Normal', '2026-10-13 10:33:10'),
(12, 4, 1, 3, 1, 4, NULL, 'Matricula 2026-2', 'MAT-2026-2-0004', 850000.00, 0.00, 425000.00, 425000.00, 0.00, 425000.00, '2026-08-10', '2026-09-15', 'Pendiente', 'Normal', '2026-10-13 10:33:10'),
(13, 4, 3, 3, 4, NULL, NULL, 'Arancel Octubre 2026', 'ARA-2026-10', 680000.00, 0.00, 340000.00, 340000.00, 0.00, 340000.00, '2026-10-01', '2026-11-10', 'Pendiente', 'Normal', '2026-10-13 10:33:10'),
(14, 5, 1, 3, 1, 7, NULL, 'Matrícula Matricula general 2026-2', 'MAT-2026-0005', 850000.00, 0.00, 255000.00, 595000.00, 595000.00, 0.00, '2026-10-13', '2026-08-15', 'Pagado', 'Alta', '2026-10-13 11:51:01'),
(15, 5, 1, 1, NULL, 5, NULL, 'Matricula 2025-2', 'MAT-2025-2-0070', 780000.00, 0.00, 0.00, 780000.00, 780000.00, 0.00, '2025-07-16', '2025-08-15', 'Pagado', 'Alta', '2025-07-16 09:00:00'),
(16, 5, 3, 1, 3, NULL, NULL, 'Arancel Agosto 2025', 'ARA-2025-08', 650000.00, 0.00, 0.00, 650000.00, 650000.00, 0.00, '2025-08-01', '2025-08-10', 'Pagado', 'Normal', '2025-08-01 09:00:00'),
(17, 5, 1, 2, NULL, 6, NULL, 'Matricula 2026-1', 'MAT-2026-1-0070', 820000.00, 0.00, 0.00, 820000.00, 820000.00, 0.00, '2026-01-26', '2026-02-15', 'Pagado', 'Alta', '2026-01-26 09:00:00'),
(18, 5, 6, 2, NULL, NULL, NULL, 'Final - Analisis de Sistemas', 'EXA-HIST', 140000.00, 0.00, 0.00, 140000.00, 140000.00, 0.00, '2026-06-15', '2026-06-25', 'Pagado', 'Normal', '2026-06-15 09:00:00'),
(19, 5, 3, 3, 3, NULL, NULL, 'Arancel Julio 2026', 'ARA-2026-07', 720000.00, 0.00, 216000.00, 504000.00, 504000.00, 0.00, '2026-07-01', '2026-08-10', 'Pagado', 'Normal', '2026-07-01 09:00:00'),
(20, 5, 3, 3, 3, NULL, NULL, 'Arancel Agosto 2026', 'ARA-2026-08', 720000.00, 0.00, 216000.00, 504000.00, 504000.00, 0.00, '2026-08-01', '2026-09-10', 'Pagado', 'Normal', '2026-08-01 09:00:00'),
(21, 5, 3, 3, 3, NULL, NULL, 'Arancel Septiembre 2026', 'ARA-2026-09', 720000.00, 0.00, 216000.00, 504000.00, 504000.00, 0.00, '2026-09-01', '2026-10-10', 'Pagado', 'Normal', '2026-09-01 09:00:00'),
(22, 5, 3, 3, 3, NULL, NULL, 'Arancel Octubre 2026', 'ARA-2026-10', 720000.00, 0.00, 216000.00, 504000.00, 302000.00, 202000.00, '2026-10-01', '2026-11-10', 'Parcial', 'Normal', '2026-10-01 09:00:00'),
(23, 5, 3, 3, 3, NULL, NULL, 'Arancel Noviembre 2026', 'ARA-2026-11', 720000.00, 0.00, 216000.00, 504000.00, 0.00, 504000.00, '2026-11-01', '2026-12-10', 'Pendiente', 'Normal', '2026-11-01 09:00:00'),
(24, 5, 9, 3, NULL, NULL, NULL, 'Constancia de alumno regular', 'TRA-20261013-0001', 80000.00, 0.00, 0.00, 80000.00, 80000.00, 0.00, '2026-10-13', NULL, 'Pagado', 'Normal', '2026-10-13 11:51:01'),
(25, 5, 10, 3, NULL, NULL, NULL, 'Certificado de calificaciones', 'TRA-20261013-0002', 120000.00, 0.00, 0.00, 120000.00, 120000.00, 0.00, '2026-10-13', NULL, 'Pagado', 'Normal', '2026-10-13 11:51:01'),
(26, 5, 12, 3, NULL, NULL, NULL, 'Duplicado de credencial', 'TRA-20261013-0004', 100000.00, 0.00, 0.00, 100000.00, 0.00, 100000.00, '2026-10-13', NULL, 'Pendiente', 'Normal', '2026-10-13 11:51:01'),
(27, 5, 4, 3, 13, NULL, NULL, 'Laboratorio Ing. Sistemas 2026', 'LAB-2026', 300000.00, 16000.00, 0.00, 316000.00, 316000.00, 0.00, '2026-08-01', '2026-09-30', 'Pagado', 'Alta', '2026-08-01 09:00:00'),
(28, 5, 13, 3, 12, NULL, NULL, 'Kit universitario 2026', 'KIT-2026', 250000.00, 0.00, 0.00, 250000.00, 0.00, 0.00, '2026-08-01', '2026-09-30', 'Anulado', 'Normal', '2026-08-01 09:00:00'),
(29, 5, 6, 3, NULL, NULL, 2, 'Final - Programacion Web', 'EXA-2', 150000.00, 0.00, 0.00, 150000.00, 0.00, 150000.00, '2026-10-13', '2026-11-10', 'Pendiente', 'Normal', '2026-10-13 11:51:01'),
(30, 5, 6, 3, NULL, NULL, 3, 'Final - Base de Datos II', 'EXA-3', 150000.00, 0.00, 0.00, 150000.00, 0.00, 150000.00, '2026-10-13', '2026-11-12', 'Pendiente', 'Normal', '2026-10-13 11:51:01'),
(32, 2, 6, 3, NULL, NULL, 4, 'Final - Programacion Web', 'EXA-4', 150000.00, 0.00, 0.00, 150000.00, 150000.00, 0.00, '2026-10-13', '2026-11-10', 'Pagado', 'Normal', '2026-10-13 12:21:59'),
(33, 2, 9, 3, NULL, NULL, NULL, 'Constancia de alumno regular', 'TRA-20261013-0005', 80000.00, 0.00, 0.00, 80000.00, 80000.00, 0.00, '2026-10-13', NULL, 'Pagado', 'Normal', '2026-10-13 12:21:59'),
(50, 2, 6, 3, NULL, NULL, 5, 'Final - Base de Datos II', 'EXA-5', 150000.00, 0.00, 0.00, 150000.00, 150000.00, 0.00, '2026-10-13', '2026-11-12', 'Pagado', 'Normal', '2026-10-13 12:44:37'),
(51, 2, 10, 3, NULL, NULL, NULL, 'Certificado de calificaciones', 'TRA-20261013-0006', 120000.00, 0.00, 0.00, 120000.00, 120000.00, 0.00, '2026-10-13', NULL, 'Pagado', 'Normal', '2026-10-13 12:44:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `id_metodo_pago` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_periodo` int(11) DEFAULT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `codigo_transaccion` varchar(145) DEFAULT NULL,
  `pasarela` varchar(45) DEFAULT NULL COMMENT 'sandbox, bancard, pagopar, transferencia, caja',
  `id_transaccion_pasarela` varchar(145) DEFAULT NULL,
  `monto_total` decimal(12,2) DEFAULT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'PYG',
  `tipo_pago` varchar(45) NOT NULL DEFAULT 'Online' COMMENT 'Online, Caja, Transferencia',
  `monto_recibido` decimal(12,2) DEFAULT NULL,
  `vuelto` decimal(12,2) DEFAULT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `estado_pago` varchar(45) DEFAULT NULL,
  `comprobante_ref` varchar(145) DEFAULT NULL,
  `url_comprobante` varchar(255) DEFAULT NULL,
  `numero_comprobante` varchar(45) DEFAULT NULL,
  `observacion` varchar(255) DEFAULT NULL,
  `ip_origen` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`id_pago`, `id_alumno`, `id_metodo_pago`, `id_usuario`, `id_periodo`, `id_sede`, `codigo_transaccion`, `pasarela`, `id_transaccion_pasarela`, `monto_total`, `moneda`, `tipo_pago`, `monto_recibido`, `vuelto`, `fecha_pago`, `estado_pago`, `comprobante_ref`, `url_comprobante`, `numero_comprobante`, `observacion`, `ip_origen`, `user_agent`, `creado_en`, `actualizado_en`) VALUES
(1, 1, 7, 2, 3, 1, 'TX-20260722-0001', 'sandbox', NULL, 850000.00, 'PYG', 'Online', NULL, NULL, '2026-07-22 10:00:00', 'Aprobado', NULL, NULL, 'REC-2026-000001', 'Pago de matricula 2026-2', NULL, NULL, '2026-07-22 10:00:00', '2026-10-13 10:32:58'),
(2, 1, 7, 2, 3, 1, 'TX-20260726-0002', 'sandbox', NULL, 720000.00, 'PYG', 'Online', NULL, NULL, '2026-07-26 20:12:00', 'Aprobado', NULL, NULL, 'REC-2026-000002', 'Arancel Julio 2026', NULL, NULL, '2026-07-26 20:12:00', '2026-10-13 10:32:58'),
(3, 1, 2, 4, 3, 1, 'TX-20260805-0003', 'caja', NULL, 720000.00, 'PYG', 'Caja', NULL, NULL, '2026-08-05 09:30:00', 'Aprobado', NULL, NULL, 'REC-2026-000003', 'Arancel Agosto 2026 en ventanilla', NULL, NULL, '2026-08-05 09:30:00', '2026-10-13 10:32:58'),
(4, 2, 7, 3, 3, 1, 'TX-20260723-0004', 'sandbox', NULL, 850000.00, 'PYG', 'Online', NULL, NULL, '2026-07-23 08:45:00', 'Aprobado', NULL, NULL, 'REC-2026-000004', 'Pago de matricula 2026-2', NULL, NULL, '2026-07-23 08:45:00', '2026-10-13 10:32:58'),
(5, 1, 7, 2, 3, 1, 'TX-20260910-0005', 'sandbox', NULL, 720000.00, 'PYG', 'Online', NULL, NULL, '2026-09-10 19:05:00', 'Aprobado', NULL, NULL, 'REC-2026-000005', 'Arancel Septiembre 2026', NULL, NULL, '2026-09-10 19:05:00', '2026-10-13 10:32:58'),
(6, 2, 7, 3, 3, 1, 'TX-20260912-0006', 'sandbox', NULL, 680000.00, 'PYG', 'Online', NULL, NULL, '2026-09-12 21:40:00', 'Aprobado', NULL, NULL, 'REC-2026-000006', 'Arancel Septiembre 2026', NULL, NULL, '2026-09-12 21:40:00', '2026-10-13 10:32:58'),
(7, 5, 7, 9, 3, 1, 'TX-20261013-0BB9E36F', 'sandbox', 'SBX-20261013115101-034A6F', 780000.00, 'PYG', 'Online', 780000.00, 0.00, '2025-07-18 10:00:00', 'Aprobado', 'TX-20261013-0BB9E36F', '/SistemaUnvesGestion/pagos/comprobante/7', 'REC-2026-000007', 'Pago de matricula 2025-2', NULL, '', '2025-07-18 10:00:00', '2026-10-13 11:51:01'),
(8, 5, 2, 9, 3, 1, 'TX-20261013-CC286453', 'transferencia', 'UNVES-00000008', 650000.00, 'PYG', 'Online', 650000.00, 0.00, '2025-08-07 10:00:00', 'Aprobado', 'TX-20261013-CC286453', '/SistemaUnvesGestion/pagos/comprobante/8', 'REC-2026-000008', 'Arancel Agosto 2025 por transferencia', NULL, '', '2025-08-07 10:00:00', '2026-10-13 11:51:01'),
(9, 5, 7, 9, 3, 1, 'TX-20261013-6EE0B8D0', 'sandbox', 'SBX-20261013115101-761131', 820000.00, 'PYG', 'Online', 820000.00, 0.00, '2026-01-28 10:00:00', 'Aprobado', 'TX-20261013-6EE0B8D0', '/SistemaUnvesGestion/pagos/comprobante/9', 'REC-2026-000009', 'Pago de matricula 2026-1', NULL, '', '2026-01-28 10:00:00', '2026-10-13 11:51:01'),
(10, 5, 5, 9, 3, 1, 'TX-20261013-D0825370', 'sandbox', 'SBX-20261013115101-C3FDEF', 140000.00, 'PYG', 'Online', 140000.00, 0.00, '2026-06-20 10:00:00', 'Aprobado', 'TX-20261013-D0825370', '/SistemaUnvesGestion/pagos/comprobante/10', 'REC-2026-000010', 'Derecho de examen final', NULL, '', '2026-06-20 10:00:00', '2026-10-13 11:51:01'),
(11, 5, 7, 9, 3, 1, 'TX-20261013-E17E323C', 'sandbox', 'SBX-20261013115101-89F9F7', 595000.00, 'PYG', 'Online', 595000.00, 0.00, '2026-07-23 10:00:00', 'Aprobado', 'TX-20261013-E17E323C', '/SistemaUnvesGestion/pagos/comprobante/11', 'REC-2026-000011', 'Pago de matricula 2026-2', NULL, '', '2026-07-23 10:00:00', '2026-10-13 11:51:01'),
(12, 5, 2, 9, 3, 1, 'TX-20261013-0440C559', 'transferencia', 'UNVES-00000012', 504000.00, 'PYG', 'Online', 504000.00, 0.00, '2026-08-05 10:00:00', 'Aprobado', 'TX-20261013-0440C559', '/SistemaUnvesGestion/pagos/comprobante/12', 'REC-2026-000012', 'Arancel Julio 2026 por transferencia', NULL, '', '2026-08-05 10:00:00', '2026-10-13 11:51:01'),
(13, 5, 5, 9, 3, 1, 'TX-20261013-A3C6456E', 'sandbox', 'SBX-20261013115101-E3C001', 504000.00, 'PYG', 'Online', 504000.00, 0.00, '2026-09-08 10:00:00', 'Aprobado', 'TX-20261013-A3C6456E', '/SistemaUnvesGestion/pagos/comprobante/13', 'REC-2026-000013', 'Arancel Agosto 2026 con Tigo Money', NULL, '', '2026-09-08 10:00:00', '2026-10-13 11:51:01'),
(14, 5, 3, 9, 3, 1, 'TX-20261013-2101675D', 'sandbox', 'SBX-20261013115101-9DA145', 504000.00, 'PYG', 'Online', 504000.00, 0.00, '2026-10-02 10:00:00', 'Aprobado', 'TX-20261013-2101675D', '/SistemaUnvesGestion/pagos/comprobante/14', 'REC-2026-000014', 'Arancel Septiembre 2026 con tarjeta', NULL, '', '2026-10-02 10:00:00', '2026-10-13 11:51:01'),
(15, 5, 7, 9, 3, 1, 'TX-20261013-99CD1526', 'sandbox', 'SBX-20261013115101-F00AFF', 80000.00, 'PYG', 'Online', 80000.00, 0.00, '2026-10-05 10:00:00', 'Aprobado', 'TX-20261013-99CD1526', '/SistemaUnvesGestion/pagos/comprobante/15', 'REC-2026-000015', 'Arancel de constancia de alumno regular', NULL, '', '2026-10-05 10:00:00', '2026-10-13 11:51:01'),
(16, 5, 1, 9, 3, 1, 'TX-PARCIAL-20261008', 'caja', NULL, 302000.00, 'PYG', 'Caja', 302000.00, 0.00, '2026-10-08 10:00:00', 'Aprobado', NULL, '/SistemaUnvesGestion/pagos/comprobante/16', 'REC-2026-000016', 'Entrega parcial del arancel de octubre en caja.', NULL, NULL, '2026-10-08 10:00:00', '2026-10-13 11:51:01'),
(17, 5, 4, 9, 3, 1, 'TX-20261013-447B8140', 'sandbox', 'SBX-20261013115101-05E2CC', 120000.00, 'PYG', 'Online', 120000.00, 0.00, '2026-10-11 10:00:00', 'Aprobado', 'TX-20261013-447B8140', '/SistemaUnvesGestion/pagos/comprobante/17', 'REC-2026-000017', 'Arancel del certificado de calificaciones', NULL, '', '2026-10-11 10:00:00', '2026-10-13 11:51:01'),
(20, 5, 7, 9, 3, 1, 'TX-20261013-1F66026F', 'sandbox', 'SBX-20261013121718-BEFC9E', 316000.00, 'PYG', 'Online', 316000.00, 0.00, '2026-10-13 12:17:23', 'Aprobado', '63C0A733', '/SistemaUnvesGestion/pagos/comprobante/20', 'REC-2026-000018', 'Laboratorio Ing. Sistemas 2026', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 12:17:18', '2026-10-13 12:17:23'),
(21, 2, 7, 3, 3, 1, 'TX-20261013-3F8A19E0', 'sandbox', 'SBX-20261013122159-CD23FE', 910000.00, 'PYG', 'Online', 910000.00, 0.00, '2026-10-13 12:22:00', 'Aprobado', 'E2FE3007', '/SistemaUnvesGestion/pagos/comprobante/21', 'REC-2026-000019', 'Arancel Octubre 2026 + Final - Programacion Web + Constancia de alumno regular', '::1', '', '2026-10-13 12:21:59', '2026-10-13 12:22:00'),
(34, 2, 7, 3, 3, 1, 'TX-20261013-76BF6A46', 'sandbox', 'SBX-34', 270000.00, 'PYG', 'Online', 270000.00, 0.00, '2026-10-13 12:44:37', 'Aprobado', 'F552AF88', '/SistemaUnvesGestion/pagos/comprobante/34', 'REC-2026-000020', 'Final - Base de Datos II + Certificado de calificaciones', '::1', '', '2026-10-13 12:44:37', '2026-10-13 12:44:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago_detalles`
--

CREATE TABLE `pago_detalles` (
  `id_pago_detalle` int(11) NOT NULL,
  `id_pago` int(11) DEFAULT NULL,
  `id_obligacion` int(11) DEFAULT NULL,
  `monto_pagado` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `pago_detalles`
--

INSERT INTO `pago_detalles` (`id_pago_detalle`, `id_pago`, `id_obligacion`, `monto_pagado`) VALUES
(1, 1, 1, 850000.00),
(2, 2, 2, 720000.00),
(3, 3, 3, 720000.00),
(4, 4, 7, 850000.00),
(5, 5, 4, 720000.00),
(6, 6, 8, 680000.00),
(7, 7, 15, 780000.00),
(8, 8, 16, 650000.00),
(9, 9, 17, 820000.00),
(10, 10, 18, 140000.00),
(11, 11, 14, 595000.00),
(12, 12, 19, 504000.00),
(13, 13, 20, 504000.00),
(14, 14, 21, 504000.00),
(15, 15, 24, 80000.00),
(16, 16, 22, 302000.00),
(17, 17, 25, 120000.00),
(25, 20, 27, 316000.00),
(26, 21, 9, 680000.00),
(27, 21, 32, 150000.00),
(28, 21, 33, 80000.00),
(43, 34, 50, 150000.00),
(44, 34, 51, 120000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_resets`
--

CREATE TABLE `password_resets` (
  `id_reset` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `token` varchar(128) NOT NULL,
  `expira_en` datetime NOT NULL,
  `usado` tinyint(1) NOT NULL DEFAULT 0,
  `ip_solicitud` varchar(45) DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `periodos_academicos`
--

CREATE TABLE `periodos_academicos` (
  `id_periodo` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `periodos_academicos`
--

INSERT INTO `periodos_academicos` (`id_periodo`, `nombre`, `fecha_inicio`, `fecha_fin`, `estado`) VALUES
(1, '2025 - Segundo Semestre', '2025-07-01', '2025-12-20', 'Cerrado'),
(2, '2026 - Primer Semestre', '2026-02-02', '2026-07-17', 'Cerrado'),
(3, '2026 - Segundo Semestre', '2026-07-20', '2026-12-18', 'Activo'),
(4, '2027 - Primer Semestre', '2027-02-01', '2027-07-16', 'Planificado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `id_persona` int(11) NOT NULL,
  `cedula` varchar(45) DEFAULT NULL,
  `nombres` varchar(145) DEFAULT NULL,
  `apellidos` varchar(145) DEFAULT NULL,
  `telefono` varchar(25) DEFAULT NULL,
  `email` varchar(145) DEFAULT NULL,
  `celular` varchar(25) DEFAULT NULL,
  `direccion` varchar(145) DEFAULT NULL,
  `id_ciudades` int(11) DEFAULT NULL,
  `fecha_nac` date DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `nacionalidad` varchar(45) DEFAULT NULL,
  `sexo` varchar(15) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`id_persona`, `cedula`, `nombres`, `apellidos`, `telefono`, `email`, `celular`, `direccion`, `id_ciudades`, `fecha_nac`, `estado`, `nacionalidad`, `sexo`, `foto`, `creado_en`) VALUES
(1, '1234567', 'Administrador', 'del Sistema', '+595 991 461 220', 'admin@unves.edu.py', '0991 461 220', 'Campus Central', 1, '1985-03-12', 'Activo', 'Paraguaya', 'M', NULL, '2026-10-13 10:32:58'),
(2, '4567890', 'Juan Carlos', 'Perez Gonzalez', '+595 981 111 222', 'juan.perez@unves.edu.py', '0981 111 222', 'Barrio Ybaroty, Villarrica', 1, '2003-05-21', 'Activo', 'Paraguaya', 'M', NULL, '2026-10-13 10:32:58'),
(3, '4321098', 'Maria Fernanda', 'Lopez Ramirez', '+595 982 333 444', 'maria.lopez@unves.edu.py', '0982 333 444', 'Barrio Santa Lucia, Villarrica', 1, '2002-11-08', 'Activo', 'Paraguaya', 'F', NULL, '2026-10-13 10:32:58'),
(4, '3210987', 'Carlos Alberto', 'Ramirez Vega', '+595 983 555 666', 'carlos.ramirez@unves.edu.py', '0983 555 666', 'Centro, Villarrica', 1, '1990-01-30', 'Activo', 'Paraguaya', 'M', NULL, '2026-10-13 10:32:58'),
(5, '2987654', 'Ana Belen', 'Benitez Torres', '+595 984 777 888', 'ana.benitez@unves.edu.py', '0984 777 888', 'Barrio San Miguel', 1, '1982-07-14', 'Activo', 'Paraguaya', 'F', NULL, '2026-10-13 10:32:58'),
(6, '3876543', 'Lucia', 'Gimenez Aquino', '+595 985 999 000', 'lucia.gimenez@unves.edu.py', '0985 999 000', 'Barrio Estacion', 1, '1995-09-02', 'Activo', 'Paraguaya', 'F', NULL, '2026-10-13 10:32:58'),
(7, '4123567', 'Pedro Andres', 'Martinez Silva', '+595 986 123 456', 'pedro.martinez@unves.edu.py', '0986 123 456', 'Barrio Las Mercedes', 1, '2001-04-18', 'Activo', 'Paraguaya', 'M', NULL, '2026-10-13 10:32:58'),
(8, '4987123', 'Sofia', 'Cabrera Nunez', '+595 987 654 321', 'sofia.cabrera@unves.edu.py', '0987 654 321', 'Barrio Ita Ybate', 1, '2004-02-25', 'Activo', 'Paraguaya', 'F', NULL, '2026-10-13 10:32:58'),
(9, '5234891-6', 'Lucia Fernanda', 'Villalba Rios', '+595 991 234 567', 'lucia.villalba@unves.edu.py', '0991 234 567', 'Barrio San Blas, calle Mcal. Estigarribia 1245, Villarrica', 1, '2004-06-12', 'Activo', 'Paraguaya', 'F', NULL, '2026-10-13 11:51:01'),
(12, '9906308', 'Prueba', 'Auto174508', NULL, 'alumno174508@test.local', '0981 000 111', NULL, NULL, NULL, 'Activo', 'Paraguaya', NULL, NULL, '2026-10-13 12:45:08'),
(13, '8906308', 'Usuario', 'Prueba174508', NULL, 'usuario174508@test.local', NULL, NULL, NULL, NULL, 'Activo', NULL, NULL, NULL, '2026-10-13 12:45:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `plantillas_documento`
--

CREATE TABLE `plantillas_documento` (
  `id_plantilla` int(11) NOT NULL,
  `id_tipo_tramite` int(11) DEFAULT NULL,
  `nombre` varchar(145) NOT NULL,
  `contenido_html` longtext NOT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'Activo',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `plantillas_documento`
--

INSERT INTO `plantillas_documento` (`id_plantilla`, `id_tipo_tramite`, `nombre`, `contenido_html`, `estado`, `creado_en`) VALUES
(1, 1, 'Constancia de alumno regular', '<h2>CONSTANCIA DE ALUMNO REGULAR</h2><p>Se expide la presente constancia a favor de <b>{{ALUMNO}}</b>, portador del documento N&deg; <b>{{CEDULA}}</b>, alumno/a de la carrera de <b>{{CARRERA}}</b>, quien se encuentra regularmente matriculado/a en el periodo lectivo <b>{{PERIODO}}</b>.</p><p>Se expide a pedido del interesado para los fines que estime convenientes.</p>', 'Activo', '2026-10-13 10:32:58'),
(2, 2, 'Certificado de calificaciones', '<h2>CERTIFICADO DE CALIFICACIONES</h2><p>La Secretaria Academica certifica que <b>{{ALUMNO}}</b>, documento N&deg; <b>{{CEDULA}}</b>, de la carrera de <b>{{CARRERA}}</b>, registra las asignaturas aprobadas segun el analitico adjunto.</p>', 'Activo', '2026-10-13 10:32:58'),
(3, 3, 'Duplicado de credencial', '<h2>CONSTANCIA PARA DUPLICADO DE CREDENCIAL</h2><p>Se autoriza la emision del duplicado de credencial universitaria a favor de <b>{{ALUMNO}}</b>, documento N&deg; <b>{{CEDULA}}</b>.</p>', 'Activo', '2026-10-13 10:32:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `descripcion` varchar(145) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre`, `descripcion`, `estado`) VALUES
(1, 'Administrador', 'Acceso total al sistema', 'Activo'),
(2, 'Alumno', 'Portal del estudiante', 'Activo'),
(3, 'Docente', 'Consulta academica y actas', 'Activo'),
(4, 'Cajero', 'Registro de pagos en ventanilla', 'Activo'),
(5, 'Secretaria', 'Gestion de tramites y matriculas', 'Activo'),
(6, 'Finanzas', 'Aranceles, becas y reportes de recaudacion', 'Activo'),
(7, 'Consulta', 'Acceso de solo lectura', 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sedes`
--

CREATE TABLE `sedes` (
  `id_sede` int(11) NOT NULL,
  `nombre` varchar(95) DEFAULT NULL,
  `direccion` varchar(95) DEFAULT NULL,
  `ciudad` varchar(95) DEFAULT NULL,
  `telefono` varchar(45) DEFAULT NULL,
  `email` varchar(145) DEFAULT NULL,
  `es_central` tinyint(1) NOT NULL DEFAULT 0,
  `tipo` varchar(45) DEFAULT 'Campus',
  `id_ciudades` int(11) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `sedes`
--

INSERT INTO `sedes` (`id_sede`, `nombre`, `direccion`, `ciudad`, `telefono`, `email`, `es_central`, `tipo`, `id_ciudades`, `estado`) VALUES
(1, 'Campus Central - Villarrica', 'Bvar. Río Apa entre Pa\'i Anasagasti y Juan Carlos Scavone', 'Villarrica', '(+595 541) 44 535', 'rectorado@unves.edu.py', 1, 'Campus', 1, 'Activo'),
(2, 'Sede Paraguarí', 'Calle 14 de Mayo e/ Mcal. López, Paraguarí', 'Paraguarí', NULL, NULL, 0, 'Filial', 2, 'Activo'),
(3, 'Sede Yuty', 'Ruta PY08, Yuty', 'Yuty', NULL, NULL, 0, 'Filial', 3, 'Activo'),
(4, 'Sede Caazapá', 'Avda. Florida, Caazapá', 'Caazapá', NULL, NULL, 0, 'Filial', 4, 'Activo'),
(5, 'Sede Carapeguá', 'Ruta PY01, Carapeguá', 'Carapeguá', NULL, NULL, 0, 'Filial', NULL, 'Activo'),
(6, 'Sede Pedro Juan Caballero', 'Avda. Internacional, Pedro Juan Caballero', 'Pedro Juan Caballero', NULL, NULL, 0, 'Filial', NULL, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesiones_web`
--

CREATE TABLE `sesiones_web` (
  `id_sesion` bigint(20) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `token` varchar(128) NOT NULL,
  `ip_origen` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `navegador` varchar(95) DEFAULT NULL,
  `plataforma` varchar(95) DEFAULT NULL,
  `fecha_inicio` datetime NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_cierre` datetime DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'Activa' COMMENT 'Activa, Cerrada, Expirada'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sesiones_web`
--

INSERT INTO `sesiones_web` (`id_sesion`, `id_usuario`, `token`, `ip_origen`, `user_agent`, `navegador`, `plataforma`, `fecha_inicio`, `ultimo_acceso`, `fecha_cierre`, `estado`) VALUES
(1, 9, 'c1abd205b02aac6eb03bd2c572e0426b4b47c12902e22df9cbe8cbcc93fe8ec6', '190.104.10.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0 Safari/537.36', 'Chrome', 'Windows', '2026-10-13 09:51:01', '2026-10-13 11:46:01', NULL, 'Activa'),
(2, 9, '35a7f99315f10308663336357125c9341b55fc204412aedf4f54b8609115739f', '181.123.44.9', 'Mozilla/5.0 (Linux; Android 14; SM-A546E) AppleWebKit/537.36 Chrome/131.0 Mobile Safari/537.36', 'Chrome Mobile', 'Android', '2026-10-04 11:51:01', '2026-10-05 11:51:01', '2026-10-05 11:51:01', 'Cerrada'),
(3, 1, '3aca65994577535703790e92aedaff3994131eb1b1e287983bfb8e05f5f74dc0', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:16:27', '2026-10-13 12:16:27', '2026-10-13 12:16:28', 'Cerrada'),
(4, 1, '064b3908ea8159e62e48c727598a57687d668f0135325c66d70ebb1fc0db38b7', '::1', 'curl/8.21.0', 'Desconocido', 'Desconocida', '2026-10-13 12:16:35', '2026-10-13 12:16:35', NULL, 'Activa'),
(5, 1, '19e59a662a63d2f4df914534ed9fd7ad1887f5beb99ca2fa4958b560aabf9b50', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:16:48', '2026-10-13 12:16:48', NULL, 'Activa'),
(6, 1, '0b0e7fd5ecaad524500006f649386fd8c471a3d07808dca846f75461611e4a6f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', 'Chrome', 'Windows', '2026-10-13 12:17:05', '2026-10-13 12:17:05', '2026-10-13 12:38:33', 'Cerrada'),
(7, 1, 'ce0801c62163dcd3631ba1acd0470fb846006dcdac6324aa7251436242d9a4d3', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:21:54', '2026-10-13 12:21:54', '2026-10-13 12:21:56', 'Cerrada'),
(8, 3, '9f9fa321ddd79a0e9337d6af11ccbae4038eb78c6538287112b14047dffaf87c', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:21:59', '2026-10-13 12:21:59', NULL, 'Activa'),
(9, 9, '28502c751d670fec8b860d7217145ef50680f998a658c3f3d36469e81edffc81', '::1', 'curl/8.21.0', 'Desconocido', 'Desconocida', '2026-10-13 12:24:24', '2026-10-13 12:24:24', NULL, 'Activa'),
(10, 9, '8145138f2861dce60fed45f6516fa2e5908f17ecffeb2f6e14c63b515785db35', '::1', 'curl/8.21.0', 'Desconocido', 'Desconocida', '2026-10-13 12:24:30', '2026-10-13 12:24:30', NULL, 'Activa'),
(11, 9, '71c89b6cc57b0bb797ab84dbb65d78c97c24aaa15ef786598b8f13d20f4436c6', '::1', 'curl/8.21.0', 'Desconocido', 'Desconocida', '2026-10-13 12:24:34', '2026-10-13 12:24:34', NULL, 'Activa'),
(14, 9, 'b309d04c5c2c527fbb1d0c0b6391da04bd978e6af4e61358e913d0cc7f5d76a0', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:35:04', '2026-10-13 12:35:04', NULL, 'Activa'),
(15, 9, '76229dbe2ec2113d8b16054ebb83a5869694b748a666bf32bd2b171718cf1372', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:36:13', '2026-10-13 12:36:13', NULL, 'Activa'),
(16, 9, '0b270083bf92ccdc591e76ed5f23d92837525ea3b6e726e1658412eaf2ae30f2', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:37:06', '2026-10-13 12:37:06', NULL, 'Activa'),
(17, 9, '6af2e97980f3e58d5a7ae513f21b9540b5eb47cb5e591810e979e99fb5b73f39', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:37:45', '2026-10-13 12:37:45', NULL, 'Activa'),
(18, 9, '7fc6964bcd6381e671437ef0ef848065cdff14d70e3c564c4719c217b6f36726', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:37:59', '2026-10-13 12:37:59', NULL, 'Activa'),
(19, 9, '37e1b708858d05596a733b693e0817fa040730d88f09172383b159cb3ea26444', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.141.0 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36', 'Chrome', 'Windows', '2026-10-13 12:38:34', '2026-10-13 12:38:34', '2026-10-13 12:51:38', 'Cerrada'),
(20, 1, 'a8a0cd212d38c199245a6db52063ef88b8745d0463e5ab583fdffdce6df9f2c8', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:42:56', '2026-10-13 12:42:56', '2026-10-13 12:42:58', 'Cerrada'),
(21, 3, '7e354bd9839cd38b02b57c07d28c78d859468bedd2aa7c9a29919a7feb4d3522', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:44:37', '2026-10-13 12:44:37', NULL, 'Activa'),
(22, 1, '2379d7f87eac57d57f040cd3b9cf2c483d22b6afb575897d5cf495127e2e7830', '::1', '', 'Desconocido', 'Desconocida', '2026-10-13 12:45:08', '2026-10-13 12:45:08', NULL, 'Activa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitudes_tramite`
--

CREATE TABLE `solicitudes_tramite` (
  `id_solicitud` int(11) NOT NULL,
  `id_alumno` int(11) DEFAULT NULL,
  `id_pago` int(11) DEFAULT NULL,
  `id_tipo_tramite` int(11) DEFAULT NULL,
  `codigo_seguimiento` varchar(45) DEFAULT NULL,
  `fecha_solicitud` datetime DEFAULT NULL,
  `estado_tramite` varchar(45) DEFAULT NULL,
  `tipo_entrega` varchar(45) NOT NULL DEFAULT 'Digital',
  `fecha_estimada` date DEFAULT NULL,
  `fecha_entrega` datetime DEFAULT NULL,
  `id_usuario_gestion` int(11) DEFAULT NULL,
  `monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `documento_generado_url` varchar(255) DEFAULT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `solicitudes_tramite`
--

INSERT INTO `solicitudes_tramite` (`id_solicitud`, `id_alumno`, `id_pago`, `id_tipo_tramite`, `codigo_seguimiento`, `fecha_solicitud`, `estado_tramite`, `tipo_entrega`, `fecha_estimada`, `fecha_entrega`, `id_usuario_gestion`, `monto`, `creado_en`, `documento_generado_url`, `observaciones`) VALUES
(1, 1, NULL, 1, 'TRA-20261001-0001', '2026-10-01 09:20:00', 'En proceso', 'Digital', '2026-10-03', NULL, NULL, 80000.00, '2026-10-13 10:33:10', NULL, 'Constancia para tramite bancario'),
(2, 3, NULL, 2, 'TRA-20261005-0002', '2026-10-05 15:45:00', 'Pendiente de pago', 'Digital', '2026-10-08', NULL, NULL, 120000.00, '2026-10-13 10:33:10', NULL, 'Certificado de calificaciones'),
(3, 5, 15, 1, 'TRA-20261013-0001', '2026-10-03 09:15:00', 'Entregado', 'Digital', '2026-10-15', '2026-10-13 11:51:01', 9, 80000.00, '2026-10-03 09:15:00', NULL, 'Constancia entregada en ventanilla de secretaria.'),
(4, 5, 17, 2, 'TRA-20261013-0002', '2026-10-09 16:40:00', 'Listo para retirar', 'Digital', '2026-10-16', NULL, 9, 120000.00, '2026-10-09 16:40:00', NULL, 'Listo para retirar en Registro Academico.'),
(5, 5, NULL, 7, 'TRA-20261013-0003', '2026-10-13 11:51:01', 'En proceso', 'Digital', '2026-10-23', NULL, 9, 0.00, '2026-10-13 11:51:01', NULL, 'Solicito evaluar el cambio a Ingenieria Industrial.'),
(6, 5, NULL, 3, 'TRA-20261013-0004', '2026-10-13 11:51:01', 'Pendiente de pago', 'Presencial', '2026-10-18', NULL, NULL, 100000.00, '2026-10-13 11:51:01', NULL, 'Perdi mi credencial universitaria.'),
(7, 2, 21, 1, 'TRA-20261013-0005', '2026-10-13 12:21:59', 'En proceso', 'Digital', '2026-10-15', NULL, NULL, 80000.00, '2026-10-13 12:21:59', NULL, 'Solicitud de prueba automatica'),
(8, 2, 34, 2, 'TRA-20261013-0006', '2026-10-13 12:44:37', 'En proceso', 'Digital', '2026-10-16', NULL, NULL, 120000.00, '2026-10-13 12:44:37', NULL, 'Solicitud de prueba automatica');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `timbrados`
--

CREATE TABLE `timbrados` (
  `id_timbrado` int(11) NOT NULL,
  `id_sede` int(11) DEFAULT NULL,
  `numero_timbrado` varchar(45) DEFAULT NULL,
  `punto_expedicion` varchar(10) DEFAULT NULL,
  `tipo_documento` varchar(45) NOT NULL DEFAULT 'Factura',
  `establecimiento` varchar(10) DEFAULT NULL,
  `fecha_inicio_vigencia` date DEFAULT NULL,
  `fecha_fin_vigencia` date DEFAULT NULL,
  `numero_inicio` int(11) DEFAULT NULL,
  `numero_fin` int(11) DEFAULT NULL,
  `numero_actual` int(11) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `timbrados`
--

INSERT INTO `timbrados` (`id_timbrado`, `id_sede`, `numero_timbrado`, `punto_expedicion`, `tipo_documento`, `establecimiento`, `fecha_inicio_vigencia`, `fecha_fin_vigencia`, `numero_inicio`, `numero_fin`, `numero_actual`, `estado`) VALUES
(1, 1, '12345678', '001', 'Factura', '001', '2026-01-01', '2027-12-31', 1, 5000, 21, 'Activo'),
(2, 2, '87654321', '002', 'Factura', '001', '2026-01-01', '2027-12-31', 1, 5000, 1, 'Activo'),
(3, 1, 'T174508', '003', 'Factura', '001', '2026-01-01', '2026-12-31', 1, 1000, 0, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_tramite`
--

CREATE TABLE `tipos_tramite` (
  `id_tipo_tramite` int(11) NOT NULL,
  `id_concepto_pago` int(11) DEFAULT NULL,
  `nombre_tramite` varchar(145) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `dias_resolucion` int(11) DEFAULT NULL,
  `requiere_aprobacion` tinyint(1) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `tipos_tramite`
--

INSERT INTO `tipos_tramite` (`id_tipo_tramite`, `id_concepto_pago`, `nombre_tramite`, `descripcion`, `dias_resolucion`, `requiere_aprobacion`, `estado`) VALUES
(1, 9, 'Constancia de alumno regular', NULL, 2, 0, 'Activo'),
(2, 10, 'Certificado de calificaciones', NULL, 3, 0, 'Activo'),
(3, 12, 'Duplicado de credencial', NULL, 5, 0, 'Activo'),
(4, 11, 'Título profesional', NULL, 30, 1, 'Activo'),
(5, NULL, 'Certificado de estudios completo', NULL, 7, 1, 'Activo'),
(6, NULL, 'Justificación de inasistencia', NULL, 1, 1, 'Activo'),
(7, NULL, 'Cambio de carrera', NULL, 10, 1, 'Activo'),
(8, 1, 'Tramite ZZ174508', '', 3, 0, 'Activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `user` varchar(95) DEFAULT NULL,
  `email` varchar(145) DEFAULT NULL,
  `id_persona` int(11) DEFAULT NULL,
  `pass` varchar(255) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `ultimo_acceso` datetime DEFAULT NULL,
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  `debe_cambiar_pass` tinyint(1) NOT NULL DEFAULT 0,
  `token_recuerdo` varchar(128) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `id_rol` int(11) DEFAULT NULL,
  `sucursal_cod` varchar(45) DEFAULT NULL,
  `claveprimaria` varchar(45) DEFAULT NULL,
  `sucursal` varchar(45) DEFAULT NULL,
  `facultad` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `user`, `email`, `id_persona`, `pass`, `estado`, `ultimo_acceso`, `intentos_fallidos`, `bloqueado_hasta`, `debe_cambiar_pass`, `token_recuerdo`, `creado_en`, `id_rol`, `sucursal_cod`, `claveprimaria`, `sucursal`, `facultad`) VALUES
(1, 'admin', 'admin@unves.edu.py', 1, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 12:45:08', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 1, '001', NULL, 'Campus Central', 'Todas'),
(2, 'juan.perez', 'juan.perez@unves.edu.py', 2, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 11:07:54', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 2, '001', NULL, 'Campus Central', 'Ingenieria'),
(3, 'maria.lopez', 'maria.lopez@unves.edu.py', 3, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 12:44:37', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 2, '001', NULL, 'Campus Central', 'Ciencias Empresariales'),
(4, 'caja1', 'carlos.ramirez@unves.edu.py', 4, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 11:05:44', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 4, '001', NULL, 'Campus Central', 'Todas'),
(5, 'docente1', 'ana.benitez@unves.edu.py', 5, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 11:06:29', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 3, '001', NULL, 'Campus Central', 'Ingenieria'),
(6, 'secretaria1', 'lucia.gimenez@unves.edu.py', 6, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 11:05:52', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 5, '001', NULL, 'Campus Central', 'Todas'),
(7, 'pedro.martinez', 'pedro.martinez@unves.edu.py', 7, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 11:06:03', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 2, '001', NULL, 'Campus Central', 'Ingenieria'),
(8, 'sofia.cabrera', 'sofia.cabrera@unves.edu.py', 8, '$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W', 'Activo', '2026-10-13 11:06:44', 0, NULL, 0, NULL, '2026-10-13 10:32:58', 2, '001', NULL, 'Campus Central', 'Ciencias Empresariales'),
(9, 'lucia.villalba', 'lucia.villalba@unves.edu.py', 9, '$2y$12$6cdw49oXpfZqG85Jc5CgHeGzzX1YxrBe0.5Xps83w37sWtjPcqLYC', 'Activo', '2026-10-13 12:38:34', 0, NULL, 0, NULL, '2026-10-13 11:51:01', 2, '001', NULL, 'Campus Central', 'Ingenieria'),
(12, 'prb174508', 'usuario174508@test.local', 13, '$2y$12$NcidooD/DMvWTgMZfM9IkeUeUTCA.5Um.VDPBO2shcoo6OpAwjhFm', 'Activo', NULL, 0, NULL, 0, NULL, '2026-10-13 12:45:09', 4, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_rol`
--

CREATE TABLE `usuario_rol` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `usuario_rol`
--

INSERT INTO `usuario_rol` (`id_usuario`, `id_rol`) VALUES
(1, 1),
(2, 2),
(3, 2),
(4, 4),
(5, 3),
(6, 5),
(7, 2),
(8, 2),
(9, 2),
(12, 4),
(13, 4),
(16, 4),
(17, 2),
(17, 4),
(18, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventanas_academicas`
--

CREATE TABLE `ventanas_academicas` (
  `id_ventana` int(11) NOT NULL,
  `nombre` varchar(145) NOT NULL,
  `tipo` varchar(30) NOT NULL COMMENT 'Matricula, Examen, Arancel, Tramite, General',
  `id_periodo` int(11) DEFAULT NULL COMMENT 'NULL = todos los periodos',
  `id_carrera` int(11) DEFAULT NULL COMMENT 'NULL = todas las carreras',
  `id_sede` int(11) DEFAULT NULL COMMENT 'NULL = todas las sedes',
  `fecha_apertura` date NOT NULL,
  `hora_apertura` time DEFAULT '00:00:00',
  `fecha_cierre` date NOT NULL,
  `hora_cierre` time DEFAULT '23:59:59',
  `permite_pago_tardio` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_limite_pago` date DEFAULT NULL COMMENT 'Solo si permite_pago_tardio = 1',
  `recargo_tardio` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Porcentaje sobre el monto',
  `monto_recargo` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Recargo fijo en guaranies',
  `aviso` varchar(255) DEFAULT NULL COMMENT 'Mensaje que ve el alumno',
  `estado` varchar(20) NOT NULL DEFAULT 'Activo' COMMENT 'Activo, Inactivo',
  `observaciones` varchar(255) DEFAULT NULL,
  `id_usuario_gestion` int(11) DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `ventanas_academicas`
--

INSERT INTO `ventanas_academicas` (`id_ventana`, `nombre`, `tipo`, `id_periodo`, `id_carrera`, `id_sede`, `fecha_apertura`, `hora_apertura`, `fecha_cierre`, `hora_cierre`, `permite_pago_tardio`, `fecha_limite_pago`, `recargo_tardio`, `monto_recargo`, `aviso`, `estado`, `observaciones`, `id_usuario_gestion`, `creado_en`, `actualizado_en`) VALUES
(1, 'Matriculación 2026-2 (general)', 'Matricula', 3, NULL, NULL, '2026-07-01', '00:00:00', '2026-08-15', '23:59:59', 1, '2027-03-31', 10.00, 0.00, 'El plazo ordinario venció. Podés matricularte con un recargo del 10% hasta el 31/03/2027.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(2, 'Matriculación 2026-2 - Ingeniería en Informática', 'Matricula', 3, 4, 1, '2026-09-01', '00:00:00', '2026-12-05', '23:59:59', 1, '2027-02-28', 5.00, 0.00, 'Matriculación extraordinaria habilitada para Ingeniería en Informática hasta el 05/12/2026.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(3, 'Inscripción y pago de exámenes 2026-2', 'Examen', 3, NULL, NULL, '2026-09-15', '00:00:00', '2026-11-25', '23:59:59', 1, '2026-12-05', 10.00, 50000.00, 'Podés inscribirte y pagar mesas finales hasta el 25/11/2026. Después se aplica un recargo del 10% más Gs. 50.000.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(4, 'Aranceles 2026-2', 'Arancel', 3, NULL, NULL, '2026-07-20', '00:00:00', '2026-12-18', '23:59:59', 1, '2027-03-31', 8.00, 0.00, 'Los aranceles del periodo se pueden pagar en línea hasta el 18/12/2026. Luego se aplica un recargo del 8%.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(5, 'Trámites y documentos 2026-2', 'Tramite', 3, NULL, NULL, '2026-07-20', '00:00:00', '2026-12-18', '23:59:59', 0, NULL, 0.00, 0.00, 'Solicitud de constancias y certificados habilitada hasta el 18/12/2026.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(6, 'Matriculación 2026-1', 'Matricula', 2, NULL, NULL, '2026-01-26', '00:00:00', '2026-02-20', '23:59:59', 0, NULL, 0.00, 0.00, 'El plazo de matriculación del primer semestre 2026 ya finalizó.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(7, 'Inscripción y pago de exámenes 2026-1', 'Examen', 2, NULL, NULL, '2026-05-04', '00:00:00', '2026-06-15', '23:59:59', 0, NULL, 0.00, 0.00, 'Las mesas finales del primer semestre 2026 están cerradas.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(8, 'Matriculación 2025-2', 'Matricula', 1, NULL, NULL, '2025-07-01', '00:00:00', '2025-08-20', '23:59:59', 0, NULL, 0.00, 0.00, 'Periodo cerrado.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(9, 'Matriculación 2027-1', 'Matricula', 4, NULL, NULL, '2027-01-25', '00:00:00', '2027-02-26', '23:59:59', 0, NULL, 0.00, 0.00, 'Matriculación del primer semestre 2027: del 25/01 al 26/02/2027.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:18:39'),
(10, 'Aranceles 2027-1', 'Arancel', 4, NULL, NULL, '2027-02-01', '00:00:00', '2027-07-16', '23:59:59', 1, '2027-08-31', 8.00, 0.00, 'Aranceles del primer semestre 2027.', 'Activo', NULL, NULL, '2026-10-13 12:06:38', '2026-10-13 12:06:38');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD PRIMARY KEY (`id_alumno`),
  ADD UNIQUE KEY `uk_alumno_persona` (`id_persona`),
  ADD UNIQUE KEY `uk_alumno_legajo` (`legajo`),
  ADD UNIQUE KEY `uk_alumno_codigo` (`codigo_externo`),
  ADD KEY `idx_alumno_carrera` (`id_carrera`),
  ADD KEY `idx_alumno_facultad` (`id_facultades`),
  ADD KEY `idx_alumno_sede` (`id_sede`),
  ADD KEY `idx_alumno_estado` (`estado_academico`);

--
-- Indices de la tabla `alumno_beca`
--
ALTER TABLE `alumno_beca`
  ADD PRIMARY KEY (`id_alumno_beca`),
  ADD KEY `id_beca` (`id_beca`),
  ADD KEY `id_periodo` (`id_periodo`);

--
-- Indices de la tabla `api_sincronizaciones`
--
ALTER TABLE `api_sincronizaciones`
  ADD PRIMARY KEY (`id_sync`),
  ADD KEY `idx_sync_tipo` (`tipo_dato`),
  ADD KEY `idx_sync_fecha` (`fecha_inicio`);

--
-- Indices de la tabla `aranceles`
--
ALTER TABLE `aranceles`
  ADD PRIMARY KEY (`id_arancel`),
  ADD KEY `id_concepto_pago` (`id_concepto_pago`),
  ADD KEY `id_carrera` (`id_carrera`),
  ADD KEY `id_periodo` (`id_periodo`);

--
-- Indices de la tabla `auditorias`
--
ALTER TABLE `auditorias`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `becas`
--
ALTER TABLE `becas`
  ADD PRIMARY KEY (`id_beca`);

--
-- Indices de la tabla `carreras`
--
ALTER TABLE `carreras`
  ADD PRIMARY KEY (`id_carrera`),
  ADD KEY `fk_carrera_facultad` (`id_facultades`);

--
-- Indices de la tabla `carrera_sede`
--
ALTER TABLE `carrera_sede`
  ADD PRIMARY KEY (`id_carrera_sede`),
  ADD UNIQUE KEY `uk_carrera_sede` (`id_carrera`,`id_sede`),
  ADD KEY `fk_cs_sede` (`id_sede`);

--
-- Indices de la tabla `carrito_items`
--
ALTER TABLE `carrito_items`
  ADD PRIMARY KEY (`id_item`),
  ADD UNIQUE KEY `uk_carrito_usuario_obligacion` (`id_usuario`,`id_obligacion`),
  ADD KEY `idx_carrito_obligacion` (`id_obligacion`);

--
-- Indices de la tabla `ciudades`
--
ALTER TABLE `ciudades`
  ADD PRIMARY KEY (`id_ciudades`);

--
-- Indices de la tabla `comprobantes`
--
ALTER TABLE `comprobantes`
  ADD PRIMARY KEY (`id_comprobante`),
  ADD UNIQUE KEY `uk_comprobante_numero` (`numero`),
  ADD KEY `idx_comprobante_pago` (`id_pago`);

--
-- Indices de la tabla `conceptos_pago`
--
ALTER TABLE `conceptos_pago`
  ADD PRIMARY KEY (`id_concepto_pago`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `cursos_academicos`
--
ALTER TABLE `cursos_academicos`
  ADD PRIMARY KEY (`id_curso`),
  ADD UNIQUE KEY `uk_curso_division` (`id_carrera`,`id_periodo`,`curso`,`semestre`,`seccion`,`id_sede`),
  ADD KEY `idx_curso_periodo` (`id_periodo`,`estado`),
  ADD KEY `fk_curso_sede` (`id_sede`),
  ADD KEY `fk_curso_malla` (`id_malla`);

--
-- Indices de la tabla `datos_fiscales`
--
ALTER TABLE `datos_fiscales`
  ADD PRIMARY KEY (`id_datos_fiscales`),
  ADD KEY `id_persona` (`id_persona`);

--
-- Indices de la tabla `examenes`
--
ALTER TABLE `examenes`
  ADD PRIMARY KEY (`id_examen`),
  ADD KEY `idx_examen_periodo` (`id_periodo`),
  ADD KEY `idx_examen_fecha` (`fecha_examen`),
  ADD KEY `idx_examen_estado` (`estado`),
  ADD KEY `fk_examen_carrera` (`id_carrera`),
  ADD KEY `fk_examen_sede` (`id_sede`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id_factura`),
  ADD KEY `id_carrera` (`id_carrera`),
  ADD KEY `id_sede` (`id_sede`),
  ADD KEY `fk_factura_pago` (`id_pago`);

--
-- Indices de la tabla `factura_detalles`
--
ALTER TABLE `factura_detalles`
  ADD PRIMARY KEY (`id_factura_detalle`),
  ADD KEY `id_factura` (`id_factura`);

--
-- Indices de la tabla `facultades`
--
ALTER TABLE `facultades`
  ADD PRIMARY KEY (`id_facultades`);

--
-- Indices de la tabla `gateway_logs`
--
ALTER TABLE `gateway_logs`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `id_pago` (`id_pago`);

--
-- Indices de la tabla `inscripciones_examen`
--
ALTER TABLE `inscripciones_examen`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD UNIQUE KEY `uk_inscripcion_examen_alumno` (`id_examen`,`id_alumno`),
  ADD KEY `idx_inscripcion_alumno` (`id_alumno`),
  ADD KEY `fk_insc_pago` (`id_pago`);

--
-- Indices de la tabla `logs_actividad`
--
ALTER TABLE `logs_actividad`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `idx_log_usuario` (`id_usuario`),
  ADD KEY `idx_log_fecha` (`fecha_hora`),
  ADD KEY `idx_log_modulo` (`modulo`);

--
-- Indices de la tabla `mallas_curriculares`
--
ALTER TABLE `mallas_curriculares`
  ADD PRIMARY KEY (`id_malla`),
  ADD UNIQUE KEY `uk_malla_carrera_nombre` (`id_carrera`,`nombre`),
  ADD KEY `idx_malla_carrera` (`id_carrera`,`vigente`);

--
-- Indices de la tabla `materias`
--
ALTER TABLE `materias`
  ADD PRIMARY KEY (`id_materia`),
  ADD UNIQUE KEY `uk_materia_malla_codigo` (`id_malla`,`codigo`),
  ADD KEY `idx_materia_ubicacion` (`id_carrera`,`curso`,`semestre`),
  ADD KEY `idx_materia_global` (`id_carrera`,`semestre_global`);

--
-- Indices de la tabla `matriculas`
--
ALTER TABLE `matriculas`
  ADD PRIMARY KEY (`id_matricula`),
  ADD UNIQUE KEY `uk_matricula_numero` (`numero_matricula`),
  ADD UNIQUE KEY `uk_matricula_alumno_periodo` (`id_alumno`,`id_periodo`),
  ADD KEY `idx_matricula_periodo` (`id_periodo`),
  ADD KEY `idx_matricula_estado` (`estado`),
  ADD KEY `fk_matricula_carrera` (`id_carrera`),
  ADD KEY `fk_matricula_sede` (`id_sede`),
  ADD KEY `idx_matricula_malla` (`id_malla`),
  ADD KEY `idx_matricula_curso` (`id_curso`);

--
-- Indices de la tabla `matricula_materias`
--
ALTER TABLE `matricula_materias`
  ADD PRIMARY KEY (`id_matricula_materia`),
  ADD UNIQUE KEY `uk_matricula_materia` (`id_matricula`,`id_materia`),
  ADD KEY `idx_mm_materia` (`id_materia`),
  ADD KEY `fk_mm_curso` (`id_curso`);

--
-- Indices de la tabla `mensajes_contacto`
--
ALTER TABLE `mensajes_contacto`
  ADD PRIMARY KEY (`id_mensaje`),
  ADD KEY `idx_mensaje_estado` (`estado`),
  ADD KEY `idx_mensaje_usuario` (`id_usuario`);

--
-- Indices de la tabla `metodos_pago`
--
ALTER TABLE `metodos_pago`
  ADD PRIMARY KEY (`id_metodo_pago`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `idx_notif_usuario` (`id_usuario`,`leida`);

--
-- Indices de la tabla `obligaciones_pago`
--
ALTER TABLE `obligaciones_pago`
  ADD PRIMARY KEY (`id_obligacion`),
  ADD KEY `id_concepto_pago` (`id_concepto_pago`),
  ADD KEY `id_periodo` (`id_periodo`),
  ADD KEY `id_arancel` (`id_arancel`),
  ADD KEY `idx_oblig_alumno` (`id_alumno`),
  ADD KEY `idx_oblig_estado` (`estado`),
  ADD KEY `idx_oblig_vence` (`fecha_vencimiento`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `id_metodo_pago` (`id_metodo_pago`),
  ADD KEY `idx_pagos_alumno` (`id_alumno`),
  ADD KEY `idx_pagos_estado` (`estado_pago`),
  ADD KEY `idx_pagos_fecha` (`fecha_pago`),
  ADD KEY `idx_pagos_usuario` (`id_usuario`);

--
-- Indices de la tabla `pago_detalles`
--
ALTER TABLE `pago_detalles`
  ADD PRIMARY KEY (`id_pago_detalle`),
  ADD KEY `id_pago` (`id_pago`);

--
-- Indices de la tabla `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id_reset`),
  ADD UNIQUE KEY `uk_reset_token` (`token`),
  ADD KEY `idx_reset_usuario` (`id_usuario`);

--
-- Indices de la tabla `periodos_academicos`
--
ALTER TABLE `periodos_academicos`
  ADD PRIMARY KEY (`id_periodo`);

--
-- Indices de la tabla `personas`
--
ALTER TABLE `personas`
  ADD PRIMARY KEY (`id_persona`),
  ADD KEY `id_ciudades` (`id_ciudades`);

--
-- Indices de la tabla `plantillas_documento`
--
ALTER TABLE `plantillas_documento`
  ADD PRIMARY KEY (`id_plantilla`),
  ADD KEY `idx_plantilla_tramite` (`id_tipo_tramite`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `sedes`
--
ALTER TABLE `sedes`
  ADD PRIMARY KEY (`id_sede`),
  ADD KEY `id_ciudades` (`id_ciudades`);

--
-- Indices de la tabla `sesiones_web`
--
ALTER TABLE `sesiones_web`
  ADD PRIMARY KEY (`id_sesion`),
  ADD UNIQUE KEY `uk_sesion_token` (`token`),
  ADD KEY `idx_sesion_usuario` (`id_usuario`);

--
-- Indices de la tabla `solicitudes_tramite`
--
ALTER TABLE `solicitudes_tramite`
  ADD PRIMARY KEY (`id_solicitud`),
  ADD UNIQUE KEY `uk_solicitud_codigo` (`codigo_seguimiento`),
  ADD KEY `id_pago` (`id_pago`),
  ADD KEY `id_tipo_tramite` (`id_tipo_tramite`);

--
-- Indices de la tabla `timbrados`
--
ALTER TABLE `timbrados`
  ADD PRIMARY KEY (`id_timbrado`),
  ADD KEY `id_sede` (`id_sede`);

--
-- Indices de la tabla `tipos_tramite`
--
ALTER TABLE `tipos_tramite`
  ADD PRIMARY KEY (`id_tipo_tramite`),
  ADD KEY `id_concepto_pago` (`id_concepto_pago`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `uk_usuario_email` (`email`),
  ADD KEY `id_persona` (`id_persona`),
  ADD KEY `fk_usuario_rol` (`id_rol`);

--
-- Indices de la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD PRIMARY KEY (`id_usuario`,`id_rol`),
  ADD KEY `id_rol` (`id_rol`);

--
-- Indices de la tabla `ventanas_academicas`
--
ALTER TABLE `ventanas_academicas`
  ADD PRIMARY KEY (`id_ventana`),
  ADD KEY `idx_ventana_busqueda` (`tipo`,`id_periodo`,`estado`),
  ADD KEY `idx_ventana_fechas` (`fecha_apertura`,`fecha_cierre`),
  ADD KEY `fk_ventana_periodo` (`id_periodo`),
  ADD KEY `fk_ventana_carrera` (`id_carrera`),
  ADD KEY `fk_ventana_sede` (`id_sede`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  MODIFY `id_alumno` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `alumno_beca`
--
ALTER TABLE `alumno_beca`
  MODIFY `id_alumno_beca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `api_sincronizaciones`
--
ALTER TABLE `api_sincronizaciones`
  MODIFY `id_sync` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `aranceles`
--
ALTER TABLE `aranceles`
  MODIFY `id_arancel` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `auditorias`
--
ALTER TABLE `auditorias`
  MODIFY `id_auditoria` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `becas`
--
ALTER TABLE `becas`
  MODIFY `id_beca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `carreras`
--
ALTER TABLE `carreras`
  MODIFY `id_carrera` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `carrera_sede`
--
ALTER TABLE `carrera_sede`
  MODIFY `id_carrera_sede` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT de la tabla `carrito_items`
--
ALTER TABLE `carrito_items`
  MODIFY `id_item` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `ciudades`
--
ALTER TABLE `ciudades`
  MODIFY `id_ciudades` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `comprobantes`
--
ALTER TABLE `comprobantes`
  MODIFY `id_comprobante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `conceptos_pago`
--
ALTER TABLE `conceptos_pago`
  MODIFY `id_concepto_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `cursos_academicos`
--
ALTER TABLE `cursos_academicos`
  MODIFY `id_curso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de la tabla `datos_fiscales`
--
ALTER TABLE `datos_fiscales`
  MODIFY `id_datos_fiscales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `examenes`
--
ALTER TABLE `examenes`
  MODIFY `id_examen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `factura_detalles`
--
ALTER TABLE `factura_detalles`
  MODIFY `id_factura_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `facultades`
--
ALTER TABLE `facultades`
  MODIFY `id_facultades` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `gateway_logs`
--
ALTER TABLE `gateway_logs`
  MODIFY `id_log` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT de la tabla `inscripciones_examen`
--
ALTER TABLE `inscripciones_examen`
  MODIFY `id_inscripcion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `logs_actividad`
--
ALTER TABLE `logs_actividad`
  MODIFY `id_log` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=182;

--
-- AUTO_INCREMENT de la tabla `mallas_curriculares`
--
ALTER TABLE `mallas_curriculares`
  MODIFY `id_malla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `materias`
--
ALTER TABLE `materias`
  MODIFY `id_materia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=290;

--
-- AUTO_INCREMENT de la tabla `matriculas`
--
ALTER TABLE `matriculas`
  MODIFY `id_matricula` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `matricula_materias`
--
ALTER TABLE `matricula_materias`
  MODIFY `id_matricula_materia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `mensajes_contacto`
--
ALTER TABLE `mensajes_contacto`
  MODIFY `id_mensaje` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `metodos_pago`
--
ALTER TABLE `metodos_pago`
  MODIFY `id_metodo_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT de la tabla `obligaciones_pago`
--
ALTER TABLE `obligaciones_pago`
  MODIFY `id_obligacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT de la tabla `pago_detalles`
--
ALTER TABLE `pago_detalles`
  MODIFY `id_pago_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT de la tabla `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id_reset` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `periodos_academicos`
--
ALTER TABLE `periodos_academicos`
  MODIFY `id_periodo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `personas`
--
ALTER TABLE `personas`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `plantillas_documento`
--
ALTER TABLE `plantillas_documento`
  MODIFY `id_plantilla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `sedes`
--
ALTER TABLE `sedes`
  MODIFY `id_sede` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `sesiones_web`
--
ALTER TABLE `sesiones_web`
  MODIFY `id_sesion` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `solicitudes_tramite`
--
ALTER TABLE `solicitudes_tramite`
  MODIFY `id_solicitud` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `timbrados`
--
ALTER TABLE `timbrados`
  MODIFY `id_timbrado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipos_tramite`
--
ALTER TABLE `tipos_tramite`
  MODIFY `id_tipo_tramite` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `ventanas_academicas`
--
ALTER TABLE `ventanas_academicas`
  MODIFY `id_ventana` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD CONSTRAINT `fk_alumno_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_alumno_facultad` FOREIGN KEY (`id_facultades`) REFERENCES `facultades` (`id_facultades`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_alumno_persona` FOREIGN KEY (`id_persona`) REFERENCES `personas` (`id_persona`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_alumno_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL;

--
-- Filtros para la tabla `alumno_beca`
--
ALTER TABLE `alumno_beca`
  ADD CONSTRAINT `alumno_beca_ibfk_1` FOREIGN KEY (`id_beca`) REFERENCES `becas` (`id_beca`),
  ADD CONSTRAINT `alumno_beca_ibfk_2` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`);

--
-- Filtros para la tabla `aranceles`
--
ALTER TABLE `aranceles`
  ADD CONSTRAINT `aranceles_ibfk_1` FOREIGN KEY (`id_concepto_pago`) REFERENCES `conceptos_pago` (`id_concepto_pago`),
  ADD CONSTRAINT `aranceles_ibfk_2` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`),
  ADD CONSTRAINT `aranceles_ibfk_3` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`);

--
-- Filtros para la tabla `auditorias`
--
ALTER TABLE `auditorias`
  ADD CONSTRAINT `auditorias_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `carreras`
--
ALTER TABLE `carreras`
  ADD CONSTRAINT `fk_carrera_facultad` FOREIGN KEY (`id_facultades`) REFERENCES `facultades` (`id_facultades`);

--
-- Filtros para la tabla `carrera_sede`
--
ALTER TABLE `carrera_sede`
  ADD CONSTRAINT `fk_cs_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cs_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`) ON DELETE CASCADE;

--
-- Filtros para la tabla `carrito_items`
--
ALTER TABLE `carrito_items`
  ADD CONSTRAINT `fk_carrito_obligacion` FOREIGN KEY (`id_obligacion`) REFERENCES `obligaciones_pago` (`id_obligacion`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_carrito_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `comprobantes`
--
ALTER TABLE `comprobantes`
  ADD CONSTRAINT `fk_comprobante_pago` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`) ON DELETE CASCADE;

--
-- Filtros para la tabla `cursos_academicos`
--
ALTER TABLE `cursos_academicos`
  ADD CONSTRAINT `fk_curso_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_curso_malla` FOREIGN KEY (`id_malla`) REFERENCES `mallas_curriculares` (`id_malla`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_curso_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_curso_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL;

--
-- Filtros para la tabla `datos_fiscales`
--
ALTER TABLE `datos_fiscales`
  ADD CONSTRAINT `datos_fiscales_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `personas` (`id_persona`);

--
-- Filtros para la tabla `examenes`
--
ALTER TABLE `examenes`
  ADD CONSTRAINT `fk_examen_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_examen_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_examen_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL;

--
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `facturas_ibfk_1` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`),
  ADD CONSTRAINT `facturas_ibfk_2` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`),
  ADD CONSTRAINT `fk_factura_pago` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`);

--
-- Filtros para la tabla `factura_detalles`
--
ALTER TABLE `factura_detalles`
  ADD CONSTRAINT `factura_detalles_ibfk_1` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`);

--
-- Filtros para la tabla `gateway_logs`
--
ALTER TABLE `gateway_logs`
  ADD CONSTRAINT `gateway_logs_ibfk_1` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`);

--
-- Filtros para la tabla `inscripciones_examen`
--
ALTER TABLE `inscripciones_examen`
  ADD CONSTRAINT `fk_insc_alumno` FOREIGN KEY (`id_alumno`) REFERENCES `alumnos` (`id_alumno`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_insc_examen` FOREIGN KEY (`id_examen`) REFERENCES `examenes` (`id_examen`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_insc_pago` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`) ON DELETE SET NULL;

--
-- Filtros para la tabla `mallas_curriculares`
--
ALTER TABLE `mallas_curriculares`
  ADD CONSTRAINT `fk_malla_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE;

--
-- Filtros para la tabla `materias`
--
ALTER TABLE `materias`
  ADD CONSTRAINT `fk_materia_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_materia_malla` FOREIGN KEY (`id_malla`) REFERENCES `mallas_curriculares` (`id_malla`) ON DELETE CASCADE;

--
-- Filtros para la tabla `matriculas`
--
ALTER TABLE `matriculas`
  ADD CONSTRAINT `fk_matricula_alumno` FOREIGN KEY (`id_alumno`) REFERENCES `alumnos` (`id_alumno`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_matricula_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_matricula_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_matricula_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`) ON DELETE SET NULL;

--
-- Filtros para la tabla `matricula_materias`
--
ALTER TABLE `matricula_materias`
  ADD CONSTRAINT `fk_mm_curso` FOREIGN KEY (`id_curso`) REFERENCES `cursos_academicos` (`id_curso`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mm_materia` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id_materia`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mm_matricula` FOREIGN KEY (`id_matricula`) REFERENCES `matriculas` (`id_matricula`) ON DELETE CASCADE;

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `fk_notif_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `obligaciones_pago`
--
ALTER TABLE `obligaciones_pago`
  ADD CONSTRAINT `obligaciones_pago_ibfk_1` FOREIGN KEY (`id_concepto_pago`) REFERENCES `conceptos_pago` (`id_concepto_pago`),
  ADD CONSTRAINT `obligaciones_pago_ibfk_2` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`),
  ADD CONSTRAINT `obligaciones_pago_ibfk_3` FOREIGN KEY (`id_arancel`) REFERENCES `aranceles` (`id_arancel`);

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodos_pago` (`id_metodo_pago`),
  ADD CONSTRAINT `pagos_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `pago_detalles`
--
ALTER TABLE `pago_detalles`
  ADD CONSTRAINT `pago_detalles_ibfk_1` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`);

--
-- Filtros para la tabla `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `fk_reset_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `personas`
--
ALTER TABLE `personas`
  ADD CONSTRAINT `personas_ibfk_1` FOREIGN KEY (`id_ciudades`) REFERENCES `ciudades` (`id_ciudades`);

--
-- Filtros para la tabla `sedes`
--
ALTER TABLE `sedes`
  ADD CONSTRAINT `sedes_ibfk_1` FOREIGN KEY (`id_ciudades`) REFERENCES `ciudades` (`id_ciudades`);

--
-- Filtros para la tabla `sesiones_web`
--
ALTER TABLE `sesiones_web`
  ADD CONSTRAINT `fk_sesion_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `solicitudes_tramite`
--
ALTER TABLE `solicitudes_tramite`
  ADD CONSTRAINT `solicitudes_tramite_ibfk_1` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id_pago`),
  ADD CONSTRAINT `solicitudes_tramite_ibfk_2` FOREIGN KEY (`id_tipo_tramite`) REFERENCES `tipos_tramite` (`id_tipo_tramite`);

--
-- Filtros para la tabla `timbrados`
--
ALTER TABLE `timbrados`
  ADD CONSTRAINT `timbrados_ibfk_1` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`);

--
-- Filtros para la tabla `tipos_tramite`
--
ALTER TABLE `tipos_tramite`
  ADD CONSTRAINT `tipos_tramite_ibfk_1` FOREIGN KEY (`id_concepto_pago`) REFERENCES `conceptos_pago` (`id_concepto_pago`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`),
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `personas` (`id_persona`);

--
-- Filtros para la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD CONSTRAINT `usuario_rol_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `usuario_rol_ibfk_2` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);

--
-- Filtros para la tabla `ventanas_academicas`
--
ALTER TABLE `ventanas_academicas`
  ADD CONSTRAINT `fk_ventana_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carreras` (`id_carrera`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ventana_periodo` FOREIGN KEY (`id_periodo`) REFERENCES `periodos_academicos` (`id_periodo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ventana_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
