> [!WARNING]
> 🇫🇷 **fr / Francais**
> 
> Remarque : Ce README a été automatiquement traduit par un assistant IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour la documentation la plus précise et la plus à jour, veuillez vous référer à la version originale en anglais. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Réseau de portails Mekanism (CC: modifié)

> Une interface tactile professionnelle et performante pour les **téléporteurs Mekanism**. Comprend une interface utilisateur à double tampon sans scintillement, une gestion des fréquences multipages et un éditeur de fréquence intégré avec personnalisation des couleurs.


---

## ✨ Caractéristiques

- **Rendu à double tampon** — Mises à jour de l'interface utilisateur sans scintillement à l'aide d'un système de tampon personnalisé basé sur une fenêtre.
- **Fenêtres de superposition mobiles** — Faites glisser le menu de sélection des couleurs n'importe où sur l'écran pour une visibilité optimale.
- **Indicateurs de rayures d'accentuation** — Les barres verticales à contraste élevé sur les boutons affichent les couleurs attribuées avec des bordures ombrées noires pour une visibilité sur n'importe quel arrière-plan.
- **Grille de portail dynamique** – Découvre automatiquement toutes les fréquences avec une pagination intelligente et une **Réinitialisation de page** automatique lors des modifications de liste.
- **Surveillance de l'état en temps réel** — Commentaires en direct sur l'état du portail, la fréquence cible et le propriétaire (avec résolution Mojang UUID).
- **Mode d'édition et personnalisation des couleurs** — Attribuez des couleurs spécifiques à des fréquences ou utilisez le cycle de couleurs aléatoire.
- **Prise en charge du rappel à distance** — Modem intégré et API Rednet pour l'activation du portail à distance (via le script Recaller).

---

## 🛠️ Configuration matérielle

![Ingame Setup](../../assets/images/hub-setup.png)


1. **Ordinateur avancé** — Requis pour les graphiques haute résolution et le double tampon.
2. **Moniteur avancé**
- Taille recommandée : **blocs 4x3** pour la meilleure disposition des boutons.
- Connectez-vous via des **modems filaires** et des câbles réseau.
3. **Téléporteur Mécanisme**
- Connectez le téléporteur au même réseau câblé à l'aide d'un **modem filaire**.
- Cliquez avec le bouton droit sur le modem pour l'allumer **ON** (anneau rouge).
4. **Modem (facultatif)**
- Connectez un modem sans fil ou filaire à l'ordinateur pour activer la fonctionnalité **Rappel à distance**.

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
Sélectionnez **Mekanism Portal Dialer Hub** dans le menu. Le programme d'installation téléchargera automatiquement les fichiers de l'application (`HubSystem`, `UUIDService`, `Dashboard`) et résoudra toutes les dépendances principales (par exemple, `ButtonGrid`, `PeripheralScanner`).

---

## ⚙️ Configuration

Le système dispose d'un menu de configuration graphique interactif pour personnaliser facilement les paramètres des périphériques :

- **Configuration des paramètres** : Vous pouvez lancer l'interface de configuration à tout moment en exécutant :
  ```bash
  startup.lua --config
  ```
  ou :
  ```bash
  startup.lua -c
  ```
  Cela vous permet de sélectionner dynamiquement le moniteur et le téléporteur. Les paramètres sont enregistrés dans `config.json`.
- **Options avancées** : Pour personnaliser les dimensions de la grille ou le canal de rappel, vous pouvez modifier directement le fichier `config.json` généré :
  - `"gridColumns"` / `"gridRows"` : Ajuste la disposition des boutons (par défaut : 4x4).
  - `"recallChannel"` : Définit le canal du modem pour les demandes de rappel à distance (par défaut : 99).

---

## ⌨️ Commandes et modes

### **Mode de numérotation (par défaut)**
- **Appuyez sur un portail** — Changez instantanément la fréquence du téléporteur. Le bouton restera en surbrillance jusqu'à ce que le matériel confirme le changement.
- **Suivant/Précédent** — Basculez entre les pages si vous avez plusieurs fréquences.

### **Mode édition (icône Paramètres)**
1. Appuyez sur l'icône **¤** dans le coin supérieur droit pour accéder au mode édition.
2. Sélectionnez n'importe quel portail pour ouvrir la **Superposition de couleurs**.
3. Choisissez une **Couleur fixe** pour ce portail spécifique ou sélectionnez **ALÉATOIRE** pour un cycle de couleurs dynamique.
4. Utilisez la barre **MOVE** en haut de la superposition pour déplacer la fenêtre si elle bloque votre vue.

---

## 📝 API de rappel à distance

Le système écoute les messages du modem sur le « recallChannel » configuré. Pour déclencher un portail à distance, envoyez une table avec la structure suivante :
```lua
{
    command = "RECALL",
    target = "My Base" -- Name of the frequency
}
```
Vous pouvez également utiliser le script dédié **Mekanism Portal Recaller** sur un ordinateur de poche.

---

## 📝 Crédits
Développé dans le cadre de l'initiative **Advanced Agentic Coding** pour l'automatisation professionnelle de Minecraft.




