# -*- coding: utf-8 -*-
"""Genera sql/05_datos_unves.sql con la informacion institucional real de la UNVES."""
import json, io, os

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
MALLAS = json.load(io.open(os.path.join(RAIZ, 'almacen', 'cache', 'unves_mallas.json'), encoding='utf-8'))

S = io.open(os.path.join(RAIZ, 'sql', '05_datos_unves.sql'), 'w', encoding='utf-8', newline='\n')

def q(v):
    if v is None:
        return 'NULL'
    return "'" + str(v).replace('\\', '\\\\').replace("'", "''") + "'"

def n(v):
    return 'NULL' if v is None else str(v)

def w(*lineas):
    for linea in lineas:
        S.write(str(linea) + '\n')

# ------------------------------------------------------------------ #
#  Unidades academicas (13 facultades y escuelas de la UNVES)
# ------------------------------------------------------------------ #
FACULTADES = [
    (1,  'FCE',  'Ciencias Económicas',                          'Facultad'),
    (2,  'FIA',  'Ingeniería y Arquitectura',                    'Facultad'),
    (3,  'FCS',  'Ciencias de la Salud',                         'Facultad'),
    (4,  'FCJP', 'Ciencias Jurídicas, Políticas y Sociales',     'Facultad'),
    (5,  'FFCH', 'Filosofía y Ciencias Humanas',                 'Facultad'),
    (6,  'FPOL', 'Politécnica',                                  'Facultad'),
    (7,  'FFQM', 'Ciencias Físicas, Químicas y Matemáticas',     'Facultad'),
    (8,  'FCA',  'Ciencias Agrarias',                            'Facultad'),
    (9,  'FC',   'Facultad de Ciencias',                         'Facultad'),
    (10, 'EA',   'Escuela de Arte',                              'Escuela'),
    (11, 'EG',   'Escuela de Gastronomía',                       'Escuela'),
    (12, 'EP',   'Escuela de Posgrado',                          'Escuela'),
]

SEDES = [
    (1, 'Campus Central - Villarrica', "Bvar. Río Apa entre Pa'i Anasagasti y Juan Carlos Scavone", 'Villarrica',           '(+595 541) 44 535', 'rectorado@unves.edu.py', 1, 'Campus'),
    (2, 'Sede Paraguarí',              'Calle 14 de Mayo e/ Mcal. López, Paraguarí',                'Paraguarí',            None,                None,                     0, 'Filial'),
    (3, 'Sede Yuty',                   'Ruta PY08, Yuty',                                           'Yuty',                 None,                None,                     0, 'Filial'),
    (4, 'Sede Caazapá',                'Avda. Florida, Caazapá',                                    'Caazapá',              None,                None,                     0, 'Filial'),
    (5, 'Sede Carapeguá',              'Ruta PY01, Carapeguá',                                      'Carapeguá',            None,                None,                     0, 'Filial'),
    (6, 'Sede Pedro Juan Caballero',   'Avda. Internacional, Pedro Juan Caballero',                 'Pedro Juan Caballero', None,                None,                     0, 'Filial'),
]

# (id, codigo, nombre, titulo, facultad, anios, semestres, carga, area, sedes)
CARRERAS = [
    (1,  'ADM',    'Licenciatura en Administración de Empresa',                'Licenciado/a en Administración de Empresa',        1,  None, None, None, 'Ciencias Empresariales',      [1, 4, 5, 6]),
    (2,  'CONT',   'Licenciatura en Ciencias Contables y Auditoría',           'Contador/a Público/a',                            1,  5,    10,   None, 'Ciencias Empresariales',      [1, 2, 4, 5]),
    (3,  'EDU',    'Licenciatura en Ciencias de la Educación',                 'Licenciado/a en Ciencias de la Educación',        5,  4,    8,    5040, 'Ciencias de la Educación',    [1, 3, 4, 6]),
    (4,  'INFO',   'Ingeniería en Informática',                                'Ingeniero/a en Informática',                      6,  6,    12,   None, 'Ingeniería',                  [1]),
    (5,  'IELE',   'Ingeniería Eléctrica',                                     'Ingeniero/a Electricista',                        6,  5,    10,   None, 'Ingeniería',                  [1]),
    (6,  'IAM',    'Ingeniería Ambiental',                                     'Ingeniero/a Ambiental',                           2,  None, None, None, 'Ingeniería',                  [1]),
    (7,  'ARQ',    'Arquitectura',                                             'Arquitecto/a',                                    2,  None, None, None, 'Arquitectura',                [1]),
    (8,  'COM',    'Licenciatura en Ciencias de la Comunicación',              'Licenciado/a en Ciencias de la Comunicación',     5,  4,    8,    5040, 'Comunicación',                [1]),
    (9,  'GE',     'Licenciatura en Gestión Educativa',                        'Licenciado/a en Gestión Educativa',               5,  4,    8,    5040, 'Ciencias de la Educación',    [1]),
    (10, 'ING',    'Licenciatura en Inglés',                                   'Licenciado/a en Lengua Inglesa',                  5,  4,    8,    5040, 'Idiomas',                     [1]),
    (11, 'DER',    'Derecho',                                                  'Abogado/a',                                       4,  None, None, None, 'Ciencias Jurídicas',          [1]),
    (12, 'IQ',     'Ingeniería Química',                                       'Ingeniero/a Químico/a',                           7,  None, None, None, 'Ciencias Químicas',           [1]),
    (13, 'PSI',    'Licenciatura en Psicología',                               'Licenciado/a en Psicología',                      3,  None, None, None, 'Ciencias de la Salud',        [1]),
    (14, 'NUT',    'Licenciatura en Nutrición',                                'Licenciado/a en Nutrición',                       3,  None, None, None, 'Ciencias de la Salud',        [1]),
    (15, 'ENF',    'Licenciatura en Enfermería',                               'Licenciado/a en Enfermería',                      3,  None, None, None, 'Ciencias de la Salud',        [1, 6]),
    (16, 'AGRO',   'Ingeniería en Agroindustria',                              'Ingeniero/a en Agroindustria',                    8,  5,    10,   None, 'Ciencias Agrarias',           [1]),
    (17, 'ZOO',    'Ingeniería en Zootecnia',                                  'Ingeniero/a en Zootecnia',                        8,  5,    10,   None, 'Ciencias Agrarias',           [1]),
    (18, 'GP',     'Licenciatura en Gestión Pública',                          'Licenciado/a en Gestión Pública',                 9,  4,    8,    5040, 'Gestión Pública',             [5]),
    (19, 'GHT',    'Licenciatura en Gastronomía, Hotelería y Turismo',         'Licenciado/a en Gastronomía, Hotelería y Turismo', 11, None, None, None, 'Gastronomía y Turismo',       [2]),
    (20, 'IPADR',  'Ingeniería en Producción Agropecuaria y Desarrollo Rural', 'Ingeniero/a en Producción Agropecuaria',          9,  None, None, None, 'Ciencias Agrarias',           [5]),
    (21, 'MUS',    'Licenciatura en Música',                                   'Licenciado/a en Música',                          10, 4,    8,    5040, 'Artes',                       [1]),
    (22, 'HT',     'Licenciatura en Hotelería y Turismo',                      'Licenciado/a en Hotelería y Turismo',             11, None, None, None, 'Gastronomía y Turismo',       [1]),
    (23, 'GAS',    'Licenciatura en Gastronomía',                              'Licenciado/a en Gastronomía',                     11, None, None, None, 'Gastronomía y Turismo',       [1]),
    (24, 'POS-ES', 'Especialización en Didáctica Superior Universitaria',      'Especialista en Didáctica Superior Universitaria', 12, None, None, None, 'Posgrado',                    [1]),
    (25, 'POS-MA', 'Maestría en Didáctica Superior Universitaria',             'Magíster en Didáctica Superior Universitaria',     12, None, None, None, 'Posgrado',                    [1]),
]

MALLAS_REALES = {
    4: ('/facultades/politecnica/carreras/ingenieria-en-informatica', 'Plan 2015 - Ingeniería en Informática'),
    5: ('/facultades/politecnica/carreras/ingenieria-electrica',      'Plan 2015 - Ingeniería Eléctrica'),
}

VENTANAS = [
    (1,  'Matriculación 2026-2 (general)',                    'Matricula', 3, None, None, '2026-07-01', '2026-08-15', 1, '2027-03-31', 10.00, 0,     'El plazo ordinario venció. Podés matricularte con un recargo del 10% hasta el 31/03/2027.', 'Activo'),
    (2,  'Matriculación 2026-2 - Ingeniería en Informática',  'Matricula', 3, 4,    1,    '2026-09-01', '2026-12-05', 1, '2027-02-28', 5.00,  0,     'Matriculación extraordinaria habilitada para Ingeniería en Informática hasta el 05/12/2026.', 'Activo'),
    (3,  'Inscripción y pago de exámenes 2026-2',             'Examen',    3, None, None, '2026-09-15', '2026-11-25', 1, '2026-12-05', 10.00, 50000, 'Podés inscribirte y pagar mesas finales hasta el 25/11/2026. Después se aplica un recargo del 10% más Gs. 50.000.', 'Activo'),
    (4,  'Aranceles 2026-2',                                  'Arancel',   3, None, None, '2026-07-20', '2026-12-18', 1, '2027-03-31', 8.00,  0,     'Los aranceles del periodo se pueden pagar en línea hasta el 18/12/2026. Luego se aplica un recargo del 8%.', 'Activo'),
    (5,  'Trámites y documentos 2026-2',                      'Tramite',   3, None, None, '2026-07-20', '2026-12-18', 0, None,        0.00,  0,     'Solicitud de constancias y certificados habilitada hasta el 18/12/2026.', 'Activo'),
    (6,  'Matriculación 2026-1',                              'Matricula', 2, None, None, '2026-01-26', '2026-02-20', 0, None,        0.00,  0,     'El plazo de matriculación del primer semestre 2026 ya finalizó.', 'Activo'),
    (7,  'Inscripción y pago de exámenes 2026-1',             'Examen',    2, None, None, '2026-05-04', '2026-06-15', 0, None,        0.00,  0,     'Las mesas finales del primer semestre 2026 están cerradas.', 'Activo'),
    (8,  'Matriculación 2025-2',                              'Matricula', 1, None, None, '2025-07-01', '2025-08-20', 0, None,        0.00,  0,     'Periodo cerrado.', 'Activo'),
    (9,  'Matriculación 2027-1',                              'Matricula', 4, None, None, '2027-01-25', '2027-02-26', 0, None,        0.00,  0,     'Matriculación del primer semestre 2027: del 25/01 al 26/02/2027.', 'Activo'),
    (10, 'Aranceles 2027-1',                                  'Arancel',   4, None, None, '2027-02-01', '2027-07-16', 1, '2027-08-31', 8.00,  0,     'Aranceles del primer semestre 2027.', 'Activo'),
]

# ================================================================== #
w('-- =====================================================================',
  '--  SISTEMA DE GESTION ACADEMICA UNVES - DATOS INSTITUCIONALES',
  '--  Archivo : sql/05_datos_unves.sql',
  '--  Objetivo: Unidades academicas, sedes, carreras, oferta por sede,',
  '--            mallas curriculares, cursos abiertos y ventanas academicas',
  '--            con la informacion publica de la UNVES.',
  '--  Nota    : Script IDEMPOTENTE (ON DUPLICATE KEY UPDATE).',
  '--  Cuidado : aplicarlo con  mysql --default-character-set=utf8mb4 < archivo',
  '--            para no perder los acentos.',
  '-- =====================================================================',
  '',
  'SET NAMES utf8mb4;',
  'SET FOREIGN_KEY_CHECKS = 0;',
  '')

# ------------------------------------------------------- Facultades
w('-- ---------------------------------------------------------------------',
  '-- UNIDADES ACADEMICAS (facultades y escuelas)',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `facultades` (`id_facultades`,`siglas`,`nombre`,`tipo`,`estado`) VALUES')
filas = ['  (%d,%s,%s,%s,\'Activo\')' % (i, q(sig), q(nom), q(tipo)) for i, sig, nom, tipo in FACULTADES]
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `siglas`=VALUES(`siglas`),`nombre`=VALUES(`nombre`),`tipo`=VALUES(`tipo`);', '')

# ------------------------------------------------------------ Sedes
w('-- ---------------------------------------------------------------------',
  '-- SEDES',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `sedes` (`id_sede`,`nombre`,`direccion`,`ciudad`,`telefono`,`email`,`es_central`,`tipo`,`estado`) VALUES')
filas = ['  (%d,%s,%s,%s,%s,%s,%d,%s,\'Activo\')' % (i, q(nom), q(dir_), q(ciu), q(tel), q(ema), cen, q(tipo))
         for i, nom, dir_, ciu, tel, ema, cen, tipo in SEDES]
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`direccion`=VALUES(`direccion`),`ciudad`=VALUES(`ciudad`),'
  '`telefono`=VALUES(`telefono`),`email`=VALUES(`email`),`es_central`=VALUES(`es_central`),`tipo`=VALUES(`tipo`);', '')

# --------------------------------------------------------- Carreras
w('-- ---------------------------------------------------------------------',
  '-- CARRERAS DE GRADO Y POSGRADO',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `carreras` (`id_carrera`,`codigo_carrera`,`nombre`,`titulo_otorgado`,`id_facultades`,',
  '  `duracion_anio`,`duracion_anios`,`duracion_semestres`,`carga_horaria`,`area`,`estado`) VALUES')
filas = ['  (%d,%s,%s,%s,%d,%s,%s,%s,%s,%s,\'Activo\')' % (cid, q(cod), q(nom), q(tit), fac, n(a), n(a), n(sem), n(carga), q(area))
         for cid, cod, nom, tit, fac, a, sem, carga, area, _sd in CARRERAS]
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `codigo_carrera`=VALUES(`codigo_carrera`),`nombre`=VALUES(`nombre`),',
  '  `titulo_otorgado`=VALUES(`titulo_otorgado`),`id_facultades`=VALUES(`id_facultades`),',
  '  `duracion_anio`=VALUES(`duracion_anio`),`duracion_anios`=VALUES(`duracion_anios`),',
  '  `duracion_semestres`=VALUES(`duracion_semestres`),`carga_horaria`=VALUES(`carga_horaria`),',
  '  `area`=VALUES(`area`),`estado`=VALUES(`estado`);', '',
  '-- Carreras cargadas por pruebas o fuera de la oferta actual',
  'UPDATE `carreras` SET `estado` = \'Inactivo\' WHERE id_carrera > %d;' % len(CARRERAS), '')

# ------------------------------------------------ Oferta por sede
w('-- ---------------------------------------------------------------------',
  '-- OFERTA ACADEMICA POR SEDE',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `carrera_sede` (`id_carrera`,`id_sede`,`turnos`,`cupo`,`estado`) VALUES')
filas = []
for cid, _cod, _nom, _tit, _fac, _a, _s, _c, _ar, sd in CARRERAS:
    turnos = 'Mañana,Tarde,Noche' if cid <= 17 or cid == 21 else 'Noche'
    for s in sd:
        filas.append('  (%d,%d,%s,0,\'Activo\')' % (cid, s, q(turnos)))
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `turnos`=VALUES(`turnos`),`estado`=VALUES(`estado`);', '')

# ----------------------------------------------------------- Mallas
w('-- ---------------------------------------------------------------------',
  '-- MALLAS CURRICULARES (plan de estudios por carrera)',
  '-- Las carreras cuya malla no esta publicada como tabla quedan con la',
  '-- cabecera creada para que secretaria cargue sus materias.',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `mallas_curriculares` (`id_malla`,`id_carrera`,`nombre`,`anio_vigencia`,`total_cursos`,`total_semestres`,`carga_horaria`,`vigente`,`observaciones`,`estado`) VALUES')
filas = []
for cid, cod, nom, _tit, _fac, a, sem, carga, _area, _sd in CARRERAS:
    malla = MALLAS.get(MALLAS_REALES[cid][0]) if cid in MALLAS_REALES else None
    if malla and malla['filas']:
        cursos = max(f['curso'] for f in malla['filas'])
        carga_m = sum(f['horas'] for f in malla['filas'])
        obs = 'Malla cargada desde la información pública de la UNVES.'
        nombre = MALLAS_REALES[cid][1]
    else:
        cursos = a or 5
        carga_m = carga or 0
        obs = 'Pendiente de carga: usá la carga masiva con la lista de materias del plan de estudios.'
        nombre = 'Plan de estudios vigente - ' + nom
    filas.append('  (%d,%d,%s,2015,%d,2,%d,1,%s,\'Activo\')' % (cid, cid, q(nombre), cursos, carga_m, q(obs)))
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`total_cursos`=VALUES(`total_cursos`),',
  '  `carga_horaria`=VALUES(`carga_horaria`),`observaciones`=VALUES(`observaciones`),`estado`=VALUES(`estado`);', '')

# --------------------------------------------------------- Materias
w('-- ---------------------------------------------------------------------',
  '-- MATERIAS DE LA MALLA (carrera + curso + semestre)',
  '-- Se cargan las mallas que la universidad publica como tabla editable.',
  '-- ---------------------------------------------------------------------')
for cid, (ruta, nombre_malla) in sorted(MALLAS_REALES.items()):
    malla = MALLAS[ruta]
    w('-- %s (%d materias)' % (MALLAS[ruta]['nombre'], len(malla['filas'])))
    w('INSERT INTO `materias` (`id_malla`,`id_carrera`,`codigo`,`nombre`,`curso`,`semestre`,`semestre_global`,`horas_catedra`,`creditos`,`tipo`,`orden`,`estado`) VALUES')
    filas = []
    orden = 0
    for f in sorted(malla['filas'], key=lambda x: (x['curso'], x['semestre'], x['codigo'])):
        orden += 1
        sem_dentro = ((f['semestre'] - 1) % 2) + 1
        creditos = round(f['horas'] / 90.0 * 3, 2)
        filas.append('  (%d,%d,%s,%s,%d,%d,%d,%d,%s,\'Obligatoria\',%d,\'Activo\')' % (
            cid, cid, q(f['codigo']), q(f['materia']), f['curso'], sem_dentro, f['semestre'], f['horas'], creditos, orden))
    w(',\n'.join(filas))
    w('ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`curso`=VALUES(`curso`),`semestre`=VALUES(`semestre`),',
      '  `semestre_global`=VALUES(`semestre_global`),`horas_catedra`=VALUES(`horas_catedra`),',
      '  `creditos`=VALUES(`creditos`),`orden`=VALUES(`orden`);', '')

# ---------------------------------------------------- Cursos abiertos
w('-- ---------------------------------------------------------------------',
  '-- CURSOS ABIERTOS DEL PERIODO ACTIVO (divisiones con cupo)',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `cursos_academicos` (`id_carrera`,`id_periodo`,`id_sede`,`id_malla`,`curso`,`semestre`,`seccion`,`turno`,`modalidad`,`aula`,`cupo`,`estado`) VALUES')
filas = []
for cid, _cod, _nom, _tit, _fac, _a, _s, _c, _ar, _sd in CARRERAS:
    if cid not in (1, 2, 4, 11, 15):
        continue
    anio_max = 6 if cid == 4 else 2
    for curso in range(1, anio_max + 1):
        for sem in (1, 2):
            filas.append('  (%d,3,1,%d,%d,%d,\'A\',\'Noche\',\'Presencial\',%s,40,\'Abierto\')' % (
                cid, cid, curso, sem, q('Aula %02d' % (curso * 2 + sem))))
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `cupo`=VALUES(`cupo`),`aula`=VALUES(`aula`),`estado`=VALUES(`estado`);', '')

# ---------------------------------------------------------- Ventanas
w('-- ---------------------------------------------------------------------',
  '-- VENTANAS ACADEMICAS (desde y hasta cuando se puede operar en linea)',
  '-- ---------------------------------------------------------------------',
  'INSERT INTO `ventanas_academicas` (`id_ventana`,`nombre`,`tipo`,`id_periodo`,`id_carrera`,`id_sede`,',
  '  `fecha_apertura`,`fecha_cierre`,`permite_pago_tardio`,`fecha_limite_pago`,`recargo_tardio`,`monto_recargo`,`aviso`,`estado`) VALUES')
filas = ['  (%d,%s,%s,%s,%s,%s,%s,%s,%d,%s,%s,%s,%s,%s)' % (
    v, q(nom), q(tipo), n(per), n(car), n(sed), q(ap), q(ci), tardio, q(lim), rec, monto, q(aviso), q(est))
    for v, nom, tipo, per, car, sed, ap, ci, tardio, lim, rec, monto, aviso, est in VENTANAS]
w(',\n'.join(filas))
w('ON DUPLICATE KEY UPDATE `nombre`=VALUES(`nombre`),`tipo`=VALUES(`tipo`),`id_periodo`=VALUES(`id_periodo`),',
  '  `id_carrera`=VALUES(`id_carrera`),`id_sede`=VALUES(`id_sede`),`fecha_apertura`=VALUES(`fecha_apertura`),',
  '  `fecha_cierre`=VALUES(`fecha_cierre`),`permite_pago_tardio`=VALUES(`permite_pago_tardio`),',
  '  `fecha_limite_pago`=VALUES(`fecha_limite_pago`),`recargo_tardio`=VALUES(`recargo_tardio`),',
  '  `monto_recargo`=VALUES(`monto_recargo`),`aviso`=VALUES(`aviso`),`estado`=VALUES(`estado`);', '')

# ----------------------------------------------------------- Ajustes
w('-- ---------------------------------------------------------------------',
  '-- AJUSTES PARA QUE LOS DATOS DE DEMOSTRACION SIGAN SIENDO COHERENTES',
  '-- ---------------------------------------------------------------------',
  'UPDATE `aranceles` SET `id_carrera` = 15 WHERE `id_arancel` = 6 AND `id_carrera` = 7;',
  'UPDATE `aranceles` SET `id_carrera` = 11 WHERE `id_arancel` = 7 AND `id_carrera` = 10;',
  'UPDATE `examenes`  SET `id_carrera` = 11 WHERE `id_examen` = 5 AND `id_carrera` = 10;',
  'UPDATE `aranceles` SET `nombre` = \'Arancel mensual Ingeniería en Informática\' WHERE `id_arancel` IN (3,13);',
  'UPDATE `aranceles` SET `nombre` = \'Arancel mensual Enfermería\' WHERE `id_arancel` = 6;',
  'UPDATE `aranceles` SET `nombre` = \'Arancel mensual Derecho\' WHERE `id_arancel` = 7;',
  'UPDATE `conceptos_pago` SET `nombre` = \'Matrícula ordinaria\', `descripcion` = \'Matriculación por periodo\' WHERE `id_concepto_pago` = 1;',
  'UPDATE `conceptos_pago` SET `nombre` = \'Matrícula de reinscripción\' WHERE `id_concepto_pago` = 2;',
  'UPDATE `conceptos_pago` SET `nombre` = \'Examen final\', `descripcion` = \'Derecho a mesa final\' WHERE `id_concepto_pago` = 6;',
  'UPDATE `conceptos_pago` SET `nombre` = \'Examen recuperatorio\' WHERE `id_concepto_pago` = 7;',
  'UPDATE `conceptos_pago` SET `nombre` = \'Examen de titulación\', `descripcion` = \'Defensa de tesis\' WHERE `id_concepto_pago` = 8;',
  'UPDATE `conceptos_pago` SET `nombre` = \'Título profesional\' WHERE `id_concepto_pago` = 11;',
  'UPDATE `tipos_tramite` SET `nombre_tramite` = \'Constancia de alumno regular\' WHERE `id_tipo_tramite` = 1;',
  'UPDATE `tipos_tramite` SET `nombre_tramite` = \'Certificado de calificaciones\' WHERE `id_tipo_tramite` = 2;',
  'UPDATE `tipos_tramite` SET `nombre_tramite` = \'Duplicado de credencial\' WHERE `id_tipo_tramite` = 3;',
  'UPDATE `tipos_tramite` SET `nombre_tramite` = \'Título profesional\' WHERE `id_tipo_tramite` = 4;',
  'UPDATE `tipos_tramite` SET `nombre_tramite` = \'Certificado de estudios completo\' WHERE `id_tipo_tramite` = 5;',
  'UPDATE `tipos_tramite` SET `nombre_tramite` = \'Justificación de inasistencia\' WHERE `id_tipo_tramite` = 6;',
  '-- Facultad y semestre de cada alumno segun su carrera real',
  'UPDATE `alumnos` a INNER JOIN `carreras` c ON c.id_carrera = a.id_carrera SET a.`id_facultades` = c.`id_facultades`;',
  'UPDATE `matriculas` m INNER JOIN `carreras` c ON c.id_carrera = m.id_carrera SET m.`id_facultades` = c.`id_facultades`;',
  '',
  'SET FOREIGN_KEY_CHECKS = 1;',
  '',
  '-- =====================================================================',
  '--  FIN DEL SCRIPT',
  '-- =====================================================================')

S.close()
print('sql/05_datos_unves.sql regenerado')
print('  unidades academicas:', len(FACULTADES), '| sedes:', len(SEDES), '| carreras:', len(CARRERAS))
print('  ventanas:', len(VENTANAS), '| materias reales:', sum(len(MALLAS[r[0]]['filas']) for r in MALLAS_REALES.values()))
