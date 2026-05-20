> [!WARNING]
> 🇪🇸 **es / Espanol**
> 
> Nota: Este README fue traducido automáticamente por un asistente de IA (Antigravity) y puede contener errores de traducción o imprecisiones. Para obtener la documentación más precisa y actualizada, consulte el original en inglés. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Red del portal de mecanismos (CC: modificado)

> Una interfaz táctil profesional de alto rendimiento para **Mekanism Teleporters**. Cuenta con una interfaz de usuario con doble búfer sin parpadeos, administración de frecuencia de varias páginas y un editor de frecuencia incorporado con personalización de color.


---

## ✨ Características

- **Representación con doble búfer**: actualizaciones de la interfaz de usuario sin parpadeo mediante un sistema de búfer personalizado basado en ventanas.
- **Ventanas superpuestas móviles**: arrastre el menú de selección de color a cualquier lugar de la pantalla para obtener una visibilidad óptima.
- **Indicadores de franjas decorativas**: las barras verticales de alto contraste en los botones muestran los colores asignados con bordes de sombra negros para mayor visibilidad en cualquier fondo.
- **Dynamic Portal Grid**: descubre automáticamente todas las frecuencias con paginación inteligente y **Restablecimiento de página** automático en los cambios de lista.
- **Monitoreo de estado en tiempo real**: comentarios en vivo sobre el estado del portal, la frecuencia de destino y el propietario (con resolución UUID de Mojang).
- **Modo de edición y personalización del color**: asigne colores específicos a frecuencias o utilice el ciclo de color aleatorio.
- **Soporte de recuperación remota**: Módem integrado y API Rednet para activación remota del portal (a través del script Recaller).

---

## 🛠️ Configuración de hardware

![Ingame Setup](../../assets/images/hub-setup.png)


1. **Computadora avanzada**: necesaria para gráficos de alta resolución y doble almacenamiento en búfer.
2. **Monitor avanzado**
- Tamaño recomendado: **bloques de 4x3** para obtener la mejor disposición de botones.
- Conéctese a través de **módems con cable** y cables de red.
3. **Mecanismo Teletransportador**
- Conecte el Teleporter a la misma red de cable usando un **Módem con cable**.
- Haga clic derecho en el módem para **ON** (anillo rojo).
4. **Módem (opcional)**
- Conecte un módem inalámbrico o por cable a la computadora para habilitar la funcionalidad **Recuperación remota**.

---

## 🚀 Instalación

1. Descargue el archivo install.lua del repositorio.
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Ejecute el archivo install.lua
```bash
install.lua
```
Seleccione **Mekanism Portal Dialer Hub** en el menú. El instalador descargará automáticamente los archivos de la aplicación (`HubSystem`, `UUIDService`, `Dashboard`) y resolverá todas las dependencias principales (por ejemplo, `ButtonGrid`, `PeripheralScanner`).

---

## ⚙️ Configuración

Abra `inicio` en la computadora para personalizar el comportamiento del sistema:

- `gridColumns` / `gridRows`: Ajusta el número de botones por página.
- `recallChannel`: configura el canal del módem para solicitudes de portal remoto (predeterminado: 99).

---

## ⌨️ Controles y modos

### **Modo de marcador (predeterminado)**
- **Toca un portal**: cambia instantáneamente la frecuencia del teletransportador. El botón permanecerá resaltado hasta que el hardware confirme el cambio.
- **Siguiente/Anterior**: cambia entre páginas si tienes muchas frecuencias.

### **Modo de edición (icono de configuración)**
1. Toque el icono **¤** en la esquina superior derecha para ingresar al modo de edición.
2. Seleccione cualquier portal para abrir **Superposición de color**.
3. Elija un **Color fijo** para ese portal específico o seleccione **ALEATORIO** para un ciclo dinámico de colores.
4. Utilice la barra **MOVER** en la parte superior de la superposición para mover la ventana si bloquea su vista.

---

## 📝 API de recuperación remota

El sistema escucha los mensajes del módem en el `recallChannel` configurado. Para activar un portal de forma remota, envíe una tabla con la siguiente estructura:
```lua
{
    command = "RECALL",
    target = "My Base" -- Name of the frequency
}
```
Alternativamente, puede utilizar el script dedicado **Mekanism Portal Recaller** en una computadora de bolsillo portátil.

---

## 📝 Créditos
Desarrollado como parte de la iniciativa **Advanced Agentic Coding** para la automatización profesional de Minecraft.




