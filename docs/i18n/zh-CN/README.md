> [!WARNING]
> 🇨🇳 **zh-CN / 简体中文**
> 
> ⚠️ **注意**：本 README 由 AI 助手 (Antigravity) 自动翻译，可能包含翻译错误或不准确之处。如需最准确和最新的文档，请参阅英文原版 [README.md](../../../README.md)。

<div align="center">

# Zonk 的 CC:Tweaked 自动化套件 🚀

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

一套适用于我的世界 **CC:Tweaked** 模组的专业级自动化脚本合集，采用模块化的 **Feature-Core** 架构、高颜值的高级 UI 界面以及健壮的清单驱动安装器。

---

## 🚀 安装方法

在 **高级电脑 (Advanced Computer)** 上运行以下命令：

1. 从仓库下载 `install.lua` 文件：
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. 运行 `install.lua` 文件：
```bash
install.lua
```

---

## 📦 可用软件包

| ID | 名称 | 描述 | 核心特性 |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **传送门拨号中心** | 触屏式高级传送门拨号器。 | 可移动的 UI、侧边指示条、自动重置页面。 |
| `mekanism_recall_sender`| **传送门召回发送器** | 远程无线触发器。 | 硬件故障诊断、实时状态监测。 |
| `create_crafter` | **机械动力自动合成** | 网格自动合成系统。 | 游戏内配方录制与校准、支持多步合成。 |
| `powah_orb` | **充能石自动充能** | 并行化自动合成系统。 | AE2 ME Bridge 集成、断电/堵塞自动恢复。 |
| `developer_suite` | **CC 开发者套件** | 系统调试与诊断工具。 | 事件监视器、外设接口审查器。 |

---

## 🏗️ 架构设计：Feature-Core Skeleton 模块化骨架

本仓库使用模块化骨架构建，以实现极高的可维护性和运行性能。

### **核心模块 (`lib/core`)**
通用工具类已提取到隐藏的核心包中，以减少重复代码：
- **`core.base`**：基础逻辑，例如 `ConfigStore`（JSON 持久化数据存储）。
- **`core.peripherals`**：安全的外设搜索与封装（`PeripheralScanner`）。
- **`core.network`**：标准化的无线红网通信协议（`RednetProtocol`）。
- **`core.redstone`**：红石交互辅助类（`RedstoneController`）。
- **`core.ui`**：可重用的界面组件（`ButtonGrid` 按钮网格）。
- **`core.inventory`**：标准化的容器与物品交互层（`InventoryAdapter`、`ItemMatcher`）。
- **`core.recipes`**：基于 JSON 的配方管理器（`RecipeStore`）。

### **依赖自动解析**
安装器会自动递归解析软件包的依赖关系。例如，在安装 `create_crafter` 时，安装器将自动识别并下载所需的 `core.inventory` 和 `core.redstone` 模块。应用逻辑文件将被放置在根目录中，而核心库文件将被维护在 `lib/core/` 目录结构下（通过修改 `startup.lua` 中的 package 搜索路径进行加载）。

---

## 🛠️ 开发与贡献指南

### **添加新应用**
1. 创建你的应用文件夹（例如 `My New App`）。
2. 实现你的逻辑，并尽量利用现有的 `lib/core` 核心模块。
3. 在 `manifest.lua` 中注册你的应用。
4. 如果使用了核心模块，请在清单中声明其依赖关系。

### **添加核心模块**
1. 将模块文件放置在 `lib/core/<类别>/ModuleName.lua` 中。
2. 在 `manifest.lua` 中将其注册为隐藏软件包 (`hidden = true`)。

---

## ⚖️ 安全准则与运行规则

本仓库的所有代码完全遵循 **[AGENTS.md](./AGENTS.md)** 规范：
- **严格沙盒环境 (Strict Mode)**：应用脚本与主入口文件在严格的环境下运行，防止因未声明 local 变量产生全局污染（核心库为了减少本地化开销目前暂不启用严格环境限制）。
- **非破坏性安装**：安装器绝不会在未经允许的情况下删除用户的任何已有文件（在安装完成后清理自身临时文件如 `manifest.lua` 和 `install.lua` 除外，或者在升级时替换老版本应用文件）。
- **安装状态缓存**：安装器会生成隐藏的 `.install_state.json` 文件以记录已下载文件的版本。这会极大加快二次运行时的依赖检查速度，并跳过未发生变化的文件（显示为 `CACHED`）。此文件随时可以安全删除，下一次运行时将重新下载所有文件。
- **无自动重启**：安装器在运行入口程序前会进行询问，且绝对不会在未授权的情况下自动重启系统。
- **单一电脑单一应用原则**：为了防止冲突，每台高级电脑建议仅安装**一个**应用程序。安装多个应用可能会导致资源冲突，并覆盖如 `startup.lua` 或 `Dashboard.lua` 等入口文件。

---

## 📝 致谢与故障排查

本项目由 **Antigravity** 在 Advanced Agentic Coding 框架下开发。
如果遇到运行故障：
1. 确保你正在使用的是 **高级电脑 (Advanced Computer)**。
2. 运行 `install.lua --validate` 以排查安装清单的错误。
3. 查看各应用文件夹内的 `README.md` 以获取硬件设置指南。

**[开源许可](./LICENSE)**: MIT
