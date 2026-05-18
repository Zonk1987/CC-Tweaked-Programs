> [!WARNING]
> 🇫🇷 **fr / Français**
> 
> ⚠️ **Remarque**: Ce fichier README a été traduit automatiquement par une IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour obtenir la documentation la plus précise et à jour, veuillez vous référer au [README.md](../../../README.md) original en anglais.

<div align="center">

# Suite d'Automatisation CC:Tweaked de Zonk 🚀

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

Une collection de scripts d'automatisation de qualité professionnelle pour Minecraft **CC:Tweaked**, caractérisée par une architecture modulaire **Feature-Core**, une esthétique d'interface premium et un installateur robuste piloté par un manifeste.

---

## 🚀 Installation

Exécutez cette commande sur un **Ordinateur Avancé** :

1. Téléchargez le fichier `install.lua` depuis le dépôt :
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Exécutez le fichier `install.lua` :
```bash
install.lua
```

---

## 📦 Paquets Disponibles

| ID | Nom | Description | Caractéristiques Clés |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | Sélecteur de portail tactile premium. | Interface déplaçable, bandes d'accentuation, réinitialisation de page. |
| `mekanism_recall_sender`| **Portal Recall Sender** | Déclencheur sans fil à distance. | Diagnostics matériels, surveillance de l'état en direct. |
| `create_crafter` | **Mechanical Crafter** | Automatisation de fabrication en grille. | Enregistrement et calibrage, recettes à étapes multiples. |
| `powah_orb` | **Energizing Orb** | Automatisation de fabrication en parallèle. | Intégration ME Bridge, récupération automatique. |
| `developer_suite` | **CC Developer Suite** | Boîte à outils de diagnostic. | Analyseur d'événements, inspecteur de périphériques. |

---

## 🏗️ Architecture: Feature-Core Skeleton

Ce dépôt est conçu pour la maintenabilité et la performance grâce à une architecture modulaire squelette.

### **Modules Core (`lib/core`)**
Les utilitaires génériques sont extraits dans des paquets core masqués pour réduire la duplication :
- **`core.base`** : Logique fondamentale comme `ConfigStore` (persistance JSON).
- **`core.peripherals`** : Découverte et enveloppement sécurisés des périphériques (`PeripheralScanner`).
- **`core.network`** : Protocoles de communication standardisés (`RednetProtocol`).
- **`core.redstone`** : Aides à l'interaction avec la redstone (`RedstoneController`).
- **`core.ui`** : Composants d'interface utilisateur réutilisables (`ButtonGrid`).
- **`core.inventory`** : Gestion standardisée des inventaires (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`** : Stockage de recettes basé sur JSON (`RecipeStore`).

### **Résolution des Dépendances**
L'installateur résout automatiquement les dépendances de manière récursive. Par exemple, l'installation de `create_crafter` téléchargera automatiquement les modules requis `core.inventory` et `core.redstone`. Les fichiers d'application sont placés dans le répertoire racine, tandis que les bibliothèques du noyau sont conservées dans la hiérarchie `lib/core/` (accessible via des chemins de paquets ajustés dans `startup.lua`).

---

## 🛠️ Directives de Développement

### **Ajouter une Nouvelle Application**
1. Créez le dossier de votre application (par exemple, `Ma Nouvelle App`).
2. Implémentez votre logique, en tirant parti des modules existants dans `lib/core`.
3. Enregistrez votre application dans `manifest.lua`.
4. Ajoutez des dépendances si vous utilisez des modules core.

### **Ajouter un Module Core**
1. Placez le module dans `lib/core/<catégorie>/ModuleName.lua`.
2. Enregistrez-le en tant que paquet masqué (`hidden = true`) dans `manifest.lua`.

---

## ⚖️ Sécurité & Règles

Tout le code de ce dépôt est régi par **[AGENTS.md](./AGENTS.md)**.
- **Mode Strict** : Les scripts d'application et les fichiers d'entrée utilisent un environnement strict pour éviter les variables globales accidentelles (les bibliothèques de base contournent actuellement cela pour réduire le code redondant de localisation).
- **Pas de Suppression** : L'installateur ne supprime jamais les fichiers utilisateur existants (sauf pour nettoyer ses propres fichiers temporaires comme `manifest.lua` et `install.lua` après achèvement, ou remplacer les anciennes versions lors d'une mise à jour).
- **Cache de l'État d'Installation** : L'installateur crée un fichier masqué `.install_state.json` pour mémoriser les versions des fichiers installés. Cela accélère les exécutions futures en sautant les fichiers inchangés (affichés comme `CACHED`). Il est sûr de supprimer ce fichier à tout moment — la prochaine installation téléchargera simplement tout à nouveau.
- **Pas de Redémarrage Automatique** : L'installateur demande la permission avant d'exécuter des fichiers d'entrée et ne redémarre jamais le système sans autorisation.
- **Politique d'Application Unique** : Une seule application est prise en charge par Ordinateur Avancé. L'installation de plusieurs applications sur le même ordinateur entraînera des collisions de fichiers et écrasera les fichiers critiques comme `startup.lua` ou `Dashboard.lua`.

---

## 📝 Crédits & Dépannage

Développé par **Antigravity** dans le cadre de l'initiative Advanced Agentic Coding.
Si vous rencontrez des problèmes :
1. Assurez-vous d'utiliser un **Ordinateur Avancé**.
2. Exécutez `install.lua --validate` pour vérifier les erreurs de manifeste.
3. Consultez le `README.md` dans le dossier de chaque application pour la configuration matérielle spécifique.

**[LICENSE](./LICENSE)** : MIT
