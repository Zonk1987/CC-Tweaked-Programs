<div align="center">

# Zonk's CC:Tweaked Automation Suite 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality%20Checks)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

A collection of professional-grade automation scripts for Minecraft **CC:Tweaked**, featuring a modular **Feature-Core** architecture, premium UI aesthetics, and a robust manifest-driven installer.

🌐 **Languages:** [English](README.md) | [Deutsch](docs/i18n/de/README.md) | [Español](docs/i18n/es/README.md) | [Français](docs/i18n/fr/README.md) | [Português (Brasil)](docs/i18n/pt-BR/README.md) | [日本語](docs/i18n/ja/README.md) | [한국어](docs/i18n/ko/README.md) | [Русский](docs/i18n/ru/README.md) | [简体中文](docs/i18n/zh-CN/README.md)

---

## 🚀 Installation & CLI Options

Run this command on an **Advanced Computer**:

1. Download the `install.lua` file:
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Run the installer:
```bash
install.lua
```

### **Installer CLI Options**
- `install.lua --validate`: Checks the manifest structure and validates dependency trees.
- `install.lua --dry-run`: Performs a detailed simulation of the planned installation without writing or downloading any files (ideal for testing updates).
- `install.lua --force` or `install.lua -f`: Bypasses the local version-fingerprint cache and forces a full re-download of all system files.

---

## 📦 Available Packages

| ID | Name | Description | Key Features |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | [**Portal Dialer Hub**](./Mekanism%20Portal%20Dialer%20Hub/README.md) | Premium touch-screen dialer. | Moveable UI, Accent Stripes, Page-Reset. |
| `mekanism_recall_sender`| [**Portal Recall Sender**](./Mekanism%20Portal%20Dialer%20Recall%20Sender/README.md) | Remote wireless trigger. | Hardware diagnostics, Live status monitoring. |
| `create_crafter` | [**Mechanical Crafter**](./Create%20Mechanical%20Crafter%20Automation/README.md) | Grid crafting automation. | Recording & Calibration, Multi-step recipes. |
| `powah_orb` | [**Energizing Orb**](./Powah%20Energizing%20Orb%20Automation/README.md) | Parallel crafting automation. | ME Bridge integration, Auto-recovery. |
| `developer_suite` | [**CC Developer Suite**](./CC%20Developer%20Suite/README.md) | Diagnostic toolkit. | Event sniffer, Peripheral inspector. |

---

## 🏗️ Architecture: Feature-Core Skeleton

This repository is built for maintainability and performance using a modular skeleton.

### **Core Modules (`lib/core`)**
Generic utilities are extracted into hidden core packages to reduce duplication:
- **`core.base`**: Fundamental logic like `ConfigStore` (JSON persistence).
- **`core.logger`**: File-based structured logging (`Logger`).
- **`core.peripherals`**: Safe peripheral discovery, wrapping, and hardware abstraction (`PeripheralScanner`, `HAL`).
- **`core.network`**: Standardized communication protocols (`RednetProtocol`).
- **`core.redstone`**: Redstone interaction helpers (`RedstoneController`).
- **`core.ui`**: Reusable UI components (`ButtonGrid`, `ConfigGUI`).
- **`core.ui.boot_assistant`**: Interactive startup diagnostics and boot guidance (`boot_assistant`).
- **`core.inventory`**: Standardized inventory handling (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: JSON-backed recipe storage (`RecipeStore`).

### **Dependency Resolution**
The installer automatically resolves dependencies recursively. For example, installing `create_crafter` will automatically pull the required `core.inventory` and `core.redstone` modules. Entry files are placed in the root directory as `startup.lua`, while app modules are installed into `system/` and `ui/`. Core libraries remain in `lib/core/` (accessible via adjusted package paths in the `startup.lua`).

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
- **Strict Mode**: Application scripts and entry files use a strict environment to prevent accidental globals (core libraries currently bypass this to reduce localization boilerplate).
- **Self-Update**: The installer automatically checks whether a newer installer version is available on GitHub and upgrades itself transparently before continuing.
- **Rollback Safety**: The installer creates temporary `.bak` copies of files being updated. If any download, connection, or size check fails mid-installation, it initiates an automatic transactional rollback to restore the system to its precise previous state.
- **Protected Files (Overwrite Protection)**: Critical user files such as `config.json`, `crafter_mapping.json`, `.env`, any `*.local.json` hardware overrides, and `user_*.json` configurations are never overwritten and will be preserved automatically.
- **No Deletion**: The installer never deletes existing user files (except for cleaning up its own temporary files like `manifest.lua` and `install.lua` after completion, or replacing older versions during an update).
- **Install State Cache**: The installer creates a hidden file `.install_state.json` to remember which file versions have been installed. This speeds up future runs by skipping files that haven't changed (shown as `CACHED`). It is safe to delete this file at any time — the next install will simply re-download everything.
- **No Auto-Reboot**: The installer asks before running entry files and never reboots the system without permission.
- **Single App Policy**: Only **one** application is supported per Advanced Computer. Installing multiple apps on the same computer will cause file collisions and overwrite critical files like `startup.lua` or `Dashboard.lua`.

---

## 📝 Credits & Troubleshooting
Developed by **Antigravity** as part of the Advanced Agentic Coding initiative. 
If you encounter issues:
1. Ensure you are using an **Advanced Computer**.
2. Run `install.lua --validate` to check for manifest errors.
3. Check the `README.md` within each application's folder for hardware-specific setup.

**[LICENSE](./LICENSE)**: MIT





