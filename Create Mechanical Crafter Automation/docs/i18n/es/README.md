> [!WARNING]
> 🇪🇸 **es / Espanol**
> 
> Nota: Este README fue traducido automáticamente por un asistente de IA (Antigravity) y puede contener errores de traducción o imprecisiones. Para obtener la documentación más precisa y actualizada, consulte el original en inglés. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Crear automatización de Mechanical Crafter ðŸ› ï¸

> Sistema ComputerCraft totalmente automatizado y listo para producción para los **Mechanical Crafters** del mod **Create**. Diseñado para una integración perfecta con AE2/Almacenamiento refinado en **Modo de bloqueo**.


---

## âœ¨ Características

- **Grabación de recetas en el juego**: coloca los elementos en los artesanos, presiona "S", escribe un nombre. Listo. No se requiere edición JSON.
- **Administración visual de recetas**: presione `M` para explorar todas las recetas guardadas, ver los ingredientes necesarios y administrar patrones.
- **Calibración de red interactiva**: detección automática del diseño exacto de su red mediante activación secuencial del módem.
- **Listo para modo de bloqueo AE2/RS**: optimizado para la integración del cofre de buffer con procesamiento de un solo arte garantizado.
- **Detección inteligente de atascos**: alertas en tiempo real que muestran la ranura exacta del artesano y el elemento que causa un cuello de botella.
- **Panel en vivo**: interfaz de usuario de alto rendimiento codificada por colores que muestra el estado de la cuadrícula, el historial de trabajos y los ingredientes faltantes.

---

## ðŸ› ï¸ Configuración de hardware

![Ingame Setup](../../assets/images/crafter-setup.png)


1. **Computadora avanzada**: necesaria para el tablero en color de alta resolución.
2. **Crafter Grid**: cree su matriz (por ejemplo, 3×3, 5×5, 9×9).
3. **Establecimiento de contactos (paso crucial):**
- Conecte un **módem con cable** a **cada** Mechanical Crafter.
- Conecte todos los módems a la computadora con **Cables de red**.
- Haga clic derecho en los módems hasta que se ilumine el **anillo rojo**.
- **âš ï¸ IMPORTANTE:** DEBE activar los módems en **orden de lectura** (arriba a la izquierda → arriba a la derecha, luego fila por fila) durante la calibración.
4. **Buffer Chest**: conecte un cofre (por ejemplo, Diamond Chest) adyacente a la computadora a través de un módem con cable.
5. **Disparador de Redstone**: conecte una señal de Redstone desde **cualquier lado** de la computadora a los Crafters.

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
3. Seleccione **Crear automatización de Mechanical Crafter**.
4. **Calibración**: En el primer inicio, siga las instrucciones en pantalla para hacer clic derecho en los módems en orden. Esto asigna la red física al software.
5. **Modo de bloqueo**: configure su proveedor de patrones AE2 en **"Modo de bloqueo"** frente al cofre de búfer.

---

## ðŸ“– Cómo utilizar

### Grabar una nueva receta
1. Coloque los ingredientes manualmente en los Mechanical Crafters físicos.
2. Presione **`S`** en el tablero.
3. Escriba un nombre y presione **ENTER**. ¡El sistema escanea la cuadrícula y la guarda al instante!

### Gestión de recetas
1. Presione **`M`** en el tablero para abrir el Administrador.
2. Busque recetas, vea ingredientes y presione **`X`** para eliminar patrones antiguos.

---

## âŒ¨ï¸ teclas de acceso rápido

| Llave | Acción |
|:---:|---|
| **`S`** | **Escanear/Registrar** nueva receta de la cuadrícula *(Cancelar presionando ENTER con el nombre vacío)* |
| **`M`** | **Administrar** recetas guardadas y ver patrones |
| **`R`** | **Recargar** recetas de `crafter_recipes.json` |
| **`P`** | **Salir** (Salga del menú del Administrador de recetas y regrese al Panel de control) |

---

## âš™ï¸ Configuración

El sistema está diseñado para funcionar desde el primer momento. Los datos de calibración se almacenan en `crafter_mapping.json`. Elimine este archivo para activar una nueva calibración.

---

## ðŸ›‘ Solución de problemas

| Error | Causa y solución |
|---|---|
| `¡Falta el cofre de búfer!` | El módem del cofre está apagado o desconectado. |
| `¡No hay artesanos mecánicos!` | No se encontraron módems. ¡Revisa cables y anillos rojos! |
| `ATASCADO: Ranura #X` | La elaboración no terminó. Verifique el pulso y la potencia de Redstone. |
| `Patrón no coincidente` | Los elementos incorrectos en la cuadrícula o el archivo de mapeo están corruptos. ¡Recalibrar! |

---
*Desarrollado con â¤ï¸ para codificación agente avanzada.*


