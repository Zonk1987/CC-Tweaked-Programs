> [!WARNING]
> 🇫🇷 **fr / Francais**
> 
> Remarque : Ce README a été automatiquement traduit par un assistant IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour la documentation la plus précise et la plus à jour, veuillez vous référer à la version originale en anglais. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Powah Energizing Orb Automation (CC: modifié)

> Système ComputerCraft entièrement automatisé et prêt pour la production pour les **Orbes énergisants** du mod **Powah**. Prend en charge le traitement parallèle, l'intégration avancée AE2 et la compatibilité intelligente des modpacks.


---

## ✨ Caractéristiques

- **Prise en charge multi-orbes** — Détecte automatiquement tous les orbes énergisants et objets artisanaux connectés en parallèle.
- **Intégration ME Bridge (obligatoire)** — Utilise « meBridge » d'Advanced Peripherals pour lire les données détaillées du modèle AE2 (entrées, sorties, quantités).
- **Accès direct au fournisseur (facultatif)** — Prise en charge complète du mod **`ae2communicate`**. Lorsqu'il est associé au ME Bridge, il vous permet de filtrer les recettes par **fournisseurs de modèles nommés**, éliminant ainsi le besoin de rechercher sur de grands réseaux.
- **Précision et intelligence** — Gestion automatique des multiplicateurs et validation exacte des ingrédients basée sur l'identification lors de l'importation.
- **Compatibilité Modpack** — Basculez entre « Powah uniquement » ou « Tous les mods » (touche « M ») pour prendre en charge les recettes de n'importe quel mod utilisant l'Orbe énergisant.
- **Récupération automatique** — Récupération automatisée des objets et réinitialisation des orbes en cas de blocage de fabrication ou de panne de courant.

---

## 🛠️ Configuration matérielle

![Ingame Setup](../../assets/images/orb-setup.png)


1. **Ordinateur avancé** — Requis pour le tableau de bord couleur haute résolution.
2. **Buffer Chest** — Connectez n'importe quel coffre (par exemple, Diamond Chest) adjacent à l'ordinateur ou via le réseau.
3. **Orbes énergisants** — Connectez tous les orbes via des **câbles réseau** et des **modems filaires**.
4. **ME Bridge (obligatoire) :** Connectez un **ME Bridge** au réseau pour permettre au système de lire les données de modèle détaillées.
5. **Fonctionnalité de qualité de vie en option (ae2communicate) :**
- Installez le module **`ae2communicate`**.
- Placez un **Modem filaire** directement sur une **Interface AE2** (reconnue comme un « ae2_scanner »).
- Nommez vos fournisseurs de modèles dans votre système AE2 (par exemple, « Powah Orb »).
- **Avantage :** Filtre les données ME Bridge pour afficher uniquement les modèles de ce fournisseur spécifique !

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
3. Sélectionnez **Powah Automation** dans le menu.
4. Le système détecte automatiquement vos périphériques au démarrage.
5. **Important** : définissez vos fournisseurs de modèles AE2 sur **"Mode de blocage"** et pointez-les vers le coffre tampon.

---

## 📖 Importation de recettes AE2

Le système dispose d'un menu d'importation intelligent (Touche **`I`**) :

### Scénario A : Avec le scanner AE2 en option
1. Appuyez sur **`I`**.
2. Sélectionnez le **Fournisseur de modèles nommés** à partir duquel vous souhaitez importer.
3. Parcourez les recettes filtrées et appuyez sur **`ENTER`** pour importer.

### Scénario B : Standard (ME Bridge uniquement)
1. Appuyez sur **`I`**.
2. Parcourez tous les modèles disponibles sur le réseau.
3. Utilisez **`M`** pour basculer entre **Powah Only** et **All Mods**.
4. Appuyez sur **`ENTER`** pour importer.

---

## ⌨️ Raccourcis clavier

| Clé | Action |
|:---:|---|
| **`R`** | **Recharger** les recettes sans redémarrer |
| **`Je`** | **Menu Importer** (Parcourir et ajouter des modèles AE2) |
| **`M`** | **Mod Toggle** (Dans le menu d'importation : Powah contre All. *Uniquement disponible si le mod 'ae2communicate' n'est PAS utilisé*) |
| **`B`** | **Retour** (Dans le menu d'importation : revenir à la sélection du fournisseur) |
| **`X`** | **Supprimer** (Supprimer une recette importée du système) |
| **`Q`** | **Quitter** (Quittez le menu Importer et revenez au tableau de bord) |

---

## ⚙️ Configuration

Le système dispose d'un menu de configuration graphique interactif pour personnaliser facilement les paramètres :

- **Configuration des paramètres** : Vous pouvez lancer l'interface de configuration à tout moment en exécutant :
  ```bash
  startup.lua --config
  ```
  ou :
  ```bash
  startup.lua -c
  ```
  Cela vous permet de sélectionner le coffre tampon, de spécifier le nom du pont ME (ME Bridge) et d'attribuer dynamiquement le périphérique optionnel de scanner AE (AE Scanner). Les paramètres sont enregistrés dans `config.json`.

---

## 🛑 Dépannage

| Erreur | Cause et solution |
|---|---|
| `Aucun pont ME trouvé !` | Vérifiez les câbles et l'état du modem. |
| « Scanner AE : Aucun » | Normal si vous n'avez pas le mod. Le mode classique sera utilisé. |
| `Délai d'attente dans Orb...` | La fabrication a pris plus de 60 ans. Objets retournés dans le coffre. Vérifiez la puissance ! |
| `Nom en double` | Vous essayez d'importer une recette qui existe déjà. |

---
*Développé avec ❤️ pour Advanced Agentic Coding.*




