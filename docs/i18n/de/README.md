> [!WARNING]
> 🇩🇪 **de / Deutsch**
> 
> ⚠️ **Hinweis**: Diese README wurde automatisch von einer KI (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Die genaueste und aktuellste Dokumentation findest du in der englischen Original-[README.md](../../../README.md).

<div align="center">

# Zonks CC:Tweaked Automations-Suite 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

Eine Sammlung von professionellen Automatisierungsskripten für Minecraft **CC:Tweaked**, basierend auf einer modularen **Feature-Core**-Architektur, Premium-UI-Ästhetik und einem robusten manifestgesteuerten Installer.

---

## 🚀 Installation

Führe diesen Befehl auf einem **Erweiterten Computer (Advanced Computer)** aus:

1. Lade die Datei `install.lua` aus dem Repository herunter:
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Führe die Datei `install.lua` aus:
```bash
install.lua
```

---

## 📦 Verfügbare Pakete

| ID | Name | Beschreibung | Hauptmerkmale |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | Premium Touchscreen-Portalwähler. | Bewegliche UI, Akzentstreifen, Seiten-Reset. |
| `mekanism_recall_sender`| **Portal Recall Sender** | Drahtloser Fernauslöser. | Hardware-Diagnose, Live-Statusüberwachung. |
| `create_crafter` | **Mechanical Crafter** | Gitter-Crafting-Automatisierung. | Aufnahme & Kalibrierung, mehrstufige Rezepte. |
| `powah_orb` | **Energizing Orb** | Parallele Crafting-Automatisierung. | Integration der ME-Brücke, automatische Wiederherstellung. |
| `developer_suite` | **CC Developer Suite** | Diagnose-Toolkit. | Event-Sniffer, Peripherie-Inspektor. |

---

## 🏗️ Architektur: Feature-Core Skeleton

Dieses Repository ist für einfache Wartbarkeit und hohe Performance modular aufgebaut.

### **Core-Module (`lib/core`)**
Generische Hilfsfunktionen sind in versteckte Core-Pakete ausgelagert, um Redundanz zu vermeiden:
- **`core.base`**: Grundlegende Logik wie `ConfigStore` (JSON-Persistenz).
- **`core.peripherals`**: Sichere Peripheriesuche und -bindung (`PeripheralScanner`).
- **`core.network`**: Standardisierte Kommunikationsprotokolle (`RednetProtocol`).
- **`core.redstone`**: Hilfsfunktionen für Redstone-Interaktionen (`RedstoneController`).
- **`core.ui`**: Wiederverwendbare UI-Komponenten (`ButtonGrid`).
- **`core.inventory`**: Standardisierte Inventarverwaltung (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: JSON-basierter Rezeptspeicher (`RecipeStore`).

### **Abhängigkeitsauflösung**
Der Installer löst Abhängigkeiten automatisch rekursiv auf. Wenn du beispielsweise `create_crafter` installierst, werden die benötigten Module `core.inventory` und `core.redstone` automatisch mit heruntergeladen. Anwendungsdateien werden im Hauptverzeichnis platziert, während Core-Bibliotheken in der Hierarchie `lib/core/` verwaltet werden (erreichbar über angepasste Paketpfade in der `startup.lua`).

---

## 🛠️ Entwicklungsrichtlinien

### **Eine neue App hinzufügen**
1. Erstelle einen App-Ordner (z. B. `Meine Neue App`).
2. Implementiere deine Logik und nutze dabei vorhandene `lib/core`-Module.
3. Registriere deine App in `manifest.lua`.
4. Füge Abhängigkeiten hinzu, falls du Core-Module verwendest.

### **Ein Core-Modul hinzufügen**
1. Platziere das Modul unter `lib/core/<kategorie>/ModuleName.lua`.
2. Registriere es als verstecktes Paket (`hidden = true`) in `manifest.lua`.

---

## ⚖️ Sicherheit & Regeln

Der gesamte Code in diesem Repository unterliegt den Richtlinien in **[AGENTS.md](./AGENTS.md)**.
- **Strict-Modus**: Anwendungsskripte und Startdateien verwenden eine strikte Umgebung, um versehentliche globale Variablen zu verhindern (Core-Bibliotheken umgehen dies derzeit, um Lokalisierungs-Code zu reduzieren).
- **Keine Löschung**: Der Installer löscht niemals bestehende Benutzerdateien (außer beim Aufräumen eigener temporärer Dateien wie `manifest.lua` und `install.lua` nach Abschluss oder beim Ersetzen älterer Versionen bei einem Update).
- **Installationsstatus-Cache**: Der Installer erstellt eine versteckte Datei `.install_state.json`, um installierte Dateiversionen zu speichern. Dies beschleunigt zukünftige Durchläufe, indem unveränderte Dateien übersprungen werden (angezeigt als `CACHED`). Es ist absolut sicher, diese Datei jederzeit zu löschen — beim nächsten Durchlauf wird einfach alles neu heruntergeladen.
- **Kein automatischer Neustart**: Der Installer fragt vor dem Ausführen von Startdateien um Erlaubnis und startet das System niemals ungefragt neu.
- **Ein-App-Richtlinie**: Pro erweitertem Computer wird nur **eine** Anwendung unterstützt. Die Installation mehrerer Apps auf demselben Computer führt zu Dateikonflikten und überschreibt wichtige Dateien wie `startup.lua` oder `Dashboard.lua`.

---

## 📝 Credits & Fehlerbehebung

Entwickelt von **Antigravity** im Rahmen der Advanced Agentic Coding Initiative. 
Bei Problemen:
1. Stelle sicher, dass du einen **Advanced Computer** verwendest.
2. Führe `install.lua --validate` aus, um den Manifest-Status zu prüfen.
3. Sieh dir die `README.md` im jeweiligen App-Ordner für hardwarespezifische Setups an.

**[LICENSE](./LICENSE)**: MIT
