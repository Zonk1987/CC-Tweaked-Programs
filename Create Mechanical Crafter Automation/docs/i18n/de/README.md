> [!WARNING]
> 🇩🇪 **de / Deutsch**
> 
> Hinweis: Diese README-Datei wurde automatisch von einem KI-Assistenten (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Für die genaueste und aktuellste Dokumentation beziehen Sie sich bitte auf das englische Original [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Erstellen Sie eine mechanische Crafter-Automatisierung 🛠️

> Vollautomatisches, produktionsbereites ComputerCraft-System für die **Mechanical Crafters** aus der **Create**-Mod. Entwickelt für die nahtlose Integration mit AE2 / Refined Storage im **Blockierungsmodus**.


---

## ✨ Funktionen

- **Rezeptaufzeichnung im Spiel** – Platziere Gegenstände in Handwerkern, drücke „S“ und gib einen Namen ein. Erledigt. Keine JSON-Bearbeitung erforderlich.
- **Visuelle Rezeptverwaltung** – Drücken Sie „M“, um alle gespeicherten Rezepte zu durchsuchen, erforderliche Zutaten anzuzeigen und Muster zu verwalten.
- **Interaktive Netzkalibrierung** – Automatische Erkennung Ihres genauen Netzlayouts durch sequentielle Modemaktivierung.
- **Bereit für den AE2-/RS-Blockierungsmodus** – Optimiert für die Integration von Puffertruhen mit garantierter Einzelfertigungsverarbeitung.
- **Intelligente Stauerkennung** – Echtzeitwarnungen, die den genauen Handwerkerplatz und den Artikel anzeigen, der einen Engpass verursacht.
- **Live-Dashboard** – Farbcodierte Hochleistungs-Benutzeroberfläche, die den Rasterstatus, den Auftragsverlauf und fehlende Zutaten anzeigt.

---

## 🛠️ Hardware-Setup

![Ingame Setup](../../assets/images/crafter-setup.png)


1. **Advanced Computer** – Erforderlich für das farbige hochauflösende Dashboard.
2. **Crafter Grid** – Erstellen Sie Ihr Array (z. B. 3×3, 5×5, 9×9).
3. **Networking (entscheidender Schritt):**
- Schließen Sie ein **kabelgebundenes Modem** an **jeden einzelnen** Mechanical Crafter an.
- Verbinden Sie alle Modems mit **Netzwerkkabeln** mit dem Computer.
- Klicken Sie mit der rechten Maustaste auf Modems, bis der **rote Ring** aufleuchtet.
- **⚠️ WICHTIG:** Sie MÜSSEN die Modems während der Kalibrierung in **Lesereihenfolge** (oben links → oben rechts, dann Zeile für Zeile) aktivieren.
4. **Puffertruhe** – Verbinden Sie eine Truhe (z. B. Diamond Chest) neben dem Computer über ein kabelgebundenes Modem.
5. **Redstone-Trigger** – Verbinden Sie ein Redstone-Signal von **einer beliebigen Seite** des Computers mit den Crafters.

---

## 🚀 Installation und Nutzung

1. Laden Sie die Datei install.lua aus dem Repo herunter
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Führen Sie die Datei install.lua aus
```bash
install.lua
```
3. Wählen Sie **Mechanical Crafter-Automatisierung erstellen**.
4. **Kalibrierung**: Befolgen Sie beim ersten Start die Anweisungen auf dem Bildschirm, um mit der rechten Maustaste auf die Modems zu klicken. Dadurch wird das physische Raster der Software zugeordnet.
5. **Blockierungsmodus**: Stellen Sie Ihren AE2-Musteranbieter auf den **„Blockierungsmodus“** mit Blick auf die Puffertruhe ein.

---

## 📖 Verwendung

### Aufzeichnen eines neuen Rezepts
1. Geben Sie die Zutaten manuell in die physischen mechanischen Handwerker.
2. Drücken Sie **`S`** auf dem Dashboard.
3. Geben Sie einen Namen ein und drücken Sie **ENTER**. Das System scannt das Raster und speichert es sofort!

### Rezepte verwalten
1. Drücken Sie **`M`** auf dem Dashboard, um den Manager zu öffnen.
2. Durchsuchen Sie Rezepte, sehen Sie sich Zutaten an und drücken Sie **`X`**, um alte Muster zu löschen.

---

## ⌨️ Hotkeys

| Schlüssel | Aktion |
|:---:|---|
| **`S`** | **Scannen/Aufzeichnen** neues Rezept aus dem Raster *(Abbrechen durch Drücken der EINGABETASTE mit leerem Namen)* |
| **`M`** | **Verwalten** gespeicherte Rezepte und Muster anzeigen |
| **`R`** | **Rezepte neu laden** aus „crafter_recipes.json“. |
| **`Q`** | **Beenden** (Verlassen Sie das Rezept-Manager-Menü und kehren Sie zum Dashboard zurück) |

---

## ⚙️ Konfiguration

Das System ist so konzipiert, dass es sofort einsatzbereit ist. Kalibrierungsdaten werden in „crafter_mapping.json“ gespeichert. Löschen Sie diese Datei, um eine neue Kalibrierung auszulösen.

---

## 🛑 Fehlerbehebung

| Fehler | Ursache und Behebung |
|---|---|
| „Puffertruhe fehlt!“. | Das Modem auf der Brust ist ausgeschaltet oder nicht angeschlossen. |
| „Keine mechanischen Handwerker!“. | Keine Modems gefunden. Kabel und rote Ringe prüfen! |
| „VERSTAUT: Steckplatz #X“. | Die Herstellung wurde nicht abgeschlossen. Überprüfen Sie den Redstone-Puls und die Leistung. |
| „Musterkonflikt“. | Falsche Elemente im Raster oder in der Zuordnungsdatei sind beschädigt. Neu kalibrieren! |

---
*Entwickelt mit ❤️ für Advanced Agentic Coding.*






