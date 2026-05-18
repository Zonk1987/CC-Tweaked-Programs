> [!WARNING]
> 🇯🇵 **ja / Japanese**
> 
> 注: この README は AI アシスタント (Antigravity) によって自動的に翻訳されており、翻訳エラーや不正確な部分が含まれている可能性があります。最も正確で最新のドキュメントについては、オリジナルの英語版を参照してください。 [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div align="center">

# Zonk の CC:調整されたオートメーション スイート 🚀

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

Minecraft **CC:Tweaked** 用のプロフェッショナル グレードの自動化スクリプトのコレクション。モジュラー **Feature-Core** アーキテクチャ、プレミアム UI の美しさ、堅牢なマニフェスト駆動のインストーラーを特徴としています。


---

## 🚀 インストール

**高度なコンピュータ**で次のコマンドを実行します。

1. リポジトリから install.lua ファイルをダウンロードします。
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. install.lua ファイルを実行します。
```bash
install.lua
```

---

## 📦 利用可能なパッケージ

| ID | 名前 | 説明 | 主な特長 |
|:---|:---|:---|:---|
| 「mekanism_portal_hub」 | [**ポータル ダイヤラー ハブ**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/ja/README.md) | プレミアムタッチスクリーンダイヤラー。 | 移動可能な UI、アクセントストライプ、ページリセット。 |
| `mekanism_recall_sender` | [**ポータル リコール送信者**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/ja/README.md) | リモートワイヤレストリガー。 | ハードウェア診断、ライブステータス監視。 |
| `create_crafter` | [**Mechanical Crafter**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/ja/README.md) | グリッド作成の自動化。 | 記録とキャリブレーション、マルチステップレシピ。 |
| `ポワオーブ` | [**エネルギーを与えるオーブ**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/ja/README.md) | 並行クラフトの自動化。 | ME ブリッジの統合、自動回復。 |
| 「開発者スイート」 | [**CC 開発者スイート**](../../../CC%20Developer%20Suite/docs/i18n/ja/README.md) | 診断ツールキット。 | イベントスニファー、ペリフェラルインスペクター。 |

---

## 🏗️ アーキテクチャ: 機能コアのスケルトン

このリポジトリは、モジュール式スケルトンを使用して保守性とパフォーマンスを考慮して構築されています。

### **コア モジュール (`lib/core`)**
汎用ユーティリティは、重複を減らすために非表示のコア パッケージに抽出されます。
- **`core.base`**: `ConfigStore` などの基本的なロジック (JSON 永続化)。
- **`core.peripherals`**: 安全なペリフェラルの検出とラッピング (`PeripheralScanner`)。
- **`core.network`**: 標準化された通信プロトコル (`RednetProtocol`)。
- **`core.redstone`**: レッドストーン インタラクション ヘルパー (`RedstoneController`)。
- **`core.ui`**: 再利用可能な UI コンポーネント (`ButtonGrid`)。
- **`core.inventory`**: 標準化された在庫処理 (`InventoryAdapter`、`ItemMatcher`)。
- **`core.recipes`**: JSON ベースのレシピ ストレージ (`RecipeStore`)。

### **依存関係の解決**
インストーラーは依存関係を再帰的に自動的に解決します。たとえば、`create_crafter` をインストールすると、必要な `core.inventory` および `core.redstone` モジュールが自動的にプルされます。アプリケーション ファイルはルート ディレクトリに配置され、コア ライブラリは `lib/core/` 階層に維持されます (`startup.lua` 内の調整されたパッケージ パスを介してアクセス可能)。

---

## 🛠️開発ガイドライン

### **新しいアプリの追加**
1. アプリフォルダー (「My New App」など) を作成します。
2. 既存の「lib/core」モジュールを利用してロジックを実装します。
3. アプリを「manifest.lua」に登録します。
4. コアモジュールを使用する場合は、依存関係を追加します。

### **コアモジュールの追加**
1. モジュールを `lib/core/<category>/ModuleName.lua` に配置します。
2. `manifest.lua`に`hidden = true`パッケージとして登録します。

---

## ⚖️ 安全性とルール

このリポジトリ内のすべてのコードは **[AGENTS.md](../../../AGENTS.md)** によって管理されます。
- **厳密モード**: アプリケーション スクリプトとエントリ ファイルは、偶発的なグローバルを防ぐために厳密な環境を使用します (コア ライブラリは現在、ローカリゼーションのボイラープレートを減らすためにこれをバイパスしています)。
- **削除なし**: インストーラーは既存のユーザー ファイルを削除しません (完了後の「manifest.lua」や「install.lua」などの独自の一時ファイルのクリーンアップや、更新中の古いバージョンの置き換えを除く)。
- **状態キャッシュのインストール**: インストーラーは、インストールされているファイル バージョンを記憶するために隠しファイル `.install_state.json` を作成します。これにより、変更されていないファイル (「CACHED」として表示) がスキップされるため、今後の実行が高速化されます。このファイルはいつでも安全に削除できます。次回のインストールでは、すべてが再ダウンロードされるだけです。
- **自動再起動なし**: インストーラーはエントリ ファイルを実行する前に確認を行い、許可なしにシステムを再起動することはありません。
- **単一アプリ ポリシー**: アドバンスト コンピューターごとに **1 つ**のアプリケーションのみがサポートされます。同じコンピューターに複数のアプリをインストールすると、ファイルの衝突が発生し、「startup.lua」や「Dashboard.lua」などの重要なファイルが上書きされます。

---

## 📝 クレジットとトラブルシューティング
Advanced Agenticcoding イニシアチブの一環として **Antigravity** によって開発されました。
問題が発生した場合:
1. **高度なコンピュータ**を使用していることを確認します。
2. `install.lua --validate` を実行してマニフェスト エラーを確認します。
3. ハードウェア固有のセットアップについては、各アプリケーションのフォルダー内の「README.md」を確認してください。

**[ライセンス](../../../LICENSE)**: MIT



