<?php
/**
 * Tabla de rutas del sistema.
 * Cada modulo registra aqui sus rutas publicas, privadas y de API.
 */

use App\Core\Router;

return static function (Router $router): void {

    // =================================================================
    //  SITIO PUBLICO
    // =================================================================
    $router->get('/', 'Modulos\Inicio\InicioController@index');
    $router->get('/institucional', 'Modulos\Inicio\InicioController@institucional');
    $router->get('/carreras', 'Modulos\Inicio\InicioController@carreras');
    $router->get('/contacto', 'Modulos\Contacto\ContactoController@index');
    $router->post('/contacto', 'Modulos\Contacto\ContactoController@enviar', ['csrf']);
    $router->get('/seguimiento', 'Modulos\Tramites\TramitesController@seguimientoPublico');
    $router->get('/ayuda', 'Modulos\Inicio\InicioController@ayuda');

    // =================================================================
    //  AUTENTICACION (solo visitantes)
    // =================================================================
    $router->get('/login', 'Modulos\Auth\AuthController@mostrarLogin', ['invitado']);
    $router->post('/login', 'Modulos\Auth\AuthController@ingresar', ['invitado', 'csrf']);
    $router->get('/registro', 'Modulos\Auth\AuthController@mostrarRegistro', ['invitado']);
    $router->post('/registro', 'Modulos\Auth\AuthController@registrar', ['invitado', 'csrf']);
    $router->get('/recuperar', 'Modulos\Auth\AuthController@mostrarRecuperar', ['invitado']);
    $router->post('/recuperar', 'Modulos\Auth\AuthController@enviarRecuperacion', ['invitado', 'csrf']);
    $router->get('/restablecer/{token}', 'Modulos\Auth\AuthController@mostrarRestablecer', ['invitado']);
    $router->post('/restablecer', 'Modulos\Auth\AuthController@restablecer', ['invitado', 'csrf']);
    $router->post('/logout', 'Modulos\Auth\AuthController@salir', ['auth', 'csrf']);
    $router->get('/logout', 'Modulos\Auth\AuthController@salir', ['auth']);

    // =================================================================
    //  ZONA PRIVADA  (requiere sesion)
    // =================================================================
    $router->grupo('/', ['auth'], function (Router $r) {

        // ---- Panel principal ----------------------------------------
        $r->get('/panel', 'Modulos\Dashboard\DashboardController@index');
        $r->get('/panel/resumen', 'Modulos\Dashboard\DashboardController@resumenAjax');

        // ---- Perfil -----------------------------------------------
        $r->get('/perfil', 'Modulos\Perfil\PerfilController@index');
        $r->post('/perfil/actualizar', 'Modulos\Perfil\PerfilController@actualizar', ['csrf']);
        $r->post('/perfil/clave', 'Modulos\Perfil\PerfilController@cambiarClave', ['csrf']);
        $r->post('/perfil/foto', 'Modulos\Perfil\PerfilController@subirFoto', ['csrf']);
        $r->get('/perfil/sesiones', 'Modulos\Perfil\PerfilController@sesiones');
        $r->post('/perfil/sesiones/cerrar', 'Modulos\Perfil\PerfilController@cerrarSesion', ['csrf']);

        // ---- Notificaciones ----------------------------------------
        $r->get('/notificaciones', 'Modulos\Notificaciones\NotificacionesController@index');
        $r->get('/notificaciones/lista', 'Modulos\Notificaciones\NotificacionesController@listaJson');
        $r->post('/notificaciones/leer', 'Modulos\Notificaciones\NotificacionesController@marcarLeida', ['csrf']);
        $r->post('/notificaciones/leer-todas', 'Modulos\Notificaciones\NotificacionesController@marcarTodas', ['csrf']);

        // =============================================================
        //  MODULO PAGOS  (alumno y caja)
        // =============================================================
        $r->grupo('pagos', ['modulo:pagos'], function (Router $p) {
            $p->get('/', 'Modulos\Pagos\PagosController@index');
            $p->get('/pendientes', 'Modulos\Pagos\PagosController@pendientes');
            $p->get('/historial', 'Modulos\Pagos\PagosController@historial');
            $p->get('/carrito', 'Modulos\Pagos\PagosController@verCarrito');
            $p->post('/carrito/agregar', 'Modulos\Pagos\PagosController@agregarAlCarrito', ['csrf']);
            $p->post('/carrito/quitar', 'Modulos\Pagos\PagosController@quitarDelCarrito', ['csrf']);
            $p->post('/carrito/vaciar', 'Modulos\Pagos\PagosController@vaciarCarrito', ['csrf']);
            $p->get('/checkout', 'Modulos\Pagos\PagosController@checkout');
            $p->post('/checkout', 'Modulos\Pagos\PagosController@confirmarCheckout', ['csrf']);
            $p->post('/procesar', 'Modulos\Pagos\PagosController@procesarPago', ['csrf']);
            $p->get('/pasarela/{id}', 'Modulos\Pagos\PagosController@simularPasarela');
            $p->post('/pasarela/{id}/confirmar', 'Modulos\Pagos\PagosController@confirmarPasarela', ['csrf']);
            $p->get('/resultado/{id}', 'Modulos\Pagos\PagosController@resultado');
            $p->get('/detalle/{id}', 'Modulos\Pagos\PagosController@detalle');
            $p->get('/comprobante/{id}', 'Modulos\Pagos\PagosController@comprobante');
            $p->get('/comprobante/{id}/descargar', 'Modulos\Pagos\PagosController@descargarComprobante');
            $p->get('/api/obligaciones', 'Modulos\Pagos\PagosController@apiObligaciones');
            $p->get('/api/resumen', 'Modulos\Pagos\PagosController@apiResumen');
        });

        // ---- Caja (cobros presenciales) ------------------------------
        $r->grupo('caja', ['rol:Administrador|Cajero|Finanzas|Secretaria'], function (Router $c) {
            $c->get('/', 'Modulos\Pagos\CajaController@index');
            $c->get('/buscar-alumno', 'Modulos\Pagos\CajaController@buscarAlumno');
            $c->get('/alumno/{id}', 'Modulos\Pagos\CajaController@cuentaAlumno');
            $c->post('/cobrar', 'Modulos\Pagos\CajaController@cobrar', ['csrf']);
            $c->get('/arqueo', 'Modulos\Pagos\CajaController@arqueo');
            $c->get('/comprobante/{id}', 'Modulos\Pagos\CajaController@comprobante');
        });

        // =============================================================
        //  MODULO MATRICULAS
        // =============================================================
        $r->grupo('matriculas', ['modulo:matriculas'], function (Router $m) {
            $m->get('/', 'Modulos\Matriculas\MatriculasController@index');
            $m->get('/nueva', 'Modulos\Matriculas\MatriculasController@nueva');
            $m->post('/solicitar', 'Modulos\Matriculas\MatriculasController@solicitar', ['csrf', 'alumno']);
            $m->get('/detalle/{id}', 'Modulos\Matriculas\MatriculasController@detalle');
            $m->post('/anular', 'Modulos\Matriculas\MatriculasController@anular', ['csrf']);
            $m->get('/constancia/{id}', 'Modulos\Matriculas\MatriculasController@constancia');
            $m->get('/admin', 'Modulos\Matriculas\MatriculasController@admin', ['rol:Administrador|Secretaria|Finanzas']);
            $m->post('/admin/confirmar', 'Modulos\Matriculas\MatriculasController@confirmar', ['csrf', 'rol:Administrador|Secretaria|Finanzas']);
            $m->post('/admin/rechazar', 'Modulos\Matriculas\MatriculasController@rechazar', ['csrf', 'rol:Administrador|Secretaria|Finanzas']);
        });

        // =============================================================
        //  MODULO EXAMENES
        // =============================================================
        $r->grupo('examenes', ['modulo:examenes'], function (Router $x) {
            $x->get('/', 'Modulos\Examenes\ExamenesController@index');
            $x->get('/disponibles', 'Modulos\Examenes\ExamenesController@disponibles');
            $x->get('/mis-inscripciones', 'Modulos\Examenes\ExamenesController@misInscripciones');
            $x->post('/inscribir', 'Modulos\Examenes\ExamenesController@inscribir', ['csrf']);
            $x->post('/cancelar', 'Modulos\Examenes\ExamenesController@cancelar', ['csrf']);
            $x->get('/detalle/{id}', 'Modulos\Examenes\ExamenesController@detalle');
            $x->get('/admin', 'Modulos\Examenes\ExamenesController@admin', ['rol:Administrador|Secretaria|Docente']);
            $x->post('/admin/guardar', 'Modulos\Examenes\ExamenesController@guardar', ['csrf', 'rol:Administrador|Secretaria']);
            $x->post('/admin/eliminar', 'Modulos\Examenes\ExamenesController@eliminar', ['csrf', 'rol:Administrador|Secretaria']);
            $x->post('/admin/notas', 'Modulos\Examenes\ExamenesController@registrarNotas', ['csrf', 'rol:Administrador|Secretaria|Docente']);
            $x->get('/acta/{id}', 'Modulos\Examenes\ExamenesController@acta', ['rol:Administrador|Secretaria|Docente']);
        });

        // =============================================================
        //  MODULO TRAMITES (solicitud de documentos)
        // =============================================================
        $r->grupo('tramites', ['modulo:tramites'], function (Router $t) {
            $t->get('/', 'Modulos\Tramites\TramitesController@index');
            $t->get('/solicitar', 'Modulos\Tramites\TramitesController@solicitar');
            $t->post('/solicitar', 'Modulos\Tramites\TramitesController@guardar', ['csrf', 'alumno']);
            $t->get('/detalle/{id}', 'Modulos\Tramites\TramitesController@detalle');
            $t->post('/cancelar', 'Modulos\Tramites\TramitesController@cancelar', ['csrf']);
            $t->get('/documento/{id}', 'Modulos\Tramites\TramitesController@documento');
            $t->get('/admin', 'Modulos\Tramites\TramitesController@admin', ['rol:Administrador|Secretaria']);
            $t->post('/admin/estado', 'Modulos\Tramites\TramitesController@cambiarEstado', ['csrf', 'rol:Administrador|Secretaria']);
            $t->get('/admin/tipos', 'Modulos\Tramites\TramitesController@tipos', ['rol:Administrador|Secretaria|Finanzas']);
            $t->post('/admin/tipos/guardar', 'Modulos\Tramites\TramitesController@guardarTipo', ['csrf', 'rol:Administrador|Secretaria']);
            $t->post('/admin/tipos/eliminar', 'Modulos\Tramites\TramitesController@eliminarTipo', ['csrf', 'rol:Administrador']);
        });

        // =============================================================
        //  ADMINISTRACION
        // =============================================================

        // ---- Alumnos -------------------------------------------------
        $r->grupo('alumnos', ['rol:Administrador|Secretaria|Cajero|Finanzas|Docente'], function (Router $a) {
            $a->get('/', 'Modulos\Alumnos\AlumnosController@index');
            $a->get('/nuevo', 'Modulos\Alumnos\AlumnosController@nuevo', ['rol:Administrador|Secretaria']);
            $a->post('/guardar', 'Modulos\Alumnos\AlumnosController@guardar', ['csrf', 'rol:Administrador|Secretaria']);
            $a->get('/editar/{id}', 'Modulos\Alumnos\AlumnosController@editar', ['rol:Administrador|Secretaria']);
            $a->post('/actualizar', 'Modulos\Alumnos\AlumnosController@actualizar', ['csrf', 'rol:Administrador|Secretaria']);
            $a->get('/detalle/{id}', 'Modulos\Alumnos\AlumnosController@detalle');
            $a->post('/estado', 'Modulos\Alumnos\AlumnosController@cambiarEstado', ['csrf', 'rol:Administrador|Secretaria']);
            $a->get('/cuenta/{id}', 'Modulos\Alumnos\AlumnosController@cuentaCorriente');
            $a->get('/exportar', 'Modulos\Alumnos\AlumnosController@exportar');
        });

        // ---- Usuarios y roles ----------------------------------------
        $r->grupo('usuarios', ['rol:Administrador'], function (Router $u) {
            $u->get('/', 'Modulos\Usuarios\UsuariosController@index');
            $u->get('/nuevo', 'Modulos\Usuarios\UsuariosController@nuevo');
            $u->post('/guardar', 'Modulos\Usuarios\UsuariosController@guardar', ['csrf']);
            $u->get('/editar/{id}', 'Modulos\Usuarios\UsuariosController@editar');
            $u->post('/actualizar', 'Modulos\Usuarios\UsuariosController@actualizar', ['csrf']);
            $u->post('/estado', 'Modulos\Usuarios\UsuariosController@cambiarEstado', ['csrf']);
            $u->post('/clave', 'Modulos\Usuarios\UsuariosController@restablecerClave', ['csrf']);
            $u->post('/eliminar', 'Modulos\Usuarios\UsuariosController@eliminar', ['csrf']);
            $u->get('/roles', 'Modulos\Usuarios\UsuariosController@roles');
            $u->post('/roles/guardar', 'Modulos\Usuarios\UsuariosController@guardarRol', ['csrf']);
        });

        // ---- Estructura academica ------------------------------------
        $r->grupo('academico', ['rol:Administrador|Secretaria|Finanzas'], function (Router $ac) {
            $ac->get('/', 'Modulos\Academico\AcademicoController@index');
            $ac->get('/facultades', 'Modulos\Academico\AcademicoController@facultades');
            $ac->post('/facultades/guardar', 'Modulos\Academico\AcademicoController@guardarFacultad', ['csrf']);
            $ac->post('/facultades/eliminar', 'Modulos\Academico\AcademicoController@eliminarFacultad', ['csrf']);
            $ac->get('/sedes', 'Modulos\Academico\AcademicoController@sedes');
            $ac->post('/sedes/guardar', 'Modulos\Academico\AcademicoController@guardarSede', ['csrf']);
            $ac->post('/sedes/eliminar', 'Modulos\Academico\AcademicoController@eliminarSede', ['csrf']);
            $ac->get('/carreras', 'Modulos\Academico\AcademicoController@carreras');
            $ac->post('/carreras/guardar', 'Modulos\Academico\AcademicoController@guardarCarrera', ['csrf']);
            $ac->post('/carreras/eliminar', 'Modulos\Academico\AcademicoController@eliminarCarrera', ['csrf']);
            $ac->get('/periodos', 'Modulos\Academico\AcademicoController@periodos');
            $ac->post('/periodos/guardar', 'Modulos\Academico\AcademicoController@guardarPeriodo', ['csrf']);
            $ac->post('/periodos/activar', 'Modulos\Academico\AcademicoController@activarPeriodo', ['csrf']);
            $ac->post('/periodos/eliminar', 'Modulos\Academico\AcademicoController@eliminarPeriodo', ['csrf']);
        });

        // ---- Estructura academica (mallas, cursos y ventanas) --------
        $r->grupo('estructura', ['modulo:estructura'], function (Router $es) {
            $es->get('/', 'Modulos\Estructura\EstructuraController@index');

            $es->get('/mallas', 'Modulos\Estructura\EstructuraController@mallas');
            $es->post('/mallas/guardar', 'Modulos\Estructura\EstructuraController@guardarMalla', ['csrf']);
            $es->post('/mallas/eliminar', 'Modulos\Estructura\EstructuraController@eliminarMalla', ['csrf']);
            $es->post('/mallas/vigente', 'Modulos\Estructura\EstructuraController@marcarVigente', ['csrf']);

            $es->get('/malla/{id}', 'Modulos\Estructura\EstructuraController@malla');
            $es->post('/materias/guardar', 'Modulos\Estructura\EstructuraController@guardarMateria', ['csrf']);
            $es->post('/materias/eliminar', 'Modulos\Estructura\EstructuraController@eliminarMateria', ['csrf']);
            $es->post('/materias/importar', 'Modulos\Estructura\EstructuraController@importarMaterias', ['csrf']);

            $es->get('/cursos', 'Modulos\Estructura\EstructuraController@cursos');
            $es->post('/cursos/guardar', 'Modulos\Estructura\EstructuraController@guardarCurso', ['csrf']);
            $es->post('/cursos/eliminar', 'Modulos\Estructura\EstructuraController@eliminarCurso', ['csrf']);
            $es->post('/cursos/generar', 'Modulos\Estructura\EstructuraController@generarCursos', ['csrf']);

            $es->get('/ventanas', 'Modulos\Estructura\EstructuraController@ventanas');
            $es->post('/ventanas/guardar', 'Modulos\Estructura\EstructuraController@guardarVentana', ['csrf']);
            $es->post('/ventanas/eliminar', 'Modulos\Estructura\EstructuraController@eliminarVentana', ['csrf']);
            $es->post('/ventanas/estado', 'Modulos\Estructura\EstructuraController@estadoVentana', ['csrf']);
        });

        // ---- Aranceles y conceptos de pago ---------------------------
        $r->grupo('aranceles', ['modulo:aranceles'], function (Router $ar) {
            $ar->get('/', 'Modulos\Aranceles\ArancelesController@index');
            $ar->post('/guardar', 'Modulos\Aranceles\ArancelesController@guardar', ['csrf']);
            $ar->post('/eliminar', 'Modulos\Aranceles\ArancelesController@eliminar', ['csrf']);
            $ar->get('/conceptos', 'Modulos\Aranceles\ArancelesController@conceptos');
            $ar->post('/conceptos/guardar', 'Modulos\Aranceles\ArancelesController@guardarConcepto', ['csrf']);
            $ar->post('/conceptos/eliminar', 'Modulos\Aranceles\ArancelesController@eliminarConcepto', ['csrf']);
            $ar->get('/generar', 'Modulos\Aranceles\ArancelesController@generar');
            $ar->post('/generar', 'Modulos\Aranceles\ArancelesController@generarObligaciones', ['csrf']);
            $ar->post('/mora', 'Modulos\Aranceles\ArancelesController@aplicarMora', ['csrf']);
        });

        // ---- Becas ----------------------------------------------------
        $r->grupo('becas', ['modulo:becas'], function (Router $b) {
            $b->get('/', 'Modulos\Becas\BecasController@index');
            $b->post('/guardar', 'Modulos\Becas\BecasController@guardar', ['csrf']);
            $b->post('/eliminar', 'Modulos\Becas\BecasController@eliminar', ['csrf']);
            $b->get('/asignadas', 'Modulos\Becas\BecasController@asignadas');
            $b->post('/asignar', 'Modulos\Becas\BecasController@asignar', ['csrf']);
            $b->post('/revocar', 'Modulos\Becas\BecasController@revocar', ['csrf']);
        });

        // ---- Facturacion ---------------------------------------------
        $r->grupo('facturacion', ['modulo:facturacion'], function (Router $fa) {
            $fa->get('/', 'Modulos\Facturacion\FacturacionController@index');
            $fa->get('/facturas', 'Modulos\Facturacion\FacturacionController@facturas');
            $fa->get('/detalle/{id}', 'Modulos\Facturacion\FacturacionController@detalle');
            $fa->post('/emitir', 'Modulos\Facturacion\FacturacionController@emitir', ['csrf']);
            $fa->post('/anular', 'Modulos\Facturacion\FacturacionController@anular', ['csrf']);
            $fa->get('/timbrados', 'Modulos\Facturacion\FacturacionController@timbrados');
            $fa->post('/timbrados/guardar', 'Modulos\Facturacion\FacturacionController@guardarTimbrado', ['csrf']);
            $fa->get('/datos-fiscales', 'Modulos\Facturacion\FacturacionController@datosFiscales');
            $fa->post('/datos-fiscales/guardar', 'Modulos\Facturacion\FacturacionController@guardarDatosFiscales', ['csrf']);
        });

        // ---- Reportes -------------------------------------------------
        $r->grupo('reportes', ['modulo:reportes'], function (Router $rep) {
            $rep->get('/', 'Modulos\Reportes\ReportesController@index');
            $rep->get('/recaudacion', 'Modulos\Reportes\ReportesController@recaudacion');
            $rep->get('/morosidad', 'Modulos\Reportes\ReportesController@morosidad');
            $rep->get('/matriculas', 'Modulos\Reportes\ReportesController@matriculas');
            $rep->get('/examenes', 'Modulos\Reportes\ReportesController@examenes');
            $rep->get('/tramites', 'Modulos\Reportes\ReportesController@tramites');
            $rep->get('/alumnos', 'Modulos\Reportes\ReportesController@alumnos');
            $rep->get('/exportar', 'Modulos\Reportes\ReportesController@exportar');
            $rep->get('/api/grafico', 'Modulos\Reportes\ReportesController@apiGrafico');
        });

        // ---- Auditoria y actividad ------------------------------------
        $r->grupo('auditoria', ['rol:Administrador|Finanzas'], function (Router $au) {
            $au->get('/', 'Modulos\Auditoria\AuditoriaController@index');
            $au->get('/actividad', 'Modulos\Auditoria\AuditoriaController@actividad');
            $au->get('/sesiones', 'Modulos\Auditoria\AuditoriaController@sesiones');
            $au->get('/acciones', 'Modulos\Auditoria\AuditoriaController@acciones');
            $au->get('/detalle/{id}', 'Modulos\Auditoria\AuditoriaController@detalle');
            $au->get('/exportar', 'Modulos\Auditoria\AuditoriaController@exportar');
        });

        // ---- Integracion con el sistema central -----------------------
        $r->grupo('integracion', ['rol:Administrador|Secretaria'], function (Router $in) {
            $in->get('/', 'Modulos\Api\IntegracionController@index');
            $in->post('/sincronizar', 'Modulos\Api\IntegracionController@sincronizar', ['csrf']);
            $in->get('/historial', 'Modulos\Api\IntegracionController@historial');
            $in->get('/probando', 'Modulos\Api\IntegracionController@probarConexion');
            $in->post('/configuracion', 'Modulos\Api\IntegracionController@guardarConfiguracion', ['csrf']);
        });

        // ---- Configuracion del sistema --------------------------------
        $r->grupo('configuracion', ['rol:Administrador'], function (Router $cf) {
            $cf->get('/', 'Modulos\Configuracion\ConfiguracionController@index');
            $cf->post('/guardar', 'Modulos\Configuracion\ConfiguracionController@guardar', ['csrf']);
            $cf->get('/logs', 'Modulos\Configuracion\ConfiguracionController@logs');
            $cf->get('/respaldos', 'Modulos\Configuracion\ConfiguracionController@respaldos');
        });

        // ---- Mensajes de contacto -------------------------------------
        $r->grupo('mensajes', ['rol:Administrador|Secretaria|Finanzas'], function (Router $ms) {
            $ms->get('/', 'Modulos\Contacto\MensajesController@index');
            $ms->get('/detalle/{id}', 'Modulos\Contacto\MensajesController@detalle');
            $ms->post('/responder', 'Modulos\Contacto\MensajesController@responder', ['csrf']);
            $ms->post('/estado', 'Modulos\Contacto\MensajesController@cambiarEstado', ['csrf']);
        });
    });

    // =================================================================
    //  API PUBLICA (webhooks de pasarela)
    // =================================================================
    $router->post('/api/pasarela/notificacion', 'Modulos\Api\PasarelaController@notificacion');
    $router->post('/api/pasarela/retorno', 'Modulos\Api\PasarelaController@retorno');
    $router->get('/api/estado', 'Modulos\Api\PasarelaController@estado');
};
