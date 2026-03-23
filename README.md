# ai-manifest

Cursor / Claude Code / Codex / Gemini CLI 向けの設定をまとめるリポジトリ。

## 概要

- **共通の正本**: `.rulesync/`（`rules` / `skills` / `subagents`。対象は `rulesync.jsonc` の `features` に従う）
- **生成物**: `rulesync generate` で `.cursor/` `.claude/` `.codex/` `.gemini/` が更新される
- **ホーム反映**: `bash scripts/install.sh` で `~/.cursor` などへシンボリックリンクを張る

hooks や MCP、Claude のモデル設定などは rulesync の対象外。

## はじめ方

1. Rulesync を入れる（例: `brew install rulesync`）。その他は [Rulesync（GitHub）](https://github.com/dyoshikawa/rulesync) を参照する
2. リポジトリを clone してディレクトリに入る
3. `rulesync generate` を実行する
4. `bash scripts/install.sh` を実行する

既存の `~/.cursor` などがある場合は、`scripts/backup/<timestamp>/` に退避してからリンクを張り替える。

## 日常運用

- ルール・スキル・サブエージェントを変えたい → `.rulesync/` を編集し、`rulesync generate` を実行する
- `~/.cursor` などホーム側を、リポジトリの現在の内容に合わせたい → `bash scripts/install.sh` を実行する

`.rulesync/` を変えたあとは、必ず `rulesync generate` を実行する。

## `.rulesync` と生成先

次の対応でファイルが出力される。ここに出てくるパスは **`rulesync generate` で上書き**されるので、内容を保ちたい場合は **`.rulesync/` 側を編集**する（生成物を手で直し続けない）。

| 正本 | Cursor | Claude Code | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| `.rulesync/rules/` | `.cursor/rules` | `.claude/rules` | `.codex/memories` | `.gemini/memories` |
| `.rulesync/skills/` | `.cursor/skills` | `.claude/skills` | `.codex/skills` | `.gemini/skills` |
| `.rulesync/subagents/` | `.cursor/agents` | `.claude/agents` | `.codex/agents` | - |

## hooks とそのほかの個別設定

rulesync の生成対象ではないものは、リポジトリ内の該当ファイルを直接編集する。

| パス | 用途 |
| --- | --- |
| `.cursor/mcp.json` | Cursor 用 MCP |
| `.cursor/hooks.json` | Cursor 用 hooks |
| `.claude/settings.json` | Claude Code（モデル・statusline・hooks など） |
| `.claude/settings.local.json` | マシン固有の上書き（任意） |
| `.claude/scripts/` | statusline 用スクリプトなど |

MCP などは公式手順に従い、このリポジトリ外だけで管理してもよい。

## `install.sh` がリンクするパス

| ツール | リンク対象 |
| --- | --- |
| Cursor | `.cursor/mcp.json`, `.cursor/hooks.json`, `.cursor/rules`, `.cursor/skills`, `.cursor/agents` |
| Claude Code | `.claude/settings.json`, `.claude/settings.local.json`, `.claude/rules`, `.claude/skills`, `.claude/agents`, `.claude/scripts` |
| Codex | `.codex/memories`, `.codex/skills`, `.codex/agents` |
| Gemini CLI | `.gemini/memories`, `.gemini/skills` |

## コマンド

```bash
rulesync generate
```

```bash
bash scripts/install.sh
```
