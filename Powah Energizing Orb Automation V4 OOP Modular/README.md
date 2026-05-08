# Powah Energizing Orb Automation (V5 Modular Edition)

## Description
This script fully automates the crafting process for Powah's Energizing Orbs using Applied Energistics 2 (AE2) or Refined Storage. It supports multiple orbs (auto-scaling), auto-recovery on failures, and strict recipe validation.

This edition features a completely modular architecture, strict mode scoping, localized global lookups, and EmmyLua type annotations.

## Installation
Run the following command in your ComputerCraft terminal to automatically download and install all required files:
```bash
wget run https://raw.githubusercontent.com/Zonk1987/CC-Tweaked/refs/heads/main/Powah%20Energizing%20Orb%20Automation%20V4%20OOP%20Modular/install.lua
```

## Hardware Setup

![Ingame Setup](images/setup.png)

1. Place an Advanced Computer.
2. Connect an ME Pattern Provider (or similar) to a Chest/Buffer.
3. Place the Chest directly next to the Computer (e.g., on the left side).
4. Connect one or multiple Powah Energizing Orbs to the Computer using Networking Cables and Wired Modems.
5. *(Optional but recommended)* Set the Pattern Provider to "Blocking Mode".
6. Use an Import Bus on the Energizing Orbs to extract the finished items.

## Configuration
Scroll to the very bottom of the `startup` file to configure the chest/buffer.
Change `"left"` in `PowahSystem:new("left", "rezepte.json")` to the correct side (`"right"`, `"top"`, `"bottom"`, `"front"`, `"back"`) or the network name (e.g., `"extendedae:ingredient_buffer_0"`) if connected via modem.

## How to Add Recipes
If the `rezepte.json` file does not exist when the script starts, it will **automatically generate** a template file with placeholder items and wait for you. You can then edit the file and press <kbd>R</kbd> to load your changes without restarting!

Here is an example of a correctly configured recipe:

```json
[
    {
        "name": "Nitro Crystal",
        "ingredients": {
            "minecraft:redstone_block": 2,
            "powah:blazing_crystal_block": 1,
            "minecraft:nether_star": 1
        }
    }
]
```

- **name**: The display name on the dashboard.
- **ingredients**: The exact registry names of the items and their amounts.

> **Note**: The Energizing Orb can hold a maximum of 6 items!

## Hotkeys
- Press <kbd>R</kbd> while the script is running to hot-reload recipes from JSON.
