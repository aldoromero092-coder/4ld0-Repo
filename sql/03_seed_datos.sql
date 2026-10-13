-- =====================================================================
--  SISTEMA DE GESTION ACADEMICA UNVES - DATOS SEMILLA (DEMO)
--  Archivo : sql/03_seed_datos.sql
--  Objetivo: Catálogos base + datos de demostración funcionales.
--  Clave de todos los usuarios de demo : Unves.2026
--  Nota    : Script IDEMPOTENTE (ON DUPLICATE KEY UPDATE).
-- =====================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- ROLES
-- ---------------------------------------------------------------------
INSERT INTO `roles` (`id_rol`,`nombre`,`descripcion`,`estado`) VALUES
  (1,'Administrador','Acceso total al sistema','Activo'),
  (2,'Alumno','Portal del estudiante','Activo'),
  (3,'Docente','Consulta academica y actas','Activo'),
  (4,'Cajero','Registro de pagos en ventanilla','Activo'),
  (5,'Secretaria','Gestion de tramites y matriculas','Activo'),
  (6,'Finanzas','Aranceles, becas y reportes de recaudacion','Activo'),
  (7,'Consulta','Acceso de solo lectura','Activo')
ON DUPLICATE KEY UPDATE `descripcion`=VALUES(`descripcion`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- CONFIGURACION DEL SISTEMA
-- ---------------------------------------------------------------------
INSERT INTO `configuracion` (`clave`,`valor`,`tipo`,`grupo`,`descripcion`) VALUES
  ('app_nombre','Sistema de Gestion Academica','texto','general','Nombre mostrado del sistema'),
  ('app_siglas','UNVES','texto','general','Siglas de la universidad'),
  ('app_institucion','Universidad Nacional de Villarrica del Espiritu Santo','texto','general','Razon social'),
  ('app_ruc','80012345-6','texto','general','RUC institucional'),
  ('app_moneda','PYG','texto','pagos','Moneda del sistema'),
  ('app_moneda_simbolo','Gs.','texto','pagos','Simbolo de moneda'),
  ('app_zona_horaria','America/Asuncion','texto','general','Zona horaria'),
  ('whatsapp_numero','595991461220','texto','contacto','WhatsApp de atencion'),
  ('whatsapp_mensaje','Hola, me comunico desde el portal de pagos de la UNVES.','texto','contacto','Mensaje precargado'),
  ('contacto_email','pagos@unves.edu.py','texto','contacto','Correo de atencion'),
  ('contacto_telefono','+595 991 461 220','texto','contacto','Telefono de atencion'),
  ('iva_general','10','numero','facturacion','Porcentaje de IVA general'),
  ('mora_diaria_defecto','2000','numero','pagos','Mora diaria por defecto (Gs)'),
  ('dias_gracia_defecto','5','numero','pagos','Dias de gracia antes de aplicar mora'),
  ('pasarela_activa','sandbox','texto','pagos','Pasarela de pago activa'),
  ('pasarela_modo','pruebas','texto','pagos','pruebas | produccion'),
  ('matricula_online_activa','1','booleano','matriculas','Permitir matricula por web'),
  ('api_universidad_url','','texto','integracion','Endpoint del sistema central'),
  ('api_universidad_token','','texto','integracion','Token Bearer de la API'),
  ('api_sync_automatica','0','booleano','integracion','Sincronizacion programada'),
  ('app_logo','','texto','general','Ruta del logo institucional (vacio = deteccion automatica)'),
  ('app_logo_claro','','texto','general','Variante del logo para fondos oscuros'),
  ('app_favicon','','texto','general','Icono de la pestana del navegador')
ON DUPLICATE KEY UPDATE `valor`=VALUES(`valor`),`grupo`=VALUES(`grupo`),`descripcion`=VALUES(`descripcion`);

-- ---------------------------------------------------------------------
-- CIUDADES
-- ---------------------------------------------------------------------
INSERT INTO `ciudades` (`id_ciudades`,`nombre`,`id_departamento`,`estado`) VALUES
  (1,'Villarrica',NULL,'Activo'),
  (2,'Asuncion',NULL,'Activo'),
  (3,'Encarnacion',NULL,'Activo'),
  (4,'Ciudad del Este',NULL,'Activo'),
  (5,'Coronel Oviedo',NULL,'Activo'),
  (6,'Caaguazu',NULL,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`);

-- ---------------------------------------------------------------------
-- SEDES
-- ---------------------------------------------------------------------
INSERT INTO `sedes` (`id_sede`,`nombre`,`direccion`,`telefono`,`id_ciudades`,`estado`) VALUES
  (1,'Campus Central - Villarrica','Ruta 8 Km 3, Villarrica','+595 991 461 220',1,'Activo'),
  (2,'Filial Asuncion','Av. Mariscal Lopez 1234, Asuncion','+595 981 220 110',2,'Activo'),
  (3,'Filial Encarnacion','Av. Costanera 450, Encarnacion','+595 983 330 220',3,'Activo'),
  (4,'Filial Ciudad del Este','Av. San Blas 890, CDE','+595 984 440 330',4,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`direccion`=VALUES(`direccion`),`telefono`=VALUES(`telefono`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- FACULTADES
-- ---------------------------------------------------------------------
INSERT INTO `facultades` (`id_facultades`,`nombre`,`id_sede`,`estado`) VALUES
  (1,'Facultad de Ciencias Empresariales',1,'Activo'),
  (2,'Facultad de Ingenieria',1,'Activo'),
  (3,'Facultad de Ciencias de la Salud',1,'Activo'),
  (4,'Facultad de Ciencias Juridicas',2,'Activo'),
  (5,'Facultad de Humanidades',3,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`id_sede`=VALUES(`id_sede`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- CARRERAS
-- ---------------------------------------------------------------------
INSERT INTO `carreras` (`id_carrera`,`codigo_carrera`,`nombre`,`id_facultades`,`duracion_anio`,`estado`) VALUES
  (1,'ADM','Administracion de Empresas',1,5,'Activo'),
  (2,'CON','Contabilidad Publica',1,5,'Activo'),
  (3,'ECO','Economia',1,5,'Activo'),
  (4,'ISI','Ingenieria en Sistemas Informaticos',2,5,'Activo'),
  (5,'IND','Ingenieria Industrial',2,5,'Activo'),
  (6,'CIV','Ingenieria Civil',2,5,'Activo'),
  (7,'ENF','Enfermeria',3,5,'Activo'),
  (8,'MED','Medicina',3,6,'Activo'),
  (9,'ODE','Odontologia',3,5,'Activo'),
  (10,'DER','Derecho',4,5,'Activo'),
  (11,'PSI','Psicologia',5,5,'Activo'),
  (12,'EDU','Ciencias de la Educacion',5,4,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`codigo_carrera`=VALUES(`codigo_carrera`),`id_facultades`=VALUES(`id_facultades`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- PERIODOS ACADEMICOS
-- ---------------------------------------------------------------------
INSERT INTO `periodos_academicos` (`id_periodo`,`nombre`,`fecha_inicio`,`fecha_fin`,`estado`) VALUES
  (1,'2025 - Segundo Semestre','2025-07-01','2025-12-20','Cerrado'),
  (2,'2026 - Primer Semestre','2026-02-02','2026-07-17','Cerrado'),
  (3,'2026 - Segundo Semestre','2026-07-20','2026-12-18','Activo'),
  (4,'2027 - Primer Semestre','2027-02-01','2027-07-16','Planificado')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`fecha_inicio`=VALUES(`fecha_inicio`),`fecha_fin`=VALUES(`fecha_fin`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- CONCEPTOS DE PAGO
-- ---------------------------------------------------------------------
INSERT INTO `conceptos_pago` (`id_concepto_pago`,`codigo`,`nombre`,`descripcion`,`es_recurrente`,`categoria`,`orden`,`estado`) VALUES
  (1,'MAT','Matricula ordinaria','Matriculacion por periodo',1,'Matricula',1,'Activo'),
  (2,'MAT-RE','Matricula de reinscripcion','Reinscripcion de alumnos regulares',1,'Matricula',2,'Activo'),
  (3,'ARA','Arancel mensual','Cuota mensual de carrera',1,'Arancel',3,'Activo'),
  (4,'LAB','Uso de laboratorio','Derecho de laboratorio',1,'Arancel',4,'Activo'),
  (5,'EXA-INI','Examen de ingreso','Examen de admision',0,'Examen',5,'Activo'),
  (6,'EXA-FIN','Examen final','Derecho a mesa final',1,'Examen',6,'Activo'),
  (7,'EXA-REC','Examen recuperatorio','Derecho a recuperatorio',1,'Examen',7,'Activo'),
  (8,'EXA-TIT','Examen de titulacion','Defensa de tesis',0,'Examen',8,'Activo'),
  (9,'TRA-CON','Constancia de estudios','Constancia de alumno regular',0,'Tramite',9,'Activo'),
  (10,'TRA-NOT','Certificado de calificaciones','Analitico parcial',0,'Tramite',10,'Activo'),
  (11,'TRA-TIT','Titulo profesional','Emision de titulo',0,'Tramite',11,'Activo'),
  (12,'TRA-DUP','Duplicado de documentos','Segunda emision',0,'Tramite',12,'Activo'),
  (13,'KIT','Kit universitario','Credencial y materiales',1,'General',13,'Activo'),
  (14,'MUL','Multa por mora','Recargo por atraso',0,'General',14,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`codigo`=VALUES(`codigo`),`categoria`=VALUES(`categoria`),`orden`=VALUES(`orden`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- METODOS DE PAGO
-- ---------------------------------------------------------------------
INSERT INTO `metodos_pago` (`id_metodo_pago`,`nombre`,`tipo`,`estado`) VALUES
  (1,'Efectivo','Contado','Activo'),
  (2,'Transferencia bancaria','Transferencia','Activo'),
  (3,'Tarjeta de credito','Credito','Activo'),
  (4,'Tarjeta de debito','Debito','Activo'),
  (5,'Tigo Money','Billetera electronica','Activo'),
  (6,'Personal Pay','Billetera electronica','Activo'),
  (7,'Pago QR / Web','Online','Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`tipo`=VALUES(`tipo`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- ARANCELES (montos en Guaranies)
-- ---------------------------------------------------------------------
INSERT INTO `aranceles` (`id_arancel`,`id_concepto_pago`,`id_carrera`,`id_periodo`,`nombre`,`monto_base`,`monto_mora_diaria`,`dias_gracia`,`cuotas`,`fecha_vencimiento`,`estado`) VALUES
  (1, 1, NULL, 3,'Matricula general 2026-2',        850000,  5000, 5, 1,'2026-08-15','Activo'),
  (2, 2, NULL, 3,'Reinscripcion 2026-2',            650000,  5000, 5, 1,'2026-08-15','Activo'),
  (3, 3, 4,    3,'Arancel mensual Ing. Sistemas',   720000,  3000, 5, 6,'2026-10-10','Activo'),
  (4, 3, 1,    3,'Arancel mensual Administracion',  680000,  3000, 5, 6,'2026-10-10','Activo'),
  (5, 3, 2,    3,'Arancel mensual Contabilidad',    680000,  3000, 5, 6,'2026-10-10','Activo'),
  (6, 3, 7,    3,'Arancel mensual Enfermeria',      780000,  3000, 5, 6,'2026-10-10','Activo'),
  (7, 3, 10,   3,'Arancel mensual Derecho',         700000,  3000, 5, 6,'2026-10-10','Activo'),
  (8, 6, NULL, 3,'Examen final 2026-2',             150000,     0, 0, 1,'2026-11-20','Activo'),
  (9, 7, NULL, 3,'Examen recuperatorio 2026-2',     180000,     0, 0, 1,'2026-11-27','Activo'),
  (10,9, NULL, 3,'Constancia de estudios',           80000,     0, 0, 1,NULL,'Activo'),
  (11,10,NULL, 3,'Certificado de calificaciones',   120000,     0, 0, 1,NULL,'Activo'),
  (12,13,NULL, 3,'Kit universitario 2026',          250000,     0, 0, 1,'2026-09-30','Activo'),
  (13,4, 4,    3,'Laboratorio Ing. Sistemas',       300000,     0, 0, 1,'2026-09-30','Activo'),
  (14,12,NULL, 3,'Duplicado de credencial',         100000,     0, 0, 1,NULL,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`monto_base`=VALUES(`monto_base`),`monto_mora_diaria`=VALUES(`monto_mora_diaria`),`cuotas`=VALUES(`cuotas`),`fecha_vencimiento`=VALUES(`fecha_vencimiento`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- BECAS
-- ---------------------------------------------------------------------
INSERT INTO `becas` (`id_beca`,`nombre`,`porcentaje_descuento`,`monto_fijo_descuento`,`tipo`,`estado`) VALUES
  (1,'Beca Excelencia Academica',50.00,NULL,'Porcentaje','Activo'),
  (2,'Beca Deportiva',30.00,NULL,'Porcentaje','Activo'),
  (3,'Beca Hermanos',20.00,NULL,'Porcentaje','Activo'),
  (4,'Beca de Ayuda Social',NULL,150000.00,'Monto fijo','Activo'),
  (5,'Beca Excelencia Total',100.00,NULL,'Porcentaje','Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`porcentaje_descuento`=VALUES(`porcentaje_descuento`),`monto_fijo_descuento`=VALUES(`monto_fijo_descuento`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- TIPOS DE TRAMITE
-- ---------------------------------------------------------------------
INSERT INTO `tipos_tramite` (`id_tipo_tramite`,`id_concepto_pago`,`nombre_tramite`,`dias_resolucion`,`requiere_aprobacion`,`estado`) VALUES
  (1, 9,'Constancia de alumno regular',2,0,'Activo'),
  (2,10,'Certificado de calificaciones',3,0,'Activo'),
  (3,12,'Duplicado de credencial',5,0,'Activo'),
  (4,11,'Titulo profesional',30,1,'Activo'),
  (5,NULL,'Certificado de estudios completo',7,1,'Activo'),
  (6,NULL,'Justificacion de inasistencia',1,1,'Activo'),
  (7,NULL,'Cambio de carrera',10,1,'Activo')
ON DUPLICATE KEY UPDATE `nombre_tramite`=VALUES(`nombre_tramite`),`dias_resolucion`=VALUES(`dias_resolucion`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- TIMBRADOS (facturacion electronica)
-- ---------------------------------------------------------------------
INSERT INTO `timbrados` (`id_timbrado`,`id_sede`,`numero_timbrado`,`tipo_documento`,`punto_expedicion`,`establecimiento`,`fecha_inicio_vigencia`,`fecha_fin_vigencia`,`numero_inicio`,`numero_fin`,`numero_actual`,`estado`) VALUES
  (1,1,'12345678','Factura','001','001','2026-01-01','2027-12-31',1,5000,1,'Activo'),
  (2,2,'87654321','Factura','002','001','2026-01-01','2027-12-31',1,5000,1,'Activo')
ON DUPLICATE KEY UPDATE `numero_timbrado`=VALUES(`numero_timbrado`),`fecha_inicio_vigencia`=VALUES(`fecha_inicio_vigencia`),`fecha_fin_vigencia`=VALUES(`fecha_fin_vigencia`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- PLANTILLAS DE DOCUMENTO
-- ---------------------------------------------------------------------
INSERT INTO `plantillas_documento` (`id_plantilla`,`id_tipo_tramite`,`nombre`,`contenido_html`,`estado`) VALUES
  (1,1,'Constancia de alumno regular','<h2>CONSTANCIA DE ALUMNO REGULAR</h2><p>Se expide la presente constancia a favor de <b>{{ALUMNO}}</b>, portador del documento N&deg; <b>{{CEDULA}}</b>, alumno/a de la carrera de <b>{{CARRERA}}</b>, quien se encuentra regularmente matriculado/a en el periodo lectivo <b>{{PERIODO}}</b>.</p><p>Se expide a pedido del interesado para los fines que estime convenientes.</p>','Activo'),
  (2,2,'Certificado de calificaciones','<h2>CERTIFICADO DE CALIFICACIONES</h2><p>La Secretaria Academica certifica que <b>{{ALUMNO}}</b>, documento N&deg; <b>{{CEDULA}}</b>, de la carrera de <b>{{CARRERA}}</b>, registra las asignaturas aprobadas segun el analitico adjunto.</p>','Activo'),
  (3,3,'Duplicado de credencial','<h2>CONSTANCIA PARA DUPLICADO DE CREDENCIAL</h2><p>Se autoriza la emision del duplicado de credencial universitaria a favor de <b>{{ALUMNO}}</b>, documento N&deg; <b>{{CEDULA}}</b>.</p>','Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`contenido_html`=VALUES(`contenido_html`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- PERSONAS (demo)
-- ---------------------------------------------------------------------
INSERT INTO `personas` (`id_persona`,`cedula`,`nombres`,`apellidos`,`telefono`,`email`,`celular`,`direccion`,`id_ciudades`,`fecha_nac`,`estado`,`nacionalidad`,`sexo`) VALUES
  (1,'1234567','Administrador','del Sistema','+595 991 461 220','admin@unves.edu.py','0991 461 220','Campus Central',1,'1985-03-12','Activo','Paraguaya','M'),
  (2,'4567890','Juan Carlos','Perez Gonzalez','+595 981 111 222','juan.perez@unves.edu.py','0981 111 222','Barrio Ybaroty, Villarrica',1,'2003-05-21','Activo','Paraguaya','M'),
  (3,'4321098','Maria Fernanda','Lopez Ramirez','+595 982 333 444','maria.lopez@unves.edu.py','0982 333 444','Barrio Santa Lucia, Villarrica',1,'2002-11-08','Activo','Paraguaya','F'),
  (4,'3210987','Carlos Alberto','Ramirez Vega','+595 983 555 666','carlos.ramirez@unves.edu.py','0983 555 666','Centro, Villarrica',1,'1990-01-30','Activo','Paraguaya','M'),
  (5,'2987654','Ana Belen','Benitez Torres','+595 984 777 888','ana.benitez@unves.edu.py','0984 777 888','Barrio San Miguel',1,'1982-07-14','Activo','Paraguaya','F'),
  (6,'3876543','Lucia','Gimenez Aquino','+595 985 999 000','lucia.gimenez@unves.edu.py','0985 999 000','Barrio Estacion',1,'1995-09-02','Activo','Paraguaya','F'),
  (7,'4123567','Pedro Andres','Martinez Silva','+595 986 123 456','pedro.martinez@unves.edu.py','0986 123 456','Barrio Las Mercedes',1,'2001-04-18','Activo','Paraguaya','M'),
  (8,'4987123','Sofia','Cabrera Nunez','+595 987 654 321','sofia.cabrera@unves.edu.py','0987 654 321','Barrio Ita Ybate',1,'2004-02-25','Activo','Paraguaya','F')
ON DUPLICATE KEY UPDATE `nombres`=VALUES(`nombres`),`apellidos`=VALUES(`apellidos`),`email`=VALUES(`email`),`telefono`=VALUES(`telefono`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- USUARIOS (clave: Unves.2026)
-- ---------------------------------------------------------------------
INSERT INTO `usuarios` (`id_usuario`,`user`,`email`,`id_persona`,`pass`,`estado`,`id_rol`,`sucursal_cod`,`sucursal`,`facultad`) VALUES
  (1,'admin','admin@unves.edu.py',1,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',1,'001','Campus Central','Todas'),
  (2,'juan.perez','juan.perez@unves.edu.py',2,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',2,'001','Campus Central','Ingenieria'),
  (3,'maria.lopez','maria.lopez@unves.edu.py',3,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',2,'001','Campus Central','Ciencias Empresariales'),
  (4,'caja1','carlos.ramirez@unves.edu.py',4,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',4,'001','Campus Central','Todas'),
  (5,'docente1','ana.benitez@unves.edu.py',5,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',3,'001','Campus Central','Ingenieria'),
  (6,'secretaria1','lucia.gimenez@unves.edu.py',6,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',5,'001','Campus Central','Todas'),
  (7,'pedro.martinez','pedro.martinez@unves.edu.py',7,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',2,'001','Campus Central','Ingenieria'),
  (8,'sofia.cabrera','sofia.cabrera@unves.edu.py',8,'$2y$12$a381PeC34ksL8daPLwVbgesEMMTCSGzAUoGcqiE7ji.piumGk.r.W','Activo',2,'001','Campus Central','Ciencias Empresariales')
ON DUPLICATE KEY UPDATE `email`=VALUES(`email`),`id_persona`=VALUES(`id_persona`),`pass`=VALUES(`pass`),`estado`=VALUES(`estado`),`id_rol`=VALUES(`id_rol`);

INSERT INTO `usuario_rol` (`id_usuario`,`id_rol`) VALUES
  (1,1),(2,2),(3,2),(4,4),(5,3),(6,5),(7,2),(8,2)
ON DUPLICATE KEY UPDATE `id_rol`=VALUES(`id_rol`);

-- ---------------------------------------------------------------------
-- ALUMNOS (demo)
-- ---------------------------------------------------------------------
INSERT INTO `alumnos` (`id_alumno`,`id_persona`,`legajo`,`codigo_externo`,`id_carrera`,`id_facultades`,`id_sede`,`id_periodo_ingreso`,`semestre_actual`,`estado_academico`,`modalidad`,`turno`,`fecha_ingreso`,`promedio_general`,`creditos_aprobados`,`origen_datos`) VALUES
  (1,2,'2023-ISI-001','EXT-1001',4,2,1,1,8,'Activo','Presencial','Noche','2023-02-06',4.15,180,'Local'),
  (2,3,'2022-CON-014','EXT-1002',2,1,1,1,10,'Activo','Presencial','Noche','2022-02-07',4.42,220,'Local'),
  (3,7,'2024-ISI-033','EXT-1003',4,2,1,2,6,'Activo','Presencial','Tarde','2024-02-05',3.85,120,'Local'),
  (4,8,'2025-ADM-052','EXT-1004',1,1,1,3,3,'Activo','Presencial','Noche','2025-07-21',3.60,60,'Local')
ON DUPLICATE KEY UPDATE `legajo`=VALUES(`legajo`),`id_carrera`=VALUES(`id_carrera`),`semestre_actual`=VALUES(`semestre_actual`),`estado_academico`=VALUES(`estado_academico`);

-- ---------------------------------------------------------------------
-- MATRICULAS (demo)
-- ---------------------------------------------------------------------
INSERT INTO `matriculas` (`id_matricula`,`numero_matricula`,`id_alumno`,`id_periodo`,`id_carrera`,`id_facultades`,`id_sede`,`semestre`,`turno`,`modalidad`,`monto_matricula`,`fecha_solicitud`,`fecha_confirmacion`,`estado`,`documentacion_ok`) VALUES
  (1,'MAT-2026-2-0001',1,3,4,2,1,8,'Noche','Presencial',850000,'2026-07-21 09:15:00','2026-07-22 10:00:00','Confirmada',1),
  (2,'MAT-2026-2-0002',2,3,2,1,1,10,'Noche','Presencial',850000,'2026-07-22 14:30:00','2026-07-23 08:45:00','Confirmada',1),
  (3,'MAT-2026-2-0003',3,3,4,2,1,6,'Tarde','Presencial',850000,'2026-08-03 11:05:00',NULL,'Pendiente',0),
  (4,'MAT-2026-2-0004',4,3,1,1,1,3,'Noche','Presencial',850000,'2026-08-10 16:40:00',NULL,'Pendiente',0)
ON DUPLICATE KEY UPDATE `estado`=VALUES(`estado`),`fecha_confirmacion`=VALUES(`fecha_confirmacion`);

-- ---------------------------------------------------------------------
-- EXAMENES (demo)
-- ---------------------------------------------------------------------
INSERT INTO `examenes` (`id_examen`,`nombre`,`materia`,`tipo`,`id_periodo`,`id_carrera`,`id_facultades`,`id_sede`,`id_concepto_pago`,`monto`,`fecha_examen`,`hora_inicio`,`duracion_min`,`aula`,`cupo_maximo`,`inscritos`,`fecha_limite_insc`,`requiere_pago`,`estado`) VALUES
  (1,'Mesa Final - Programacion Web','Programacion Web','Final',3,4,2,1,6,150000,'2026-11-10','18:00:00',90,'Aula 12',40,0,'2026-11-05',1,'Inscripcion abierta'),
  (2,'Mesa Final - Base de Datos II','Base de Datos II','Final',3,4,2,1,6,150000,'2026-11-12','18:00:00',90,'Aula 12',40,0,'2026-11-06',1,'Inscripcion abierta'),
  (3,'Mesa Final - Contabilidad IV','Contabilidad IV','Final',3,2,1,1,6,150000,'2026-11-17','19:00:00',90,'Aula 05',35,0,'2026-11-11',1,'Inscripcion abierta'),
  (4,'Recuperatorio - Algoritmos','Algoritmos y Estructuras','Recuperatorio',3,4,2,1,7,180000,'2026-11-24','18:30:00',90,'Aula 08',30,0,'2026-11-18',1,'Inscripcion abierta'),
  (5,'Mesa Final - Derecho Civil','Derecho Civil','Final',3,10,4,2,6,150000,'2026-11-19','18:00:00',90,'Aula 21',45,0,'2026-11-13',1,'Inscripcion abierta'),
  (6,'Suficiencia - Ingles Tecnico','Ingles Tecnico','Suficiencia',3,4,2,1,6,200000,'2026-12-01','09:00:00',120,'Aula Magna',60,0,'2026-11-25',1,'Programado')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`fecha_examen`=VALUES(`fecha_examen`),`monto`=VALUES(`monto`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- OBLIGACIONES DE PAGO (demo) - mezcla de pagadas, pendientes y vencidas
-- ---------------------------------------------------------------------
INSERT INTO `obligaciones_pago`
  (`id_obligacion`,`id_alumno`,`id_concepto_pago`,`id_periodo`,`id_arancel`,`id_matricula`,`descripcion`,`referencia`,`monto_original`,`monto_mora`,`monto_descuento`,`monto_final`,`monto_pagado`,`saldo`,`fecha_emision`,`fecha_vencimiento`,`estado`,`prioridad`) VALUES
  -- Alumno 1 (Juan) - matricula pagada + aranceles
  (1,1,1,3,1,1,'Matricula 2026-2','MAT-2026-2-0001',850000,0,0,850000,850000,0,'2026-07-21','2026-08-15','Pagado','Normal'),
  (2,1,3,3,3,NULL,'Arancel Julio 2026','ARA-2026-07',720000,0,0,720000,720000,0,'2026-07-25','2026-08-10','Pagado','Normal'),
  (3,1,3,3,3,NULL,'Arancel Agosto 2026','ARA-2026-08',720000,0,0,720000,720000,0,'2026-08-01','2026-09-10','Pagado','Normal'),
  (4,1,3,3,3,NULL,'Arancel Septiembre 2026','ARA-2026-09',720000,0,0,720000,720000,0,'2026-09-01','2026-10-10','Pagado','Normal'),
  (5,1,3,3,3,NULL,'Arancel Octubre 2026','ARA-2026-10',720000,0,0,720000,0,720000,'2026-10-01','2026-11-10','Pendiente','Normal'),
  (6,1,4,3,13,NULL,'Laboratorio Ing. Sistemas 2026','LAB-2026',300000,0,0,300000,0,300000,'2026-08-01','2026-09-30','Vencido','Alta'),
  -- Alumno 2 (Maria) - al dia
  (7,2,1,3,1,2,'Matricula 2026-2','MAT-2026-2-0002',850000,0,0,850000,850000,0,'2026-07-22','2026-08-15','Pagado','Normal'),
  (8,2,3,3,5,NULL,'Arancel Septiembre 2026','ARA-2026-09',680000,0,0,680000,680000,0,'2026-09-01','2026-10-10','Pagado','Normal'),
  (9,2,3,3,5,NULL,'Arancel Octubre 2026','ARA-2026-10',680000,0,0,680000,0,680000,'2026-10-01','2026-11-10','Pendiente','Normal'),
  -- Alumno 3 (Pedro) - matricula pendiente
  (10,3,1,3,1,3,'Matricula 2026-2','MAT-2026-2-0003',850000,25000,0,875000,0,875000,'2026-08-03','2026-08-15','Vencido','Alta'),
  (11,3,3,3,3,NULL,'Arancel Octubre 2026','ARA-2026-10',720000,0,0,720000,0,720000,'2026-10-01','2026-11-10','Pendiente','Normal'),
  -- Alumno 4 (Sofia) - beca aplicada
  (12,4,1,3,1,4,'Matricula 2026-2','MAT-2026-2-0004',850000,0,425000,425000,0,425000,'2026-08-10','2026-09-15','Pendiente','Normal'),
  (13,4,3,3,4,NULL,'Arancel Octubre 2026','ARA-2026-10',680000,0,340000,340000,0,340000,'2026-10-01','2026-11-10','Pendiente','Normal')
ON DUPLICATE KEY UPDATE `monto_pagado`=VALUES(`monto_pagado`),`saldo`=VALUES(`saldo`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- PAGOS (demo) + detalles
-- ---------------------------------------------------------------------
INSERT INTO `pagos` (`id_pago`,`id_alumno`,`id_metodo_pago`,`id_usuario`,`id_periodo`,`id_sede`,`codigo_transaccion`,`pasarela`,`monto_total`,`moneda`,`tipo_pago`,`fecha_pago`,`estado_pago`,`numero_comprobante`,`observacion`,`creado_en`) VALUES
  (1,1,7,2,3,1,'TX-20260722-0001','sandbox',850000,'PYG','Online','2026-07-22 10:00:00','Aprobado','REC-2026-000001','Pago de matricula 2026-2','2026-07-22 10:00:00'),
  (2,1,7,2,3,1,'TX-20260726-0002','sandbox',720000,'PYG','Online','2026-07-26 20:12:00','Aprobado','REC-2026-000002','Arancel Julio 2026','2026-07-26 20:12:00'),
  (3,1,2,4,3,1,'TX-20260805-0003','caja',720000,'PYG','Caja','2026-08-05 09:30:00','Aprobado','REC-2026-000003','Arancel Agosto 2026 en ventanilla','2026-08-05 09:30:00'),
  (4,2,7,3,3,1,'TX-20260723-0004','sandbox',850000,'PYG','Online','2026-07-23 08:45:00','Aprobado','REC-2026-000004','Pago de matricula 2026-2','2026-07-23 08:45:00'),
  (5,1,7,2,3,1,'TX-20260910-0005','sandbox',720000,'PYG','Online','2026-09-10 19:05:00','Aprobado','REC-2026-000005','Arancel Septiembre 2026','2026-09-10 19:05:00'),
  (6,2,7,3,3,1,'TX-20260912-0006','sandbox',680000,'PYG','Online','2026-09-12 21:40:00','Aprobado','REC-2026-000006','Arancel Septiembre 2026','2026-09-12 21:40:00')
ON DUPLICATE KEY UPDATE `estado_pago`=VALUES(`estado_pago`);

INSERT INTO `pago_detalles` (`id_pago_detalle`,`id_pago`,`id_obligacion`,`monto_pagado`) VALUES
  (1,1,1,850000),(2,2,2,720000),(3,3,3,720000),(4,4,7,850000),(5,5,4,720000),(6,6,8,680000)
ON DUPLICATE KEY UPDATE `monto_pagado`=VALUES(`monto_pagado`);

-- ---------------------------------------------------------------------
-- SOLICITUDES DE TRAMITE (demo)
-- ---------------------------------------------------------------------
INSERT INTO `solicitudes_tramite` (`id_solicitud`,`id_alumno`,`id_pago`,`id_tipo_tramite`,`codigo_seguimiento`,`fecha_solicitud`,`estado_tramite`,`tipo_entrega`,`fecha_estimada`,`monto`,`observaciones`) VALUES
  (1,1,NULL,1,'TRA-20261001-0001','2026-10-01 09:20:00','En proceso','Digital','2026-10-03',80000,'Constancia para tramite bancario'),
  (2,3,NULL,2,'TRA-20261005-0002','2026-10-05 15:45:00','Pendiente de pago','Digital','2026-10-08',120000,'Certificado de calificaciones')
ON DUPLICATE KEY UPDATE `estado_tramite`=VALUES(`estado_tramite`);

-- ---------------------------------------------------------------------
-- BECAS ASIGNADAS
-- ---------------------------------------------------------------------
INSERT INTO `alumno_beca` (`id_alumno_beca`,`id_alumno`,`id_beca`,`id_periodo`,`fecha_asignacion`,`fecha_fin`,`estado`,`observaciones`) VALUES
  (1,4,1,3,'2026-07-20','2026-12-18','Activo','Beca Excelencia Academica 50%')
ON DUPLICATE KEY UPDATE `estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- LOGS / AUDITORIA INICIAL
-- ---------------------------------------------------------------------
INSERT INTO `logs_actividad` (`id_usuario`,`modulo`,`accion`,`descripcion`,`nivel`) VALUES
  (1,'sistema','instalacion','Instalacion del portal web y carga de datos semilla','info');

-- =====================================================================
--  FIN DEL SCRIPT
-- =====================================================================
