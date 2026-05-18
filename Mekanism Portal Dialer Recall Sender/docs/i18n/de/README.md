> [!WARNING]
> 🇩🇪 **de / Deutsch**
> 
> Hinweis: Diese README-Datei wurde automatisch von einem KI-Assistenten (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Für die genaueste und aktuellste Dokumentation beziehen Sie sich bitte auf das englische Original [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Rückrufsender des Mekanism-Portals (CC:Tweaked)

> Ein dedizierter Fernauslöser für das **Mekanism Portal Network**. Ermöglicht Ihnen, Ihr Heimportal aus der Ferne anzurufen, indem Sie einfach ein Redstone-Signal (Knopf, Druckplatte usw.) an Ihrem Ziel bereitstellen.


---

## ✨ Funktionen

- **Hardware-Diagnose** – Scannt alle angeschlossenen Peripheriegeräte beim Start und gibt klares Feedback zur Anwesenheit von Modem und Teleporter.
- **Live-Portalstatus (optional)** – Echtzeitüberwachung des Status des lokalen Portals (z. B. „Bereit“, „Kein Strom“), wenn ein lokaler Teleporter-Block physisch angeschlossen ist (ansonsten ist die Standardeinstellung „Nur Remote-Hub“).
- **Heartbeat Auto-Refresh** – Aktualisiert den Status automatisch alle 2 Sekunden, um die Anzeige mit dem Hub synchronisiert zu halten.
- **Interaktive Einrichtung** – Keine Codebearbeitung erforderlich. Das Skript fragt beim ersten Durchlauf nach dem Zielort.
- **Konfigurationsmenü (Hotkeys)** – Drücken Sie „C“ am Computerterminal, um den Zielnamen oder Kanal zu ändern.
- **Dual-Path-Protokoll** – Sendet Befehle sowohl über die Standard-Modem-API als auch über Rednet für maximale Zuverlässigkeit.

---

## 🛠️ Hardware-Setup

1. **Taschencomputer oder kleiner Computer** – Platzieren Sie einen Computer an Ihrem entfernten Ziel (z. B. Mondbasis, Bergbau-Außenposten).
2. **Modem (kabellos oder kabelgebunden)** – Schließen Sie ein kabelloses Modem (ideal für abgelegene Standorte) oder ein kabelgebundenes Modem an den Computer an.
3. **Redstone-Trigger** – Schließen Sie einen Button, eine Druckplatte oder eine beliebige Redstone-Quelle an eine beliebige Seite des Computers an.
- Wenn das Redstone-Signal **EIN** wird, sendet der Computer den Rückrufbefehl an Ihre Hauptbasis.

---

## 🚀 Installation

1. Laden Sie die Datei install.lua aus dem Repo herunter
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Führen Sie die Datei install.lua aus
```bash
install.lua
```
Wählen Sie **Mekanism Portal Recaller** aus dem Menü.

---

## ⚙️ Nutzung

1. **Erster Start**: Der Computer fragt Sie nach einem **Zielnamen**. Geben Sie den *genauen Namen* der Frequenz ein, wie er in Ihrem Hauptportal-Hub angezeigt wird (z. B. „Hauptbasis“).
2. **Normaler Betrieb**: Auf dem Bildschirm wird „Warten auf Redstone-Signal…“ angezeigt.
3. **Auslöser**: Drücken Sie Ihre Taste. Der Hub an Ihrer Hauptbasis wechselt sofort zu Ihrem aktuellen Standort.
4. **Konfiguration**: Wenn Sie den Computer an eine neue Basis verschieben, drücken Sie „C“ auf der Tastatur, um das Menü zu öffnen und den Zielnamen zu ändern.

---

## 📝 Technische Details
Der Absender sendet eine JSON-Tabelle auf dem konfigurierten Kanal (Standard: 99):
```json
{
    "command": "RECALL",
    "target": "Your Destination Name"
}
```

---

## 📝 Credits
Entwickelt für die professionelle Minecraft-Automatisierung.




