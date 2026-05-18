> [!WARNING]
> 🇫🇷 **fr / Francais**
> 
> Remarque : Ce README a été automatiquement traduit par un assistant IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour la documentation la plus précise et la plus à jour, veuillez vous référer à la version originale en anglais. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div align="centre">

# CC de Zonk : suite d'automatisation optimisée 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality%20Checks)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

Une collection de scripts d'automatisation de qualité professionnelle pour Minecraft **CC:Tweaked**, comprenant une architecture modulaire **Feature-Core**, une esthétique d'interface utilisateur haut de gamme et un programme d'installation robuste piloté par manifeste.


---

## 🚀Installation

Exécutez cette commande sur un **ordinateur avancé** :

1. Téléchargez le fichier install.lua depuis le dépôt
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Exécutez le fichier install.lua
```bash
install.lua
```

---

## 📦 Forfaits disponibles

| IDENTIFIANT | Nom | Description | Principales fonctionnalités |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | [**Portal Dialer Hub**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/fr/README.md) | Numéroteur à écran tactile haut de gamme. | Interface utilisateur mobile, bandes d'accentuation, réinitialisation de page. |
| `mekanism_recall_sender` | [**Expéditeur de rappel de portail**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/fr/README.md) | Déclencheur sans fil à distance. | Diagnostics matériels, surveillance de l'état en direct. |
| `create_crafter` | [**Artisan mécanique**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/fr/README.md) | Automatisation de la création de grilles. | Enregistrement et calibrage, recettes en plusieurs étapes. |
| `powah_orb` | [**Orbe énergisant**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/fr/README.md) | Automatisation de la fabrication parallèle. | Intégration ME Bridge, récupération automatique. |
| `developer_suite` | [**Suite de développement CC**](../../../CC%20Developer%20Suite/docs/i18n/fr/README.md) | Boîte à outils de diagnostic. | Renifleur d'événements, inspecteur de périphériques. |

---

## 🏗️ Architecture : squelette de base des fonctionnalités

Ce référentiel est construit pour la maintenabilité et les performances à l'aide d'un squelette modulaire.

### **Modules de base (`lib/core`)**
Les utilitaires génériques sont extraits dans des packages principaux cachés pour réduire la duplication :
- **`core.base`** : Logique fondamentale comme `ConfigStore` (persistance JSON).
- **`core.peripherals`** : découverte et emballage sécurisés de périphériques (`PeripheralScanner`).
- **`core.network`** : Protocoles de communication standardisés (`RednetProtocol`).
- **`core.redstone`** : assistants d'interaction Redstone (`RedstoneController`).
- **`core.ui`** : composants d'interface utilisateur réutilisables (`ButtonGrid`).
- **`core.inventory`** : gestion standardisée des stocks (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`** : stockage de recettes basé sur JSON (`RecipeStore`).

### **Résolution des dépendances**
Le programme d'installation résout automatiquement les dépendances de manière récursive. Par exemple, l'installation de « create_crafter » extraira automatiquement les modules « core.inventory » et « core.redstone » requis. Les fichiers d'application sont placés dans le répertoire racine, tandis que les bibliothèques principales sont conservées dans la hiérarchie `lib/core/` (accessible via les chemins de paquets ajustés dans `startup.lua`).

---

## 🛠️ Lignes directrices de développement

### **Ajout d'une nouvelle application**
1. Créez votre dossier d'application (par exemple, « Ma nouvelle application »).
2. Implémentez votre logique, en tirant parti des modules `lib/core` existants.
3. Enregistrez votre application dans « manifest.lua ».
4. Ajoutez des dépendances si vous utilisez des modules de base.

### **Ajout d'un module principal**
1. Placez le module dans `lib/core/<category>/ModuleName.lua`.
2. Enregistrez-le en tant que package `hidden = true` dans `manifest.lua`.

---

## ⚖️ Sécurité et règles

Tout le code de ce référentiel est régi par **[AGENTS.md](../../../AGENTS.md)**.
- **Mode strict** : les scripts d'application et les fichiers d'entrée utilisent un environnement strict pour empêcher les globaux accidentels (les bibliothèques principales contournent actuellement cela pour réduire le passe-partout de localisation).
- **Aucune suppression** : le programme d'installation ne supprime jamais les fichiers utilisateur existants (sauf pour nettoyer ses propres fichiers temporaires comme `manifest.lua` et `install.lua` une fois terminé, ou pour remplacer les anciennes versions lors d'une mise à jour).
- **Install State Cache** : le programme d'installation crée un fichier caché « .install_state.json » pour mémoriser les versions de fichiers qui ont été installées. Cela accélère les exécutions futures en ignorant les fichiers qui n'ont pas changé (affichés comme « CACHED »). Vous pouvez supprimer ce fichier en toute sécurité à tout moment : la prochaine installation téléchargera simplement tout à nouveau.
- **Pas de redémarrage automatique** : le programme d'installation demande avant d'exécuter les fichiers d'entrée et ne redémarre jamais le système sans autorisation.
- **Politique d'application unique** : une seule **une** application est prise en charge par ordinateur avancé. L'installation de plusieurs applications sur le même ordinateur entraînera des collisions de fichiers et écrasera des fichiers critiques tels que « startup.lua » ou « Dashboard.lua ».

---

## 📝 Crédits et dépannage
Développé par **Antigravity** dans le cadre de l'initiative Advanced Agentic Coding.
Si vous rencontrez des problèmes :
1. Assurez-vous que vous utilisez un **ordinateur avancé**.
2. Exécutez `install.lua --validate` pour vérifier les erreurs manifestes.
3. Vérifiez le « README.md » dans le dossier de chaque application pour la configuration spécifique au matériel.

**[LICENCE](../../../LICENSE)** : MIT





