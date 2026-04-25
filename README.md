# ai-manifest

Cursor / Claude Code / Codex / Gemini CLI 向け設定の一元管理リポジトリ。

`.rulesync/` を正本として各ツール向け設定を生成し、`scripts/install.sh` でホーム配下に反映する。

## クイックスタート

- 1: 依存パッケージインストール

  ```bash
  brew install rulesync
  ```

- 2: リポジトリ配置

  ```bash
  git clone <repository-url>
  cd ai-manifest
  ```

- 3: サブモジュール取得

  ```bash
  git submodule update --init --recursive
  ```

- 4: 各エージェント向けにファイル生成

  ```bash
  rulesync generate
  ```

- 5: ローカル用ファイルを作成

  ```bash
  cp -n .env.example .env
  cp -n .cursor/mcp.json.example .cursor/mcp.json
  cp -n .cursor/hooks.json.example .cursor/hooks.json
  ```

- 6: ホーム配下にsymlinkを作成して反映

  ```bash
  bash scripts/install.sh
  ```

  > 既存の `~/.cursor` などがある場合は、自動的に`scripts/backup/<timestamp>/` に退避してからリンクを張り替える。

- 7: セットアップ後の確認

  ```bash
  ls -la ~/.cursor ~/.claude ~/.codex ~/.gemini
  ls -la ~/.config/ai-manifest/.env
  ```

## 前提条件

- macOS / Linux
- `rulesync` が利用可能
- `bash`, `ln`, `cp`, `readlink` が利用可能

## このリポジトリの考え方

- 正本: `.rulesync/`（`rules` / `skills` / `subagents`）
- 生成物: `rulesync generate` で `.cursor/` `.claude/` `.codex/` `.gemini/` を更新
- 反映: `bash scripts/install.sh` で `~/.cursor` などへシンボリックリンク
- 参照用サブモジュール: [`references/takt`](references/takt)（TAKT）、[`references/pm-skills`](references/pm-skills)（pm-skills）。クローン後に `git submodule update --init --recursive` が必要

## 編集ルール（重要）

- `rulesync generate` で生成されるファイルは直接編集しない
- 変更したい場合は `.rulesync/` 側を編集する
- `.rulesync/` を変更したら `rulesync generate` を再実行する
- `pm-exec-*` スキルの正本は `references/pm-skills/pm-execution/skills/` で、`.rulesync/skills/pm-exec-*` はこのリポジトリ向けに取り込んだ実体コピー

## `.rulesync` と生成先

次の対応でファイルが出力されます。以下のパスは `rulesync generate` で上書きされるため、内容を保ちたい場合は `.rulesync/` 側を編集してください。

| 管理ファイル | Cursor | Claude Code | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| `.rulesync/rules/` | `.cursor/rules` | `.claude/rules` | `.codex/memories` | `.gemini/memories` |
| `.rulesync/skills/` | `.cursor/skills` | `.claude/skills` | `.codex/skills` | `.gemini/skills` |
| `.rulesync/subagents/` | `.cursor/agents` | `.claude/agents` | `.codex/agents` | - |

## rulesync の対象外（直接管理）

rulesync の生成対象ではないものは、リポジトリ内の該当ファイルを直接編集します。

| パス | 用途 |
| --- | --- |
| `.cursor/cli-config.permissions.json` | Cursor CLI の `permissions` を手動コピペで管理するファイル |
| `.cursor/cli-config.json` | Cursor CLI 設定の参考ファイル（運用上は `~/.cursor/cli-config.json` を直接更新） |
| `.cursor/mcp.json` | Cursor 用 MCP |
| `.cursor/hooks.json` | Cursor 用 hooks |
| `.cursor/hooks/` | Cursor hooks で呼び出すスクリプト置き場 |
| `.claude/.claude.mcp.json` | Claude Code の `mcpServers` を手動コピペで管理するファイル |
| `.claude/settings.json` | Claude Code（モデル・statusline・hooks など） |
| `.claude/scripts/` | statusline 用スクリプトなど |

`cli-config.json` は Cursor CLI が `~/.cursor/cli-config.json` を直接更新するため、`install.sh` ではシンボリックリンクを張りません。

### Cursor CLI - `permissions` の運用

`.cursor/cli-config.permissions.json`をコピーして`~/.cursor/cli-config.json`にペーストして反映する

**注意点:**

- `~/.cursor/cli-config.json`はsymlink管理ができないので`install.sh`ではなくコピペ運用としている

### Claude Code - `mcpServers` の運用

`.claude/.claude.mcp.json`をコピーして`~/.claude.json`にペーストして反映する（`/paht/to`部分は実態に合わせて調整すること）

**注意点:**

- `~/.claude.json`はClaude Codeが直接更新するため`install.sh`ではなくコピペ運用としている
- `mcpServers.*.command` は絶対パスを使う（`~` や `$HOME` は使わない）

## `install.sh` がリンクするパス

| ツール | リンク対象 |
| --- | --- |
| Cursor | `.cursor/mcp.json`, `.cursor/hooks.json`, `.cursor/rules`, `.cursor/skills`, `.cursor/agents`, `.cursor/scripts`, `.cursor/hooks` |
| Claude Code | `.claude/settings.json`, `.claude/rules`, `.claude/skills`, `.claude/agents`, `.claude/scripts` |
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

## `pm-exec-*` スキル一覧

- `pm-exec-*` は `phuryn/pm-skills` の `pm-execution` 由来の PM 支援スキル
- 実体は [`.rulesync/skills/`](.rulesync/skills) 配下の `pm-exec-*` ディレクトリとして管理する
- 参照元は [`references/pm-skills`](references/pm-skills) サブモジュール（先に `git submodule update --init --recursive`）
- 更新時は参照元を見て `pm-exec-*` 側に反映し、その後 `rulesync generate` を実行する

| スキル | 用途 |
| --- | --- |
| `pm-exec-brainstorm-okrs` | チーム向け OKR の草案を作る |
| `pm-exec-create-prd` | PRD を 8 セクション構成で作る |
| `pm-exec-dummy-dataset` | テストやデモ用のダミーデータを作る |
| `pm-exec-job-stories` | JTBD 形式の job story を作る |
| `pm-exec-outcome-roadmap` | 機能列挙のロードマップを outcome ベースに直す |
| `pm-exec-pre-mortem` | 企画やリリース前にリスクを洗い出す |
| `pm-exec-prioritization-frameworks` | 優先順位付けフレームワークを選ぶ |
| `pm-exec-release-notes` | ユーザー向けの release notes を作る |
| `pm-exec-retro` | スプリントレトロの整理とアクション化を行う |
| `pm-exec-sprint-plan` | スプリント計画を立てる |
| `pm-exec-stakeholder-map` | ステークホルダー整理とコミュニケーション計画を作る |
| `pm-exec-summarize-meeting` | 会議メモと決定事項を要約する |
| `pm-exec-test-scenarios` | user story からテストシナリオを作る |
| `pm-exec-user-stories` | user story と受け入れ条件を作る |
| `pm-exec-wwas` | Why-What-Acceptance 形式の backlog item を作る |
