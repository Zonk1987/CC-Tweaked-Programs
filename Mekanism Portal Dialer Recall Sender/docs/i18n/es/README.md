> [!WARNING]
> 🇪🇸 **es / Espanol**
> 
> Nota: Este README fue traducido automáticamente por un asistente de IA (Antigravity) y puede contener errores de traducción o imprecisiones. Para obtener la documentación más precisa y actualizada, consulte el original en inglés. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Remitente de recuperación del portal de mecanismo (CC: modificado)

> Un disparador remoto dedicado para la **Red del Portal Mekanism**. Le permite marcar el portal de su hogar de forma remota simplemente proporcionando una señal de redstone (botón, placa de presión, etc.) en su destino.


---

## ✨ Características

- **Diagnóstico de hardware**: escanea todos los periféricos conectados al inicio y proporciona información clara sobre la presencia del módem y el teletransportador.
- **Estado del portal en vivo (opcional)**: monitoreo en tiempo real del estado del portal local (por ejemplo, "Listo", "Sin energía") si hay un bloque de Teletransportador local conectado físicamente (de lo contrario, el valor predeterminado es "Solo concentrador remoto").
- **Heartbeat Auto-Refresh**: actualiza automáticamente el estado cada 2 segundos para mantener la pantalla sincronizada con el Hub.
- **Configuración interactiva**: no se requiere edición de código. El script solicita la ubicación de destino en la primera ejecución.
- **Menú de configuración (teclas de acceso rápido)**: presione `C` en el terminal de la computadora para cambiar el nombre o canal de destino.
- **Protocolo de ruta dual**: envía comandos a través de la API de módem estándar y Rednet para una máxima confiabilidad.

---

## 🛠️ Configuración de hardware

1. **Computadora de bolsillo o computadora pequeña**: coloque una computadora en su destino remoto (por ejemplo, base lunar, puesto minero).
2. **Módem (inalámbrico o por cable)**: conecte un módem inalámbrico (ideal para ubicaciones remotas) o un módem por cable a la computadora.
3. **Disparador de Redstone**: conecta un botón, una placa de presión o cualquier fuente de Redstone a cualquier lado de la computadora.
- Cuando la señal de Redstone se **ON**, la computadora envía el comando de recuperación a su base principal.

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
Seleccione **Recuperador del portal de mecanismo** en el menú.

---

## ⚙️ Uso

1. **Primera ejecución**: La computadora le pedirá un **Nombre de destino**. Ingrese el *nombre exacto* de la frecuencia tal como aparece en su Portal Hub principal (por ejemplo, "Base principal").
2. **Operación normal**: La pantalla mostrará "Esperando señal de Redstone...".
3. **Disparador**: Presiona tu botón. El Hub en su base principal cambiará instantáneamente a su ubicación actual.
4. **Configuración**: Si mueve la computadora a una nueva base, presione `C` en el teclado para abrir el menú y cambiar el nombre del destino.

---

## ðŸ“¡ Detalles técnicos
El remitente transmite una tabla JSON en el canal configurado (predeterminado: 99):
```json
{
    "command": "RECALL",
    "target": "Your Destination Name"
}
```

---

## ðŸ“ Créditos
Desarrollado para la automatización profesional de Minecraft.


