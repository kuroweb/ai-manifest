# ai-manifest

Cursor と Claude Code 向けのルール定義・スキル・スクリプトを統一管理する。

## セットアップ

```bash
bash ~/ai-manifest/scripts/install.sh
```

## 管理方針

### rulesync で共通化

以下は Cursor と Claude Code で共通の内容として管理：

| 対象 | 理由 |
| --- | --- |
| `rules/` | コーディング規約・設計原則は両ツール共通 |
| `skills/` | 再利用可能なワークフローやパターンは両ツール共通 |
| `agents/` | サブエージェント定義は両ツール共通 |

### 個別管理

上記以外（`settings.json`, `scripts/` など）はツール固有の設定・実行環境として個別管理する。

## 管理構成

| 項目 | 説明 |
| --- | --- |
| **ソースコード** | `agents/.claude/` と `agents/.cursor/` |
| **ビルドツール** | [Rulesync](https://github.com/dyoshikawa/rulesync) |
| **設定ファイル** | `agents/rulesync.jsonc` |

## ディレクトリ構造

**Claude Code (`~/.claude/`)**

| パス | 説明 |
| --- | --- |
| `rules/` | プロジェクト固有のルール定義 (rulesync管理) |
| `skills/` | カスタムスキル定義 (rulesync管理) |
| `agents/` | サブエージェント定義 (rulesync管理) |
| `settings.json` | statusline、モデル設定など |
| `settings.local.json` | ローカル環境固有の設定 |
| `scripts/` | statusline.sh などのカスタムスクリプト |

**Cursor (`~/.cursor/`)**

| パス | 説明 |
| --- | --- |
| `rules/` | プロジェクト固有のルール定義 (rulesync管理) |
| `skills/` | カスタムスキル定義 (rulesync管理) |
| `agents/` | サブエージェント定義 (rulesync管理) |
| `scripts/` | カスタムスクリプト |
