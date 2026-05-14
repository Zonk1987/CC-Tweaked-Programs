# Zonk's CC:Tweaked Automation Suite

A collection of professional-grade automation scripts for Minecraft **CC:Tweaked**, featuring a modular **Feature-Core** architecture and a robust manifest-driven installer.

---

## 🚀 Installation

The suite uses a unified installer. Run this command on an **Advanced Computer**:

```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/dev/install.lua
install.lua
```

### Usage Modes
- **Interactive**: Simply run `install` to open the package menu.
- **Specific Package**: `install <package_id>` (e.g., `install powah_orb`).
- **Dry Run**: `install --dry-run <package_id>` to see what will be installed without downloading.
- **Validate**: `install --validate` to check the manifest integrity.

---

## 📦 Available Packages

| ID | Name | Description |
|:---|:---|:---|
| `create_crafter` | **Create Mechanical Crafter** | Grid crafting automation with recording & calibration. |
| `powah_orb` | **Powah Energizing Orb** | Parallel crafting with ME Bridge & auto-recovery. |
| `mekanism_portal_hub` | **Mekanism Portal Hub** | Premium touch-screen dialer with visual editor. |
| `mekanism_recall_sender`| **Mekanism Portal Recaller** | Remote wireless trigger for the Portal Hub. |
| `developer_suite` | **CC Developer Suite** | Hardware inspector, event sniffer, and diagnostics. |

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
