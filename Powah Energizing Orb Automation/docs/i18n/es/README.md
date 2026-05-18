> [!WARNING]
> 🇪🇸 **es / Espanol**
> 
> Nota: Este README fue traducido automáticamente por un asistente de IA (Antigravity) y puede contener errores de traducción o imprecisiones. Para obtener la documentación más precisa y actualizada, consulte el original en inglés. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Automatización de orbes energizantes de Powah (CC:Tweaked)

> Sistema ComputerCraft totalmente automatizado y listo para producción para los **Orbes Energizantes** del mod **Powah**. Admite procesamiento paralelo, integración avanzada de AE2 y compatibilidad inteligente con modpack.


---

## âœ¨ Características

- **Compatibilidad con múltiples orbes**: descubre automáticamente todos los orbes energizantes y artesanías conectados en paralelo.
- **Integración de ME Bridge (obligatoria)**: utiliza "meBridge" de periféricos avanzados para leer datos detallados del patrón AE2 (entradas, salidas, cantidades).
- **Acceso directo de proveedor (opcional)**: compatibilidad total con el mod **`ae2communicate`**. Cuando se combina con ME Bridge, le permite filtrar recetas por **Proveedores de patrones con nombre**, lo que elimina la necesidad de buscar en redes grandes.
- **Precisión e inteligencia**: manejo automático de multiplicadores y validación exacta de ingredientes basada en la identificación durante la importación.
- **Compatibilidad de Modpack**: alterna entre "Solo Powah" o "Todos los mods" (tecla `M`) para admitir recetas de cualquier mod que use Energizing Orb.
- **Recuperación automática**: recuperación automática de objetos y reinicio de orbes en caso de problemas de elaboración o cortes de energía.

---

## ðŸ› ï¸ Configuración de hardware

![Ingame Setup](../../assets/images/orb-setup.png)


1. **Computadora avanzada**: necesaria para el tablero en color de alta resolución.
2. **Buffer Chest**: conecta cualquier cofre (por ejemplo, Diamond Chest) adyacente a la computadora o a través de la red.
3. **Orbes energizantes**: conecta todos los orbes mediante **cables de red** y **módems con cable**.
4. **Puente ME (obligatorio):** Conecte un **Puente ME** a la red para permitir que el sistema lea datos de patrones detallados.
5. **Función opcional de calidad de vida (ae2communicate):**
- Instale el mod **`ae2communicate`**.
- Coloque un **Módem con cable** directamente en una **Interfaz AE2** (reconocida como `ae2_scanner`).
- Asigne un nombre a sus proveedores de patrones en su sistema AE2 (por ejemplo, "Powah Orb").
- **Beneficio:** ¡Filtra los datos de ME Bridge para mostrar solo patrones de este proveedor específico!

---

## ðŸš€ Instalación y uso

1. Descargue el archivo install.lua del repositorio.
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Ejecute el archivo install.lua
```bash
install.lua
```
3. Seleccione **Powah Automation** en el menú.
4. El sistema detecta automáticamente sus periféricos al iniciarse.
5. **Importante**: Configure sus proveedores de patrones AE2 en **"Modo de bloqueo"** y apúntelos al cofre de búfer.

---

## ðŸ“– Importación de recetas AE2

El sistema cuenta con un menú de importación inteligente (Tecla **`I`**):

### Escenario A: con escáner AE2 opcional
1. Presione **`Yo`**.
2. Seleccione el **Proveedor de patrones con nombre** desde el que desea importar.
3. Explore las recetas filtradas y presione **`ENTER`** para importar.

### Escenario B: Estándar (solo puente ME)
1. Presione **`Yo`**.
2. Explora todos los patrones disponibles en la red.
3. Utilice **`M`** para alternar entre **Sólo Powah** y **Todas las modificaciones**.
4. Presione **`ENTER`** para importar.

---

## âŒ¨ï¸ teclas de acceso rápido

| Llave | Acción |
|:---:|---|
| **`R`** | **Recargar** recetas sin reiniciar |
| **`Yo`** | **Menú Importar** (Buscar y agregar patrones AE2) |
| **`M`** | **Alternar mod** (Dentro del menú Importar: Powah vs. Todos. *Solo disponible si NO se usa el mod 'ae2communicate'*) |
| **`B`** | **Volver** (Dentro del menú Importar: volver a la selección de proveedores) |
| **`X`** | **Eliminar** (Eliminar una receta importada del sistema) |
| **`P`** | **Salir** (Salga del menú Importar y regrese al Panel de control) |

---

## âš™ï¸ Configuración

El sistema está diseñado para funcionar desde el primer momento. Si necesita ajustes manuales, consulte `startup.lua`:
```lua
local system = PowahSystem.new({
    chestName = "left", -- Or use auto-detection variable
    recipeFile = "powah_recipes.json",
    meBridgeName = "right", -- Required for imports: ME Bridge peripheral name
    aeScannerName = "top" -- Optional: ae2communicate scanner peripheral name
})
```

---

## ðŸ›‘ Solución de problemas

| Error | Causa y solución |
|---|---|
| `¡No se encontró ningún puente ME!` | Verifique los cables y el estado del módem. |
| `Escáner AE: Ninguno` | Normal si no tienes el mod. Se utilizará el modo clásico. |
| `Tiempo de espera en Orb...` | La elaboración tomó más de 60 segundos. Artículos devueltos al cofre. ¡Comprueba el poder! |
| `Nombre duplicado` | Estás intentando importar una receta que ya existe. |

---
*Desarrollado con â¤ï¸ para codificación agente avanzada.*

