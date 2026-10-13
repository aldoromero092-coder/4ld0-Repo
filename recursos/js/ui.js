/* =====================================================================
   ui.js — Componentes visuales sin dependencias externas
   (gráficos SVG, orden de tablas, impresión, copiado de enlaces)
   ===================================================================== */

const UnvesUI = (() => {
    'use strict';

    const colores = ['#33356e', '#00afef', '#0f9d58', '#7c3aed', '#d93025', '#48a2cb', '#0891b2', '#db2777'];

    /* --------------------------------------------------- Gráfico de líneas */
    function linea(contenedor, datos, opciones = {}) {
        const el = typeof contenedor === 'string' ? document.querySelector(contenedor) : contenedor;
        if (!el || !datos || !datos.length) {
            if (el) el.innerHTML = '<p class="texto-centro color-suave texto-sm p-6">Sin datos para mostrar</p>';
            return;
        }

        const ancho = el.clientWidth || 640;
        const alto = opciones.alto || 260;
        const margen = { arriba: 20, derecha: 18, abajo: 38, izquierda: 62 };
        const interiorAncho = ancho - margen.izquierda - margen.derecha;
        const interiorAlto = alto - margen.arriba - margen.abajo;

        const valores = datos.map((d) => Number(d.valor) || 0);
        const maximo = Math.max(...valores, 1);
        const paso = interiorAncho / Math.max(datos.length - 1, 1);

        const puntos = datos.map((d, i) => ({
            x: margen.izquierda + (i * paso),
            y: margen.arriba + interiorAlto - ((Number(d.valor) || 0) / maximo) * interiorAlto,
            etiqueta: d.etiqueta,
            valor: Number(d.valor) || 0
        }));

        const lineaPuntos = puntos.map((p, i) => (i === 0 ? 'M' : 'L') + p.x.toFixed(1) + ' ' + p.y.toFixed(1)).join(' ');
        const area = lineaPuntos + ' L' + puntos[puntos.length - 1].x.toFixed(1) + ' ' + (margen.arriba + interiorAlto)
            + ' L' + puntos[0].x.toFixed(1) + ' ' + (margen.arriba + interiorAlto) + ' Z';

        const lineas = [0, 0.25, 0.5, 0.75, 1].map((f) => {
            const y = margen.arriba + interiorAlto - (f * interiorAlto);
            return '<line x1="' + margen.izquierda + '" y1="' + y + '" x2="' + (ancho - margen.derecha) + '" y2="' + y + '" stroke="#e2e8f0" stroke-width="1"/>'
                + '<text x="' + (margen.izquierda - 10) + '" y="' + (y + 4) + '" text-anchor="end" font-size="10" fill="#94a3b8">'
                + abreviar(maximo * f) + '</text>';
        }).join('');

        const marcadores = puntos.map((p) =>
            '<circle cx="' + p.x.toFixed(1) + '" cy="' + p.y.toFixed(1) + '" r="4" fill="#fff" stroke="' + (opciones.color || colores[0]) + '" stroke-width="2.5">'
            + '<title>' + p.etiqueta + ': ' + formatear(p.valor) + '</title></circle>'
        ).join('');

        const etiquetas = puntos.map((p, i) => {
            const mostrar = datos.length <= 12 || i % Math.ceil(datos.length / 10) === 0;
            return mostrar
                ? '<text x="' + p.x.toFixed(1) + '" y="' + (alto - 14) + '" text-anchor="middle" font-size="10" fill="#64748b">' + escapar(recortar(p.etiqueta, 10)) + '</text>'
                : '';
        }).join('');

        el.innerHTML = '<svg viewBox="0 0 ' + ancho + ' ' + alto + '" width="100%" height="' + alto + '" role="img">'
            + '<defs><linearGradient id="gradLinea" x1="0" y1="0" x2="0" y2="1">'
            + '<stop offset="0%" stop-color="' + (opciones.color || colores[0]) + '" stop-opacity="0.28"/>'
            + '<stop offset="100%" stop-color="' + (opciones.color || colores[0]) + '" stop-opacity="0.02"/>'
            + '</linearGradient></defs>'
            + lineas
            + '<path d="' + area + '" fill="url(#gradLinea)"/>'
            + '<path d="' + lineaPuntos + '" fill="none" stroke="' + (opciones.color || colores[0]) + '" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"/>'
            + marcadores + etiquetas + '</svg>';
    }

    /* ------------------------------------------------ Gráfico de barras */
    function barras(contenedor, datos, opciones = {}) {
        const el = typeof contenedor === 'string' ? document.querySelector(contenedor) : contenedor;
        if (!el || !datos || !datos.length) {
            if (el) el.innerHTML = '<p class="texto-centro color-suave texto-sm p-6">Sin datos para mostrar</p>';
            return;
        }

        const maximo = Math.max(...datos.map((d) => Number(d.valor) || 0), 1);

        el.innerHTML = '<div class="columna gap-3">' + datos.map((d, i) => {
            const valor = Number(d.valor) || 0;
            const porcentaje = Math.max(2, (valor / maximo) * 100);
            const color = d.color || colores[i % colores.length];
            return '<div>'
                + '<div class="fila-entre mb-1"><span class="texto-sm negrita">' + escapar(d.etiqueta) + '</span>'
                + '<span class="texto-sm color-suave">' + (opciones.formato === 'numero' ? valor.toLocaleString('es-PY') : formatear(valor)) + '</span></div>'
                + '<div class="barra"><div class="barra-valor" style="width:' + porcentaje + '%;background:' + color + '"></div></div>'
                + '</div>';
        }).join('') + '</div>';
    }

    /* ---------------------------------------------------- Gráfico circular */
    function dona(contenedor, datos, opciones = {}) {
        const el = typeof contenedor === 'string' ? document.querySelector(contenedor) : contenedor;
        if (!el || !datos || !datos.length) {
            if (el) el.innerHTML = '<p class="texto-centro color-suave texto-sm p-6">Sin datos para mostrar</p>';
            return;
        }

        const total = datos.reduce((s, d) => s + (Number(d.valor) || 0), 0) || 1;
        const radio = 78;
        const grosor = 26;
        const circunferencia = 2 * Math.PI * radio;
        let acumulado = 0;

        const segmentos = datos.map((d, i) => {
            const valor = Number(d.valor) || 0;
            const porcion = valor / total;
            const dash = porcion * circunferencia;
            const circulo = '<circle cx="100" cy="100" r="' + radio + '" fill="none"'
                + ' stroke="' + (d.color || colores[i % colores.length]) + '" stroke-width="' + grosor + '"'
                + ' stroke-dasharray="' + dash.toFixed(2) + ' ' + (circunferencia - dash).toFixed(2) + '"'
                + ' stroke-dashoffset="' + (-acumulado).toFixed(2) + '"'
                + ' transform="rotate(-90 100 100)"><title>' + escapar(d.etiqueta) + ': ' + formatear(valor) + '</title></circle>';
            acumulado += dash;
            return circulo;
        }).join('');

        const leyenda = datos.map((d, i) =>
            '<div class="fila-centro gap-2 mb-2"><span class="punto" style="background:' + (d.color || colores[i % colores.length]) + '"></span>'
            + '<span class="texto-sm crecer truncar">' + escapar(d.etiqueta) + '</span>'
            + '<span class="texto-sm negrita">' + (opciones.formato === 'numero' ? (Number(d.valor) || 0).toLocaleString('es-PY') : formatear(Number(d.valor) || 0)) + '</span></div>'
        ).join('');

        el.innerHTML = '<div class="fila env gap-6" style="align-items:center">'
            + '<div style="flex:0 0 auto"><svg viewBox="0 0 200 200" width="180" height="180" role="img">'
            + '<circle cx="100" cy="100" r="' + radio + '" fill="none" stroke="#e2e8f0" stroke-width="' + grosor + '"/>'
            + segmentos
            + '<text x="100" y="96" text-anchor="middle" font-size="13" fill="#64748b">Total</text>'
            + '<text x="100" y="118" text-anchor="middle" font-size="17" font-weight="700" fill="#1e293b">' + abreviar(total) + '</text>'
            + '</svg></div>'
            + '<div class="crecer" style="min-width:180px">' + leyenda + '</div>'
            + '</div>';
    }

    /* ------------------------------------------------ Ordenar tabla por columna */
    function iniciarOrdenTablas() {
        document.querySelectorAll('table[data-ordenable] th[data-orden]').forEach((th) => {
            th.style.cursor = 'pointer';
            th.addEventListener('click', () => {
                const tabla = th.closest('table');
                const indice = Array.from(th.parentNode.children).indexOf(th);
                const cuerpo = tabla.querySelector('tbody');
                if (!cuerpo) return;

                const ascendente = th.dataset.asc !== 'true';
                th.dataset.asc = ascendente ? 'true' : 'false';

                tabla.querySelectorAll('th').forEach((o) => { if (o !== th) o.removeAttribute('data-asc'); });

                const filas = Array.from(cuerpo.querySelectorAll('tr')).filter((f) => !f.classList.contains('fila-total'));
                filas.sort((a, b) => {
                    const va = (a.children[indice]?.textContent || '').trim();
                    const vb = (b.children[indice]?.textContent || '').trim();
                    const na = Number(va.replace(/[^\d,-]/g, '').replace(/\./g, '').replace(',', '.'));
                    const nb = Number(vb.replace(/[^\d,-]/g, '').replace(/\./g, '').replace(',', '.'));
                    const numerico = !isNaN(na) && !isNaN(nb) && va !== '' && vb !== '';
                    const r = numerico ? na - nb : va.localeCompare(vb, 'es');
                    return ascendente ? r : -r;
                });
                filas.forEach((f) => cuerpo.appendChild(f));
            });
        });
    }

    /* ------------------------------------------------- Imprimir un elemento */
    function imprimir(selector) {
        const el = typeof selector === 'string' ? document.querySelector(selector) : selector;
        if (!el) return;
        const original = document.body.innerHTML;
        document.body.innerHTML = el.innerHTML;
        window.print();
        document.body.innerHTML = original;
        window.location.reload();
    }

    /* ------------------------------------------------------------- Helpers */
    function abreviar(n) {
        const valor = Number(n) || 0;
        const f = (v) => v.toFixed(1).replace('.', ',');
        if (valor >= 1e9) return f(valor / 1e9) + 'MM';
        if (valor >= 1e6) return f(valor / 1e6) + 'M';
        if (valor >= 1e3) return (valor / 1e3 >= 100 ? Math.round(valor / 1e3) : f(valor / 1e3)) + 'k';
        return String(Math.round(valor));
    }

    function formatear(n) {
        return (Number(n) || 0).toLocaleString('es-PY');
    }

    function escapar(texto) {
        const div = document.createElement('div');
        div.textContent = String(texto ?? '');
        return div.innerHTML;
    }

    function recortar(texto, largo) {
        const t = String(texto ?? '');
        return t.length > largo ? t.slice(0, largo - 1) + '…' : t;
    }

    function iniciar() {
        iniciarOrdenTablas();
    }

    return { linea, barras, dona, imprimir, abreviar, formatear, escapar, iniciar };
})();

if (typeof window !== 'undefined') {
    window.UnvesUI = UnvesUI;
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', UnvesUI.iniciar);
    } else {
        UnvesUI.iniciar();
    }
}
