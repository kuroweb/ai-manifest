# ai-manifest

- Cursor / Claude Code / Codex / Gemini CLI 向け設定の一元管理リポジトリ。
- `.rulesync/` を正本として各ツール向け設定を生成し、`scripts/install.sh` でホーム配下に反映する。

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

| 項目 | 内容 |
| --- | --- |
| OS | macOS / Linux |
| CLIツール | `rulesync` |

## コンセプト

- dotfilesのようにエージェント用の設定ファイルを一元管理するためのリポジトリ

### ホーム配下にsymlinkを張ることでユーザースコープに展開

- `bash scripts/install.sh`ではホーム配下にsymlinkを作成している。
- ホーム配下の各エージェントディレクトリ（`~/.claude`など）にsymlinkを張ることで、ユーザースコープで利用可能となる。
- MCP設定などの一部の構成については、自動反映ではなくコピペ運用としている（ユーザーローカルな設定としたほうが取り回りやすいため）

### 共通ファイルの管理コスト削減

- `.rulesync`を設定ファイルの正本として、`rulesync generate`コマンドにより各ディレクトリ（`.claude`など）に自動生成する方式にしている。
- 差分によっては同期ミスが生じることがあるが、生成先の該当ファイルを手動削除してから`rulesync generate`を実行すれば安定する。

## `install.sh` で生成するsymlink一覧

| ツール | symlink |
| --- | --- |
| Cursor | `.cursor/mcp.json`<br>`.cursor/hooks.json`<br>`.cursor/rules`<br>`.cursor/skills`<br>`.cursor/agents`<br>`.cursor/scripts`<br>`.cursor/hooks` |
| Claude Code | `.claude/settings.json`<br>`.claude/rules`<br>`.claude/skills`<br>`.claude/agents`<br>`.claude/scripts` |
| Codex | `.codex/memories`<br>`.codex/skills`<br>`.codex/agents` |
| Gemini CLI | `.gemini/memories`<br>`.gemini/skills` |
| User Tools | `.handovers`<br>`.issues` |
| App Config | `.env` -> `~/.config/ai-manifest/.env` |

## 運用ルール

- `rulesync generate` で生成されるファイルは直接編集しない
- 変更したい場合は `.rulesync/` 側を編集する
- `.rulesync/` を変更したら `rulesync generate` を再実行する

## `.rulesync` と生成先

次の対応でファイルが出力されます。以下のパスは `rulesync generate` で上書きされるため、内容を保ちたい場合は `.rulesync/` 側を編集してください。

| 管理ファイル | Cursor | Claude Code | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| `.rulesync/rules/` | `.cursor/rules` | `.claude/rules` | `.codex/memories` | `.gemini/memories` |
| `.rulesync/skills/` | `.cursor/skills` | `.claude/skills` | `.codex/skills` | `.gemini/skills` |
| `.rulesync/subagents/` | `.cursor/agents` | `.claude/agents` | `.codex/agents` | - |

## rulesync の対象外

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

### Cursor CLI - `permissions` の運用

- `.cursor/cli-config.permissions.json`をコピーして`~/.cursor/cli-config.json`にペーストして反映する

**注意点:**

- `~/.cursor/cli-config.json`はsymlink管理ができないので`install.sh`ではなくコピペ運用としている

### Claude Code - `mcpServers` の運用

- `.claude/.claude.mcp.json`をコピーして`~/.claude.json`にペーストして反映する（`/paht/to`部分は実態に合わせて調整すること）

**注意点:**

- `~/.claude.json`はClaude Codeが直接更新するため`install.sh`ではなくコピペ運用としている
- `mcpServers.*.command` は絶対パスを使う（`~` や `$HOME` は使わない）

### 日常運用

- 設定を変える: `.rulesync/` を編集して `rulesync generate`
- ホーム側を再同期する: `bash scripts/install.sh`
