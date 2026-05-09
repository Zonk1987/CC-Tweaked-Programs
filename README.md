# CC-Tweaked Automations

Welcome to my collection of advanced ComputerCraft / CC:Tweaked automation scripts for various Minecraft mods! 

These scripts are designed to be highly reliable, visually appealing (with in-game dashboards), and **100% plug-and-play compatible** with AE2 (Applied Energistics 2) and RS (Refined Storage) using Pattern Providers in **Blocking Mode**.

---

## 📂 Projects in this Repository

### 1. [Create Mechanical Crafter Automation](./CreateCrafter/)
A fully automated, highly intelligent system for automating the Mechanical Crafters from the **Create** mod. 
* **Dynamic Recipe Recording**: Build a recipe by hand, press a hotkey on the terminal, and the system automatically learns and saves it! No manual JSON editing required.
* **Interactive Calibration**: The system learns your exact grid shape (e.g. 5x5, 9x9) via a simple interactive setup.
* **Smart Jam Detection**: If a craft gets stuck, the system throws an alarm on the dashboard telling you exactly which crafter is jammed with what item.
* **AE2/RS Ready**: Drop items into the buffer chest, and the system handles the rest seamlessly.
* **Fuzzy Matching**: Supports flexible recipes (e.g., accepting any type of wooden planks).

[👉 View the Create Crafter Setup Guide](./CreateCrafter/README.md)

---

### 2. Powah Energizing Orb Automation
A sleek, fail-safe automation script for the Energizing Orb from the **Powah** mod.
* **Perfect Blocking Mode**: Ensures that recipes are crafted flawlessly without items mixing up, perfectly suited for AE2/RS Pattern Providers.
* **Live Dashboard**: Provides a beautiful, real-time UI showing the current crafting status, the items currently in the orb, and exactly what is missing.
* **Robust Error Handling**: Automatically recovers from missing items or unexpected states without crashing your automation line.

*(Navigate to the Powah folder in this repository for specific setup instructions).*

---

## 🛠️ General Requirements

To use any of these scripts, you will need:
- **Minecraft** with the **CC:Tweaked** mod installed.
- **Advanced Computers** (the golden ones) for colored dashboards.
- **Wired Modems** and **Networking Cables** to connect your inventories and machines.
- **AE2** or **RS** (Optional but highly recommended) for pushing items into the buffer chests via Blocking Mode.

## 🚀 How to Download

If you want to download a specific project to your ComputerCraft computer, the easiest way is to use the `wget` command in-game, or copy the `.lua` files directly into your server/world's `computercraft/computer/<id>` folder.

---
*Feel free to use, modify, and improve these scripts for your own modded worlds!*
