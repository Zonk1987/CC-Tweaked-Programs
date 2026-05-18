> [!WARNING]
> 🇯🇵 **ja / 日本語**
> 
> ⚠️ **注意**: このREADMEはAIアシスタント（Antigravity）によって自動翻訳されたものであり、翻訳エラーや不正確な内容が含まれている可能性があります。最も正確で最新のドキュメントについては、オリジナルの英語版 [README.md](../../../README.md) を参照してください。

<div align="center">

# Zonk's CC:Tweaked Automation Suite 🚀

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

Minecraftの**CC:Tweaked**コンピュータ向けのプロフェッショナル仕様の自動化スクリプト集です。モジュール化された**Feature-Core**アーキテクチャ、美しいプレミアムUI、そして堅牢なマニフェスト駆動型インストーラーを特徴としています。

---

## 🚀 インストール方法

**Advanced Computer（高度なコンピュータ）**上で以下のコマンドを実行してください。

1. リポジトリから `install.lua` ファイルをダウンロードします：
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. ダウンロードした `install.lua` ファイルを実行します：
```bash
install.lua
```

---

## 📦 利用可能なパッケージ

| ID | 名前 | 説明 | 主な機能 |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | 美しいタッチパネル式のポータルダイアラー。 | 移動可能なUI、アクセントストライプ、自動リセット。 |
| `mekanism_recall_sender`| **Portal Recall Sender** | 離れた場所からのワイヤレス起動トリガー。 | ハードウェア障害診断、リアルタイムステータス表示。 |
| `create_crafter` | **Mechanical Crafter** | グリッド式の自動クラフトシステム。 | ゲーム内でのレシピ登録＆キャリブレーション、多段階クラフト。 |
| `powah_orb` | **Energizing Orb** | 並列での自動クラフトシステム。 | ME Bridge連携、クラフト停止・停電時の自動復旧機能。 |
| `developer_suite` | **CC Developer Suite** | システム診断および開発用ツールキット。 | イベントモニター、周辺機器のシグナルインスペクタ。 |

---

## 🏗️ アーキテクチャ：Feature-Core Skeleton

このリポジトリは、メンテナンスの容易さと実行速度を両立させるために、モジュール構造で設計されています。

### **コア・モジュール (`lib/core`)**
再利用性の高い共通ユーティリティは、重複を避けるために隠しパッケージとしてコアディレクトリに配置されています：
- **`core.base`**: `ConfigStore`（JSONによるデータ保存）などの基本的な基盤ロジック。
- **`core.peripherals`**: 周辺機器の安全な検出とラップ機能 (`PeripheralScanner`)。
- **`core.network`**: 標準化された無線赤網（Rednet）通信プロトコル (`RednetProtocol`)。
- **`core.redstone`**: レッドストーン信号の制御補助クラス (`RedstoneController`)。
- **`core.ui`**: 再利用可能な画面描画モジュール (`ButtonGrid`)。
- **`core.inventory`**: 標準化されたインベントリ管理および搬入出 (`InventoryAdapter`, `ItemMatcher`)。
- **`core.recipes`**: JSON形式でレシピ情報を管理するデータベース (`RecipeStore`)。

### **依存関係の自動解決**
インストーラーは依存関係を自動的かつ再帰的に検出し、ダウンロードします。例えば、`create_crafter` をインストールすると、必須モジュールである `core.inventory` と `core.redstone` が自動的にダウンロードされます。アプリケーションプログラムはルートディレクトリに配置され、共通ライブラリは `lib/core/` の階層に配置されます（`startup.lua` でパッケージの検索パスを設定することでロードします）。

---

## 🛠️ 開発・拡張ガイドライン

### **新しいアプリを追加する**
1. アプリ用のフォルダを作成します（例：`My New App`）。
2. `lib/core` のモジュールを活用してロジックを実装します。
3. `manifest.lua` にアプリを登録します。
4. 共通モジュールを使用している場合は、マニフェストファイルに依存関係を記述します。

### **新しい共通モジュールを追加する**
1. `lib/core/<カテゴリ名>/ModuleName.lua` にモジュールファイルを配置します。
2. `manifest.lua` に隠しパッケージとして登録します (`hidden = true`)。

---

## ⚖️ 安全性＆動作ルール

このリポジトリに配置されるすべてのコードは **[AGENTS.md](./AGENTS.md)** の規約に準拠します：
- **厳密な動作環境 (Strict Mode)**: アプリケーションスクリプトとスタートアップファイルは、意図しないグローバル変数の発生を防ぐために厳密な環境下で動作します（コアライブラリはコードの複雑化を防ぐため一時的に適用外にしています）。
- **非破壊インストール**: インストーラーがユーザーの既存ファイルを無断で削除することは絶対にありません（インストール完了時の `manifest.lua` や `install.lua` などの一時ファイルの削除、またはアップデート時の旧バージョンの更新時を除く）。
- **インストール状態のキャッシュ**: インストーラーは `.install_state.json` という隠しファイルを作成し、導入されたファイルバージョンを記憶します。これにより二回目以降の確認速度が向上し、変更がないファイルはダウンロードがスキップされます（`CACHED` と表示されます）。このファイルはいつでも安全に削除でき、その場合は次回のインストールで全ファイルが再取得されます。
- **自動再起動の禁止**: インストーラーがアプリ実行前に確認を挟まずに、システムを勝手に再起動することはありません。
- **1台に1アプリの原則**: 各「高度なコンピュータ（Advanced Computer）」には、1つのアプリケーションのみを導入することを推奨します。複数のアプリを同じPCにインストールすると、ファイルが衝突し `startup.lua` や `Dashboard.lua` などの重要な起動ファイルが上書きされます。

---

## 📝 クレジット＆トラブルシューティング

開発：**Antigravity**（Advanced Agentic Coding イニシアチブの一環として開発）
何か不具合が発生した場合：
1. **Advanced Computer** を使用しているか確認してください。
2. `install.lua --validate` を実行して、マニフェストファイルにエラーがないか検証してください。
3. 各アプリケーションのフォルダにある `README.md` を読み、ハードウェアの構成を確認してください。

**[ライセンス](./LICENSE)**: MIT
