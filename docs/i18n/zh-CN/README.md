> [!WARNING]
> 🇨🇳 **zh-CN / Chinese (Simplified)**
> 
> 注意：本自述文件由人工智能助手（反重力）自动翻译，可能包含翻译错误或不准确之处。如需最准确和最新的文档，请参阅英文原文 [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div对齐=“中心”>

# Zonk 的 CC：调整的自动化套件 🚀

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

Minecraft **CC:Tweaked** 的专业级自动化脚本集合，具有模块化 **功能核心** 架构、高级 UI 美观性和强大的清单驱动安装程序。


---

## 🚀 安装

在 **高级计算机** 上运行此命令：

1.从repo下载install.lua文件
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2.运行install.lua文件
```bash
install.lua
```

---

## 📦 可用套餐

| ID | 姓名 | 描述 | 主要特点 |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | [**门户拨号器中心**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/zh-CN/README.md) | 高级触摸屏拨号器。 | 可移动的用户界面、强调条纹、页面重置。 |
| `mekanism_recall_sender` | [**门户召回发件人**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/zh-CN/README.md) | 远程无线触发。 | 硬件诊断、实时状态监控。 |
| `创建工匠` | [**机械工匠**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/zh-CN/README.md) | 网格制作自动化。 | 记录和校准，多步骤食谱。 |
| `powah_orb` | [**能量球**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/zh-CN/README.md) | 并行制作自动化。 | ME Bridge 集成，自动恢复。 |
| `开发者套件` | [**CC 开发套件**](../../../CC%20Developer%20Suite/docs/i18n/zh-CN/README.md) | 诊断工具包。 | 事件嗅探器，外设检查器。 |

---

## 🏗️架构：功能核心骨架

该存储库是使用模块化框架构建的，旨在提高可维护性和性能。

### **核心模块（`lib/core`）**
通用实用程序被提取到隐藏的核心包中以减少重复：
- **`core.base`**：像`ConfigStore`（JSON持久化）这样的基本逻辑。
- **`core.peripherals`**：安全外设发现和包装（`PeripheralScanner`）。
- **`core.network`**：标准化通信协议（`RednetProtocol`）。
- **`core.redstone`**：红石交互助手（`RedstoneController`）。
- **`core.ui`**：可重用的 UI 组件（`ButtonGrid`）。
- **`core.inventory`**：标准化库存处理（`InventoryAdapter`、`ItemMatcher`）。
- **`core.recipes`**：JSON 支持的配方存储 (`RecipeStore`)。

### **依赖解析**
安装程序会自动递归地解析依赖关系。例如，安装“create_crafter”将自动提取所需的“core.inventory”和“core.redstone”模块。应用程序文件放置在根目录中，而核心库则维护在“lib/core/”层次结构中（可通过“startup.lua”中调整后的包路径访问）。

---

## 🛠️开发指南

### **添加新应用程序**
1. 创建您的应用程序文件夹（例如“我的新应用程序”）。
2. 利用现有的“lib/core”模块实现您的逻辑。
3. 在`manifest.lua`中注册您的应用程序。
4. 如果使用核心模块，请添加依赖项。

### **添加核心模块**
1. 将模块放置在 `lib/core/<category>/ModuleName.lua` 中。
2. 在`manifest.lua`中将其注册为`hidden = true`包。

---

## ⚖️ 安全与规则

此存储库中的所有代码均受 **[AGENTS.md](../../../AGENTS.md)** 管理。
- **严格模式**：应用程序脚本和入口文件使用严格的环境来防止意外的全局变量（核心库当前绕过此以减少本地化样板文件）。
- **不删除**：安装程序永远不会删除现有的用户文件（除了在完成后清理自己的临时文件，如“manifest.lua”和“install.lua”，或在更新过程中替换旧版本）。
- **安装状态缓存**：安装程序会创建一个隐藏文件“.install_state.json”来记住已安装的文件版本。这可以通过跳过未更改的文件（显示为“CACHED”）来加快将来的运行速度。随时删除该文件是安全的 - 下次安装将简单地重新下载所有内容。
- **无自动重新启动**：安装程序在运行入口文件之前进行询问，并且在未经许可的情况下绝不会重新启动系统。
- **单一应用程序策略**：每台高级计算机仅支持**一个**应用程序。在同一台计算机上安装多个应用程序将导致文件冲突并覆盖关键文件，例如“startup.lua”或“Dashboard.lua”。

---

## 📝 制作人员及疑难解答
由 **Antigravity** 开发，作为高级代理编码计划的一部分。
如果您遇到问题：
1. 确保您使用的是**高级计算机**。
2. 运行“install.lua --validate”来检查清单错误。
3. 检查每个应用程序文件夹中的“README.md”以了解特定于硬件的设置。

**[许可证](../../../LICENSE)**：麻省理工学院


