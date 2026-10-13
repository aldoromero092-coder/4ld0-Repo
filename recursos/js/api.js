/* =====================================================================
   api.js — Cliente HTTP del portal (fetch con CSRF y manejo de errores)
   ===================================================================== */

const UnvesApi = (() => {
    'use strict';

    const base = (typeof window !== 'undefined' && window.UNVES && window.UNVES.base) || '';

    function token() {
        const meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : '';
    }

    function construirUrl(ruta, parametros) {
        let url = ruta.startsWith('http') ? ruta : base + (ruta.startsWith('/') ? ruta : '/' + ruta);
        if (parametros && Object.keys(parametros).length) {
            const qs = new URLSearchParams(parametros).toString();
            url += (url.includes('?') ? '&' : '?') + qs;
        }
        return url;
    }

    async function peticion(ruta, opciones = {}) {
        const config = {
            method: opciones.method || 'GET',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            },
            credentials: 'same-origin'
        };

        if (opciones.datos) {
            if (opciones.datos instanceof FormData) {
                config.body = opciones.datos;
            } else {
                config.headers['Content-Type'] = 'application/json';
                config.body = JSON.stringify({ ...opciones.datos, _token: token() });
            }
        }

        if (config.method !== 'GET') {
            config.headers['X-CSRF-Token'] = token();
        }

        try {
            const respuesta = await fetch(construirUrl(ruta, opciones.parametros), config);
            const tipo = respuesta.headers.get('content-type') || '';

            if (!tipo.includes('application/json')) {
                const texto = await respuesta.text();
                return {
                    ok: false,
                    mensaje: respuesta.ok
                        ? 'La respuesta del servidor no tiene el formato esperado.'
                        : 'Error ' + respuesta.status + ' al procesar la solicitud.',
                    codigo: respuesta.status,
                    crudo: texto
                };
            }

            const json = await respuesta.json();

            if (!respuesta.ok) {
                return {
                    ok: false,
                    mensaje: json.mensaje || 'Ocurrió un error inesperado.',
                    codigo: respuesta.status,
                    ...json
                };
            }

            return json;
        } catch (error) {
            return {
                ok: false,
                mensaje: 'No pudimos conectar con el servidor. Verificá tu conexión a internet.',
                codigo: 0,
                error: String(error)
            };
        }
    }

    return {
        base,
        token,
        construirUrl,

        get(ruta, parametros, opciones) {
            return peticion(ruta, { ...(opciones || {}), method: 'GET', parametros });
        },

        post(ruta, datos, opciones) {
            return peticion(ruta, { ...(opciones || {}), method: 'POST', datos });
        },

        enviarFormulario(ruta, formData, opciones) {
            return peticion(ruta, { ...(opciones || {}), method: 'POST', datos: formData });
        },

        /** Envia un formulario HTML completo por AJAX. */
        enviarFormularioElemento(formulario) {
            const datos = new FormData(formulario);
            if (!datos.has('_token')) {
                datos.append('_token', token());
            }
            return peticion(formulario.action || window.location.href, { method: (formulario.method || 'POST').toUpperCase(), datos });
        }
    };
})();

if (typeof window !== 'undefined') {
    window.UnvesApi = UnvesApi;
}
