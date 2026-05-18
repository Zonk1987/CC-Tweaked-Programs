> [!WARNING]
> 🇩🇪 **de / Deutsch**
> 
> Hinweis: Diese README-Datei wurde automatisch von einem KI-Assistenten (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Für die genaueste und aktuellste Dokumentation beziehen Sie sich bitte auf das englische Original [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Mekanismus-Portalnetzwerk (CC:Tweaked)

> Eine professionelle, leistungsstarke Touch-Schnittstelle für **Mekanism Teleporter**. Verfügt über eine flimmerfreie, doppelt gepufferte Benutzeroberfläche, mehrseitiges Frequenzmanagement und einen integrierten Frequenzeditor mit Farbanpassung.


---

## ✨ Funktionen

- **Doppelt gepuffertes Rendering** – Aktualisierungen der Benutzeroberfläche ohne Flimmern mithilfe eines benutzerdefinierten fensterbasierten Puffersystems.
- **Bewegliche Overlay-Fenster** – Ziehen Sie das Farbauswahlmenü für optimale Sichtbarkeit an eine beliebige Stelle auf dem Bildschirm.
- **Akzentstreifen-Anzeigen** – Kontrastreiche vertikale Balken auf den Schaltflächen zeigen zugewiesene Farben mit schwarzen Schattenrändern für Sichtbarkeit auf jedem Hintergrund an.
- **Dynamisches Portalraster** – Erkennt automatisch alle Frequenzen mit intelligenter Paginierung und automatischem **Seiten-Reset** bei Listenänderungen.
- **Echtzeit-Statusüberwachung** – Live-Feedback zu Portalstatus, Zielfrequenz und Besitzer (mit Mojang-UUID-Auflösung).
- **Bearbeitungsmodus und Farbanpassung** – Weisen Sie Frequenzen bestimmte Farben zu oder verwenden Sie den zufälligen Farbzyklus.
- **Remote-Recall-Unterstützung** – Integrierte Modem- und Rednet-API für die Remote-Portalaktivierung (über Recaller-Skript).

---

## 🛠️ Hardware-Setup

![Ingame Setup](../../assets/images/hub-setup.png)


1. **Fortgeschrittener Computer** – Erforderlich für hochauflösende Grafiken und Doppelpufferung.
2. **Erweiterter Monitor**
- Empfohlene Größe: **4x3 Blöcke** für das beste Tastenlayout.
- Stellen Sie eine Verbindung über **kabelgebundene Modems** und Netzwerkkabel her.
3. **Mekanismus-Teleporter**
- Verbinden Sie den Teleporter über ein **kabelgebundenes Modem** mit demselben Kabelnetzwerk.
- Klicken Sie mit der rechten Maustaste auf das Modem, um es **EIN** zu schalten (roter Ring).
4. **Modem (optional)**
- Schließen Sie ein drahtloses oder kabelgebundenes Modem an den Computer an, um die **Remote Recall**-Funktionalität zu aktivieren.

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
Wählen Sie **Mekanism Portal Dialer Hub** aus dem Menü. Das Installationsprogramm lädt automatisch die App-Dateien („HubSystem“, „UUIDService“, „Dashboard“) herunter und löst alle Kernabhängigkeiten auf (z. B. „ButtonGrid“, „PeripheralScanner“).

---

## ⚙️ Konfiguration

Öffnen Sie „Startup“ auf dem Computer, um das Systemverhalten anzupassen:

- „gridColumns“ / „gridRows“: Passen Sie die Anzahl der Schaltflächen pro Seite an.
- „recallChannel“: Legen Sie den Modemkanal für Remote-Portal-Anfragen fest (Standard: 99).

---

## ⌨️ Steuerung und Modi

### **Wählmodus (Standard)**
- **Tippen Sie auf ein Portal** – Wechseln Sie sofort die Teleporterfrequenz. Die Schaltfläche bleibt hervorgehoben, bis die Hardware die Änderung bestätigt.
- **Weiter/Zurück** – Wechseln Sie zwischen den Seiten, wenn Sie viele Frequenzen haben.

### **Bearbeitungsmodus (Einstellungssymbol)**
1. Tippen Sie auf das **Â¤**-Symbol in der oberen rechten Ecke, um in den Bearbeitungsmodus zu gelangen.
2. Wählen Sie ein beliebiges Portal aus, um das **Farb-Overlay** zu öffnen.
3. Wählen Sie eine **feste Farbe** für dieses bestimmte Portal oder wählen Sie **RANDOM** für dynamischen Farbwechsel.
4. Verwenden Sie die **VERSCHIEBEN**-Leiste oben im Overlay, um das Fenster zu verschieben, wenn es Ihre Sicht blockiert.

---

## 📝 Remote-Recall-API

Das System wartet auf Modemnachrichten auf dem konfigurierten „recallChannel“. Um ein Portal aus der Ferne auszulösen, senden Sie eine Tabelle mit der folgenden Struktur:
```lua
{
    command = "RECALL",
    target = "My Base" -- Name of the frequency
}
```
Alternativ können Sie das spezielle **Mekanism Portal Recaller**-Skript auf einem Handheld-Taschencomputer verwenden.

---

## 📝 Credits
Entwickelt im Rahmen der **Advanced Agentic Coding**-Initiative für die professionelle Minecraft-Automatisierung.




