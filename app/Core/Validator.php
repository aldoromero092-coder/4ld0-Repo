<?php

namespace App\Core;

/**
 * Validador de datos de entrada con mensajes en español.
 *
 * Uso:
 *   $v = Validator::crear($datos, [
 *       'email'    => 'requerido|email',
 *       'telefono' => 'requerido|min:6|max:25',
 *       'monto'    => 'requerido|numerico|min_valor:1000',
 *   ]);
 *   if ($v->falla()) { ... $v->errores() ... }
 */
class Validator
{
    private array $errores = [];

    private const ETIQUETAS = [
        'user' => 'usuario', 'pass' => 'contraseña', 'email' => 'correo',
        'telefono' => 'teléfono', 'celular' => 'celular', 'cedula' => 'cédula',
        'nombres' => 'nombres', 'apellidos' => 'apellidos', 'monto' => 'monto',
        'fecha' => 'fecha', 'direccion' => 'dirección', 'mensaje' => 'mensaje',
        'nombre' => 'nombre', 'clave' => 'contraseña', 'clave_confirmacion' => 'confirmación de contraseña',
    ];

    public function __construct(private array $datos, private array $reglas)
    {
    }

    public static function crear(array $datos, array $reglas): self
    {
        return new self($datos, $reglas);
    }

    public function validar(): self
    {
        foreach ($this->reglas as $campo => $reglasCampo) {
            $valor  = $this->datos[$campo] ?? null;
            $reglas = is_array($reglasCampo) ? $reglasCampo : explode('|', (string) $reglasCampo);

            $esRequerido = false;
            foreach ($reglas as $regla) {
                if (str_starts_with($regla, 'requerido') || str_starts_with($regla, 'requerido_si')) {
                    $esRequerido = true;
                    break;
                }
            }

            $vacio = $valor === null || (is_string($valor) && trim($valor) === '') || $valor === [];

            if ($vacio && !$esRequerido) {
                continue;
            }

            foreach ($reglas as $regla) {
                if ($this->aplicar($campo, $valor, $regla)) {
                    // Un error por campo por regla; continuamos para acumular los demás.
                }
            }
        }

        return $this;
    }

    private function aplicar(string $campo, mixed $valor, string $regla): bool
    {
        $etiqueta = self::ETIQUETAS[$campo] ?? str_replace('_', ' ', $campo);
        $partes   = explode(':', $regla, 2);
        $nombre   = $partes[0];
        $arg      = $partes[1] ?? null;
        $texto    = is_string($valor) ? trim($valor) : $valor;

        switch ($nombre) {
            case 'requerido':
                if ($texto === null || $texto === '' || $texto === []) {
                    return $this->fallo($campo, "El campo {$etiqueta} es obligatorio.");
                }
                break;

            case 'email':
                if ($texto !== '' && !filter_var((string) $texto, FILTER_VALIDATE_EMAIL)) {
                    return $this->fallo($campo, "El campo {$etiqueta} no es un correo válido.");
                }
                break;

            case 'min':
                if (mb_strlen((string) $texto) < (int) $arg) {
                    return $this->fallo($campo, "El campo {$etiqueta} debe tener al menos {$arg} caracteres.");
                }
                break;

            case 'max':
                if (mb_strlen((string) $texto) > (int) $arg) {
                    return $this->fallo($campo, "El campo {$etiqueta} no puede superar los {$arg} caracteres.");
                }
                break;

            case 'numerico':
                if (!is_numeric((string) $texto)) {
                    return $this->fallo($campo, "El campo {$etiqueta} debe ser numérico.");
                }
                break;

            case 'entero':
                if (filter_var($texto, FILTER_VALIDATE_INT) === false) {
                    return $this->fallo($campo, "El campo {$etiqueta} debe ser un número entero.");
                }
                break;

            case 'min_valor':
                if ((float) $texto < (float) $arg) {
                    return $this->fallo($campo, "El campo {$etiqueta} debe ser mayor o igual a " . number_format((float) $arg, 0, ',', '.') . '.');
                }
                break;

            case 'max_valor':
                if ((float) $texto > (float) $arg) {
                    return $this->fallo($campo, "El campo {$etiqueta} debe ser menor o igual a " . number_format((float) $arg, 0, ',', '.') . '.');
                }
                break;

            case 'fecha':
                if (strtotime((string) $texto) === false) {
                    return $this->fallo($campo, "El campo {$etiqueta} debe ser una fecha válida.");
                }
                break;

            case 'en':
                $opciones = explode(',', (string) $arg);
                if (!in_array((string) $texto, $opciones, true)) {
                    return $this->fallo($campo, "El valor seleccionado en {$etiqueta} no es válido.");
                }
                break;

            case 'confirmado':
                if (($this->datos[$campo . '_confirmacion'] ?? null) !== $valor) {
                    return $this->fallo($campo, "La confirmación de {$etiqueta} no coincide.");
                }
                break;

            case 'documento':
                if (!preg_match('/^[0-9]{5,10}(-[0-9])?$/', (string) $texto)) {
                    return $this->fallo($campo, "La {$etiqueta} no tiene un formato válido (ej.: 4567890 o 4567890-1).");
                }
                break;

            case 'telefono':
                if (!preg_match('/^[0-9+\s()-]{6,25}$/', (string) $texto)) {
                    return $this->fallo($campo, "El {$etiqueta} no tiene un formato válido.");
                }
                break;

            case 'regex':
                if (!preg_match('#' . $arg . '#u', (string) $texto)) {
                    return $this->fallo($campo, "El campo {$etiqueta} tiene un formato inválido.");
                }
                break;

            case 'unico':
                [$tabla, $columna] = array_pad(explode(',', (string) $arg), 2, $campo);
                $sql    = "SELECT COUNT(*) FROM `{$tabla}` WHERE `{$columna}` = ?";
                $params = [$valor];

                if (!empty($this->datos['_id_excluir'])) {
                    $sql      .= ' AND ' . ($this->datos['_columna_id'] ?? 'id') . ' <> ?';
                    $params[]  = $this->datos['_id_excluir'];
                }
                try {
                    $existe = Database::instancia()->consulta($sql, $params)->entero() > 0;
                    if ($existe) {
                        return $this->fallo($campo, "El valor ingresado en {$etiqueta} ya está registrado.");
                    }
                } catch (\Throwable) {
                    // Si la tabla no existe no bloqueamos el flujo.
                }
                break;

            case 'fecha_futura':
                if (strtotime((string) $texto) !== false && strtotime((string) $texto) < strtotime('today')) {
                    return $this->fallo($campo, "El campo {$etiqueta} no puede ser una fecha pasada.");
                }
                break;

            case 'archivo':
                // Validado aparte en el servicio de subidas
                break;
        }

        return false;
    }

    private function fallo(string $campo, string $mensaje): bool
    {
        $this->errores[$campo][] = $mensaje;
        return true;
    }

    public function falla(): bool
    {
        return $this->errores !== [];
    }

    public function pasa(): bool
    {
        return $this->errores === [];
    }

    /** @return array<string, string[]> */
    public function errores(): array
    {
        return $this->errores;
    }

    /** Todos los mensajes en una lista plana. */
    public function mensajes(): array
    {
        $lista = [];
        foreach ($this->errores as $campo => $mensajes) {
            foreach ($mensajes as $mensaje) {
                $lista[] = $mensaje;
            }
        }
        return $lista;
    }

    public function primerError(): string
    {
        return $this->mensajes()[0] ?? '';
    }
}
