# Mekanism Portal Recall Sender (CC:Tweaked)

> A dedicated remote trigger for the **Mekanism Portal Network**. Allows you to dial your home portal remotely by simply providing a redstone signal (button, pressure plate, etc.) at your destination.

---

## ✨ Features

- **Hardware Diagnostics** — Scans all attached peripherals at startup and provides clear feedback on Modem and Teleporter presence.
- **Live Portal Status (Optional)** — Real-time monitoring of the local portal's state (e.g., "Ready", "No Power") if a local Teleporter block is physically attached (otherwise defaults to "Remote Hub only").
- **Heartbeat Auto-Refresh** — Automatically updates the status every 2 seconds to keep the display synchronized with the Hub.
- **Interactive Setup** — No code editing required. The script asks for the target location on the first run.
- **Config Menu (Hotkeys)** — Press `C` on the computer terminal to change the destination name or channel.
- **Dual-Path Protocol** — Sends commands via both standard Modem API and Rednet for maximum reliability.

---

## 🛠️ Hardware Setup

1. **Pocket Computer or Small Computer** — Place a computer at your remote destination (e.g., Moon Base, Mining Outpost).
2. **Modem (Wireless or Wired)** — Attach a wireless modem (ideal for remote locations) or a wired modem to the computer.
3. **Redstone Trigger** — Connect a Button, Pressure Plate, or any redstone source to any side of the computer.
   - When the redstone signal turns **ON**, the computer sends the recall command to your main base.

---

## 🚀 Installation

1. Download the install.lua file from the repo
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Run the install.lua file
```bash
install.lua
```
Select **Mekanism Portal Recaller** from the menu.

---

## ⚙️ Usage

1. **First Run**: The computer will ask you for a **Target Name**. Enter the *exact name* of the frequency as it appears in your main Portal Hub (e.g., "Main Base").
2. **Normal Operation**: The screen will show "Waiting for Redstone signal...".
3. **Trigger**: Press your button. The Hub at your main base will instantly switch to your current location.
4. **Configuration**: If you move the computer to a new base, press `C` on the keyboard to open the menu and change the target name.

---

## 📡 Technical Details
The sender broadcasts a JSON table on the configured channel (default: 99):
```json
{
    "command": "RECALL",
    "target": "Your Destination Name"
}
```

---

## 📝 Credits
Developed for professional Minecraft automation.