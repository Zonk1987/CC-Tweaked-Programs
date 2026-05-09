# Create Mechanical Crafter Automation (CC:Tweaked)

A fully automated, highly intelligent, and user-friendly ComputerCraft system for automating Create's Mechanical Crafters. This script is designed to be **100% plug-and-play compatible** with AE2 (Applied Energistics 2) or RS (Refined Storage) Pattern Providers in **Blocking Mode**.

## ✨ Features

- **AE2 / RS Blocking Mode Ready**: Simply point your Pattern Provider into the buffer chest. The script pulls the items, distributes them perfectly into the crafters, triggers the craft, and waits for completion before accepting new items.
- **In-Game Recipe Recording**: Never write JSON by hand! Place your items into the physical crafters, press `S` on the dashboard, type a name, and the system dynamically generates, pads, and saves the recipe JSON for you.
- **Interactive Auto-Calibration**: No manual config files. The system will ask you to physically click your Wired Modems in order (left-to-right, top-to-bottom) to automatically learn your exact grid layout.
- **Smart Jam Detection**: If a craft gets stuck (e.g., missing items, wrong shape) and doesn't finish within 30 seconds, the dashboard triggers an alarm telling you exactly *which* Crafter slot is jammed with *what* item.
- **Fuzzy Item Matching**: Need a recipe that accepts any wood? Use the `~` prefix in your `crafter_recipes.json` (e.g., `~planks` or `~log`) to allow the system to use any matching item from the chest!
- **Dynamic Redstone Trigger**: Emits a redstone pulse on all sides of the computer as soon as the items are placed, forcing small recipes to start immediately in a large grid.
- **Beautiful Dashboard**: A real-time, colorful UI that shows connected crafters, current status, active jobs, and intelligently calculates and displays missing items for incomplete recipes in the chest.

---

## 🛠️ Hardware Setup

![Ingame Setup](images/setup.png)

1. **The Computer**: Place an Advanced Computer.
2. **The Crafter Grid**: Build your Create Mechanical Crafter grid (e.g., 3x3, 5x5, 9x9).
3. **The Networking**: 
   - Attach a **Wired Modem** to *every single* Mechanical Crafter.
   - Connect all of them to the Computer using **Networking Cable**.
4. **The Buffer Chest**: 
   - Place a Chest or Barrel nearby. 
   - **Crucial:** Do *not* place it directly touching the Computer without a modem. 
   - Attach a **Wired Modem** to the chest and connect it to the same Networking Cable network.
5. **Turn Modems ON**: Right-click every single Wired Modem so the red ring lights up.
6. **The Redstone Trigger**: Place Redstone Dust (or a Create Redstone Link) from *any side* of the Computer to at least one of the Mechanical Crafters. The computer uses this to tell the crafters to start.

---

## 🚀 Installation & First Start

1. Download all `.lua` files into a folder on your Advanced Computer.
2. Run `startup.lua`.
3. **Calibration**: If this is your first time, the dashboard will tell you the system is uncalibrated. 
   - Walk over to your Mechanical Crafter grid.
   - Right-click the modems in reading order: **Top-Left to Top-Right**, row by row, until you reach the Bottom-Right.
   - Go back to the Computer and press `ENTER`. The system is now calibrated forever!

---

## 📖 How to Use

### 1. Recording a New Recipe
You don't need to write any code to add recipes!
1. Make sure the dashboard says `Waiting for items...`
2. Manually place your ingredients into the physical Mechanical Crafters exactly how the recipe should look.
3. Open the Computer terminal and press **`S`**.
4. Type a name for your recipe (e.g., `Crushing Wheel`) and press `ENTER`.
5. The system will scan your grid, generate the recipe, save it, and immediately reload.
6. *To cancel recording, just press ENTER without typing a name.*

### 2. Auto-Crafting (Manual or AE2/RS)
- **Manual**: Just dump the required ingredients into the Buffer Chest. The system will automatically detect the recipe, move the items into the crafters, and pulse the redstone to start.
- **Automated**: Place an AE2 ME Pattern Provider (or RS Crafter) facing the Buffer Chest. Enable **Blocking Mode**. The system will naturally handle one recipe at a time flawlessly.

### 3. Fuzzy Matching (Optional Advanced Feature)
If you want a recipe to accept *any* type of a specific item (like any wooden planks):
1. Record your recipe normally using oak planks.
2. Open `crafter_recipes.json` (`edit crafter_recipes.json`).
3. Find your recipe's `keys` section.
4. Change `"minecraft:oak_planks"` to `"~planks"`.
5. Save and close. The system will now accept any item that has "planks" in its name!

---

## 🛑 Troubleshooting

- **`No buffer inventory found!`**: Your chest is either not connected to the modem network, the modem is turned off, or you placed the chest directly against the computer and the script is ignoring it. Use a modem!
- **`Transfer Error! Crafter is missing!`**: You probably broke and replaced a Mechanical Crafter block. It now has a new internal ID. Delete `crafter_mapping.json` (`rm crafter_mapping.json`) and restart `startup.lua` to recalibrate the grid.
- **`JAMMED: Crafter #5 has ...`**: The system placed items but the crafting never finished. Check if your Redstone Trigger is properly connecting the Computer to the Crafters, or if you accidentally put a wrong item in. Remove the items manually to reset the system.
