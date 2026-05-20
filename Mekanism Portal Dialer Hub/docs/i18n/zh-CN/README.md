> [!WARNING]
> 🇨🇳 **zh-CN / Chinese (Simplified)**
> 
> 注意：本自述文件由人工智能助手（反重力）自动翻译，可能包含翻译错误或不准确之处。如需最准确和最新的文档，请参阅英文原文 [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Mekanism 门户网络（CC：调整）

> 适用于 **Mekanism Teleporters** 的专业高性能触摸界面。具有无闪烁双缓冲 UI、多页频率管理以及具有颜色自定义功能的内置频率编辑器。


---

## ✨ 特点

- **双缓冲渲染** — 使用基于窗口的自定义缓冲系统进行零闪烁 UI 更新。
- **可移动覆盖窗口** — 将颜色选择菜单拖动到屏幕上的任意位置以获得最佳可视性。
- **强调条纹指示器** - 按钮上的高对比度垂直条显示指定的颜色和黑色阴影边框，以便在任何背景上可见。
- **动态门户网格** — 通过智能分页和列表更改时自动**页面重置**自动发现所有频率。
- **实时状态监控** — 有关门户状态、目标频率和所有者的实时反馈（通过 Mojang UUID 解析）。
- **编辑模式和颜色自​​定义** — 将特定颜色分配给频率或使用随机颜色循环。
- **远程调用支持** — 集成调制解调器和 Rednet API，用于远程门户激活（通过 Recaller 脚本）。

---

## 🛠️ 硬件设置

![Ingame Setup](../../assets/images/hub-setup.png)


1. **高级计算机** — 高分辨率图形和双缓冲所需。
2. **高级监控**
- 建议尺寸：**4x3 块**以获得最佳按钮布局。
- 通过 **有线调制解调器** 和网络电缆连接。
3. **机械传送器**
- 使用 **有线调制解调器** 将 Teleporter 连接到同一有线网络。
- 右键单击调制解调器将其打开**（红色环）。
4. **调制解调器（可选）**
- 将无线或有线调制解调器连接到计算机以启用**远程调用**功能。

---

## 🚀 安装

1.从repo下载install.lua文件
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2.运行install.lua文件
```bash
install.lua
```
从菜单中选择 **Mekanism Portal Dialer Hub**。安装程序将自动下载应用程序文件（“HubSystem”、“UUIDService”、“Dashboard”）并解析所有核心依赖项（例如“ButtonGrid”、“PeripheralScanner”）。

---

## ⚙️ 配置

系统配备了交互式的图形配置菜单，可轻松自定义外设设置：

- **配置设置**：您可以通过运行以下命令随时启动配置用户界面：
  ```bash
  startup.lua --config
  ```
  或者：
  ```bash
  startup.lua -c
  ```
  这允许您动态选择显示器和传送器。设置将保存在 `config.json` 中。
- **高级选项**：要自定义网格维度或召回通道，您可以直接编辑生成的 `config.json` 文件：
  - `"gridColumns"` / `"gridRows"`：调整按钮布局（默认为 4x4）。
  - `"recallChannel"`：设置远程门户请求的调制解调器通道（默认：99）。

---

## ⌨️ 控制和模式

### **拨号器模式（默认）**
- **点击传送门** — 立即切换传送器频率。该按钮将保持突出显示状态，直到硬件确认更改。
- **下一页/上一页** — 如果您有很多频率，请在页面之间切换。

### **编辑模式（设置图标）**
1. 点击右上角的 **¤** 图标进入编辑模式。
2. 选择任意入口以打开**颜色叠加**。
3. 为该特定门户选择 **固定颜色**，或选择 **随机** 进行动态颜色循环。
4. 如果窗口挡住了您的视线，请使用覆盖层顶部的 **移动** 栏来移动窗口。

---

## 📝 远程调用 API

系统在配置的“recallChannel”上侦听调制解调器消息。要远程触发门户，请发送具有以下结构的表：
```lua
{
    command = "RECALL",
    target = "My Base" -- Name of the frequency
}
```
或者，您可以在掌上电脑上使用专用的 **Mekanism Portal Recaller** 脚本。

---

## 📝 制作人员
作为专业 Minecraft 自动化**高级代理编码**计划的一部分而开发。




