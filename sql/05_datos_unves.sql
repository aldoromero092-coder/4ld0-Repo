-- =====================================================================
--  SISTEMA DE GESTION ACADEMICA UNVES - DATOS INSTITUCIONALES
--  Archivo : sql/05_datos_unves.sql
--  Objetivo: Unidades academicas, sedes, carreras, oferta por sede,
--            mallas curriculares, cursos abiertos y ventanas academicas
--            con la informacion publica de la UNVES.
--  Nota    : Script IDEMPOTENTE (ON DUPLICATE KEY UPDATE).
--  Cuidado : aplicarlo con  mysql --default-character-set=utf8mb4 < archivo
--            para no perder los acentos.
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- UNIDADES ACADEMICAS (facultades y escuelas)
-- ---------------------------------------------------------------------
INSERT INTO `facultades` (`id_facultades`,`siglas`,`nombre`,`tipo`,`estado`) VALUES
  (1,'FCE','Ciencias Económicas','Facultad','Activo'),
  (2,'FIA','Ingeniería y Arquitectura','Facultad','Activo'),
  (3,'FCS','Ciencias de la Salud','Facultad','Activo'),
  (4,'FCJP','Ciencias Jurídicas, Políticas y Sociales','Facultad','Activo'),
  (5,'FFCH','Filosofía y Ciencias Humanas','Facultad','Activo'),
  (6,'FPOL','Politécnica','Facultad','Activo'),
  (7,'FFQM','Ciencias Físicas, Químicas y Matemáticas','Facultad','Activo'),
  (8,'FCA','Ciencias Agrarias','Facultad','Activo'),
  (9,'FC','Facultad de Ciencias','Facultad','Activo'),
  (10,'EA','Escuela de Arte','Escuela','Activo'),
  (11,'EG','Escuela de Gastronomía','Escuela','Activo'),
  (12,'EP','Escuela de Posgrado','Escuela','Activo')
ON DUPLICATE KEY UPDATE `siglas`=VALUES(`siglas`),`nombre`=VALUES(`nombre`),`tipo`=VALUES(`tipo`);

-- ---------------------------------------------------------------------
-- SEDES
-- ---------------------------------------------------------------------
INSERT INTO `sedes` (`id_sede`,`nombre`,`direccion`,`ciudad`,`telefono`,`email`,`es_central`,`tipo`,`estado`) VALUES
  (1,'Campus Central - Villarrica','Bvar. Río Apa entre Pa''i Anasagasti y Juan Carlos Scavone','Villarrica','(+595 541) 44 535','rectorado@unves.edu.py',1,'Campus','Activo'),
  (2,'Sede Paraguarí','Calle 14 de Mayo e/ Mcal. López, Paraguarí','Paraguarí',NULL,NULL,0,'Filial','Activo'),
  (3,'Sede Yuty','Ruta PY08, Yuty','Yuty',NULL,NULL,0,'Filial','Activo'),
  (4,'Sede Caazapá','Avda. Florida, Caazapá','Caazapá',NULL,NULL,0,'Filial','Activo'),
  (5,'Sede Carapeguá','Ruta PY01, Carapeguá','Carapeguá',NULL,NULL,0,'Filial','Activo'),
  (6,'Sede Pedro Juan Caballero','Avda. Internacional, Pedro Juan Caballero','Pedro Juan Caballero',NULL,NULL,0,'Filial','Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`direccion`=VALUES(`direccion`),`ciudad`=VALUES(`ciudad`),`telefono`=VALUES(`telefono`),`email`=VALUES(`email`),`es_central`=VALUES(`es_central`),`tipo`=VALUES(`tipo`);

-- ---------------------------------------------------------------------
-- CARRERAS DE GRADO Y POSGRADO
-- ---------------------------------------------------------------------
INSERT INTO `carreras` (`id_carrera`,`codigo_carrera`,`nombre`,`titulo_otorgado`,`id_facultades`,
  `duracion_anio`,`duracion_anios`,`duracion_semestres`,`carga_horaria`,`area`,`estado`) VALUES
  (1,'ADM','Licenciatura en Administración de Empresa','Licenciado/a en Administración de Empresa',1,NULL,NULL,NULL,NULL,'Ciencias Empresariales','Activo'),
  (2,'CONT','Licenciatura en Ciencias Contables y Auditoría','Contador/a Público/a',1,5,5,10,NULL,'Ciencias Empresariales','Activo'),
  (3,'EDU','Licenciatura en Ciencias de la Educación','Licenciado/a en Ciencias de la Educación',5,4,4,8,5040,'Ciencias de la Educación','Activo'),
  (4,'INFO','Ingeniería en Informática','Ingeniero/a en Informática',6,6,6,12,NULL,'Ingeniería','Activo'),
  (5,'IELE','Ingeniería Eléctrica','Ingeniero/a Electricista',6,5,5,10,NULL,'Ingeniería','Activo'),
  (6,'IAM','Ingeniería Ambiental','Ingeniero/a Ambiental',2,NULL,NULL,NULL,NULL,'Ingeniería','Activo'),
  (7,'ARQ','Arquitectura','Arquitecto/a',2,NULL,NULL,NULL,NULL,'Arquitectura','Activo'),
  (8,'COM','Licenciatura en Ciencias de la Comunicación','Licenciado/a en Ciencias de la Comunicación',5,4,4,8,5040,'Comunicación','Activo'),
  (9,'GE','Licenciatura en Gestión Educativa','Licenciado/a en Gestión Educativa',5,4,4,8,5040,'Ciencias de la Educación','Activo'),
  (10,'ING','Licenciatura en Inglés','Licenciado/a en Lengua Inglesa',5,4,4,8,5040,'Idiomas','Activo'),
  (11,'DER','Derecho','Abogado/a',4,NULL,NULL,NULL,NULL,'Ciencias Jurídicas','Activo'),
  (12,'IQ','Ingeniería Química','Ingeniero/a Químico/a',7,NULL,NULL,NULL,NULL,'Ciencias Químicas','Activo'),
  (13,'PSI','Licenciatura en Psicología','Licenciado/a en Psicología',3,NULL,NULL,NULL,NULL,'Ciencias de la Salud','Activo'),
  (14,'NUT','Licenciatura en Nutrición','Licenciado/a en Nutrición',3,NULL,NULL,NULL,NULL,'Ciencias de la Salud','Activo'),
  (15,'ENF','Licenciatura en Enfermería','Licenciado/a en Enfermería',3,NULL,NULL,NULL,NULL,'Ciencias de la Salud','Activo'),
  (16,'AGRO','Ingeniería en Agroindustria','Ingeniero/a en Agroindustria',8,5,5,10,NULL,'Ciencias Agrarias','Activo'),
  (17,'ZOO','Ingeniería en Zootecnia','Ingeniero/a en Zootecnia',8,5,5,10,NULL,'Ciencias Agrarias','Activo'),
  (18,'GP','Licenciatura en Gestión Pública','Licenciado/a en Gestión Pública',9,4,4,8,5040,'Gestión Pública','Activo'),
  (19,'GHT','Licenciatura en Gastronomía, Hotelería y Turismo','Licenciado/a en Gastronomía, Hotelería y Turismo',11,NULL,NULL,NULL,NULL,'Gastronomía y Turismo','Activo'),
  (20,'IPADR','Ingeniería en Producción Agropecuaria y Desarrollo Rural','Ingeniero/a en Producción Agropecuaria',9,NULL,NULL,NULL,NULL,'Ciencias Agrarias','Activo'),
  (21,'MUS','Licenciatura en Música','Licenciado/a en Música',10,4,4,8,5040,'Artes','Activo'),
  (22,'HT','Licenciatura en Hotelería y Turismo','Licenciado/a en Hotelería y Turismo',11,NULL,NULL,NULL,NULL,'Gastronomía y Turismo','Activo'),
  (23,'GAS','Licenciatura en Gastronomía','Licenciado/a en Gastronomía',11,NULL,NULL,NULL,NULL,'Gastronomía y Turismo','Activo'),
  (24,'POS-ES','Especialización en Didáctica Superior Universitaria','Especialista en Didáctica Superior Universitaria',12,NULL,NULL,NULL,NULL,'Posgrado','Activo'),
  (25,'POS-MA','Maestría en Didáctica Superior Universitaria','Magíster en Didáctica Superior Universitaria',12,NULL,NULL,NULL,NULL,'Posgrado','Activo')
ON DUPLICATE KEY UPDATE `codigo_carrera`=VALUES(`codigo_carrera`),`nombre`=VALUES(`nombre`),
  `titulo_otorgado`=VALUES(`titulo_otorgado`),`id_facultades`=VALUES(`id_facultades`),
  `duracion_anio`=VALUES(`duracion_anio`),`duracion_anios`=VALUES(`duracion_anios`),
  `duracion_semestres`=VALUES(`duracion_semestres`),`carga_horaria`=VALUES(`carga_horaria`),
  `area`=VALUES(`area`),`estado`=VALUES(`estado`);

-- Carreras cargadas por pruebas o fuera de la oferta actual
UPDATE `carreras` SET `estado` = 'Inactivo' WHERE id_carrera > 25;

-- ---------------------------------------------------------------------
-- OFERTA ACADEMICA POR SEDE
-- ---------------------------------------------------------------------
INSERT INTO `carrera_sede` (`id_carrera`,`id_sede`,`turnos`,`cupo`,`estado`) VALUES
  (1,1,'Mañana,Tarde,Noche',0,'Activo'),
  (1,4,'Mañana,Tarde,Noche',0,'Activo'),
  (1,5,'Mañana,Tarde,Noche',0,'Activo'),
  (1,6,'Mañana,Tarde,Noche',0,'Activo'),
  (2,1,'Mañana,Tarde,Noche',0,'Activo'),
  (2,2,'Mañana,Tarde,Noche',0,'Activo'),
  (2,4,'Mañana,Tarde,Noche',0,'Activo'),
  (2,5,'Mañana,Tarde,Noche',0,'Activo'),
  (3,1,'Mañana,Tarde,Noche',0,'Activo'),
  (3,3,'Mañana,Tarde,Noche',0,'Activo'),
  (3,4,'Mañana,Tarde,Noche',0,'Activo'),
  (3,6,'Mañana,Tarde,Noche',0,'Activo'),
  (4,1,'Mañana,Tarde,Noche',0,'Activo'),
  (5,1,'Mañana,Tarde,Noche',0,'Activo'),
  (6,1,'Mañana,Tarde,Noche',0,'Activo'),
  (7,1,'Mañana,Tarde,Noche',0,'Activo'),
  (8,1,'Mañana,Tarde,Noche',0,'Activo'),
  (9,1,'Mañana,Tarde,Noche',0,'Activo'),
  (10,1,'Mañana,Tarde,Noche',0,'Activo'),
  (11,1,'Mañana,Tarde,Noche',0,'Activo'),
  (12,1,'Mañana,Tarde,Noche',0,'Activo'),
  (13,1,'Mañana,Tarde,Noche',0,'Activo'),
  (14,1,'Mañana,Tarde,Noche',0,'Activo'),
  (15,1,'Mañana,Tarde,Noche',0,'Activo'),
  (15,6,'Mañana,Tarde,Noche',0,'Activo'),
  (16,1,'Mañana,Tarde,Noche',0,'Activo'),
  (17,1,'Mañana,Tarde,Noche',0,'Activo'),
  (18,5,'Noche',0,'Activo'),
  (19,2,'Noche',0,'Activo'),
  (20,5,'Noche',0,'Activo'),
  (21,1,'Mañana,Tarde,Noche',0,'Activo'),
  (22,1,'Noche',0,'Activo'),
  (23,1,'Noche',0,'Activo'),
  (24,1,'Noche',0,'Activo'),
  (25,1,'Noche',0,'Activo')
ON DUPLICATE KEY UPDATE `turnos`=VALUES(`turnos`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- MALLAS CURRICULARES (plan de estudios por carrera)
-- Las carreras cuya malla no esta publicada como tabla quedan con la
-- cabecera creada para que secretaria cargue sus materias.
-- ---------------------------------------------------------------------
INSERT INTO `mallas_curriculares` (`id_malla`,`id_carrera`,`nombre`,`anio_vigencia`,`total_cursos`,`total_semestres`,`carga_horaria`,`vigente`,`observaciones`,`estado`) VALUES
  (1,1,'Plan de estudios vigente - Licenciatura en Administración de Empresa',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (2,2,'Plan de estudios vigente - Licenciatura en Ciencias Contables y Auditoría',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (3,3,'Plan de estudios vigente - Licenciatura en Ciencias de la Educación',2015,4,2,5040,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (4,4,'Plan 2015 - Ingeniería en Informática',2015,6,2,5040,1,'Malla cargada desde la información pública de la UNVES.','Activo'),
  (5,5,'Plan 2015 - Ingeniería Eléctrica',2015,5,2,5274,1,'Malla cargada desde la información pública de la UNVES.','Activo'),
  (6,6,'Plan de estudios vigente - Ingeniería Ambiental',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (7,7,'Plan de estudios vigente - Arquitectura',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (8,8,'Plan de estudios vigente - Licenciatura en Ciencias de la Comunicación',2015,4,2,5040,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (9,9,'Plan de estudios vigente - Licenciatura en Gestión Educativa',2015,4,2,5040,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (10,10,'Plan de estudios vigente - Licenciatura en Inglés',2015,4,2,5040,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (11,11,'Plan de estudios vigente - Derecho',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (12,12,'Plan de estudios vigente - Ingeniería Química',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (13,13,'Plan de estudios vigente - Licenciatura en Psicología',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (14,14,'Plan de estudios vigente - Licenciatura en Nutrición',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (15,15,'Plan de estudios vigente - Licenciatura en Enfermería',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (16,16,'Plan de estudios vigente - Ingeniería en Agroindustria',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (17,17,'Plan de estudios vigente - Ingeniería en Zootecnia',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (18,18,'Plan de estudios vigente - Licenciatura en Gestión Pública',2015,4,2,5040,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (19,19,'Plan de estudios vigente - Licenciatura en Gastronomía, Hotelería y Turismo',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (20,20,'Plan de estudios vigente - Ingeniería en Producción Agropecuaria y Desarrollo Rural',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (21,21,'Plan de estudios vigente - Licenciatura en Música',2015,4,2,5040,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (22,22,'Plan de estudios vigente - Licenciatura en Hotelería y Turismo',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (23,23,'Plan de estudios vigente - Licenciatura en Gastronomía',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (24,24,'Plan de estudios vigente - Especialización en Didáctica Superior Universitaria',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo'),
  (25,25,'Plan de estudios vigente - Maestría en Didáctica Superior Universitaria',2015,5,2,0,1,'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.','Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`total_cursos`=VALUES(`total_cursos`),
  `carga_horaria`=VALUES(`carga_horaria`),`observaciones`=VALUES(`observaciones`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- MATERIAS DE LA MALLA (carrera + curso + semestre)
-- Se cargan las mallas que la universidad publica como tabla editable.
-- ---------------------------------------------------------------------
-- Ingeniería en informática (56 materias)
INSERT INTO `materias` (`id_malla`,`id_carrera`,`codigo`,`nombre`,`curso`,`semestre`,`semestre_global`,`horas_catedra`,`creditos`,`tipo`,`orden`,`estado`) VALUES
  (4,4,'ISI01','Matemática I',1,1,1,90,3.0,'Obligatoria',1,'Activo'),
  (4,4,'ISI02','Computación I',1,1,1,90,3.0,'Obligatoria',2,'Activo'),
  (4,4,'ISI03','Informática I',1,1,1,90,3.0,'Obligatoria',3,'Activo'),
  (4,4,'ISI04','Algoritmia I',1,1,1,90,3.0,'Obligatoria',4,'Activo'),
  (4,4,'ISI05','Inglés',1,1,1,90,3.0,'Obligatoria',5,'Activo'),
  (4,4,'ISI06','Matemática II',1,2,2,90,3.0,'Obligatoria',6,'Activo'),
  (4,4,'ISI07','Computación II',1,2,2,90,3.0,'Obligatoria',7,'Activo'),
  (4,4,'ISI08','Informática II',1,2,2,90,3.0,'Obligatoria',8,'Activo'),
  (4,4,'ISI09','Algoritmia II',1,2,2,90,3.0,'Obligatoria',9,'Activo'),
  (4,4,'ISI10','Programación I',1,2,2,90,3.0,'Obligatoria',10,'Activo'),
  (4,4,'ISI11','Matemática III',2,1,3,90,3.0,'Obligatoria',11,'Activo'),
  (4,4,'ISI12','Computación III',2,1,3,90,3.0,'Obligatoria',12,'Activo'),
  (4,4,'ISI13','Programación II',2,1,3,90,3.0,'Obligatoria',13,'Activo'),
  (4,4,'ISI14','Lenguaje I',2,1,3,90,3.0,'Obligatoria',14,'Activo'),
  (4,4,'ISI15','Física I',2,1,3,90,3.0,'Obligatoria',15,'Activo'),
  (4,4,'ISI16','Matemática IV',2,2,4,90,3.0,'Obligatoria',16,'Activo'),
  (4,4,'ISI17','Computación IV',2,2,4,90,3.0,'Obligatoria',17,'Activo'),
  (4,4,'ISI18','Programación III',2,2,4,90,3.0,'Obligatoria',18,'Activo'),
  (4,4,'ISI19','Lenguajes II',2,2,4,90,3.0,'Obligatoria',19,'Activo'),
  (4,4,'ISI20','Física II',2,2,4,90,3.0,'Obligatoria',20,'Activo'),
  (4,4,'ISI21','Matemática V',3,1,5,90,3.0,'Obligatoria',21,'Activo'),
  (4,4,'ISI22','Programación IV',3,1,5,90,3.0,'Obligatoria',22,'Activo'),
  (4,4,'ISI23','Análisis y Diseño de Sistemas',3,1,5,90,3.0,'Obligatoria',23,'Activo'),
  (4,4,'ISI24','Lenguajes III',3,1,5,90,3.0,'Obligatoria',24,'Activo'),
  (4,4,'ISI25','Administración I',3,1,5,90,3.0,'Obligatoria',25,'Activo'),
  (4,4,'ISI26','Matemática VI',3,2,6,90,3.0,'Obligatoria',26,'Activo'),
  (4,4,'ISI27','Programación V',3,2,6,90,3.0,'Obligatoria',27,'Activo'),
  (4,4,'ISI28','Redes I',3,2,6,90,3.0,'Obligatoria',28,'Activo'),
  (4,4,'ISI29','Estadística y Probabilidades',3,2,6,90,3.0,'Obligatoria',29,'Activo'),
  (4,4,'ISI30','Metodología de la Investigación I',3,2,6,90,3.0,'Obligatoria',30,'Activo'),
  (4,4,'ISI31','Computación V',4,1,7,90,3.0,'Obligatoria',31,'Activo'),
  (4,4,'ISI32','Informática III',4,1,7,90,3.0,'Obligatoria',32,'Activo'),
  (4,4,'ISI33','Investigación Operativa I',4,1,7,90,3.0,'Obligatoria',33,'Activo'),
  (4,4,'ISI34','Metodología de la Investigación II',4,1,7,90,3.0,'Obligatoria',34,'Activo'),
  (4,4,'ISI35','Proyecto I',4,1,7,90,3.0,'Obligatoria',35,'Activo'),
  (4,4,'ISI36','Computación VI',4,2,8,90,3.0,'Obligatoria',36,'Activo'),
  (4,4,'ISI37','Informática IV',4,2,8,90,3.0,'Obligatoria',37,'Activo'),
  (4,4,'ISI38','Investigación Operativa II',4,2,8,90,3.0,'Obligatoria',38,'Activo'),
  (4,4,'ISI39','Electrónica Digital I',4,2,8,90,3.0,'Obligatoria',39,'Activo'),
  (4,4,'ISI40','Proyecto II',4,2,8,90,3.0,'Obligatoria',40,'Activo'),
  (4,4,'ISI41','Redes II',5,1,9,90,3.0,'Obligatoria',41,'Activo'),
  (4,4,'ISI42','Administración II',5,1,9,90,3.0,'Obligatoria',42,'Activo'),
  (4,4,'ISI43','Ingeniería de Software I',5,1,9,90,3.0,'Obligatoria',43,'Activo'),
  (4,4,'ISI44','Electrónica Digital II',5,1,9,90,3.0,'Obligatoria',44,'Activo'),
  (4,4,'ISI45','Adm. de Sistemas de Información',5,1,9,90,3.0,'Obligatoria',45,'Activo'),
  (4,4,'ISI46','Sistemas Distribuidos',5,2,10,90,3.0,'Obligatoria',46,'Activo'),
  (4,4,'ISI47','Simulación de Sistemas de Control',5,2,10,90,3.0,'Obligatoria',47,'Activo'),
  (4,4,'ISI48','Ingeniería de Software II',5,2,10,90,3.0,'Obligatoria',48,'Activo'),
  (4,4,'ISI49','Modelos y Sistemas de Optimización',5,2,10,90,3.0,'Obligatoria',49,'Activo'),
  (4,4,'ISI50','Informática V',5,2,10,90,3.0,'Obligatoria',50,'Activo'),
  (4,4,'ISI51','Cibernética',6,1,11,90,3.0,'Obligatoria',51,'Activo'),
  (4,4,'ISI52','Informática VI',6,1,11,90,3.0,'Obligatoria',52,'Activo'),
  (4,4,'ISI53','Inteligencia Artificial',6,1,11,90,3.0,'Obligatoria',53,'Activo'),
  (4,4,'ISI56','Auditoria Informática',6,2,12,90,3.0,'Obligatoria',54,'Activo'),
  (4,4,'ISI57','Foros Informáticos',6,2,12,90,3.0,'Obligatoria',55,'Activo'),
  (4,4,'ISI58','Trabajo de Tesis II',6,2,12,90,3.0,'Obligatoria',56,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`curso`=VALUES(`curso`),`semestre`=VALUES(`semestre`),
  `semestre_global`=VALUES(`semestre_global`),`horas_catedra`=VALUES(`horas_catedra`),
  `creditos`=VALUES(`creditos`),`orden`=VALUES(`orden`);

-- Ingeniería Eléctrica (60 materias)
INSERT INTO `materias` (`id_malla`,`id_carrera`,`codigo`,`nombre`,`curso`,`semestre`,`semestre_global`,`horas_catedra`,`creditos`,`tipo`,`orden`,`estado`) VALUES
  (5,5,'IE01','Algebra Lineal y Vectorial',1,1,1,90,3.0,'Obligatoria',1,'Activo'),
  (5,5,'IE02','Geometría Analítica',1,1,1,90,3.0,'Obligatoria',2,'Activo'),
  (5,5,'IE03','Calculo I',1,1,1,90,3.0,'Obligatoria',3,'Activo'),
  (5,5,'IE04','Idioma',1,1,1,72,2.4,'Obligatoria',4,'Activo'),
  (5,5,'IE05','Química',1,1,1,90,3.0,'Obligatoria',5,'Activo'),
  (5,5,'IE06','Dibujo Técnico',1,1,1,90,3.0,'Obligatoria',6,'Activo'),
  (5,5,'IE07','Calculo II',1,2,2,90,3.0,'Obligatoria',7,'Activo'),
  (5,5,'IE08','Física I',1,2,2,90,3.0,'Obligatoria',8,'Activo'),
  (5,5,'IE09','Física II',1,2,2,90,3.0,'Obligatoria',9,'Activo'),
  (5,5,'IE10','Informática Avanzada Para Ingeniería',1,2,2,72,2.4,'Obligatoria',10,'Activo'),
  (5,5,'IE11','Seguridad en Ingeniería Eléctrica',1,2,2,90,3.0,'Obligatoria',11,'Activo'),
  (5,5,'IE12','Electrotecnia I',1,2,2,90,3.0,'Obligatoria',12,'Activo'),
  (5,5,'IE13','Calculo III',2,1,3,90,3.0,'Obligatoria',13,'Activo'),
  (5,5,'IE14','Física III',2,1,3,90,3.0,'Obligatoria',14,'Activo'),
  (5,5,'IE15','Estadística',2,1,3,72,2.4,'Obligatoria',15,'Activo'),
  (5,5,'IE16','Circuitos Eléctricos I',2,1,3,90,3.0,'Obligatoria',16,'Activo'),
  (5,5,'IE17','Resistencia de Materiales',2,1,3,90,3.0,'Obligatoria',17,'Activo'),
  (5,5,'IE18','Electrotecnia II',2,1,3,90,3.0,'Obligatoria',18,'Activo'),
  (5,5,'IE19','Calculo IV',2,2,4,90,3.0,'Obligatoria',19,'Activo'),
  (5,5,'IE20','Física IV',2,2,4,90,3.0,'Obligatoria',20,'Activo'),
  (5,5,'IE21','Física V',2,2,4,72,2.4,'Obligatoria',21,'Activo'),
  (5,5,'IE22','Circuitos Eléctricos II',2,2,4,90,3.0,'Obligatoria',22,'Activo'),
  (5,5,'IE23','Reglamentos de B.T. y M.T.',2,2,4,90,3.0,'Obligatoria',23,'Activo'),
  (5,5,'IE24','Electrónica I',2,2,4,90,3.0,'Obligatoria',24,'Activo'),
  (5,5,'IE25','Calculo V',3,1,5,90,3.0,'Obligatoria',25,'Activo'),
  (5,5,'IE26','Física VI',3,1,5,90,3.0,'Obligatoria',26,'Activo'),
  (5,5,'IE27','Electrónica II',3,1,5,90,3.0,'Obligatoria',27,'Activo'),
  (5,5,'IE28','Medidas Eléctricas y Magnéticas',3,1,5,90,3.0,'Obligatoria',28,'Activo'),
  (5,5,'IE29','Instalación Eléctrica I',3,1,5,90,3.0,'Obligatoria',29,'Activo'),
  (5,5,'IE30','Conversión de la Energía I',3,1,5,90,3.0,'Obligatoria',30,'Activo'),
  (5,5,'IE31','Calculo VI',3,2,6,90,3.0,'Obligatoria',31,'Activo'),
  (5,5,'IE32','Física VII',3,2,6,90,3.0,'Obligatoria',32,'Activo'),
  (5,5,'IE33','Instrumentación Industrial',3,2,6,90,3.0,'Obligatoria',33,'Activo'),
  (5,5,'IE34','Instalación Eléctrica II Industrial',3,2,6,90,3.0,'Obligatoria',34,'Activo'),
  (5,5,'IE35','Automatización y Control Industrial',3,2,6,90,3.0,'Obligatoria',35,'Activo'),
  (5,5,'IE36','Electrónica Digital',3,2,6,90,3.0,'Obligatoria',36,'Activo'),
  (5,5,'IE37','Física VIII',4,1,7,90,3.0,'Obligatoria',37,'Activo'),
  (5,5,'IE38','Conversión de la Energía II Conversión de la Energía Eléctrica II',4,1,7,90,3.0,'Obligatoria',38,'Activo'),
  (5,5,'IE39','Electrónica de Potencia I',4,1,7,90,3.0,'Obligatoria',39,'Activo'),
  (5,5,'IE40','Medición de la Energía Eléctrica',4,1,7,90,3.0,'Obligatoria',40,'Activo'),
  (5,5,'IE41','Instalación Eléctrica III M.T.',4,1,7,90,3.0,'Obligatoria',41,'Activo'),
  (5,5,'IE42','Sistemas Neumáticos Industriales',4,1,7,90,3.0,'Obligatoria',42,'Activo'),
  (5,5,'IE43','Metodología de la Investigación I',4,2,8,90,3.0,'Obligatoria',43,'Activo'),
  (5,5,'IE44','Sistemas de Potencia I',4,2,8,90,3.0,'Obligatoria',44,'Activo'),
  (5,5,'IE45','Mantenimientos Industriales',4,2,8,90,3.0,'Obligatoria',45,'Activo'),
  (5,5,'IE46','Electrónica de Potencia II',4,2,8,90,3.0,'Obligatoria',46,'Activo'),
  (5,5,'IE47','Distribución de la Energía Eléctrica',4,2,8,90,3.0,'Obligatoria',47,'Activo'),
  (5,5,'IE48','Planean. y Control de la Calidad de Producción',4,2,8,90,3.0,'Obligatoria',48,'Activo'),
  (5,5,'IE49','Generación de Energía Eléctrica',5,1,9,90,3.0,'Obligatoria',49,'Activo'),
  (5,5,'IE50','Redes Eléctricas',5,1,9,90,3.0,'Obligatoria',50,'Activo'),
  (5,5,'IE51','Sistemas de Potencia II',5,1,9,90,3.0,'Obligatoria',51,'Activo'),
  (5,5,'IE52','Administración y Organización de Empresa',5,1,9,72,2.4,'Obligatoria',52,'Activo'),
  (5,5,'IE53','Metodología de la Investigación II',5,1,9,90,3.0,'Obligatoria',53,'Activo'),
  (5,5,'IE54','Subestaciones Transformadoras',5,1,9,90,3.0,'Obligatoria',54,'Activo'),
  (5,5,'IE55','Factibilidad de Sistemas Eléctricos',5,2,10,90,3.0,'Obligatoria',55,'Activo'),
  (5,5,'IE56','Protección de Sistemas Eléctricos',5,2,10,90,3.0,'Obligatoria',56,'Activo'),
  (5,5,'IE57','Ética Profesional',5,2,10,72,2.4,'Obligatoria',57,'Activo'),
  (5,5,'IE58','Operación de Energía Eléctrica',5,2,10,90,3.0,'Obligatoria',58,'Activo'),
  (5,5,'IE59','Administración de Recursos Humanos',5,2,10,72,2.4,'Obligatoria',59,'Activo'),
  (5,5,'IE60','Proyecto de Grado I',5,2,10,90,3.0,'Obligatoria',60,'Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`curso`=VALUES(`curso`),`semestre`=VALUES(`semestre`),
  `semestre_global`=VALUES(`semestre_global`),`horas_catedra`=VALUES(`horas_catedra`),
  `creditos`=VALUES(`creditos`),`orden`=VALUES(`orden`);

-- ---------------------------------------------------------------------
-- CURSOS ABIERTOS DEL PERIODO ACTIVO (divisiones con cupo)
-- ---------------------------------------------------------------------
INSERT INTO `cursos_academicos` (`id_carrera`,`id_periodo`,`id_sede`,`id_malla`,`curso`,`semestre`,`seccion`,`turno`,`modalidad`,`aula`,`cupo`,`estado`) VALUES
  (1,3,1,1,1,1,'A','Noche','Presencial','Aula 03',40,'Abierto'),
  (1,3,1,1,1,2,'A','Noche','Presencial','Aula 04',40,'Abierto'),
  (1,3,1,1,2,1,'A','Noche','Presencial','Aula 05',40,'Abierto'),
  (1,3,1,1,2,2,'A','Noche','Presencial','Aula 06',40,'Abierto'),
  (2,3,1,2,1,1,'A','Noche','Presencial','Aula 03',40,'Abierto'),
  (2,3,1,2,1,2,'A','Noche','Presencial','Aula 04',40,'Abierto'),
  (2,3,1,2,2,1,'A','Noche','Presencial','Aula 05',40,'Abierto'),
  (2,3,1,2,2,2,'A','Noche','Presencial','Aula 06',40,'Abierto'),
  (4,3,1,4,1,1,'A','Noche','Presencial','Aula 03',40,'Abierto'),
  (4,3,1,4,1,2,'A','Noche','Presencial','Aula 04',40,'Abierto'),
  (4,3,1,4,2,1,'A','Noche','Presencial','Aula 05',40,'Abierto'),
  (4,3,1,4,2,2,'A','Noche','Presencial','Aula 06',40,'Abierto'),
  (4,3,1,4,3,1,'A','Noche','Presencial','Aula 07',40,'Abierto'),
  (4,3,1,4,3,2,'A','Noche','Presencial','Aula 08',40,'Abierto'),
  (4,3,1,4,4,1,'A','Noche','Presencial','Aula 09',40,'Abierto'),
  (4,3,1,4,4,2,'A','Noche','Presencial','Aula 10',40,'Abierto'),
  (4,3,1,4,5,1,'A','Noche','Presencial','Aula 11',40,'Abierto'),
  (4,3,1,4,5,2,'A','Noche','Presencial','Aula 12',40,'Abierto'),
  (4,3,1,4,6,1,'A','Noche','Presencial','Aula 13',40,'Abierto'),
  (4,3,1,4,6,2,'A','Noche','Presencial','Aula 14',40,'Abierto'),
  (11,3,1,11,1,1,'A','Noche','Presencial','Aula 03',40,'Abierto'),
  (11,3,1,11,1,2,'A','Noche','Presencial','Aula 04',40,'Abierto'),
  (11,3,1,11,2,1,'A','Noche','Presencial','Aula 05',40,'Abierto'),
  (11,3,1,11,2,2,'A','Noche','Presencial','Aula 06',40,'Abierto'),
  (15,3,1,15,1,1,'A','Noche','Presencial','Aula 03',40,'Abierto'),
  (15,3,1,15,1,2,'A','Noche','Presencial','Aula 04',40,'Abierto'),
  (15,3,1,15,2,1,'A','Noche','Presencial','Aula 05',40,'Abierto'),
  (15,3,1,15,2,2,'A','Noche','Presencial','Aula 06',40,'Abierto')
ON DUPLICATE KEY UPDATE `cupo`=VALUES(`cupo`),`aula`=VALUES(`aula`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- VENTANAS ACADEMICAS (desde y hasta cuando se puede operar en linea)
-- ---------------------------------------------------------------------
INSERT INTO `ventanas_academicas` (`id_ventana`,`nombre`,`tipo`,`id_periodo`,`id_carrera`,`id_sede`,
  `fecha_apertura`,`fecha_cierre`,`permite_pago_tardio`,`fecha_limite_pago`,`recargo_tardio`,`monto_recargo`,`aviso`,`estado`) VALUES
  (1,'Matriculación 2026-2 (general)','Matricula',3,NULL,NULL,'2026-07-01','2026-08-15',1,'2027-03-31',10.0,0,'El plazo ordinario venció. Podés matricularte con un recargo del 10% hasta el 31/03/2027.','Activo'),
  (2,'Matriculación 2026-2 - Ingeniería en Informática','Matricula',3,4,1,'2026-09-01','2026-12-05',1,'2027-02-28',5.0,0,'Matriculación extraordinaria habilitada para Ingeniería en Informática hasta el 05/12/2026.','Activo'),
  (3,'Inscripción y pago de exámenes 2026-2','Examen',3,NULL,NULL,'2026-09-15','2026-11-25',1,'2026-12-05',10.0,50000,'Podés inscribirte y pagar mesas finales hasta el 25/11/2026. Después se aplica un recargo del 10% más Gs. 50.000.','Activo'),
  (4,'Aranceles 2026-2','Arancel',3,NULL,NULL,'2026-07-20','2026-12-18',1,'2027-03-31',8.0,0,'Los aranceles del periodo se pueden pagar en línea hasta el 18/12/2026. Luego se aplica un recargo del 8%.','Activo'),
  (5,'Trámites y documentos 2026-2','Tramite',3,NULL,NULL,'2026-07-20','2026-12-18',0,NULL,0.0,0,'Solicitud de constancias y certificados habilitada hasta el 18/12/2026.','Activo'),
  (6,'Matriculación 2026-1','Matricula',2,NULL,NULL,'2026-01-26','2026-02-20',0,NULL,0.0,0,'El plazo de matriculación del primer semestre 2026 ya finalizó.','Activo'),
  (7,'Inscripción y pago de exámenes 2026-1','Examen',2,NULL,NULL,'2026-05-04','2026-06-15',0,NULL,0.0,0,'Las mesas finales del primer semestre 2026 están cerradas.','Activo'),
  (8,'Matriculación 2025-2','Matricula',1,NULL,NULL,'2025-07-01','2025-08-20',0,NULL,0.0,0,'Periodo cerrado.','Activo'),
  (9,'Matriculación 2027-1','Matricula',4,NULL,NULL,'2027-01-25','2027-02-26',0,NULL,0.0,0,'Matriculación del primer semestre 2027: del 25/01 al 26/02/2027.','Activo'),
  (10,'Aranceles 2027-1','Arancel',4,NULL,NULL,'2027-02-01','2027-07-16',1,'2027-08-31',8.0,0,'Aranceles del primer semestre 2027.','Activo')
ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`tipo`=VALUES(`tipo`),`id_periodo`=VALUES(`id_periodo`),
  `id_carrera`=VALUES(`id_carrera`),`id_sede`=VALUES(`id_sede`),`fecha_apertura`=VALUES(`fecha_apertura`),
  `fecha_cierre`=VALUES(`fecha_cierre`),`permite_pago_tardio`=VALUES(`permite_pago_tardio`),
  `fecha_limite_pago`=VALUES(`fecha_limite_pago`),`recargo_tardio`=VALUES(`recargo_tardio`),
  `monto_recargo`=VALUES(`monto_recargo`),`aviso`=VALUES(`aviso`),`estado`=VALUES(`estado`);

-- ---------------------------------------------------------------------
-- AJUSTES PARA QUE LOS DATOS DE DEMOSTRACION SIGAN SIENDO COHERENTES
-- ---------------------------------------------------------------------
UPDATE `aranceles` SET `id_carrera` = 15 WHERE `id_arancel` = 6 AND `id_carrera` = 7;
UPDATE `aranceles` SET `id_carrera` = 11 WHERE `id_arancel` = 7 AND `id_carrera` = 10;
UPDATE `examenes`  SET `id_carrera` = 11 WHERE `id_examen` = 5 AND `id_carrera` = 10;
UPDATE `aranceles` SET `nombre` = 'Arancel mensual Ingeniería en Informática' WHERE `id_arancel` IN (3,13);
UPDATE `aranceles` SET `nombre` = 'Arancel mensual Enfermería' WHERE `id_arancel` = 6;
UPDATE `aranceles` SET `nombre` = 'Arancel mensual Derecho' WHERE `id_arancel` = 7;
UPDATE `conceptos_pago` SET `nombre` = 'Matrícula ordinaria', `descripcion` = 'Matriculación por periodo' WHERE `id_concepto_pago` = 1;
UPDATE `conceptos_pago` SET `nombre` = 'Matrícula de reinscripción' WHERE `id_concepto_pago` = 2;
UPDATE `conceptos_pago` SET `nombre` = 'Examen final', `descripcion` = 'Derecho a mesa final' WHERE `id_concepto_pago` = 6;
UPDATE `conceptos_pago` SET `nombre` = 'Examen recuperatorio' WHERE `id_concepto_pago` = 7;
UPDATE `conceptos_pago` SET `nombre` = 'Examen de titulación', `descripcion` = 'Defensa de tesis' WHERE `id_concepto_pago` = 8;
UPDATE `conceptos_pago` SET `nombre` = 'Título profesional' WHERE `id_concepto_pago` = 11;
UPDATE `tipos_tramite` SET `nombre_tramite` = 'Constancia de alumno regular' WHERE `id_tipo_tramite` = 1;
UPDATE `tipos_tramite` SET `nombre_tramite` = 'Certificado de calificaciones' WHERE `id_tipo_tramite` = 2;
UPDATE `tipos_tramite` SET `nombre_tramite` = 'Duplicado de credencial' WHERE `id_tipo_tramite` = 3;
UPDATE `tipos_tramite` SET `nombre_tramite` = 'Título profesional' WHERE `id_tipo_tramite` = 4;
UPDATE `tipos_tramite` SET `nombre_tramite` = 'Certificado de estudios completo' WHERE `id_tipo_tramite` = 5;
UPDATE `tipos_tramite` SET `nombre_tramite` = 'Justificación de inasistencia' WHERE `id_tipo_tramite` = 6;
-- Facultad y semestre de cada alumno segun su carrera real
UPDATE `alumnos` a INNER JOIN `carreras` c ON c.id_carrera = a.id_carrera SET a.`id_facultades` = c.`id_facultades`;
UPDATE `matriculas` m INNER JOIN `carreras` c ON c.id_carrera = m.id_carrera SET m.`id_facultades` = c.`id_facultades`;

-- La columna decano debe contener el nombre de la autoridad. Se limpian los
-- rotulos genericos de decanato/direccion que no identifican a una persona;
-- cada unidad los completa desde la secretaria de su facultad o escuela.
UPDATE `facultades`
   SET `decano` = NULL
 WHERE `decano` IS NOT NULL
   AND `decano` REGEXP '^(Decanato|Direccion|Dirección|Sede central)';

-- Sitio institucional de cada unidad academica.
UPDATE `facultades` SET `sitio_web` = 'https://unves.edu.py' WHERE `sitio_web` IS NULL;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  FIN DEL SCRIPT
-- =====================================================================
