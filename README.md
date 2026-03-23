# ai-manifest

Cursor / Claude Code / Codex / Gemini CLI 向けの設定を一括管理するためのリポジトリ

## このリポジトリで管理するもの

- **編集正本**: `.rulesync/`
- **生成物**（各ツール向け）: `.cursor/`, `.claude/`, `.codex/`, `.gemini/`
- **ホームへの反映**: `scripts/install.sh`（`~/.cursor` 等へのシンボリックリンク）

## 初回セットアップ

### 1. Rulesync をインストール（Homebrew）

```bash
brew install rulesync
```

Homebrew 以外は [Rulesync（GitHub）](https://github.com/dyoshikawa/rulesync) を参照。

### 2. リポジトリを取得

```bash
git clone <repository-url>
cd ai-manifest
```

### 3. 生成物を作成

```bash
rulesync generate
```

`.rulesync/` を元に、リポジトリ内の `.cursor/` / `.claude/` / `.codex/` / `.gemini/` を更新する。

### 4. ホームディレクトリへ反映

```bash
bash scripts/install.sh
```

`~/.cursor` / `~/.claude` / `~/.codex` / `~/.gemini` にシンボリックリンクを張る。  
既存のファイルやディレクトリがある場合は、`scripts/backup/<timestamp>/` にバックアップしてから置き換える。

## 日常運用

1. `.rulesync/` を編集する
2. `rulesync generate` を実行する
3. 必要なら `bash scripts/install.sh` で `~/` 側へ再反映する

`.rulesync/` を変えたあとは、必ず `rulesync generate` を実行する。

## よく編集するファイル（個別設定）

`install.sh` が `~/` へリンクするうち、手で触ることが多いもの。

| ファイル | 用途 |
| --- | --- |
| `.cursor/mcp.json` | Cursor 用 MCP サーバー設定 |
| `.claude/settings.json` | モデル・statusline など Claude Code の設定 |
| `.claude/settings.local.json` | マシン固有の上書き（任意） |
| `.claude/scripts/` | statusline 用シェルスクリプトなど |

MCP やその他の CLI 専用設定は、各ツールの公式手順に従い、このリポジトリ外で管理してもよい。

## rulesync と install.sh の役割

### rulesync

- **入力**: `.rulesync/`
- **出力**: リポジトリ直下の `.cursor/` / `.claude/` / `.codex/` / `.gemini/`
- **設定**: `rulesync.jsonc`

| 編集正本 | Cursor | Claude Code | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| `.rulesync/rules/` | `.cursor/rules` | `.claude/rules` | `.codex/memories` | `.gemini/memories` |
| `.rulesync/skills/` | `.cursor/skills` | `.claude/skills` | `.codex/skills` | `.gemini/skills` |
| `.rulesync/subagents/` | `.cursor/agents` | `.claude/agents` | `.codex/agents` | - |

### install.sh

リポジトリ内のファイル・ディレクトリを `~/` 配下へリンクする。主な対象は次のとおり。

| ツール | リンク対象 |
| --- | --- |
| Cursor | `.cursor/mcp.json`, `.cursor/rules`, `.cursor/skills`, `.cursor/agents` |
| Claude Code | `.claude/settings.json`, `.claude/settings.local.json`, `.claude/rules`, `.claude/skills`, `.claude/agents`, `.claude/scripts` |
| Codex | `.codex/memories`, `.codex/skills`, `.codex/agents` |
| Gemini CLI | `.gemini/memories`, `.gemini/skills` |

## コマンドリファレンス

### `rulesync generate`

`.rulesync/` の編集正本から各ツール向けの出力を再生成する。

```bash
rulesync generate
```

### `bash scripts/install.sh`

生成物・個別設定を `~/.cursor` などへ反映する（既存項目はバックアップのうえで置換）。

```bash
bash scripts/install.sh
```
