-- =====================================================================
--  Limpieza de datos generados por las pruebas automaticas.
--  Deja la base con el juego de datos de demostracion original.
--  Uso: mysql -u root sistema_gestion_academica -e "source scripts/limpiar_datos_prueba.sql"
-- =====================================================================

SET FOREIGN_KEY_CHECKS = 0;
-- NOTA: este script tambien elimina el alumno de demostracion 'lucia.villalba'
-- (personas/usuarios/alumnos con id mayor al semilla). Volve a generarlo con:
--     php scripts/demo_alumno.php


-- --- Movimientos de pago -------------------------------------------------
DELETE FROM pago_detalles   WHERE id_pago_detalle  > 6;
DELETE FROM pagos           WHERE id_pago          > 6;
DELETE FROM factura_detalles;
DELETE FROM facturas;
DELETE FROM comprobantes;
DELETE FROM gateway_logs;
DELETE FROM datos_fiscales;

-- --- Actividad academica -------------------------------------------------
DELETE FROM inscripciones_examen;
DELETE FROM examenes              WHERE id_examen > 6;
DELETE FROM solicitudes_tramite   WHERE id_solicitud > 2;
DELETE FROM matriculas            WHERE id_matricula > 4;
DELETE FROM alumnos               WHERE id_alumno > 4;

-- --- Deudas y descuentos -------------------------------------------------
DELETE FROM carrito_items;
DELETE FROM obligaciones_pago WHERE id_obligacion > 13;
DELETE FROM alumno_beca       WHERE id_alumno_beca > 1;
DELETE FROM becas             WHERE id_beca > 5;

-- --- Catalogos -----------------------------------------------------------
DELETE FROM aranceles            WHERE id_arancel > 14;
DELETE FROM conceptos_pago       WHERE id_concepto_pago > 14;
DELETE FROM tipos_tramite        WHERE id_tipo_tramite > 7;
DELETE FROM carreras             WHERE id_carrera > 12;
DELETE FROM facultades           WHERE id_facultades > 5;
DELETE FROM sedes                WHERE id_sede > 4;
DELETE FROM periodos_academicos  WHERE id_periodo > 4;
DELETE FROM timbrados            WHERE id_timbrado > 2;
DELETE FROM plantillas_documento WHERE id_plantilla > 3;

-- --- Usuarios y seguridad ------------------------------------------------
DELETE FROM usuarios WHERE id_usuario > 8 OR user LIKE 'prb%';
DELETE FROM personas WHERE id_persona > 8;

DELETE FROM notificaciones;
DELETE FROM mensajes_contacto;
DELETE FROM password_resets;
DELETE FROM sesiones_web;
DELETE FROM api_sincronizaciones;
DELETE FROM auditorias;
DELETE FROM logs_actividad WHERE id_log > 1;

-- El contador de los timbrados vuelve al inicio para que la numeracion de
-- las facturas emitidas por las pruebas no deje huecos.
UPDATE timbrados SET numero_actual = numero_inicio;

-- --- Reinicio de contadores ---------------------------------------------
ALTER TABLE pago_detalles        AUTO_INCREMENT = 7;
ALTER TABLE pagos                AUTO_INCREMENT = 7;
ALTER TABLE facturas             AUTO_INCREMENT = 1;
ALTER TABLE factura_detalles     AUTO_INCREMENT = 1;
ALTER TABLE comprobantes         AUTO_INCREMENT = 1;
ALTER TABLE gateway_logs         AUTO_INCREMENT = 1;
ALTER TABLE datos_fiscales       AUTO_INCREMENT = 1;
ALTER TABLE inscripciones_examen AUTO_INCREMENT = 1;
ALTER TABLE examenes             AUTO_INCREMENT = 7;
ALTER TABLE solicitudes_tramite  AUTO_INCREMENT = 3;
ALTER TABLE matriculas           AUTO_INCREMENT = 5;
ALTER TABLE alumnos              AUTO_INCREMENT = 5;
ALTER TABLE carrito_items        AUTO_INCREMENT = 1;
ALTER TABLE obligaciones_pago    AUTO_INCREMENT = 14;
ALTER TABLE alumno_beca          AUTO_INCREMENT = 2;
ALTER TABLE becas                AUTO_INCREMENT = 6;
ALTER TABLE aranceles            AUTO_INCREMENT = 15;
ALTER TABLE conceptos_pago       AUTO_INCREMENT = 15;
ALTER TABLE tipos_tramite        AUTO_INCREMENT = 8;
ALTER TABLE carreras             AUTO_INCREMENT = 13;
ALTER TABLE facultades           AUTO_INCREMENT = 6;
ALTER TABLE sedes                AUTO_INCREMENT = 5;
ALTER TABLE periodos_academicos  AUTO_INCREMENT = 5;
ALTER TABLE timbrados            AUTO_INCREMENT = 3;
ALTER TABLE plantillas_documento AUTO_INCREMENT = 4;
ALTER TABLE usuarios             AUTO_INCREMENT = 9;
ALTER TABLE personas             AUTO_INCREMENT = 9;
ALTER TABLE notificaciones       AUTO_INCREMENT = 1;
ALTER TABLE mensajes_contacto    AUTO_INCREMENT = 1;
ALTER TABLE password_resets      AUTO_INCREMENT = 1;
ALTER TABLE sesiones_web         AUTO_INCREMENT = 1;
ALTER TABLE api_sincronizaciones AUTO_INCREMENT = 1;
ALTER TABLE auditorias           AUTO_INCREMENT = 1;
ALTER TABLE logs_actividad       AUTO_INCREMENT = 2;

SET FOREIGN_KEY_CHECKS = 1;
