# Zonk's CC:Tweaked Automation Suite 🚀

A collection of professional-grade automation scripts for Minecraft **CC:Tweaked**, featuring a modular **Feature-Core** architecture, premium UI aesthetics, and a robust manifest-driven installer.

---

## 🚀 Installation

Run this command on an **Advanced Computer**:

```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
install.lua
```

---

## 📦 Available Packages

| ID | Name | Description | Key Features |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | Premium touch-screen dialer. | Moveable UI, Accent Stripes, Page-Reset. |
| `mekanism_recall_sender`| **Portal Recall Sender** | Remote wireless trigger. | Hardware diagnostics, Live status monitoring. |
| `create_crafter` | **Mechanical Crafter** | Grid crafting automation. | Recording & Calibration, Multi-step recipes. |
| `powah_orb` | **Energizing Orb** | Parallel crafting automation. | ME Bridge integration, Auto-recovery. |
| `developer_suite` | **CC Developer Suite** | Diagnostic toolkit. | Event sniffer, Peripheral inspector. |

---

## 🏗️ Architecture: Feature-Core Skeleton

This repository is built for maintainability and performance using a modular skeleton.

### **Core Modules (`lib/core`)**
Generic utilities are extracted into hidden core packages to reduce duplication:
- **`core.base`**: Fundamental logic like `ConfigStore` (JSON persistence).
- **`core.peripherals`**: Safe peripheral discovery and wrapping (`PeripheralScanner`).
- **`core.network`**: Standardized communication protocols (`RednetProtocol`).
- **`core.redstone`**: Redstone interaction helpers (`RedstoneController`).
- **`core.ui`**: Reusable UI components (`ButtonGrid`).
- **`core.inventory`**: Standardized inventory handling (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: JSON-backed recipe storage (`RecipeStore`).

### **Dependency Resolution**
The installer automatically resolves dependencies recursively. For example, installing `create_crafter` will automatically pull the required `core.inventory` and `core.redstone` modules. All files are placed in a flat structure at the root for simple `require()` calls.

---

## 🛠️ Development Guidelines

### **Adding a New App**
1. Create your app folder (e.g., `My New App`).
2. Implement your logic, leveraging existing `lib/core` modules.
3. Register your app in `manifest.lua`.
4. Add dependencies if you use core modules.

### **Adding a Core Module**
1. Place the module in `lib/core/<category>/ModuleName.lua`.
2. Register it as a `hidden = true` package in `manifest.lua`.

---

## ⚖️ Safety & Rules

All code in this repository is governed by **[AGENTS.md](./AGENTS.md)**.
- **Strict Mode**: Every script uses a strict environment to prevent accidental globals.
- **No Deletion**: The installer never deletes existing user files (except when explicitly replacing older versions during an update).
- **No Auto-Reboot**: The installer asks before running entry files and never reboots the system without permission.

---

## 📝 Credits & Troubleshooting
Developed by **Antigravity** as part of the Advanced Agentic Coding initiative. 
If you encounter issues:
1. Ensure you are using an **Advanced Computer**.
2. Run `install --validate` to check for manifest errors.
3. Check the `README.md` within each application's folder for hardware-specific setup.

**LICENSE**: MIT
