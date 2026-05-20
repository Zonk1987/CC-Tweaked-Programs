# Powah Energizing Orb Automation (CC:Tweaked)

> Fully automated, production-ready ComputerCraft system for the **Energizing Orbs** from the **Powah** mod. Supports parallel processing, advanced AE2 integration, and intelligent modpack compatibility.

🌐 **Languages:** [English](README.md) | [Deutsch](../docs/i18n/de/README.md) | [Español](../docs/i18n/es/README.md) | [Français](../docs/i18n/fr/README.md) | [Português (Brasil)](../docs/i18n/pt-BR/README.md) | [日本語](../docs/i18n/ja/README.md) | [한국어](../docs/i18n/ko/README.md) | [Русский](../docs/i18n/ru/README.md) | [简体中文](../docs/i18n/zh-CN/README.md)

---

## ✨ Features

- **Multi-Orb Support** — Automatically discovers all connected Energizing Orbs and crafts in parallel.
- **ME Bridge Integration (Required)** — Uses Advanced Peripherals' `meBridge` to read detailed AE2 pattern data (inputs, outputs, quantities).
- **Direct Provider Access (Optional)** — Full support for the **`ae2communicate`** mod. When paired with the ME Bridge, it allows you to filter recipes by **Named Pattern Providers**, eliminating the need to search through large networks.
- **Precision & Intelligence** — Automatic handling of multipliers and exact ID-based ingredient validation during import.
- **Modpack Compatibility** — Toggle between "Powah Only" or "All Mods" (Key `M`) to support recipes from any mod using the Energizing Orb.
- **Auto-Recovery** — Automated item retrieval and orb reset in case of crafting stalls or power failures.

---

## 🛠️ Hardware Setup

![Ingame Setup](docs/assets/images/orb-setup.png)


1. **Advanced Computer** — Required for the high-resolution colored dashboard.
2. **Buffer Chest** — Connect any chest (e.g., Diamond Chest) adjacent to the computer or via the network.
3. **Energizing Orbs** — Connect all Orbs via **Networking Cables** and **Wired Modems**.
4. **ME Bridge (Required):** Connect an **ME Bridge** to the network to allow the system to read detailed pattern data.
5. **Optional Quality-of-Life Feature (ae2communicate):**
   - Install the **`ae2communicate`** mod.
   - Place a **Wired Modem** directly on an **AE2 Interface** (recognized as an `ae2_scanner`).
   - Name your Pattern Providers in your AE2 system (e.g., "Powah Orb").
   - **Benefit:** Filters the ME Bridge data to only show patterns from this specific provider!

---

## 🚀 Installation & Usage

1. Download the install.lua file from the repo
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Run the install.lua file
```bash
install.lua
```
3. Select **Powah Automation** from the menu.
4. The system auto-detects your peripherals on startup.
5. **Important**: Set your AE2 Pattern Providers to **"Blocking Mode"** and point them at the Buffer Chest.

---

## 📖 AE2 Recipe Import

The system features a smart import menu (Key **`I`**):

### Scenario A: With Optional AE2 Scanner
1. Press **`I`**.
2. Select the **Named Pattern Provider** you want to import from.
3. Browse the filtered recipes and press **`ENTER`** to import.

### Scenario B: Standard (ME Bridge Only)
1. Press **`I`**.
2. Browse all available patterns in the network.
3. Use **`M`** to toggle between **Powah Only** and **All Mods**.
4. Press **`ENTER`** to import.

---

## ⌨️ Hotkeys

| Key | Action |
|:---:|---|
| **`R`** | **Reload** recipes without restarting |
| **`I`** | **Import Menu** (Browse and add AE2 Patterns) |
| **`M`** | **Mod Toggle** (Inside Import Menu: Powah vs. All. *Only available if the 'ae2communicate' mod is NOT used*) |
| **`B`** | **Back** (Inside Import Menu: Go back to Provider selection) |
| **`X`** | **Delete** (Remove an imported recipe from the system) |
| **`Q`** | **Quit** (Exit the Import Menu and return to the Dashboard) |

---

## ⚙️ Configuration

The system is designed to work out-of-the-box. If you need manual adjustments, check `startup.lua`:
```lua
local system = PowahSystem.new({
    chestName = "left", -- Or use auto-detection variable
    recipeFile = "powah_recipes.json",
    meBridgeName = "right", -- Required for imports: ME Bridge peripheral name
    aeScannerName = "top" -- Optional: ae2communicate scanner peripheral name
})
```

---

## 🛑 Troubleshooting

| Error | Cause & Fix |
|---|---|
| `No ME Bridge found!` | Check cables and modem status. |
| `AE Scanner: None` | Normal if you don't have the mod. Classic mode will be used. |
| `Timeout in Orb...` | Crafting took >60s. Items returned to chest. Check power! |
| `Duplicate Name` | You are trying to import a recipe that already exists. |

---
*Developed with ❤️ for Advanced Agentic Coding.*




