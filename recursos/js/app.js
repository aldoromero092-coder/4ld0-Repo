/* =====================================================================
   app.js — Funcionalidad general del portal
   ===================================================================== */

const UnvesApp = (() => {
    'use strict';

    /* -------------------------------------------------------- Notificaciones */
    const avisos = {
        contenedor: null,

        obtener() {
            if (!this.contenedor) {
                this.contenedor = document.querySelector('.avisos');
                if (!this.contenedor) {
                    this.contenedor = document.createElement('div');
                    this.contenedor.className = 'avisos';
                    this.contenedor.setAttribute('role', 'status');
                    this.contenedor.setAttribute('aria-live', 'polite');
                    document.body.appendChild(this.contenedor);
                }
            }
            return this.contenedor;
        },

        mostrar(mensaje, tipo = 'info', duracion = 5200) {
            const iconos = { info: 'ℹ️', exito: '✅', advertencia: '⚠️', error: '⛔' };
            const aviso = document.createElement('div');
            aviso.className = 'aviso ' + tipo;
            aviso.innerHTML = '<span class="alerta-icono">' + (iconos[tipo] || iconos.info) + '</span>'
                + '<div class="crecer cuerpo"></div>'
                + '<button type="button" class="btn-fantasma btn btn-sm" aria-label="Cerrar">✕</button>';

            aviso.querySelector('.cuerpo').textContent = mensaje;
            aviso.querySelector('button').addEventListener('click', () => this.cerrar(aviso));

            this.obtener().appendChild(aviso);

            if (duracion > 0) {
                setTimeout(() => this.cerrar(aviso), duracion);
            }

            return aviso;
        },

        cerrar(aviso) {
            if (!aviso || !aviso.parentNode) return;
            aviso.classList.add('cerrando');
            setTimeout(() => aviso.remove(), 220);
        },

        exito(m, d) { return this.mostrar(m, 'exito', d); },
        error(m, d) { return this.mostrar(m, 'error', d); },
        advertencia(m, d) { return this.mostrar(m, 'advertencia', d); },
        info(m, d) { return this.mostrar(m, 'info', d); }
    };

    /* ---------------------------------------------------------------- Menú */
    function iniciarMenus() {
        document.addEventListener('click', (e) => {
            const disparador = e.target.closest('[data-menu]');
            const destino = disparador ? disparador.getAttribute('data-menu') : null;

            document.querySelectorAll('.menu-desplegable.abierto').forEach((menu) => {
                if (!destino || menu.id !== destino) {
                    menu.classList.remove('abierto');
                    const boton = document.querySelector('[data-menu="' + menu.id + '"]');
                    if (boton) boton.setAttribute('aria-expanded', 'false');
                }
            });

            if (disparador && destino) {
                e.preventDefault();
                const menu = document.getElementById(destino);
                if (menu) {
                    const abierto = menu.classList.toggle('abierto');
                    disparador.setAttribute('aria-expanded', abierto ? 'true' : 'false');
                }
            }
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                document.querySelectorAll('.menu-desplegable.abierto').forEach((m) => m.classList.remove('abierto'));
                document.querySelectorAll('.modal-fondo.abierto').forEach((m) => cerrarModal(m));
                cerrarPaneles();
            }
        });
    }

    /* ------------------------------------------------- Barra lateral móvil */
    function iniciarBarraLateral() {
        const barra = document.querySelector('.barra-lateral');
        const menuPublico = document.querySelector('.pub-menu');

        document.querySelectorAll('[data-alternar-menu]').forEach((boton) => {
            boton.addEventListener('click', () => {
                // Panel privado
                if (barra) {
                    barra.classList.toggle('abierta');
                    capaOscura().classList.toggle('visible', barra.classList.contains('abierta'));
                    return;
                }
                // Sitio público
                if (menuPublico) {
                    menuPublico.classList.toggle('abierto');
                    boton.setAttribute('aria-expanded', menuPublico.classList.contains('abierto') ? 'true' : 'false');
                }
            });
        });

        if (!barra) {
            return;
        }

        capaOscura().addEventListener('click', () => {
            barra.classList.remove('abierta');
            capaOscura().classList.remove('visible');
            cerrarPaneles();
        });
    }

    function capaOscura() {
        let capa = document.querySelector('.capa-oscura');
        if (!capa) {
            capa = document.createElement('div');
            capa.className = 'capa-oscura';
            document.body.appendChild(capa);
        }
        return capa;
    }

    /* ---------------------------------------------------------------- Modales */
    function abrirModal(id) {
        const modal = typeof id === 'string' ? document.getElementById(id) : id;
        if (!modal) return;
        modal.classList.add('abierto');
        document.body.style.overflow = 'hidden';
        const primero = modal.querySelector('input:not([type=hidden]), select, textarea, button');
        if (primero) setTimeout(() => primero.focus(), 60);
    }

    function cerrarModal(id) {
        const modal = typeof id === 'string' ? document.getElementById(id) : id;
        if (!modal) return;
        modal.classList.remove('abierto');
        if (!document.querySelector('.modal-fondo.abierto')) {
            document.body.style.overflow = '';
        }
    }

    function iniciarModales() {
        document.addEventListener('click', (e) => {
            const abrir = e.target.closest('[data-abrir-modal]');
            if (abrir) {
                e.preventDefault();
                abrirModal(abrir.getAttribute('data-abrir-modal'));
                return;
            }

            const cerrar = e.target.closest('[data-cerrar-modal]');
            if (cerrar) {
                e.preventDefault();
                cerrarModal(cerrar.closest('.modal-fondo'));
                return;
            }

            if (e.target.classList.contains('modal-fondo')) {
                cerrarModal(e.target);
            }
        });
    }

    /* -------------------------------------------------- Panel de notificaciones */
    function abrirPanel(id) {
        const panel = document.getElementById(id);
        if (!panel) return;
        panel.classList.add('abierto');
        capaOscura().classList.add('visible');
    }

    function cerrarPaneles() {
        document.querySelectorAll('.panel-lateral.abierto').forEach((p) => p.classList.remove('abierto'));
        capaOscura().classList.remove('visible');
    }

    function iniciarPaneles() {
        document.querySelectorAll('[data-abrir-panel]').forEach((boton) => {
            boton.addEventListener('click', () => abrirPanel(boton.getAttribute('data-abrir-panel')));
        });
        document.querySelectorAll('[data-cerrar-panel]').forEach((boton) => {
            boton.addEventListener('click', cerrarPaneles);
        });
    }

    /* --------------------------------------------------------- Formularios */
    function iniciarConfirmaciones() {
        document.addEventListener('submit', (e) => {
            const formulario = e.target;
            const mensaje = formulario.getAttribute('data-confirmar');
            if (mensaje && !window.confirm(mensaje)) {
                e.preventDefault();
                return;
            }
            if (formulario.dataset.enviando === '1') {
                e.preventDefault();
                return;
            }
            formulario.dataset.enviando = '1';
            const boton = formulario.querySelector('button[type=submit]:not([data-sin-cargar])');
            if (boton && !boton.dataset.contenidoOriginal) {
                boton.dataset.contenidoOriginal = boton.innerHTML;
                boton.innerHTML = '<span class="spinner"></span> Procesando…';
                boton.classList.add('deshabilitado');
            }
        });

        document.addEventListener('click', (e) => {
            const enlace = e.target.closest('a[data-confirmar]');
            if (enlace && !window.confirm(enlace.getAttribute('data-confirmar'))) {
                e.preventDefault();
            }
        });
    }

    /** Envío de formularios por AJAX con data-ajax. */
    function iniciarFormulariosAjax() {
        document.addEventListener('submit', async (e) => {
            const formulario = e.target;
            if (!formulario.hasAttribute('data-ajax')) return;

            e.preventDefault();
            const respuesta = await UnvesApi.enviarFormularioElemento(formulario);

            if (respuesta.ok) {
                avisos.exito(respuesta.mensaje || 'Operación realizada con éxito.');
                if (respuesta.url) {
                    setTimeout(() => { window.location.href = respuesta.url; }, 700);
                } else if (formulario.dataset.recargar !== 'no') {
                    setTimeout(() => window.location.reload(), 900);
                }
            } else {
                avisos.error(respuesta.mensaje || 'No se pudo completar la operación.');
                const boton = formulario.querySelector('button[type=submit]');
                if (boton && boton.dataset.contenidoOriginal) {
                    boton.innerHTML = boton.dataset.contenidoOriginal;
                    boton.classList.remove('deshabilitado');
                }
                formulario.dataset.enviando = '0';
            }
        });
    }

    /* ---------------------------------------------- Formato de montos en inputs */
    function iniciarMascarasMonto() {
        document.querySelectorAll('input[data-monto]').forEach((input) => {
            input.addEventListener('input', () => {
                const limpio = input.value.replace(/[^\d]/g, '');
                input.value = limpio ? Number(limpio).toLocaleString('es-PY') : '';
            });
        });
    }

    /* ------------------------------------------------ Cálculo de totales en vivo */
    function iniciarSeleccionMultiple() {
        document.querySelectorAll('[data-seleccion-grupo]').forEach((grupo) => {
            const casillas = grupo.querySelectorAll('input[type=checkbox][data-monto]');
            const salida = document.querySelector(grupo.getAttribute('data-seleccion-grupo'));

            const recalcular = () => {
                let total = 0;
                let marcadas = 0;
                casillas.forEach((c) => {
                    if (c.checked) {
                        total += Number(c.getAttribute('data-monto') || 0);
                        marcadas++;
                    }
                });
                if (salida) {
                    salida.textContent = total.toLocaleString('es-PY');
                }
                document.querySelectorAll('[data-requiere-seleccion]').forEach((boton) => {
                    boton.classList.toggle('deshabilitado', marcadas === 0);
                });
                const contador = document.querySelector('[data-contador-seleccion]');
                if (contador) contador.textContent = marcadas;
            };

            casillas.forEach((c) => c.addEventListener('change', recalcular));
            const todas = grupo.querySelector('[data-marcar-todas]');
            if (todas) {
                todas.addEventListener('change', () => {
                    casillas.forEach((c) => { c.checked = todas.checked; });
                    recalcular();
                });
            }
            recalcular();
        });
    }

    /* ------------------------------------------------------------- Búsqueda */
    function iniciarBusquedaDiferida() {
        let temporizador;
        document.querySelectorAll('[data-busqueda-auto]').forEach((input) => {
            input.addEventListener('input', () => {
                clearTimeout(temporizador);
                temporizador = setTimeout(() => {
                    const formulario = input.closest('form');
                    if (formulario) formulario.submit();
                }, 650);
            });
        });
    }

    /* ----------------------------------------------------------- Copiar texto */
    function iniciarCopiar() {
        document.addEventListener('click', async (e) => {
            const boton = e.target.closest('[data-copiar]');
            if (!boton) return;
            e.preventDefault();
            const texto = boton.getAttribute('data-copiar');
            try {
                await navigator.clipboard.writeText(texto);
                avisos.exito('Copiado: ' + texto);
            } catch {
                avisos.info('Copiá manualmente: ' + texto);
            }
        });
    }

    /* ------------------------------------------- Cuenta regresiva de vencimientos */
    function iniciarContadores() {
        document.querySelectorAll('[data-contador-hasta]').forEach((el) => {
            const destino = new Date(el.getAttribute('data-contador-hasta')).getTime();
            const actualizar = () => {
                const diff = destino - Date.now();
                if (diff <= 0) {
                    el.textContent = el.getAttribute('data-texto-vencido') || 'Vencido';
                    return;
                }
                const dias = Math.floor(diff / 86400000);
                const horas = Math.floor((diff % 86400000) / 3600000);
                const minutos = Math.floor((diff % 3600000) / 60000);
                el.textContent = dias > 0
                    ? dias + 'd ' + horas + 'h'
                    : horas + 'h ' + minutos + 'm';
            };
            actualizar();
            setInterval(actualizar, 60000);
        });
    }

    /* ------------------------------------------------------------- Arranque */
    function iniciar() {
        iniciarMenus();
        iniciarBarraLateral();
        iniciarModales();
        iniciarPaneles();
        iniciarConfirmaciones();
        iniciarFormulariosAjax();
        iniciarMascarasMonto();
        iniciarSeleccionMultiple();
        iniciarBusquedaDiferida();
        iniciarCopiar();
        iniciarContadores();

        document.querySelectorAll('[data-auto-cerrar]').forEach((el) => {
            setTimeout(() => el.remove(), Number(el.getAttribute('data-auto-cerrar')) || 6000);
        });
    }

    return {
        avisos,
        abrirModal,
        cerrarModal,
        abrirPanel,
        cerrarPaneles,
        iniciar
    };
})();

if (typeof window !== 'undefined') {
    window.UnvesApp = UnvesApp;
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', UnvesApp.iniciar);
    } else {
        UnvesApp.iniciar();
    }
}
