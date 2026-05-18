> [!WARNING]
> 🇩🇪 **de / Deutsch**
> 
> Hinweis: Diese README-Datei wurde automatisch von einem KI-Assistenten (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Für die genaueste und aktuellste Dokumentation beziehen Sie sich bitte auf das englische Original [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Powah Energizing Orb Automation (CC:Tweaked)

> Vollautomatisches, produktionsreifes ComputerCraft-System für die **Energizing Orbs** aus der **Powah**-Mod. Unterstützt Parallelverarbeitung, erweiterte AE2-Integration und intelligente Modpack-Kompatibilität.


---

## âœ¨ Funktionen

- **Multi-Orb-Unterstützung** – Erkennt automatisch alle angeschlossenen Energizing Orbs und Handwerke parallel.
- **ME Bridge-Integration (erforderlich)** – Verwendet „meBridge“ von Advanced Peripherals, um detaillierte AE2-Musterdaten (Eingänge, Ausgänge, Mengen) zu lesen.
- **Direkter Anbieterzugriff (optional)** – Volle Unterstützung für den Mod **`ae2communicate**. In Verbindung mit der ME Bridge ermöglicht es Ihnen, Rezepte nach **Named Pattern Providers** zu filtern, sodass Sie nicht mehr in großen Netzwerken suchen müssen.
- **Präzision und Intelligenz** – Automatische Handhabung von Multiplikatoren und exakte ID-basierte Zutatenvalidierung während des Imports.
- **Modpack-Kompatibilität** – Wechseln Sie zwischen „Nur Powah“ oder „Alle Mods“ (Taste „M“), um Rezepte von jedem Mod zu unterstützen, der die Energizing Orb verwendet.
- **Automatische Wiederherstellung** – Automatisiertes Abrufen von Gegenständen und Zurücksetzen der Kugeln im Falle von Herstellungsstörungen oder Stromausfällen.

---

## ðŸ› ï¸ Hardware-Setup

![Ingame Setup](../../assets/images/orb-setup.png)


1. **Advanced Computer** – Erforderlich für das hochauflösende farbige Dashboard.
2. **Puffertruhe** – Verbinden Sie eine beliebige Truhe (z. B. Diamond Chest) neben dem Computer oder über das Netzwerk.
3. **Energie spendende Orbs** – Verbinden Sie alle Orbs über **Netzwerkkabel** und **kabelgebundene Modems**.
4. **ME Bridge (erforderlich):** Schließen Sie eine **ME Bridge** an das Netzwerk an, damit das System detaillierte Musterdaten lesen kann.
5. **Optionale Lebensqualitätsfunktion (ae2communicate):**
- Installieren Sie den Mod **`ae2communicate**.
- Platzieren Sie ein **kabelgebundenes Modem** direkt an einer **AE2-Schnittstelle** (erkannt als „ae2_scanner“).
- Benennen Sie Ihre Musteranbieter in Ihrem AE2-System (z. B. „Powah Orb“).
- **Vorteil:** Filtert die ME Bridge-Daten, um nur Muster dieses bestimmten Anbieters anzuzeigen!

---

## ðŸš€ Installation und Nutzung

1. Laden Sie die Datei install.lua aus dem Repo herunter
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Führen Sie die Datei install.lua aus
```bash
install.lua
```
3. Wählen Sie **Powah Automation** aus dem Menü.
4. Das System erkennt Ihre Peripheriegeräte beim Start automatisch.
5. **Wichtig**: Stellen Sie Ihre AE2-Musteranbieter auf den **„Blockierungsmodus“** und richten Sie sie auf die Puffertruhe.

---

## ðŸ“– AE2-Rezeptimport

Das System verfügt über ein intelligentes Importmenü (Taste **`I`**):

### Szenario A: Mit optionalem AE2-Scanner
1. Drücken Sie **`I`**.
2. Wählen Sie den **Benannten Musteranbieter** aus, von dem Sie importieren möchten.
3. Durchsuchen Sie die gefilterten Rezepte und drücken Sie zum Importieren die Eingabetaste.

### Szenario B: Standard (nur ME Bridge)
1. Drücken Sie **`I`**.
2. Durchsuchen Sie alle verfügbaren Muster im Netzwerk.
3. Verwenden Sie **`M`**, um zwischen **Nur Powah** und **Alle Mods** umzuschalten.
4. Drücken Sie zum Importieren die Eingabetaste.

---

## âŒ¨ï¸ Hotkeys

| Schlüssel | Aktion |
|:---:|---|
| **`R`** | Rezepte **neu laden**, ohne neu zu starten |
| **`Ich`** | **Importmenü** (AE2-Muster durchsuchen und hinzufügen) |
| **`M`** | **Mod Toggle** (Im Importmenü: Powah vs. All. *Nur verfügbar, wenn der Mod „ae2communicate“ NICHT verwendet wird*) |
| **`B`** | **Zurück** (Im Importmenü: Zurück zur Anbieterauswahl) |
| **`X`** | **Löschen** (Ein importiertes Rezept aus dem System entfernen) |
| **`Q`** | **Beenden** (Verlassen Sie das Importmenü und kehren Sie zum Dashboard zurück) |

---

## âš™ï¸ Konfiguration

Das System ist so konzipiert, dass es sofort einsatzbereit ist. Wenn Sie manuelle Anpassungen benötigen, überprüfen Sie „startup.lua“:
```lua
local system = PowahSystem.new({
    chestName = "left", -- Or use auto-detection variable
    recipeFile = "powah_recipes.json",
    meBridgeName = "right", -- Required for imports: ME Bridge peripheral name
    aeScannerName = "top" -- Optional: ae2communicate scanner peripheral name
})
```

---

## ðŸ›‘ Fehlerbehebung

| Fehler | Ursache und Behebung |
|---|---|
| „Keine ME Bridge gefunden!“. | Überprüfen Sie den Kabel- und Modemstatus. |
| „AE-Scanner: Keine“. | Normal, wenn Sie den Mod nicht haben. Es wird der klassische Modus verwendet. |
| `Timeout in Orb...` | Die Herstellung dauerte >60s. Gegenstände werden in die Truhe zurückgelegt. Überprüfen Sie die Stromversorgung! |
| „Doppelter Name“. | Sie versuchen, ein bereits vorhandenes Rezept zu importieren. |

---
*Entwickelt mit â¤ï¸ für Advanced Agentic Coding.*

