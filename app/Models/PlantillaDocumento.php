<?php

namespace App\Models;

use App\Core\Model;

class PlantillaDocumento extends Model
{
    protected string $tabla = 'plantillas_documento';
    protected string $clavePrimaria = 'id_plantilla';
    protected string $colCreado = 'creado_en';
    protected string $colActualizado = '';
    protected array $asignables = ['id_tipo_tramite', 'nombre', 'contenido_html', 'estado'];

    public function listar(): array
    {
        return $this->sql(
            'SELECT p.*, t.nombre_tramite
               FROM plantillas_documento p
               LEFT JOIN tipos_tramite t ON t.id_tipo_tramite = p.id_tipo_tramite
              ORDER BY p.nombre'
        )->obtenerTodo();
    }

    public function deTipo(int $idTipoTramite): ?array
    {
        return $this->sql(
            'SELECT * FROM plantillas_documento WHERE id_tipo_tramite = ? AND estado = "Activo" LIMIT 1',
            [$idTipoTramite]
        )->obtener();
    }

    /** Rellena la plantilla con los datos del alumno. */
    public function renderizar(string $html, array $variables): string
    {
        $buscar  = [];
        $reemplazar = [];
        foreach ($variables as $clave => $valor) {
            $buscar[]     = '{{' . $clave . '}}';
            $reemplazar[] = (string) $valor;
        }
        return str_replace($buscar, $reemplazar, $html);
    }
}
