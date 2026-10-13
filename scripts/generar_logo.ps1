# =====================================================================
#  Genera los recursos graficos del logo institucional UNVES Villarrica
#  a partir del archivo oficial aportado por la universidad.
#
#  Uso:
#    powershell -ExecutionPolicy Bypass -File scripts\generar_logo.ps1
#    powershell -ExecutionPolicy Bypass -File scripts\generar_logo.ps1 -Origen "C:\ruta\logo.png"
#
#  Requiere: .NET System.Drawing (incluido en Windows). No instala nada.
#  Salida: recursos/img/logo-unves.png, logo-unves-compacto.png,
#          favicon-64.png, apple-touch-icon.png, logo-unves-original.png
# =====================================================================

param(
    [string] $Origen = "",
    [string] $Destino = ""
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$raiz = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Destino)) {
    $Destino = Join-Path $raiz "recursos\img"
}

function Buscar-LogoOficial {
    param([string] $Preferido)

    if (-not [string]::IsNullOrWhiteSpace($Preferido) -and (Test-Path $Preferido)) {
        return (Get-Item $Preferido).FullName
    }

    # 1) Carpeta del proyecto
    $candidatos = @()
    foreach ($nombre in @("logo-oficial", "logo-unves-original", "logo-unves", "logo")) {
        foreach ($ext in @("png", "jpg", "jpeg", "webp", "gif", "bmp")) {
            $candidatos += Join-Path $Destino "$nombre.$ext"
        }
    }
    foreach ($c in $candidatos) { if (Test-Path $c) { return (Get-Item $c).FullName } }

    # 2) Carpeta de adjuntos de la sesion de VS Code (el archivo compartido por el usuario)
    $adjuntos = Join-Path $env:APPDATA "Code\agentSessionData"
    if (Test-Path $adjuntos) {
        $encontrado = Get-ChildItem -Path $adjuntos -Recurse -Filter *.png -ErrorAction SilentlyContinue |
                      Where-Object { $_.Length -gt 10000 } |
                      Sort-Object LastWriteTime -Descending |
                      Select-Object -First 1
        if ($null -ne $encontrado) { return $encontrado.FullName }
    }

    throw "No se encontro el logo oficial. Copialo en recursos\img\ como logo-oficial.png o pasalo con -Origen."
}

# --- Utilidades -------------------------------------------------------

function Obtener-MapaBits {
    param([System.Drawing.Bitmap] $Bmp)

    $rect = New-Object System.Drawing.Rectangle(0, 0, $Bmp.Width, $Bmp.Height)
    $data = $Bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $stride = [Math]::Abs($data.Stride)
    $bytes = New-Object byte[] ($stride * $Bmp.Height)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
    $Bmp.UnlockBits($data)

    return [pscustomobject]@{ Bytes = $bytes; Stride = $stride; Ancho = $Bmp.Width; Alto = $Bmp.Height }
}

function Es-Tinta {
    param([byte] $B, [byte] $G, [byte] $R, [byte] $A)
    return ($A -gt 40) -and ($R -lt 235 -or $G -lt 235 -or $B -lt 235)
}

# Devuelve el rectangulo que contiene las filas de contenido indicadas
function Obtener-Recorte {
    param($Mapa, [int] $DesdeY, [int] $HastaY, [int] $Padding = 6, [int] $LimiteMaxY = -1)

    $minX = $Mapa.Ancho; $maxX = -1; $minY = $Mapa.Alto; $maxY = -1

    for ($y = $DesdeY; $y -le $HastaY -and $y -lt $Mapa.Alto; $y++) {
        for ($x = 0; $x -lt $Mapa.Ancho; $x++) {
            $i = $y * $Mapa.Stride + $x * 4
            if (Es-Tinta $Mapa.Bytes[$i] $Mapa.Bytes[$i + 1] $Mapa.Bytes[$i + 2] $Mapa.Bytes[$i + 3]) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }

    if ($maxX -lt 0) { throw "No se detecto contenido en el rango de filas $DesdeY..$HastaY." }

    $minX = [Math]::Max(0, $minX - $Padding)
    $minY = [Math]::Max(0, $minY - $Padding)
    $maxX = [Math]::Min($Mapa.Ancho - 1, $maxX + $Padding)
    $maxY = [Math]::Min($Mapa.Alto - 1, $maxY + $Padding)

    # No invadir la bajada cuando se recorta solo el wordmark
    if ($LimiteMaxY -ge 0) { $maxY = [Math]::Min($maxY, $LimiteMaxY) }

    return New-Object System.Drawing.Rectangle($minX, $minY, ($maxX - $minX + 1), ($maxY - $minY + 1))
}

# Filas donde hay contenido, agrupadas en bloques (para separar el wordmark de la bajada)
function Obtener-Bloques {
    param($Mapa)

    $bloques = New-Object System.Collections.ArrayList
    $enBloque = $false
    $inicio = 0

    for ($y = 0; $y -lt $Mapa.Alto; $y++) {
        $hay = $false
        for ($x = 0; $x -lt $Mapa.Ancho; $x++) {
            $i = $y * $Mapa.Stride + $x * 4
            if (Es-Tinta $Mapa.Bytes[$i] $Mapa.Bytes[$i + 1] $Mapa.Bytes[$i + 2] $Mapa.Bytes[$i + 3]) { $hay = $true; break }
        }

        if ($hay -and (-not $enBloque)) {
            $enBloque = $true
            $inicio = $y
        }
        elseif ((-not $hay) -and $enBloque) {
            $enBloque = $false
            [void]$bloques.Add([pscustomobject]@{ Inicio = $inicio; Fin = ($y - 1) })
        }
    }

    if ($enBloque) {
        [void]$bloques.Add([pscustomobject]@{ Inicio = $inicio; Fin = ($Mapa.Alto - 1) })
    }

    return $bloques
}

function Guardar-Recorte {
    param(
        [System.Drawing.Bitmap] $Origen,
        [System.Drawing.Rectangle] $Recorte,
        [string] $RutaSalida,
        [int] $AnchoMaximo = 600,
        [int] $LienzoCuadrado = 0,
        [int] $MargenPorcentaje = 0
    )

    $ancho = $Recorte.Width
    $alto = $Recorte.Height

    if ($LienzoCuadrado -gt 0) {
        # Lienzo cuadrado con margen proporcional (para favicon / icono movil)
        $disponible = [int]($LienzoCuadrado * (1 - ($MargenPorcentaje / 100.0)))
        $escala = [Math]::Min($disponible / $ancho, $disponible / $alto)
        $nuevoAncho = [int][Math]::Round($ancho * $escala)
        $nuevoAlto = [int][Math]::Round($alto * $escala)
        $destinoAncho = $LienzoCuadrado
        $destinoAlto = $LienzoCuadrado
        $posX = [int](($LienzoCuadrado - $nuevoAncho) / 2)
        $posY = [int](($LienzoCuadrado - $nuevoAlto) / 2)
    } else {
        $escala = [Math]::Min(1.0, $AnchoMaximo / $ancho)
        $nuevoAncho = [int][Math]::Round($ancho * $escala)
        $nuevoAlto = [int][Math]::Round($alto * $escala)
        $destinoAncho = $nuevoAncho
        $destinoAlto = $nuevoAlto
        $posX = 0
        $posY = 0
    }

    $lienzo = New-Object System.Drawing.Bitmap($destinoAncho, $destinoAlto, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($lienzo)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::White)
    $g.DrawImage(
        $Origen,
        (New-Object System.Drawing.Rectangle($posX, $posY, $nuevoAncho, $nuevoAlto)),
        $Recorte,
        [System.Drawing.GraphicsUnit]::Pixel
    )
    $g.Dispose()

    $lienzo.Save($RutaSalida, [System.Drawing.Imaging.ImageFormat]::Png)
    $lienzo.Dispose()

    Write-Output ("  -> {0}  ({1}x{2}, {3:N0} bytes)" -f (Split-Path -Leaf $RutaSalida), $destinoAncho, $destinoAlto, (Get-Item $RutaSalida).Length)
}

# --- Proceso ----------------------------------------------------------

if (-not (Test-Path $Destino)) { New-Item -ItemType Directory -Force -Path $Destino | Out-Null }

$origenReal = Buscar-LogoOficial -Preferido $Origen
Write-Output "Logo de origen: $origenReal"
Write-Output "Carpeta destino: $Destino"
Write-Output ""

$bmp = [System.Drawing.Bitmap]::FromFile($origenReal)
Write-Output ("Dimensiones originales: {0} x {1}" -f $bmp.Width, $bmp.Height)

$mapa = Obtener-MapaBits -Bmp $bmp
$bloques = Obtener-Bloques -Mapa $mapa

Write-Output "Bloques de contenido detectados:"
foreach ($b in $bloques) { Write-Output ("  filas {0}..{1}" -f $b.Inicio, $b.Fin) }

# El ultimo bloque de poca altura corresponde a la bajada ("abriendo puertas al futuro")
$finWordmark = $bloques[$bloques.Count - 1].Fin

if ($bloques.Count -ge 2) {
    $ultimo = $bloques[$bloques.Count - 1]
    $alturaUltimo = $ultimo.Fin - $ultimo.Inicio + 1
    $alturaPrimero = $bloques[0].Fin - $bloques[0].Inicio + 1

    if ($alturaUltimo -lt ($alturaPrimero * 0.35)) {
        $finWordmark = $ultimo.Inicio - 1
        Write-Output "Se detecto una bajada separada: el logo compacto llegara hasta la fila $finWordmark."
    }
}

$recorteCompleto = Obtener-Recorte -Mapa $mapa -DesdeY 0 -HastaY ($mapa.Alto - 1) -Padding 8
$recorteCompacto = Obtener-Recorte -Mapa $mapa -DesdeY 0 -HastaY $finWordmark -Padding 8 -LimiteMaxY $finWordmark

Write-Output ""
Write-Output ("Recorte completo:  x={0} y={1} w={2} h={3}" -f $recorteCompleto.X, $recorteCompleto.Y, $recorteCompleto.Width, $recorteCompleto.Height)
Write-Output ("Recorte compacto:  x={0} y={1} w={2} h={3}" -f $recorteCompacto.X, $recorteCompacto.Y, $recorteCompacto.Width, $recorteCompacto.Height)
Write-Output ""

Write-Output "Generando recursos:"
Guardar-Recorte -Origen $bmp -Recorte $recorteCompleto -RutaSalida (Join-Path $Destino "logo-unves.png")          -AnchoMaximo 600
Guardar-Recorte -Origen $bmp -Recorte $recorteCompacto -RutaSalida (Join-Path $Destino "logo-unves-compacto.png") -AnchoMaximo 600
Guardar-Recorte -Origen $bmp -Recorte $recorteCompacto -RutaSalida (Join-Path $Destino "favicon-64.png")          -LienzoCuadrado 64  -MargenPorcentaje 8
Guardar-Recorte -Origen $bmp -Recorte $recorteCompacto -RutaSalida (Join-Path $Destino "apple-touch-icon.png")    -LienzoCuadrado 180 -MargenPorcentaje 14

# Copia del archivo oficial tal como lo entrego la universidad
$rutaOriginal = Join-Path $Destino "logo-unves-original.png"
if (-not (Test-Path $rutaOriginal) -or ($origenReal -ne (Get-Item $rutaOriginal).FullName)) {
    Copy-Item -Path $origenReal -Destination $rutaOriginal -Force
    Write-Output ("  -> logo-unves-original.png  (copia del archivo oficial)")
}

$bmp.Dispose()

Write-Output ""
Write-Output "Listo. El portal detecta estos archivos automaticamente."
