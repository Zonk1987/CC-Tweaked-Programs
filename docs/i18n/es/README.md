> [!WARNING]
> 🇪🇸 **es / Español**
> 
> ⚠️ **Nota**: Este README fue traducido automáticamente por una IA (Antigravity) y puede contener errores o imprecisiones. Para obtener la documentación más precisa y actualizada, consulta el [README.md](../../../README.md) original en inglés.

<div align="center">

# Zonk's CC:Tweaked Automation Suite 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

Una colección de scripts de automatización de calidad profesional para Minecraft **CC:Tweaked**, con una arquitectura modular **Feature-Core**, estética de interfaz premium y un robusto instalador controlado por manifiesto.

---

## 🚀 Instalación

Ejecuta este comando en una **Computadora Avanzada**:

1. Descarga el archivo `install.lua` desde el repositorio:
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Ejecuta el archivo `install.lua`:
```bash
install.lua
```

---

## 📦 Paquetes Disponibles

| ID | Nombre | Descripción | Características Clave |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | Marcador de portal táctil premium. | Interfaz móvil, franjas de acento, reinicio de página. |
| `mekanism_recall_sender`| **Portal Recall Sender** | Activador inalámbrico remoto. | Diagnóstico de hardware, monitorización en vivo. |
| `create_crafter` | **Mechanical Crafter** | Automatización de crafteo en cuadrícula. | Grabación y calibración, recetas de varios pasos. |
| `powah_orb` | **Energizing Orb** | Automatización de crafteo en paralelo. | Integración con ME Bridge, autorecuperación. |
| `developer_suite` | **CC Developer Suite** | Kit de herramientas de diagnóstico. | Sniffer de eventos, inspector de periféricos. |

---

## 🏗️ Arquitectura: Feature-Core Skeleton

Este repositorio está diseñado para un mantenimiento sencillo y alto rendimiento mediante un esqueleto modular.

### **Módulos Core (`lib/core`)**
Las utilidades genéricas se extraen en paquetes core ocultos para reducir la duplicación:
- **`core.base`**: Lógica fundamental como `ConfigStore` (persistencia JSON).
- **`core.peripherals`**: Descubrimiento y envoltura segura de periféricos (`PeripheralScanner`).
- **`core.network`**: Protocolos de comunicación estandarizados (`RednetProtocol`).
- **`core.redstone`**: Ayudas de interacción con redstone (`RedstoneController`).
- **`core.ui`**: Componentes de interfaz reutilizables (`ButtonGrid`).
- **`core.inventory`**: Gestión de inventario estandarizada (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: Almacén de recetas respaldado por JSON (`RecipeStore`).

### **Resolución de Dependencias**
El instalador resuelve automáticamente las dependencias de forma recursiva. Por ejemplo, instalar `create_crafter` descargará automáticamente los módulos requeridos `core.inventory` y `core.redstone`. Los archivos de la aplicación se colocan en el directorio raíz, mientras que las bibliotecas del núcleo se mantienen en la jerarquía `lib/core/` (accesible a través de rutas de paquete ajustadas en `startup.lua`).

---

## 🛠️ Pautas de Desarrollo

### **Añadir una Nueva Aplicación**
1. Crea la carpeta de tu aplicación (por ejemplo, `Mi Nueva App`).
2. Implementa tu lógica, aprovechando los módulos existentes de `lib/core`.
3. Registra tu aplicación en `manifest.lua`.
4. Añade dependencias si utilizas módulos core.

### **Añadir un Módulo Core**
1. Coloca el módulo en `lib/core/<categoría>/ModuleName.lua`.
2. Regístralo como un paquete oculto (`hidden = true`) en `manifest.lua`.

---

## ⚖️ Seguridad & Reglas

Todo el código en este repositorio se rige por **[AGENTS.md](./AGENTS.md)**.
- **Modo Estricto**: Los scripts de aplicación y archivos de entrada utilizan un entorno estricto para evitar variables globales accidentales (las bibliotecas del núcleo omiten esto actualmente para reducir el código redundante de localización).
- **Sin Eliminación**: El instalador nunca elimina archivos de usuario existentes (excepto para limpiar sus propios archivos temporales como `manifest.lua` e `install.lua` después de completar, o reemplazar versiones anteriores durante una actualización).
- **Caché de Estado de Instalación**: El instalador crea un archivo oculto `.install_state.json` para recordar qué versiones de archivos se han instalado. Esto acelera futuras ejecuciones omitiendo archivos que no han cambiado (mostrados como `CACHED`). Es seguro eliminar este archivo en cualquier momento; la próxima instalación simplemente volverá a descargar todo.
- **Sin Reinicio Automático**: El instalador solicita permiso antes de ejecutar archivos de entrada y nunca reinicia el sistema sin autorización.
- **Política de App Única**: Solo se admite **una** aplicación por Computadora Avanzada. Instalar varias aplicaciones en la misma computadora provocará colisiones de archivos y sobrescribirá archivos críticos como `startup.lua` o `Dashboard.lua`.

---

## 📝 Créditos & Resolución de Problemas

Desarrollado por **Antigravity** como parte de la iniciativa Advanced Agentic Coding.
Si encuentras problemas:
1. Asegúrate de estar usando una **Computadora Avanzada**.
2. Ejecuta `install.lua --validate` para verificar errores en el manifiesto.
3. Consulta el `README.md` dentro de la carpeta de cada aplicación para la configuración de hardware específica.

**[LICENSE](./LICENSE)**: MIT
