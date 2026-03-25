# ai-manifest

Cursor / Claude Code / Codex / Gemini CLI 向け設定の一元管理リポジトリです。  
`.rulesync/` を正本として各ツール向け設定を生成し、`scripts/install.sh` でホーム配下に反映します。

## クイックセットアップ

```bash
# 1) 前提ツール
brew install rulesync
rulesync --version

# 2) リポジトリ取得
git clone <repository-url>
cd ai-manifest

# 3) 生成（.rulesync -> .cursor/.claude/.codex/.gemini）
rulesync generate

# 4) .env を用意（未作成の場合）
cp -n .env.example .env

# 5) ホームへリンク反映
bash scripts/install.sh
```

セットアップ後の確認:

```bash
ls -la ~/.cursor ~/.claude ~/.codex ~/.gemini
ls -la ~/.config/ai-manifest/.env
```

既存の `~/.cursor` などがある場合は、`scripts/backup/<timestamp>/` に退避してからリンクを張り替えます。

## 前提条件

- macOS / Linux
- `rulesync` が利用可能
- `bash`, `ln`, `cp`, `readlink` が利用可能

## このリポジトリの考え方

- 正本: `.rulesync/`（`rules` / `skills` / `subagents`）
- 生成物: `rulesync generate` で `.cursor/` `.claude/` `.codex/` `.gemini/` を更新
- 反映: `bash scripts/install.sh` で `~/.cursor` などへシンボリックリンク

## 編集ルール（重要）

- `rulesync generate` で生成されるファイルは直接編集しない
- 変更したい場合は `.rulesync/` 側を編集する
- `.rulesync/` を変更したら `rulesync generate` を再実行する

## `.rulesync` と生成先

次の対応でファイルが出力されます。以下のパスは `rulesync generate` で上書きされるため、内容を保ちたい場合は `.rulesync/` 側を編集してください。

| 正本 | Cursor | Claude Code | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| `.rulesync/rules/` | `.cursor/rules` | `.claude/rules` | `.codex/memories` | `.gemini/memories` |
| `.rulesync/skills/` | `.cursor/skills` | `.claude/skills` | `.codex/skills` | `.gemini/skills` |
| `.rulesync/subagents/` | `.cursor/agents` | `.claude/agents` | `.codex/agents` | - |

## rulesync の対象外（直接管理）

rulesync の生成対象ではないものは、リポジトリ内の該当ファイルを直接編集します。

| パス | 用途 |
| --- | --- |
| `.cursor/cli-config.json` | Cursor CLI 設定（通常は `~/.cursor/cli-config.json` を直接更新） |
| `.cursor/mcp.json` | Cursor 用 MCP |
| `.cursor/hooks.json` | Cursor 用 hooks |
| `.claude/settings.json` | Claude Code（モデル・statusline・hooks など） |
| `.claude/settings.local.json` | マシン固有の上書き（任意） |
| `.claude/scripts/` | statusline 用スクリプトなど |

`cli-config.json` は Cursor CLI が `~/.cursor/cli-config.json` を直接更新するため、`install.sh` ではシンボリックリンクを張りません。必要なら手動でコピーしてください。

## `install.sh` がリンクするパス

| ツール | リンク対象 |
| --- | --- |
| Cursor | `.cursor/mcp.json`, `.cursor/rules`, `.cursor/skills`, `.cursor/agents`, `.cursor/scripts` |
| Claude Code | `.claude/settings.json`, `.claude/settings.local.json`, `.claude/rules`, `.claude/skills`, `.claude/agents`, `.claude/scripts` |
| Codex | `.codex/memories`, `.codex/skills`, `.codex/agents` |
| Gemini CLI | `.gemini/memories`, `.gemini/skills` |
| User Tools | `.handovers`, `.issues` |
| App Config | `.env` -> `~/.config/ai-manifest/.env` |

## 日常運用

- 設定を変える: `.rulesync/` を編集して `rulesync generate`
- ホーム側を再同期する: `bash scripts/install.sh`

## よく使うコマンド

```bash
rulesync generate
bash scripts/install.sh
```
