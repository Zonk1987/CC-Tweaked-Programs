> [!WARNING]
> 🇫🇷 **fr / Francais**
> 
> Remarque : Ce README a été automatiquement traduit par un assistant IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour la documentation la plus précise et la plus à jour, veuillez vous référer à la version originale en anglais. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Créer une automatisation d'artisanat mécanique 🛠️

> Système ComputerCraft entièrement automatisé et prêt pour la production pour les **artisans mécaniques** du mod **Create**. Conçu pour une intégration transparente avec AE2 / Refined Storage en **Mode blocage**.


---

## ✨ Caractéristiques

- **Enregistrement de recettes en jeu** — Placez les objets dans les artisans, appuyez sur « S », saisissez un nom. Fait. Aucune édition JSON requise.
- **Gestion visuelle des recettes** — Appuyez sur « M » pour parcourir toutes les recettes enregistrées, afficher les ingrédients requis et gérer les modèles.
- **Calibrage interactif du réseau** — Détection automatique de la disposition exacte de votre réseau via l'activation séquentielle du modem.
- **Mode de blocage AE2 / RS prêt** — Optimisé pour l'intégration du coffre tampon avec un traitement garanti pour un seul métier.
- **Détection intelligente des bourrages** — Alertes en temps réel indiquant l'emplacement exact de l'artisan et l'objet à l'origine d'un goulot d'étranglement.
- **Tableau de bord en direct** : interface utilisateur hautes performances à code couleur affichant l'état de la grille, l'historique des tâches et les ingrédients manquants.

---

## 🛠️ Configuration matérielle

![Ingame Setup](../../assets/images/crafter-setup.png)


1. **Ordinateur avancé** — Requis pour le tableau de bord coloré haute résolution.
2. **Crafter Grid** — Construisez votre tableau (par exemple, 3×3, 5×5, 9×9).
3. **Mise en réseau (étape cruciale) :**
- Connectez un **Modem filaire** à **chaque** Mechanical Crafter.
- Connectez tous les modems à l'ordinateur avec des **câbles réseau**.
- Cliquez avec le bouton droit sur les modems jusqu'à ce que l'**anneau rouge** s'allume.
- **⚠️ IMPORTANT :** Vous DEVEZ activer les modems dans **ordre de lecture** (en haut à gauche – en haut à droite, puis ligne par ligne) pendant l'étalonnage.
4. **Buffer Chest** — Connectez un coffre (par exemple, Diamond Chest) adjacent à l'ordinateur via un modem filaire.
5. **Redstone Trigger** — Connectez un signal Redstone de **n'importe quel côté** de l'ordinateur aux Crafters.

---

## 🚀 Installation et utilisation

1. Téléchargez le fichier install.lua depuis le dépôt
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Exécutez le fichier install.lua
```bash
install.lua
```
3. Sélectionnez **Créer une automatisation de création mécanique**.
4. **Calibration** : Au premier démarrage, suivez les invites à l'écran pour cliquer avec le bouton droit sur les modems dans l'ordre. Cela mappe la grille physique au logiciel.
5. **Mode de blocage** : réglez votre fournisseur de modèles AE2 sur **"Mode de blocage"** face au coffre tampon.

---

## 📖 Comment utiliser

### Enregistrer une nouvelle recette
1. Placez les ingrédients manuellement dans les artisans mécaniques physiques.
2. Appuyez sur **`S`** sur le tableau de bord.
3. Tapez un nom et appuyez sur **ENTER**. Le système scanne la grille et l'enregistre instantanément !

### Gestion des recettes
1. Appuyez sur **`M`** sur le tableau de bord pour ouvrir le gestionnaire.
2. Parcourez les recettes, affichez les ingrédients et appuyez sur **`X`** pour supprimer les anciens modèles.

---

## ⌨️ Raccourcis clavier

| Clé | Action |
|:---:|---|
| **`S`** | **Scan/Enregistrer** nouvelle recette à partir de la grille *(Annulez en appuyant sur ENTER avec un nom vide)* |
| **`M`** | **Gérer** les recettes enregistrées et afficher les modèles |
| **`R`** | **Recharger** les recettes de `crafter_recipes.json` |
| **`Q`** | **Quitter** (Quittez le menu du gestionnaire de recettes et revenez au tableau de bord) |

---

## ⚙️Configuration

Le système dispose d'un menu de configuration graphique et interactif pour personnaliser facilement les paramètres :

- **Configurer les paramètres** : Vous pouvez exécuter l'interface utilisateur de configuration à tout moment en exécutant :
  ```bash
  startup.lua --config
  ```
  ou :
  ```bash
  startup.lua -c
  ```
  Cela vous permet de sélectionner le coffre tampon et de personnaliser la couleur du tableau de bord de manière dynamique.
- **Recalibrage** : Les mappages physiques des modems sont enregistrés dans `crafter_mapping.json`. Pour recalibrer la grille (par exemple, si vous avez modifié la disposition de vos Mechanical Crafters), supprimez simplement le fichier `crafter_mapping.json` et démarrez le programme normalement.

---

## 🛑 Dépannage

| Erreur | Cause et solution |
|---|---|
| « Coffre tampon manquant ! » | Le modem sur la poitrine est éteint ou déconnecté. |
| « Pas d'artisans mécaniques ! » | Aucun modem trouvé. Vérifiez les câbles et les anneaux rouges ! |
| `JAMMED : Emplacement #X` | La fabrication n’est pas terminée. Vérifiez le pouls et la puissance de la redstone. |
| « Incompatibilité de modèle » | Des éléments incorrects dans la grille ou dans le fichier de mappage sont corrompus. Recalibrez ! |

---
*Développé avec ❤️ pour Advanced Agentic Coding.*






