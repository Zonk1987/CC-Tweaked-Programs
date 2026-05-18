> [!WARNING]
> 🇫🇷 **fr / Francais**
> 
> Remarque : Ce README a été automatiquement traduit par un assistant IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour la documentation la plus précise et la plus à jour, veuillez vous référer à la version originale en anglais. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Émetteur de rappel du portail Mekanism (CC: modifié)

> Un déclencheur à distance dédié pour le **Mekanism Portal Network**. Vous permet de composer votre portail domestique à distance en fournissant simplement un signal redstone (bouton, plaque de pression, etc.) à votre destination.


---

## ✨ Caractéristiques

- **Diagnostics matériels** — Analyse tous les périphériques connectés au démarrage et fournit des informations claires sur la présence du modem et du téléporteur.
- **État du portail en direct (facultatif)** — Surveillance en temps réel de l'état du portail local (par exemple, "Prêt", "Pas d'alimentation") si un bloc téléporteur local est physiquement connecté (sinon, la valeur par défaut est "Hub distant uniquement").
- **Heartbeat Auto-Refresh** — Met automatiquement à jour l'état toutes les 2 secondes pour maintenir l'affichage synchronisé avec le Hub.
- **Configuration interactive** — Aucune modification de code requise. Le script demande l'emplacement cible lors de la première exécution.
- **Menu de configuration (raccourcis clavier)** — Appuyez sur « C » sur le terminal de l'ordinateur pour modifier le nom ou la chaîne de destination.
- **Protocole Dual-Path** — Envoie des commandes via l'API du modem standard et Rednet pour une fiabilité maximale.

---

## 🛠️ Configuration matérielle

1. **Ordinateur de poche ou petit ordinateur** — Placez un ordinateur à votre destination distante (par exemple, base lunaire, avant-poste minier).
2. **Modem (sans fil ou filaire)** — Connectez un modem sans fil (idéal pour les emplacements distants) ou un modem filaire à l'ordinateur.
3. **Redstone Trigger** — Connectez un bouton, une plaque de pression ou toute autre source de Redstone à n'importe quel côté de l'ordinateur.
- Lorsque le signal Redstone s'allume **ON**, l'ordinateur envoie la commande de rappel à votre base principale.

---

## 🚀Installation

1. Téléchargez le fichier install.lua depuis le dépôt
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Exécutez le fichier install.lua
```bash
install.lua
```
Sélectionnez **Mekanism Portal Recaller** dans le menu.

---

## ⚙️ Utilisation

1. **Première exécution** : L'ordinateur vous demandera un **Nom de la cible**. Entrez le *nom exact* de la fréquence telle qu'elle apparaît dans votre portail principal (par exemple, « Base principale »).
2. **Fonctionnement normal** : L'écran affichera "En attente du signal Redstone...".
3. **Déclencheur** : appuyez sur votre bouton. Le Hub de votre base principale basculera instantanément vers votre emplacement actuel.
4. **Configuration** : Si vous déplacez l'ordinateur vers une nouvelle base, appuyez sur « C » sur le clavier pour ouvrir le menu et modifier le nom de la cible.

---

## ðŸ«¡ Détails techniques
L'expéditeur diffuse une table JSON sur le canal configuré (par défaut : 99) :
```json
{
    "command": "RECALL",
    "target": "Your Destination Name"
}
```

---

## ðŸ« Crédits
Développé pour l'automatisation professionnelle de Minecraft.


