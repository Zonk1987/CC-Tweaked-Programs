> [!WARNING]
> 🇩🇪 **de / Deutsch**
> 
> Hinweis: Diese README-Datei wurde automatisch von einem KI-Assistenten (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Für die genaueste und aktuellste Dokumentation beziehen Sie sich bitte auf das englische Original [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div align="center">

# Zonks CC:Tweaked Automation Suite 🚀

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

Eine Sammlung professioneller Automatisierungsskripte für Minecraft **CC:Tweaked** mit einer modularen **Feature-Core**-Architektur, erstklassiger UI-Ästhetik und einem robusten manifestgesteuerten Installationsprogramm.


---

## 🚀 Installation

Führen Sie diesen Befehl auf einem **erweiterten Computer** aus:

1. Laden Sie die Datei install.lua aus dem Repo herunter
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Führen Sie die Datei install.lua aus
```bash
install.lua
```

---

## 📦 Verfügbare Pakete

| AUSWEIS | Name | Beschreibung | Hauptmerkmale |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | [**Portal Dialer Hub**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/de/README.md) | Premium-Touchscreen-Wählgerät. | Bewegliche Benutzeroberfläche, Akzentstreifen, Seitenzurücksetzung. |
| `mekanism_recall_sender` | [**Portal Recall Sender**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/de/README.md) | Drahtloser Fernauslöser. | Hardware-Diagnose, Live-Statusüberwachung. |
| `create_crafter` | [**Mechanical Crafter**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/de/README.md) | Automatisierung des Grid-Craftings. | Aufzeichnung und Kalibrierung, mehrstufige Rezepte. |
| `powah_orb` | [**Energizing Orb**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/de/README.md) | Parallele Herstellungsautomatisierung. | ME Bridge-Integration, automatische Wiederherstellung. |
| „developer_suite“. | [**CC Developer Suite**](../../../CC%20Developer%20Suite/docs/i18n/de/README.md) | Diagnose-Toolkit. | Ereignisschnüffler, Peripherieinspektor. |

---

## 🏗️ Architektur: Feature-Core-Skelett

Dieses Repository ist auf Wartbarkeit und Leistung ausgelegt und basiert auf einem modularen Grundgerüst.

### **Kernmodule (`lib/core`)**
Generische Dienstprogramme werden in versteckte Kernpakete extrahiert, um Duplikate zu reduzieren:
- **`core.base`**: Grundlegende Logik wie `ConfigStore` (JSON-Persistenz).
- **`core.peripherals`**: Sichere Erkennung und Verpackung von Peripheriegeräten („PeripheralScanner“).
- **`core.network`**: Standardisierte Kommunikationsprotokolle (`RednetProtocol`).
- **`core.redstone`**: Redstone-Interaktionshelfer („RedstoneController“).
- **`core.ui`**: Wiederverwendbare UI-Komponenten („ButtonGrid“).
- **`core.inventory`**: Standardisierte Inventarverwaltung („InventoryAdapter“, „ItemMatcher“).
- **`core.recipes`**: JSON-gestützter Rezeptspeicher („RecipeStore“).

### **Abhängigkeitsauflösung**
Das Installationsprogramm löst Abhängigkeiten automatisch rekursiv auf. Wenn Sie beispielsweise „create_crafter“ installieren, werden automatisch die erforderlichen Module „core.inventory“ und „core.redstone“ abgerufen. Anwendungsdateien werden im Stammverzeichnis abgelegt, während Kernbibliotheken in der „lib/core/“-Hierarchie verwaltet werden (zugänglich über angepasste Paketpfade in der „startup.lua“).

---

## 🛠️ Entwicklungsrichtlinien

### **Hinzufügen einer neuen App**
1. Erstellen Sie Ihren App-Ordner (z. B. „Meine neue App“).
2. Implementieren Sie Ihre Logik und nutzen Sie dabei vorhandene „lib/core“-Module.
3. Registrieren Sie Ihre App in „manifest.lua“.
4. Fügen Sie Abhängigkeiten hinzu, wenn Sie Kernmodule verwenden.

### **Hinzufügen eines Kernmoduls**
1. Platzieren Sie das Modul in „lib/core/<category>/ModuleName.lua“.
2. Registrieren Sie es als „hidden = true“-Paket in „manifest.lua“.

---

## ⚖️ Sicherheit und Regeln

Der gesamte Code in diesem Repository unterliegt **[AGENTS.md](../../../AGENTS.md)**.
- **Strenger Modus**: Anwendungsskripte und Eintragsdateien verwenden eine strikte Umgebung, um versehentliche Globals zu verhindern (Kernbibliotheken umgehen dies derzeit, um den Lokalisierungs-Boilerplate zu reduzieren).
- **Keine Löschung**: Das Installationsprogramm löscht niemals vorhandene Benutzerdateien (außer zum Bereinigen seiner eigenen temporären Dateien wie „manifest.lua“ und „install.lua“ nach Abschluss oder zum Ersetzen älterer Versionen während eines Updates).
- **Install State Cache**: Das Installationsprogramm erstellt eine versteckte Datei „.install_state.json“, um sich zu merken, welche Dateiversionen installiert wurden. Dies beschleunigt zukünftige Ausführungen, indem Dateien übersprungen werden, die sich nicht geändert haben (angezeigt als „CACHED“). Sie können diese Datei jederzeit löschen – bei der nächsten Installation wird einfach alles erneut heruntergeladen.
- **Kein automatischer Neustart**: Das Installationsprogramm fragt vor dem Ausführen der Eintragsdateien nach und startet das System niemals ohne Erlaubnis neu.
- **Einzel-App-Richtlinie**: Pro erweitertem Computer wird nur **eine** Anwendung unterstützt. Die Installation mehrerer Apps auf demselben Computer führt zu Dateikollisionen und überschreibt wichtige Dateien wie „startup.lua“ oder „Dashboard.lua“.

---

## 📝 Credits und Fehlerbehebung
Entwickelt von **Antigravity** im Rahmen der Advanced Agentic Coding-Initiative.
Wenn Sie auf Probleme stoßen:
1. Stellen Sie sicher, dass Sie einen **Advanced Computer** verwenden.
2. Führen Sie „install.lua --validate“ aus, um nach Manifestfehlern zu suchen.
3. Überprüfen Sie die Datei „README.md“ im Ordner jeder Anwendung auf hardwarespezifische Einstellungen.

**[LIZENZ](../../../LICENSE)**: MIT


