# 🚀 Future Plans: Next-Gen Automation Suite

This document outlines the strategic roadmap for the professionalization and modernization of the CC:Tweaked Automation Suite. These plans focus on architectural integrity, user experience, and industrial-grade reliability.

---

## 🏗️ 1. Architecture: Abstraction & OOP
Transitioning from script-based logic to a true **Object-Oriented Framework**.

### **BaseApp Class**
- Create a unified `core.base.App` class that handles:
    - Standardized startup sequences.
    - Automatic `config.json` loading/saving.
    - Global event handling and background tasks.
    - Error boundary management.

### **Hardware Abstraction Layer (HAL)**
- **Unified Inventory**: A `core.inventory` service that wraps chests, barrels, drawers, and ME interfaces into a single API (`push`, `pull`, `list`).
- **Energy Monitor**: Generic interface for checking energy levels across different mod machines (Powah, Mekanism, Thermal).
- **Peripheral Auto-Discovery**: Advanced scanning that identifies hardware based on contents or NBT tags, not just side names.

---

## 🛡️ 2. Safety & Reliability
Moving towards "Industrial Grade" software that never hangs or crashes silently.

### **Validation Layer**
- **JSON Schema Validation**: Strict checks for `config.json` and `recipes.json` at startup with human-readable error messages.
- **Dependency Tracking**: Real-time monitoring of required peripherals; auto-pauses the system if a critical chest or machine is removed.

### **Error Recovery (Watchdog)**
- Implementation of a background **Watchdog Service**.
- Detects "stuck" crafting operations (e.g., Energizing Orb timeouts).
- Automatic recovery: Cleans machines, returns items to storage, and notifies the user via Rednet/Monitor.

---

## 🎨 3. UI Design & Aesthetics
A premium, responsive interface that feels alive.

### **Premium UI Framework**
- **Layout Managers**: Flexbox-inspired scaling for different monitor sizes (1x1 to 8x6).
- **Theming Engine**: Support for custom color palettes, Dark Mode, and "Glassmorphism" transparency.
- **Double-Buffered Animations**: Smooth transitions, sliding menus, and pulse effects for active buttons.
- **Icon Library**: A unified set of character-based icons for machine status and inventory types.

---

## 🤝 4. User Experience (UX)
Making complex automation accessible to everyone.

### **Interactive Setup Wizard**
- If an app is started without a config, it launches a **First-Run Wizard**.
- Interactive peripheral selection on the monitor (e.g., "Tap the chest you want to use for Input").
- Built-in diagnostic tools to test every machine connection before the app fully starts.

### **Remote Management**
- **Global Dashboard**: A central Hub system that can monitor and control multiple local automation systems (Powah, Create, etc.) via Rednet.
- **Mobile Recaller**: Advanced pocket computer tools for on-the-go status checks and remote crafting triggers.

---

## 📈 Roadmap (Phases)

| Phase | Focus | Key Deliverables |
|:---|:---|:---|
| **I** | Framework Foundation | `BaseApp`, `HAL`, and improved `ConfigStore`. |
| **II** | UI Transformation | Layout Engine, Themes, and Icon Library. |
| **III** | Hardening | Watchdog Service, Schema Validation, and Recovery. |
| **IV** | Ecosystem | Multi-App Hub and Remote Management tools. |

---

> [!NOTE]
> This plan is a living document. Implementation will follow the modular principles of the **Feature-Core Skeleton** architecture.
