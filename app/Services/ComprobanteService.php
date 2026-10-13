<?php

namespace App\Services;

use App\Core\App;

/**
 * Genera comprobantes, constancias y actas en HTML listo para imprimir
 * o exportar a PDF desde el navegador.
 */
class ComprobanteService
{
    /** Comprobante de pago (recibo oficial). */
    public function comprobantePago(array $pago): string
    {
        $filas = '';
        foreach ($pago['items'] ?? [] as $item) {
            $filas .= '<tr>'
                . '<td>' . e($item['concepto_nombre'] ?? '—') . '</td>'
                . '<td>' . e($item['descripcion'] ?? '') . '</td>'
                . '<td class="der">' . dinero((float) $item['monto_pagado']) . '</td>'
                . '</tr>';
        }

        $cuerpo = '
        <div class="encabezado">
            ' . $this->marca('RUC: ' . (string) config_dinamica('app_ruc', '80012345-6')
                . ' · ' . (string) config_dinamica('app_siglas', 'UNVES')) . '
            <div class="der">
                <h2>RECIBO DE PAGO</h2>
                <p><strong>N°:</strong> ' . e($pago['numero_comprobante'] ?? '—') . '</p>
                <p><strong>Fecha:</strong> ' . fecha_hora($pago['fecha_pago'] ?? null) . '</p>
            </div>
        </div>

        <table class="datos">
            <tr><th>Alumno</th><td>' . e($pago['alumno'] ?? '—') . '</td>
                <th>Cédula</th><td>' . e($pago['cedula'] ?? '—') . '</td></tr>
            <tr><th>Legajo</th><td>' . e($pago['legajo'] ?? '—') . '</td>
                <th>Carrera</th><td>' . e($pago['carrera_nombre'] ?? '—') . '</td></tr>
            <tr><th>Método</th><td>' . e($pago['metodo_nombre'] ?? '—') . '</td>
                <th>N° transacción</th><td>' . e($pago['codigo_transaccion'] ?? '—') . '</td></tr>
        </table>

        <table class="items">
            <thead><tr><th>Concepto</th><th>Detalle</th><th class="der">Monto</th></tr></thead>
            <tbody>' . ($filas !== '' ? $filas : '<tr><td colspan="3">Sin detalle</td></tr>') . '</tbody>
            <tfoot>
                <tr><td colspan="2" class="der"><strong>TOTAL PAGADO</strong></td>
                    <td class="der"><strong>' . dinero((float) ($pago['monto_total'] ?? 0)) . '</strong></td></tr>
            </tfoot>
        </table>

        <p class="nota">Este comprobante acredita el pago registrado en el sistema de gestión académica.
        Verificalo en línea con el número de comprobante.</p>

        <div class="firmas">
            <div><span>Caja / Tesorería</span></div>
            <div><span>Secretaría Académica</span></div>
        </div>';

        return $this->envolver('Comprobante ' . ($pago['numero_comprobante'] ?? ''), $cuerpo);
    }

    /** Constancia de matricula. */
    public function constanciaMatricula(array $matricula, array $materias = []): string
    {
        $detalleMaterias = '';
        if ($materias !== []) {
            $filas    = '';
            $horas    = 0;
            $creditos = 0.0;
            $n        = 1;

            foreach ($materias as $materia) {
                $horas    += (int) ($materia['horas'] ?? 0);
                $creditos += (float) ($materia['creditos'] ?? 0);

                $filas .= '<tr>'
                    . '<td class="centro">' . $n++ . '</td>'
                    . '<td>' . e($materia['codigo'] ?? '—') . '</td>'
                    . '<td>' . e($materia['nombre'] ?? '—') . '</td>'
                    . '<td class="centro">' . (int) ($materia['curso'] ?? 0) . '</td>'
                    . '<td class="centro">' . (int) ($materia['semestre'] ?? 0) . '</td>'
                    . '<td class="centro">' . (int) ($materia['horas'] ?? 0) . '</td>'
                    . '<td class="centro">' . number_format((float) ($materia['creditos'] ?? 0), 1, ',', '.') . '</td>'
                    . '</tr>';
            }

            $detalleMaterias = '
            <h3 class="subtitulo">Materias inscriptas</h3>
            <table class="items">
                <thead>
                    <tr>
                        <th class="centro">#</th>
                        <th>Código</th>
                        <th>Materia</th>
                        <th class="centro">Curso</th>
                        <th class="centro">Semestre</th>
                        <th class="centro">Horas</th>
                        <th class="centro">Créditos</th>
                    </tr>
                </thead>
                <tbody>' . $filas . '</tbody>
                <tfoot>
                    <tr>
                        <td colspan="5" class="der"><strong>TOTAL</strong></td>
                        <td class="centro"><strong>' . (int) $horas . '</strong></td>
                        <td class="centro"><strong>' . number_format($creditos, 1, ',', '.') . '</strong></td>
                    </tr>
                </tfoot>
            </table>';
        }

        $cuerpo = '
        <div class="encabezado">
            ' . $this->marca((string) config_dinamica('app_siglas', 'UNVES')) . '
            <div class="der"><h2>CONSTANCIA DE MATRÍCULA</h2></div>
        </div>

        <p class="parrafo">La Secretaría Académica de la ' . e((string) config('app.app_institucion', 'UNVES')) . '
        hace constar que <strong>' . e($matricula['alumno'] ?? '—') . '</strong>, con documento de identidad
        N° <strong>' . e($matricula['cedula'] ?? '—') . '</strong> y legajo <strong>' . e($matricula['legajo'] ?? '—') . '</strong>,
        se encuentra matriculado/a en la carrera de <strong>' . e($matricula['carrera_nombre'] ?? '—') . '</strong>,
        correspondiente al periodo lectivo <strong>' . e($matricula['periodo_nombre'] ?? '—') . '</strong>,
        con el número de matrícula <strong>' . e($matricula['numero_matricula'] ?? '—') . '</strong>.</p>

        <table class="datos">
            <tr><th>Facultad</th><td>' . e($matricula['facultad_nombre'] ?? '—') . '</td>
                <th>Sede</th><td>' . e($matricula['sede_nombre'] ?? '—') . '</td></tr>
            <tr><th>Semestre</th><td>' . e((string) ($matricula['semestre'] ?? '—')) . '</td>
                <th>Turno</th><td>' . e($matricula['turno'] ?? '—') . '</td></tr>
            <tr><th>Modalidad</th><td>' . e($matricula['modalidad'] ?? '—') . '</td>
                <th>Estado</th><td>' . e($matricula['estado'] ?? '—') . '</td></tr>
        </table>' . $detalleMaterias . '

        <p class="parrafo">Se expide la presente constancia a pedido del interesado para los fines que estime convenientes.</p>

        <p class="fecha">' . e((string) config_dinamica('app_siglas', 'UNVES')) . ', ' . fecha_larga(date('Y-m-d')) . '</p>

        <div class="firmas">
            <div><span>Secretaría Académica</span></div>
            <div><span>Dirección de Registro Académico</span></div>
        </div>';

        return $this->envolver('Constancia de matrícula', $cuerpo);
    }

    /** Acta de examen con notas. */
    public function actaExamen(array $examen, array $inscriptos): string
    {
        $filas = '';
        $n = 1;
        foreach ($inscriptos as $i) {
            $filas .= '<tr>'
                . '<td class="centro">' . $n++ . '</td>'
                . '<td>' . e($i['cedula'] ?? '') . '</td>'
                . '<td>' . e($i['alumno'] ?? '') . '</td>'
                . '<td class="centro">' . ($i['nota'] !== null ? number_format((float) $i['nota'], 1, ',', '.') : '—') . '</td>'
                . '<td class="centro">' . e($i['estado'] ?? '') . '</td>'
                . '</tr>';
        }

        $cuerpo = '
        <div class="encabezado">
            ' . $this->marca('Acta oficial de examen') . '
            <div class="der"><h2>ACTA DE EXAMEN</h2></div>
        </div>

        <table class="datos">
            <tr><th>Materia</th><td>' . e($examen['materia'] ?? $examen['nombre'] ?? '—') . '</td>
                <th>Tipo</th><td>' . e($examen['tipo'] ?? '—') . '</td></tr>
            <tr><th>Fecha</th><td>' . fecha($examen['fecha_examen'] ?? null) . '</td>
                <th>Hora</th><td>' . e(substr((string) ($examen['hora_inicio'] ?? ''), 0, 5)) . '</td></tr>
            <tr><th>Aula</th><td>' . e($examen['aula'] ?? '—') . '</td>
                <th>Carrera</th><td>' . e($examen['carrera_nombre'] ?? '—') . '</td></tr>
        </table>

        <table class="items">
            <thead><tr><th class="centro">#</th><th>Cédula</th><th>Alumno</th><th class="centro">Nota</th><th class="centro">Condición</th></tr></thead>
            <tbody>' . ($filas !== '' ? $filas : '<tr><td colspan="5" class="centro">Sin inscriptos</td></tr>') . '</tbody>
        </table>

        <div class="firmas">
            <div><span>Presidente de mesa</span></div>
            <div><span>Vocal</span></div>
        </div>';

        return $this->envolver('Acta de examen', $cuerpo);
    }

    /**
     * Documento generico de tramite.
     *
     * Se asume que $contenidoHtml trae su propio titulo (h2) y su texto;
     * aca solo se agrega el encabezado institucional y el estilo de impresion.
     */
    public function documento(string $titulo, string $contenidoHtml): string
    {
        $cuerpo = '
        <div class="encabezado">
            ' . $this->marca('Documento académico') . '
            <div class="der">
                <h2>' . e((string) config('app.app_siglas', 'UNVES')) . '</h2>
                <p><strong>RUC:</strong> ' . e((string) config_dinamica('app_ruc', '80012345-6')) . '</p>
                <p><strong>Emitido:</strong> ' . fecha(date('Y-m-d')) . '</p>
            </div>
        </div>
        <div class="documento">' . $contenidoHtml . '</div>';

        return $this->envolver($titulo, $cuerpo);
    }

    /**
     * Bloque de marca que encabeza los documentos: logo oficial + institucion.
     *
     * @param string $subtitulo Texto plano que acompana al nombre institucional.
     */
    private function marca(string $subtitulo = ''): string
    {
        $logo = logo_url(false, true);

        return '<div class="marca">'
            . ($logo !== null
                ? '<img class="marca-logo" src="' . e($logo) . '" alt="'
                    . e((string) config('app.app_institucion', 'UNVES')) . '">'
                : '<span class="marca-sello">' . e(monograma()) . '</span>')
            . '<div>'
            . '<h1>' . e((string) config('app.app_institucion', 'UNVES')) . '</h1>'
            . '<p class="muted">' . e($subtitulo) . '</p>'
            . '</div>'
            . '</div>';
    }

    /** Envuelve el contenido con el estilo institucional de impresion. */
    private function envolver(string $titulo, string $cuerpo): string
    {
        $css  = '
        * { box-sizing: border-box; }
        body { font-family: "Segoe UI", Arial, sans-serif; color: #1e293b; margin: 0; padding: 32px; background: #fff; font-size: 14px; }
        .hoja { max-width: 860px; margin: 0 auto; }
        .encabezado { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #33356e; padding-bottom: 14px; margin-bottom: 22px; gap: 20px; }
        .marca { display: flex; align-items: center; gap: 14px; }
        .marca-logo { height: 56px; width: auto; }
        .marca-sello { display: grid; place-items: center; width: 52px; height: 52px; border-radius: 12px; background: linear-gradient(135deg, #33356e, #48a2cb); color: #fff; font-weight: 800; font-size: 22px; }
        .encabezado h1 { font-size: 16px; margin: 0 0 4px; color: #33356e; }
        .encabezado h2 { font-size: 15px; margin: 0 0 6px; letter-spacing: .5px; }
        .muted { color: #64748b; font-size: 12px; margin: 0; }
        .der { text-align: right; }
        .centro { text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 18px; }
        table.datos th { text-align: left; width: 16%; background: #f1f5f9; }
        table th, table td { border: 1px solid #cbd5e1; padding: 7px 10px; vertical-align: top; }
        table.items thead th { background: #33356e; color: #fff; font-size: 12px; text-transform: uppercase; letter-spacing: .4px; }
        table.items tfoot td { background: #f8fafc; font-weight: 600; }
        .parrafo { line-height: 1.7; text-align: justify; }
        .subtitulo { font-size: 13px; color: #33356e; text-transform: uppercase; letter-spacing: .5px; margin: 22px 0 8px; }
        .nota { font-size: 12px; color: #64748b; margin-top: 18px; }
        .fecha { margin-top: 34px; }
        .firmas { display: flex; justify-content: space-around; margin-top: 64px; gap: 40px; }
        .firmas div { border-top: 1px solid #475569; padding-top: 8px; min-width: 210px; text-align: center; font-size: 12px; }
        .documento { line-height: 1.75; }
        .documento h2 { color: #33356e; }
        .acciones { text-align: center; margin-top: 26px; }
        .acciones button { background: #33356e; color: #fff; border: 0; padding: 11px 26px; border-radius: 8px; font-size: 14px; cursor: pointer; }
        .pie { margin-top: 34px; border-top: 1px dashed #cbd5e1; padding-top: 10px; font-size: 11px; color: #94a3b8; text-align: center; }
        @media print { body { padding: 0; } .acciones { display: none; } .hoja { max-width: none; } }
        ';

        return '<!doctype html><html lang="es"><head><meta charset="utf-8">'
            . '<meta name="viewport" content="width=device-width, initial-scale=1">'
            . '<title>' . e($titulo) . ' — ' . e((string) config('app.app_siglas', 'UNVES')) . '</title>'
            . '<style>' . $css . '</style></head><body><div class="hoja">'
            . $cuerpo
            . '<div class="acciones"><button onclick="window.print()">Imprimir / Guardar PDF</button></div>'
            . '<div class="pie">Documento generado por el ' . e((string) config('app.app_nombre', 'Sistema de Gestión Académica'))
            . ' el ' . fecha_hora(date('Y-m-d H:i:s')) . ' &middot; ' . e(App::url('/')) . '</div>'
            . '</div></body></html>';
    }
}
