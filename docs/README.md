# Sistema de Gestión Académica — UNVES

Portal web de pagos y gestión académica para la Universidad Nacional de Villarrica del Espíritu Santo.
Permite a los alumnos matricularse, pagar aranceles y exámenes, solicitar documentos y consultar su
historial completo; y al personal administrativo gestionar la cobranza, la facturación y los reportes.

---

## 1. Requisitos

| Componente | Versión mínima |
|---|---|
| PHP | 8.1 (probado en 8.5) |
| MariaDB / MySQL | 10.4 / 5.7 |
| Apache | con `mod_rewrite` y `mod_headers` |
| Extensiones PHP | `pdo_mysql`, `mbstring`, `json`, `curl`, `openssl`, `fileinfo` |

El sistema está preparado para ejecutarse en **XAMPP** sobre Windows, pero funciona igual en
Linux (LAMP) cambiando únicamente la ruta base.

---

## 2. Instalación

1. **Copiar el proyecto** en la raíz web:

   ```
   C:\xampp\htdocs\SistemaUnvesGestion
   ```

2. **Crear la base de datos** (si no existe) e importar los scripts en este orden:

   ```powershell
   C:\xampp\mysql\bin\mysql.exe -u root -e "CREATE DATABASE IF NOT EXISTS sistema_gestion_academica
     CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

   C:\xampp\mysql\bin\mysql.exe -u root sistema_gestion_academica -e "source sql/02_extension_web.sql"
   C:\xampp\mysql\bin\mysql.exe -u root sistema_gestion_academica -e "source sql/03_seed_datos.sql"
   ```

   > El script `02_extension_web.sql` es idempotente: agrega las tablas y columnas que necesita
   > el portal (alumnos, matrículas, exámenes, carrito, sesiones, notificaciones, logs, etc.)
   > sin destruir los datos existentes.
   > El script `03_seed_datos.sql` carga los catálogos y los datos de demostración.

3. **Configurar la conexión** en `config/database.php` (por defecto `root` sin contraseña en XAMPP).
   También se puede sobreescribir con variables de entorno: `APP_DB_HOST`, `APP_DB_PORT`,
   `APP_DB_NAME`, `APP_DB_USER`, `APP_DB_PASS`.

4. **Verificar permisos de escritura** en `almacen/logs` y `public/uploads`.

5. **Abrir el portal**: `http://localhost/SistemaUnvesGestion/`

### Usuarios de demostración

Todos usan la contraseña **`Unves.2026`**

| Usuario | Rol | Para probar |
|---|---|---|
| `lucia.villalba` | Alumna | **Cuenta de prueba completa**: historial de pagos, matrículas, beca del 30 %, pago parcial, mora, exámenes y trámites |
| `admin` | Administrador | Panel general, usuarios, configuración, auditoría |
| `juan.perez` | Alumno | Alumno con deuda pendiente y vencida |
| `maria.lopez` | Alumna | Alumno al día |
| `pedro.martinez` | Alumno | Matrícula vencida |
| `sofia.cabrera` | Alumna | Alumno con beca del 50% |
| `caja1` | Cajero | Ventanilla de caja, arqueo |
| `secretaria1` | Secretaría | Matrículas, trámites, alumnos |
| `docente1` | Docente | Mesas de examen, actas |

### Alumno de prueba generado

La cuenta `lucia.villalba` (cédula `5234891-6`, legajo `2024-ISI-070`) no viene en el semilla: se
construye con el generador de datos de prueba, que arma un caso realista para ejercitar todo el
circuito de pagos.

```bash
# Generar o regenerar el alumno de prueba (es idempotente)
php scripts/demo_alumno.php

# Eliminar únicamente sus datos
php scripts/demo_alumno.php --borrar
```

El generador crea:

* Perfil completo (persona, usuario, legajo) y matrícula en el periodo activo.
* **Beca Deportiva del 30 %** aplicada a matrícula y aranceles.
* 3 matrículas (2025-2 y 2026-1 confirmadas + 2026-2 del periodo activo).
* 17 obligaciones en todos los estados: **pagadas, pendientes, vencidas con mora, parcial y anulada**.
* 11 pagos aprobados con sus **comprobantes y facturas legales**, usando distintos métodos
  (QR/web, transferencia, Tigo Money, tarjeta, caja) y un pago parcial en efectivo.
* Inscripciones a examen (una rendida con nota, dos del periodo activo con derecho pendiente).
* 4 trámites en estados distintos (entregado, listo para retirar, en proceso, pendiente de pago).
* Notificaciones, sesiones web, logs de actividad, registros de auditoría y un mensaje de contacto.

> ⚠️ **Antes de poner el sistema en producción**: cambiá todas las contraseñas de demostración,
> poné `app_entorno` en `produccion` dentro de `config/app.php` y configurá las credenciales de la
> pasarela real.

---

## 3. Estructura del proyecto

```
SistemaUnvesGestion/
├── index.php                  Controlador frontal (todas las peticiones pasan por acá)
├── .htaccess                  Reescritura de URLs y cabeceras de seguridad
│
├── config/                    Configuración
│   ├── app.php                Parámetros generales, pagos, integración, subidas
│   ├── database.php           Conexión a la base de datos
│   ├── menu.php               Definición del menú lateral
│   └── routes.php             Tabla de rutas
│
├── app/                       Núcleo de la aplicación (framework propio)
│   ├── Core/                  Router, Model, Auth, Session, Csrf, Validator, View, Logger...
│   ├── Models/                Un modelo por tabla (consultas especializadas incluidas)
│   ├── Services/              Lógica de negocio
│   │   └── Pasarela/          Adaptadores de pago (Sandbox, Bancard, Pagopar, Transferencia)
│   └── Views/
│       ├── layouts/           Layouts: principal (panel), publico, auth
│       ├── partials/          Menú lateral, barra superior, mensajes, notificaciones
│       └── errores/           403, 404, 405, 419, 500
│
├── modulos/                   Un módulo por funcionalidad, autocontenido
│   └── <modulo>/
│       ├── <Modulo>Controller.php
│       ├── vistas/            Vistas propias del módulo
│       ├── css/<modulo>.css   Estilos propios (se cargan automáticamente)
│       └── js/<modulo>.js     Comportamiento propio (se carga automáticamente)
│
├── recursos/                  Recursos compartidos
│   ├── css/                   base.css · componentes.css · layout.css
│   ├── img/                   Logo institucional, favicon e íconos
│   └── js/                    api.js · app.js · ui.js
│
├── public/uploads/            Archivos subidos (fotos, comprobantes, documentos)
├── almacen/logs/              Registro de errores
├── sql/                       Scripts de base de datos
├── scripts/                   Utilidades de línea de comandos
│   ├── demo_alumno.php        Genera el alumno de prueba con su historial
│   ├── generar_logo.ps1       Recorta el logo oficial y regenera favicon e íconos
│   ├── pruebas_*.php          Suite de pruebas automatizadas
│   ├── limpiar_datos_prueba.sql
│   └── sincronizar_api.php    Sincronización programada con el sistema central
└── docs/                      Esta documentación
```

---

## 4. Módulos

| Módulo | Descripción | Roles |
|---|---|---|
| **Inicio** | Portada pública, carreras, institucional, centro de ayuda | Público |
| **Auth** | Ingreso, registro, recuperación de contraseña, cierre de sesión | Público |
| **Dashboard** | Tablero distinto según el rol | Todos |
| **Pagos** | Obligaciones, carrito, checkout, pasarela, comprobantes, historial | Alumno |
| **Caja** | Cobros presenciales, cuenta corriente del alumno, arqueo diario | Cajero, Finanzas, Secretaría, Admin |
| **Matrículas** | Solicitud en línea, pago, confirmación, constancia | Alumno / Secretaría |
| **Exámenes** | Convocatorias, inscripción con pago, actas y notas | Alumno / Docente / Secretaría |
| **Trámites** | Solicitud de documentos, seguimiento por código, generación | Alumno / Secretaría |
| **Alumnos** | Legajos, cuenta corriente, exportación | Staff |
| **Usuarios** | Usuarios, roles, permisos, restablecimiento de claves | Admin |
| **Académico** | Facultades, sedes, carreras, periodos | Admin, Secretaría, Finanzas |
| **Aranceles** | Conceptos de pago, aranceles, generación masiva, mora | Admin, Finanzas |
| **Becas** | Tipos de beca, asignación y descuentos automáticos | Admin, Finanzas, Secretaría |
| **Facturación** | Facturas legales, timbrados, datos fiscales | Admin, Finanzas |
| **Reportes** | Recaudación, morosidad, matrículas, exámenes, trámites, alumnos | Staff |
| **Auditoría** | Bitácora de actividad, sesiones, cambios en datos | Admin, Finanzas |
| **Integración** | Sincronización con el sistema central de la universidad | Admin, Secretaría |
| **Configuración** | Parámetros del sistema, logs, respaldos | Admin |
| **Contacto** | Formulario público, bandeja de mensajes, WhatsApp | Público / Staff |
| **Perfil** | Datos personales, contraseña, foto, sesiones activas | Todos |
| **Notificaciones** | Bandeja de avisos del sistema | Todos |

---

## 5. Flujo de pago

```
Alumno                 Portal                       Pasarela              Sistema
  │                      │                             │                    │
  ├─ Selecciona obligaciones ─►                        │                    │
  │                      ├─ Agrega al carrito ─────────────────────────────► │
  │                      ├─ Checkout (medio de pago) ─►│                    │
  │                      │                             │                    │
  │◄─────────────────────┤ Redirige a la pasarela ─────►│                    │
  ├─ Confirma el pago ───────────────────────────────►│                    │
  │                      │◄──── Notificación (webhook) ─┤                    │
  │                      ├─ Confirma el pago ──────────────────────────────►│
  │                      │      · Acredita la obligación                     │
  │                      │      · Emite comprobante y factura                │
  │                      │      · Confirma matrícula / examen / trámite      │
  │                      │      · Notifica al alumno y a caja                │
  │◄─────────────────────┤ Resultado + comprobante descargable               │
```

**Estados de un pago:** `Pendiente` → `Aprobado` · `Rechazado` · `Anulado`

**Estados de una obligación:** `Pendiente` · `Vencido` · `Parcial` · `Pagado` · `Anulado`

---

## 6. Pasarelas de pago

El sistema usa una arquitectura de *drivers*: para agregar un proveedor nuevo basta con implementar
`App\Services\Pasarela\PasarelaInterface`.

| Pasarela | Estado | Configuración |
|---|---|---|
| `sandbox` | ✅ Funciona sin credenciales | Modo de prueba, simula aprobación/rechazo |
| `transferencia` | ✅ Funciona sin credenciales | Datos bancarios y referencia única |
| `bancard` | 🔧 Requiere credenciales | `Configuración → Pagos → Bancard vPOS` |
| `pagopar` | 🔧 Requiere credenciales | `Configuración → Pagos → Pagopar` |

La pasarela activa se define con la clave `pasarela_activa` (`sandbox`, `bancard`, `pagopar` o
`transferencia`) y no requiere tocar código.

### Webhooks

| Endpoint | Método | Uso |
|---|---|---|
| `/api/pasarela/notificacion` | POST | Notificación servidor-a-servidor de la pasarela |
| `/api/pasarela/retorno` | POST | Retorno del navegador del usuario |
| `/api/estado` | GET | Estado general del servicio de pagos |

---

## 7. Integración con el sistema central de la universidad

El portal consume una API REST del sistema académico central para mantener sincronizados los
alumnos, facultades, sedes, carreras y periodos.

### Configuración

En `Configuración → Integración` (o en la tabla `configuracion`):

| Clave | Descripción |
|---|---|
| `api_universidad_url` | URL base, ej. `https://sistema.unves.edu.py/api/v1` |
| `api_universidad_token` | Token Bearer de autenticación |

### Endpoints que consume el portal

| Endpoint | Devuelve |
|---|---|
| `GET /alumnos` | Lista de alumnos |
| `GET /facultades` | Lista de facultades |
| `GET /sedes` | Lista de sedes |
| `GET /carreras` | Lista de carreras |
| `GET /periodos` | Lista de periodos académicos |
| `GET /alumnos/{codigo}/obligaciones` | Obligaciones del alumno en el sistema central |

### Formato de respuesta esperado

```json
{
  "ok": true,
  "datos": [
    {
      "codigo": "EXT-1001",
      "cedula": "4567890",
      "nombres": "Juan Carlos",
      "apellidos": "Pérez González",
      "email": "juan.perez@unves.edu.py",
      "telefono": "+595 981 111 222",
      "celular": "0981 111 222",
      "direccion": "Barrio Ybaroty, Villarrica",
      "fecha_nac": "2003-05-21",
      "sexo": "M",
      "carrera": "ISI",
      "facultad": "Facultad de Ingeniería",
      "sede": "Campus Central - Villarrica",
      "legajo": "2023-ISI-001",
      "semestre": 8,
      "turno": "Noche",
      "modalidad": "Presencial",
      "fecha_ingreso": "2023-02-06",
      "estado_academico": "Activo",
      "promedio": 4.15
    }
  ]
}
```

> El portal también acepta la clave `data` en lugar de `datos`, y una lista plana sin envoltorio.
> Los campos se emparejan por **cédula** (obligatoria) y se usa `codigo` como identificador externo.

### Sincronización

- **Manual:** `Configuración → Integración → Sincronizar ahora`
- **Automática:** programar la tarea `php scripts/sincronizar_api.php`

```powershell
# Programador de tareas de Windows (diariamente a las 03:00)
schtasks /create /sc daily /st 03:00 /tn "UNVES Sincronizacion" ^
  /tr "C:\xampp\php\php.exe C:\xampp\htdocs\SistemaUnvesGestion\scripts\sincronizar_api.php"
```

---

## 8. WhatsApp

Número configurado: **595991461220** (`Configuración → Contacto`).

- Cada pantalla incluye acceso directo por WhatsApp con mensaje contextual precargado.
- El módulo de contacto registra los mensajes y permite responderlos desde la bandeja interna.
- **Opcional:** para envíos automáticos vía API oficial de WhatsApp Business, configurar
  `whatsapp_api_url` y `whatsapp_api_token` en la tabla `configuracion`.

---

## 9. Seguridad implementada

- Contraseñas con `bcrypt` (costo 12) y re-hash automático.
- Bloqueo temporal de cuentas tras 5 intentos fallidos.
- Tokens CSRF en todos los formularios y peticiones AJAX (`X-CSRF-Token`).
- Regeneración del id de sesión al iniciar sesión (anti *session fixation*).
- Expiración de sesión por inactividad (2 h) y cookie "recordarme" con token hasheado.
- Consultas parametrizadas (PDO con *prepared statements* nativos) en toda la aplicación.
- Escape de salida con `e()` en todas las vistas.
- Validación del contenido real de los archivos subidos (MIME + firma) y bloqueo de ejecución
  de scripts en `public/uploads`.
- Auditoría completa: `logs_actividad` (acciones) y `auditorias` (cambios antes/después).
- Cabeceras `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`.

---

## 10. Comandos útiles

```powershell
# Prueba de humo: sitio público, login, todos los módulos y flujo de pago completo
C:\xampp\php\php.exe scripts\pruebas_humo.php http://localhost/SistemaUnvesGestion admin Unves.2026

# Pruebas de los formularios de gestión (verifica el alta en la base de datos)
C:\xampp\php\php.exe scripts\pruebas_modulos.php

# Pruebas del flujo del alumno (examen, trámite y pago completo del carrito)
C:\xampp\php\php.exe scripts\pruebas_alumno.php http://localhost/SistemaUnvesGestion maria.lopez Unves.2026

# Restaurar el juego de datos de demostración (borra lo generado por las pruebas)
C:\xampp\mysql\bin\mysql.exe -u root sistema_gestion_academica -e "source scripts/limpiar_datos_prueba.sql"
C:\xampp\mysql\bin\mysql.exe -u root sistema_gestion_academica -e "source sql/03_seed_datos.sql"

# Regenerar el alumno de prueba (la limpieza anterior también lo elimina)
C:\xampp\php\php.exe scripts\demo_alumno.php

# Generar el hash de una contraseña
C:\xampp\php\php.exe scripts\generar_hash.php "MiClaveSegura"

# Sincronizar con el sistema central
C:\xampp\php\php.exe scripts\sincronizar_api.php
C:\xampp\php\php.exe scripts\sincronizar_api.php alumnos

# Verificar la sintaxis de todos los archivos PHP
Get-ChildItem -Recurse -Filter *.php | ForEach-Object { C:\xampp\php\php.exe -l $_.FullName }
```

> Los tres scripts de prueba crean registros reales identificables (marcados con `ZZ`, `prb`,
> correos `@test.local`). Después de ejecutarlos, restaurá el estado con los dos comandos de
> limpieza indicados arriba.

---

## 11. Respaldo

1. **Base de datos:**

   ```powershell
   C:\xampp\mysql\bin\mysqldump.exe -u root --routines --triggers sistema_gestion_academica > respaldo.sql
   ```

2. **Archivos subidos:** copiar el contenido de `public/uploads`.

3. Desde `Configuración → Respaldos` se puede consultar el estado de los archivos de esquema y de
   las carpetas de subida.

---

## 12. Identidad visual

El escudo institucional de la UNVES (paloma + logotipo `unves`) se usa en la barra lateral, el
encabezado del sitio público, las pantallas de acceso, las páginas de error y los documentos
imprimibles (comprobantes, constancias y actas).

| Recurso | Archivo |
|---|---|
| Logo principal (color, fondos claros) | `recursos/img/logo-unves-compacto.png` |
| Logo con más aire | `recursos/img/logo-unves.png` |
| Favicon | `recursos/img/favicon-64.png` |
| Ícono para móviles | `recursos/img/apple-touch-icon.png` |
| Original recibido de la universidad | `recursos/img/logo-unves-original.png` |

El archivo tiene fondo blanco, por eso sobre fondos oscuros se muestra dentro de un «chip» claro
(clases `logo-claro` / `bl-marca-logo`).

### Reemplazar el logo

1. Guardá el archivo oficial nuevo en `recursos/img/` con el nombre `logo-unves-original.png`
   (o pasá su ruta con `-Origen`).
2. Ejecutá el generador de recursos:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\generar_logo.ps1
   ```

   El script recorta el escudo, separa el logotipo de la bajada «abriendo puertas al futuro» y
   regenera el favicon y el ícono de móviles en los tamaños correctos.

3. Si preferís subir un logo ya recortado sin procesarlo, cargalo desde
   `Configuración → General` (claves `app_logo`, `app_logo_claro` y `app_favicon`) o dejá el PNG
   en `recursos/img/` con alguno de los nombres que busca `logo_institucional()`:
   `logo-unves-compacto`, `logo-unves`, `logo-oficial` o `logo`.

### Colores

La paleta de `recursos/css/base.css` está tomada del escudo:

| Variable | Valor | Uso |
|---|---|---|
| `--azul-700` | `#33356e` | Color primario (navy del logotipo) |
| `--azul-900` | `#1d1f45` | Fondos oscuros y degradados |
| `--azul-500` | `#48a2cb` | Azul claro del logotipo |
| `--acento-500` | `#00afef` | Celeste de la paloma (acentos y resaltados) |

Los colores semánticos (`--verde-*`, `--rojo-*`, `--ambar-*`) son independientes de la marca y no
deberían cambiarse.

---

## 13. Personalización

| Qué | Dónde |
|---|---|
| Logo y favicon | `recursos/img/` + `scripts/generar_logo.ps1` (ver sección 12) |
| Colores institucionales | `recursos/css/base.css` (variables `--azul-*`, `--acento-*`) |
| Nombre, siglas, moneda | `config/app.php` o `Configuración → General` |
| Menú lateral | `config/menu.php` |
| Rutas | `config/routes.php` |
| Reglas de mora y días de gracia | `Configuración → Pagos` |
| Plantillas de documentos | Tabla `plantillas_documento` |

---

© Universidad Nacional de Villarrica del Espíritu Santo — Sistema de Gestión Académica v1.0
