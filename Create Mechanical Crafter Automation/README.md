# Create Mechanical Crafter Automation (CC:Tweaked)

> Fully automated, production-ready ComputerCraft system for the **Mechanical Crafters** from the **Create** mod. Designed for seamless integration with AE2 / Refined Storage in **Blocking Mode**.

---

## ✨ Features

- **In-Game Recipe Recording** — Place items in crafters, press `S`, type a name. Done. No JSON editing required.
- **Visual Recipe Management** — Press `M` to browse all saved recipes, view required ingredients, and delete obsolete patterns.
- **Interactive Grid Calibration** — Click your Wired Modems in order and the system learns your exact grid layout automatically.
- **AE2 / RS Blocking Mode Ready** — Point your Pattern Provider into the buffer chest. The system handles one recipe at a time, perfectly.
- **Smart Jam Detection** — If a craft gets stuck, the dashboard alerts you with the exact crafter slot and item that is blocked.
- **Fuzzy Item Matching** — Use `~planks` in your recipe to accept any type of planks (or any other item family).
- **Dynamic Redstone Trigger** — Pulses all sides of the computer after item placement to guarantee the crafting starts.
- **Live Dashboard** — Color-coded UI showing crafter count, current status, last job, and missing items for incomplete recipes.

---

## 🛠️ Hardware Setup

![Ingame Setup](images/setup.png)

1. **Computer** — Place an **Advanced Computer** (required for colored display).
2. **Crafter Grid** — Build your Mechanical Crafter array (e.g. 3×3, 5×5, 9×9).
3. **Networking**
   - Attach a **Wired Modem** to **every single** Mechanical Crafter.
   - Connect all modems to the Computer with **Networking Cables**.
   - Right-click every modem until the **red ring** lights up. **⚠️ IMPORTANT:** You MUST activate the modems in **reading order** (top-left → top-right, then row by row) so the system understands your grid layout.
4. **Buffer Chest / Barrel**
   - Place a Chest or Barrel **adjacent** to the Computer.
   - Attach a **Wired Modem** to it and connect it to the same cable network.
   - ⚠️ Do **not** connect it as a bare side-inventory without a modem.
5. **Redstone Trigger** — Connect Redstone Dust or a Create Redstone Link from **any side** of the Computer to at least one Mechanical Crafter.
6. **AE2 / RS (Optional)** — Place an ME Pattern Provider or RS Crafter facing the Buffer Chest. Enable **Blocking Mode**.

---

## 🚀 Installation

Run this single command on your ComputerCraft terminal:
```
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/Universal%20Installer/install.lua
install
```
Select **Create Mechanical Crafter Automation** from the menu.

---

## ⚙️ First Start & Calibration

On the **very first start**, the dashboard will prompt you to calibrate your grid:

1. Walk to your Mechanical Crafter array.
2. Right-click the Wired Modems **in reading order**: top-left → top-right, row by row, ending at the bottom-right.
3. Return to the computer and press **Enter**.

Calibration is saved permanently in `crafter_mapping.json`. Delete this file to recalibrate.

---

## 📖 How to Use

### Recording a New Recipe
1. Ensure the dashboard shows `Waiting for items...`
2. Manually place your ingredients into the physical Mechanical Crafters.
3. Press **`S`** on the computer terminal.
4. Type a name for the recipe and press **Enter**.
5. The system scans, saves, and reloads the recipe automatically.
> *Press Enter without a name to cancel.*

### Managing Recipes
1. Press **`M`** on the dashboard.
2. Browse through the list of saved recipes (Left Pane).
3. See the required items and counts for the selected recipe (Right Pane).
4. Press **`X`** to delete a selected recipe or **`Q`** to return.

### Fuzzy Matching
Edit `crafter_recipes.json` and prefix an item name with `~` to match any item containing that string:
```json
"keys": { "A": "~planks" }
```

---

## ⌨️ Hotkeys

| Key | Action |
|---|---|
| `S` | Start in-game recipe recording |
| `M` | Open Recipe Management UI |
| `R` | Hot-reload recipes from `crafter_recipes.json` |

---

## 🛑 Troubleshooting

| Error | Cause & Fix |
|---|---|
| `No buffer inventory found!` | The chest has no modem, or the modem is turned off. |
| `Transfer Error! Crafter is missing!` | A crafter was replaced. Delete `crafter_mapping.json` and recalibrate. |
| `JAMMED: Crafter #X has ...` | Crafting did not finish. Check redstone connection. Remove items manually to reset. |
