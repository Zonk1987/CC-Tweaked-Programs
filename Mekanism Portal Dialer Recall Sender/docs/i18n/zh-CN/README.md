> [!WARNING]
> 🇿🇳 **zh-CN / Chinese (Simplified)**
> 
> 注意：本自述文件由人工智能助手（反重力）自动翻译，可能包含翻译错误或不准确之处。如需最准确和最新的文档，请参阅英文原文 [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Mekanism Portal 召回发送者（CC：调整）

> **Mekanism Portal Network** 的专用远程触发器。允许您通过简单地在目的地提供红石信号（按钮、压力板等）来远程拨打您的家庭门户。


---

## ◈ 特点

- **硬件诊断** — 在启动时扫描所有连接的外围设备，并提供有关调制解调器和 Teleporter 存在的清晰反馈。
- **实时门户状态（可选）** – 如果物理连接本地 Teleporter 块（否则默认为“仅限远程集线器”），则实时监控本地门户的状态（例如“就绪”、“未通电”）。
- **心跳自动刷新** – 每 2 秒自动更新一次状态，以保持显示与集线器同步。
- **交互式设置** – 无需编辑代码。该脚本在第一次运行时会询问目标位置。
- **配置菜单（热键）** – 在计算机终端上按“C”可更改目标名称或频道。
- **双路径协议** — 通过标准调制解调器 API 和 Rednet 发送命令，以实现最大可靠性。

---

## 硬件设置

1. **袖珍计算机或小型计算机** - 将计算机放置在远程目的地（例如月球基地、采矿前哨站）。
2. **调制解调器（无线或有线）** — 将无线调制解调器（适合远程位置）或有线调制解调器连接到计算机。
3. **红石触发器** - 将按钮、压力板或任何红石源连接到计算机的任意一侧。
- 当红石信号打开**时，计算机将向您的主基地发送召回命令。

---

## 安装

1.从repo下载install.lua文件
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2.运行install.lua文件
```bash
install.lua
```
从菜单中选择 **Mekanism Portal Recaller**。

---

## ➡️用法

1. **首次运行**：计算机将询问您**目标名称**。输入出现在主门户中心（例如“主基地”）中的频率的*准确名称*。
2. **正常操作**：屏幕将显示“等待红石信号...”。
3. **触发器**：按下按钮。您主基地的中心将立即切换到您当前的位置。
4. **配置**：如果您将计算机移动到新的基地，请按键盘上的“C”打开菜单并更改目标名称。

---

## 技术细节
发送者在配置的通道上广播 JSON 表（默认值：99）：
```json
{
    "command": "RECALL",
    "target": "Your Destination Name"
}
```

---

## ð“ 制作人员
专为专业 Minecraft 自动化而开发。

