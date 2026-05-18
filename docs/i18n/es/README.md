> [!WARNING]
> 🇪🇸 **es / Espanol**
> 
> Nota: Este README fue traducido automáticamente por un asistente de IA (Antigravity) y puede contener errores de traducción o imprecisiones. Para obtener la documentación más precisa y actualizada, consulte el original en inglés. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div align="centro">

# CC de Zonk: suite de automatización modificada 🚀

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

Una colección de scripts de automatización de nivel profesional para Minecraft **CC:Tweaked**, que presenta una arquitectura modular **Feature-Core**, una estética de interfaz de usuario premium y un instalador robusto basado en manifiestos.


---

## 🚀 Instalación

Ejecute este comando en una **Computadora avanzada**:

1. Descargue el archivo install.lua del repositorio.
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Ejecute el archivo install.lua
```bash
install.lua
```

---

## 📦 Paquetes disponibles

| IDENTIFICACIÓN | Nombre | Descripción | Características clave |
|:---|:---|:---|:---|
| `mekanismo_portal_hub` | [**Centro de marcador del portal**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/es/README.md) | Marcador de pantalla táctil premium. | Interfaz de usuario móvil, rayas decorativas, restablecimiento de página. |
| `mekanism_recall_sender` | [**Remitente de recuperación del portal**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/es/README.md) | Disparador inalámbrico remoto. | Diagnóstico de hardware, monitoreo del estado en vivo. |
| `crea_crafter` | [**Mechanical Crafter**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/es/README.md) | Automatización de elaboración de cuadrículas. | Grabación y calibración, recetas de varios pasos. |
| `powah_orb` | [**Orbe energizante**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/es/README.md) | Automatización de elaboración paralela. | Integración de ME Bridge, recuperación automática. |
| `suite_desarrollador` | [**CC Developer Suite**](../../../CC%20Developer%20Suite/docs/i18n/es/README.md) | Kit de herramientas de diagnóstico. | Rastreador de eventos, inspector de periféricos. |

---

## 🏗️ Arquitectura: esqueleto de funciones principales

Este repositorio está diseñado para brindar mantenimiento y rendimiento utilizando un esqueleto modular.

### **Módulos principales (`lib/core`)**
Las utilidades genéricas se extraen en paquetes principales ocultos para reducir la duplicación:
- **`core.base`**: Lógica fundamental como `ConfigStore` (persistencia JSON).
- **`core.peripherals`**: Descubrimiento y ajuste seguro de periféricos (`PeripheralScanner`).
- **`core.network`**: Protocolos de comunicación estandarizados (`RednetProtocol`).
- **`core.redstone`**: ayudantes de interacción de Redstone (`RedstoneController`).
- **`core.ui`**: Componentes de UI reutilizables (`ButtonGrid`).
- **`core.inventory`**: Manejo de inventario estandarizado (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: almacenamiento de recetas respaldado por JSON (`RecipeStore`).

### **Resolución de dependencia**
El instalador resuelve automáticamente las dependencias de forma recursiva. Por ejemplo, la instalación de `create_crafter` extraerá automáticamente los módulos `core.inventory` y `core.redstone` necesarios. Los archivos de la aplicación se colocan en el directorio raíz, mientras que las bibliotecas principales se mantienen en la jerarquía `lib/core/` (accesible a través de rutas de paquetes ajustadas en `startup.lua`).

---

## 🛠️ Pautas de desarrollo

### **Agregar una nueva aplicación**
1. Cree la carpeta de su aplicación (por ejemplo, "Mi nueva aplicación").
2. Implemente su lógica, aprovechando los módulos `lib/core` existentes.
3. Registre su aplicación en `manifest.lua`.
4. Agregue dependencias si usa módulos principales.

### **Agregar un módulo principal**
1. Coloque el módulo en `lib/core/<categoría>/ModuleName.lua`.
2. Regístrelo como un paquete `hidden = true` en `manifest.lua`.

---

## ⚖️ Seguridad y reglas

Todo el código de este repositorio se rige por **[AGENTS.md](../../../AGENTS.md)**.
- **Modo estricto**: los scripts de aplicaciones y los archivos de entrada utilizan un entorno estricto para evitar globales accidentales (las bibliotecas principales actualmente omiten esto para reducir el texto estándar de localización).
- **Sin eliminación**: el instalador nunca elimina los archivos de usuario existentes (excepto para limpiar sus propios archivos temporales como `manifest.lua` e `install.lua` una vez completado, o reemplazar versiones anteriores durante una actualización).
- **Instalar caché de estado**: el instalador crea un archivo oculto `.install_state.json` para recordar qué versiones de archivos se han instalado. Esto acelera las ejecuciones futuras al omitir archivos que no han cambiado (que se muestran como "CACHED"). Es seguro eliminar este archivo en cualquier momento; la próxima instalación simplemente volverá a descargarlo todo.
- **Sin reinicio automático**: el instalador pregunta antes de ejecutar los archivos de entrada y nunca reinicia el sistema sin permiso.
- **Política de aplicación única**: Solo se admite **una** aplicación por computadora avanzada. La instalación de varias aplicaciones en la misma computadora provocará colisiones de archivos y sobrescribirá archivos críticos como `startup.lua` o `Dashboard.lua`.

---

## 📝 Créditos y solución de problemas
Desarrollado por **Antigravity** como parte de la iniciativa Advanced Agentic Coding.
Si tiene problemas:
1. Asegúrese de estar utilizando una **Computadora avanzada**.
2. Ejecute `install.lua --validate` para comprobar si hay errores de manifiesto.
3. Verifique `README.md` dentro de la carpeta de cada aplicación para conocer la configuración específica del hardware.

**[LICENCIA](../../../LICENSE)**: MIT


