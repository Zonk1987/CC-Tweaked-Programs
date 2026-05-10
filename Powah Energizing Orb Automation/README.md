# Powah Energizing Orb Automation (CC:Tweaked)

> Fully automated, production-ready ComputerCraft system for the **Energizing Orbs** from the **Powah** mod. Supports multiple orbs in parallel and seamless integration with AE2 / Refined Storage in **Blocking Mode**.

---

## ✨ Features

- **Multi-Orb Support** — Automatically discovers all connected Energizing Orbs and crafts in parallel across all of them.
- **AE2 / RS Blocking Mode Ready** — Point your Pattern Provider into the buffer chest. The system processes one recipe at a time, perfectly.
- **Strict Recipe Validation** — Validates all recipes on startup. Detects missing names, wrong item counts, and recipes exceeding the 6-item orb limit.
- **Auto-Recovery** — If an orb times out (60 seconds), the system automatically pulls items back to the buffer chest and resets.
- **Auto-Template Generation** — If `rezepte.json` does not exist, the system creates a ready-to-edit template automatically.
- **Live Dashboard** — Color-coded UI showing connected orb count, current status, active jobs per orb, and last crafted item.
- **Hot-Reload** — Press `R` to reload your recipe file without restarting the script.

---

## 🛠️ Hardware Setup

![Ingame Setup](images/setup.png)

1. **Computer** — Place an **Advanced Computer** (required for colored display).
2. **Buffer Chest**
   - Place a Chest or Barrel directly next to the Computer (e.g. on the **left** side).
   - The side must match the value set in `startup` (default: `"left"`).
3. **Energizing Orbs**
   - Attach a **Wired Modem** to each Energizing Orb.
   - Connect all modems to the Computer via **Networking Cables**.
   - Right-click every modem until the **red ring** lights up.
4. **AE2 / RS (Optional)**
   - Place an ME Pattern Provider or RS Crafter facing the Buffer Chest. Enable **Blocking Mode**.
   - Use an **Import Bus** (AE2) or **Importer** (RS) on the Energizing Orbs to extract finished items.

---

## 🚀 Installation

Run this single command on your ComputerCraft terminal:
```
pastebin run vYK0cPkU
```
Select **Powah Energizing Orb Automation** from the menu. The installer downloads all files and reboots automatically.

---

## ⚙️ Configuration

Open `startup` on the computer (`edit startup`) and scroll to the bottom. Change `"left"` to the correct side or peripheral name of your buffer chest:

```lua
local system = PowahSystem:new("left", "rezepte.json")
```

**Valid side values:** `"top"`, `"bottom"`, `"left"`, `"right"`, `"front"`, `"back"`

**Modem network name (if connected via cable):** Use `peripheral.getNames()` in the Lua prompt to find the exact name (e.g. `"extendedae:ingredient_buffer_0"`).

---

## 📖 How to Add Recipes

Edit `rezepte.json` on the computer (`edit rezepte.json`). Add one entry per recipe:

```json
[
    {
        "name": "Nitro Crystal",
        "ingredients": {
            "minecraft:nether_star": 1,
            "minecraft:redstone_block": 2,
            "powah:blazing_crystal_block": 1
        }
    }
]
```

- **`name`** — Display name shown on the dashboard.
- **`ingredients`** — Exact item registry names and their required amounts.

> ⚠️ The Energizing Orb holds a **maximum of 6 items** across all ingredients.

**To find the exact item name:** Use `lua peripheral.getItemDetail("left", 1)` in the Lua prompt. The `name` field in the output is the registry name.

After editing, press **`R`** in the dashboard to reload without restarting.

---

## ⌨️ Hotkeys

| Key | Action |
|---|---|
| `R` | Hot-reload `rezepte.json` without restarting |

---

## 🛑 Troubleshooting

| Error | Cause & Fix |
|---|---|
| `Chest missing!` | The buffer chest side is wrong or the chest was removed. Check the `"left"` value in `startup`. |
| `Transfer Error! Starting Recovery...` | Items could not be pushed into the orb. Check modem connections and that the orb is empty. |
| `Timeout in <orb>. Recovering...` | The orb did not finish within 60 seconds. Check if the orb has power. Items are returned to the chest automatically. |
| `Generated rezepte.json! Please edit.` | First-time setup. Edit `rezepte.json` with your real recipes, then press `R`. |
