# Create Mechanical Crafter Automation 🛠️

> Fully automated, production-ready ComputerCraft system for the **Mechanical Crafters** from the **Create** mod. Designed for seamless integration with AE2 / Refined Storage in **Blocking Mode**.

---

## ✨ Features

- **In-Game Recipe Recording** — Place items in crafters, press `S`, type a name. Done. No JSON editing required.
- **Visual Recipe Management** — Press `M` to browse all saved recipes, view required ingredients, and manage patterns.
- **Interactive Grid Calibration** — Automatic detection of your exact grid layout via sequential modem activation.
- **AE2 / RS Blocking Mode Ready** — Optimized for buffer chest integration with guaranteed single-craft processing.
- **Smart Jam Detection** — Real-time alerts showing the exact crafter slot and item causing a bottleneck.
- **Live Dashboard** — Color-coded high-performance UI showing grid status, job history, and missing ingredients.

---

## 🛠️ Hardware Setup

![Ingame Setup](images/setup.png)

1. **Advanced Computer** — Required for the colored high-resolution dashboard.
2. **Crafter Grid** — Build your array (e.g., 3×3, 5×5, 9×9).
3. **Networking (Crucial Step):**
   - Attach a **Wired Modem** to **every single** Mechanical Crafter.
   - Connect all modems to the Computer with **Networking Cables**.
   - Right-click modems until the **red ring** lights up.
   - **⚠️ IMPORTANT:** You MUST activate the modems in **reading order** (top-left → top-right, then row by row) during calibration.
4. **Buffer Chest** — Connect a chest (e.g., Diamond Chest) adjacent to the Computer via a Wired Modem.
5. **Redstone Trigger** — Connect a Redstone signal from **any side** of the Computer to the Crafters.

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
3. Select **Create Mechanical Crafter Automation**.
4. **Calibration**: On the first start, follow the on-screen prompts to right-click modems in order. This maps the physical grid to the software.
5. **Blocking Mode**: Set your AE2 Pattern Provider to **"Blocking Mode"** facing the Buffer Chest.

---

## 📖 How to Use

### Recording a New Recipe
1. Place ingredients manually into the physical Mechanical Crafters.
2. Press **`S`** on the dashboard.
3. Type a name and press **ENTER**. The system scans the grid and saves it instantly!

### Managing Recipes
1. Press **`M`** on the dashboard to open the Manager.
2. Browse recipes, view ingredients, and press **`X`** to delete old patterns.

---

## ⌨️ Hotkeys

| Key | Action |
|:---:|---|
| **`S`** | **Scan/Record** new recipe from the grid *(Cancel by pressing ENTER with empty name)* |
| **`M`** | **Manage** saved recipes and view patterns |
| **`R`** | **Reload** recipes from `crafter_recipes.json` |
| **`Q`** | **Quit** (Exit the Recipe Manager menu and return to the Dashboard) |

---

## ⚙️ Configuration

The system is designed to work out-of-the-box. Calibration data is stored in `crafter_mapping.json`. Delete this file to trigger a new calibration.

---

## 🛑 Troubleshooting

| Error | Cause & Fix |
|---|---|
| `Buffer chest missing!` | Modem on the chest is off or disconnected. |
| `No Mechanical Crafters!` | No modems found. Check cables and red rings! |
| `JAMMED: Slot #X` | Crafting did not finish. Check redstone pulse and power. |
| `Pattern Mismatch` | Wrong items in grid or mapping file is corrupt. Recalibrate! |

---
*Developed with ❤️ for Advanced Agentic Coding.*
