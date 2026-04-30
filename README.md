# ai-manifest

- Cursor / Claude Code / Codex / Gemini CLI 向け設定の一元管理リポジトリ。
- `.rulesync/` を正本として設定を生成し、`scripts/install.sh` でホーム配下へ反映する。

# クイックスタート

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

- 6: ホーム配下に symlink を作成して反映

  ```bash
  bash scripts/install.sh
  ```

  > 既存の `~/.cursor` などがある場合は、自動的に `scripts/backup/<timestamp>/` に退避してからリンクを張り替える。

- 7: セットアップ後の確認

  ```bash
  ls -la ~/.cursor ~/.claude ~/.codex ~/.gemini
  ls -la ~/.config/ai-manifest/.env
  ```

# 仕様

## 技術スタック

| 項目 | 内容 |
| --- | --- |
| OS | macOS / Linux |
| 必須 CLI | `rulesync` |
| 対象エージェント | Cursor / Claude Code / Codex / Gemini CLI |
| 主な生成コマンド | `rulesync generate` |
| 主な反映コマンド | `bash scripts/install.sh` |

## rulesyncでの構成管理

- `.rulesync/` を正本として、各ツール向けのルール・スキル・サブエージェントを生成する。
- 生成先ファイルは `rulesync generate` で上書きされる前提とする。

### 共通管理するもの

| 管理ファイル | Cursor | Claude Code | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| `.rulesync/rules/` | `.cursor/rules` | `.claude/rules` | `.codex/memories` | `.gemini/memories` |
| `.rulesync/skills/` | `.cursor/skills` | `.claude/skills` | `.codex/skills` | `.gemini/skills` |
| `.rulesync/subagents/` | `.cursor/agents` | `.claude/agents` | `.codex/agents` | `.gemini/agents` |

### 正本の扱い

- `.rulesync/` が Single Source of Truth。
- `.rulesync/` と生成先が矛盾する場合は `.rulesync/` を正とする。
- 生成先は手編集の保存場所ではなく、生成結果として扱う。

### 禁止事項

- `rulesync generate` で生成されるファイルを直接編集しない。
- 生成を伴わずに生成先だけを整合調整しない。
- 意図が不明な大量再生成をしない。

## install.sh によるホーム配下への反映

- `bash scripts/install.sh` で、リポジトリ内の管理対象をホーム配下へ symlink で反映する。
- 各エージェントがユーザースコープでそのまま利用できる状態を作る。

### symlink を張る対象

| ツール | symlink |
| --- | --- |
| Cursor | `.cursor/mcp.json`<br>`.cursor/hooks.json`<br>`.cursor/rules`<br>`.cursor/skills`<br>`.cursor/agents`<br>`.cursor/scripts`<br>`.cursor/hooks` |
| Claude Code | `.claude/settings.json`<br>`.claude/rules`<br>`.claude/skills`<br>`.claude/agents`<br>`.claude/scripts` |
| Codex | `.codex/memories`<br>`.codex/skills`<br>`.codex/agents` |
| Gemini CLI | `.gemini/memories`<br>`.gemini/skills` |
| User Tools | `.handovers`<br>`.issues` |
| App Config | `.env` -> `~/.config/ai-manifest/.env` |

### backup の扱い

- 既存の `~/.cursor` などがある場合は、`scripts/backup/<timestamp>/` に退避してから張り替える。
- 反映前にローカル変更の退避が必要か確認する。

## install.sh だけでは反映できない設定

- 一部の設定値は symlink 管理に向かない。
- `install.sh` だけではホーム側へ反映されない設定がある。
- それらは手動コピペで取り込む。

### 手動コピペが必要な設定

- `install.sh` 実行後も、ホーム側の実ファイルに反映されているとは限らない。
- ツール自身が更新する設定や、ローカル差分を持たせたい設定は手動運用する。

### Cursor CLI permissions

- `.cursor/cli-config.permissions.json` を `~/.cursor/cli-config.json` へコピーして反映する。
- `~/.cursor/cli-config.json` は symlink 管理せず、コピペ運用とする。

### Claude Code mcpServers

- `.claude/.claude.mcp.json` を `~/.claude.json` へコピーして反映する。
- `~/.claude.json` は Claude Code が直接更新するため、symlink 管理しない。
- `mcpServers.*.command` には絶対パスを使う。`~` や `$HOME` は使わない。

# 開発手順

## 変更前の確認

- 変更対象が `.rulesync/` 配下か、手動運用の実ファイルかを確認する。
- 生成先ファイルを直接編集しようとしていないか確認する。
- 必要なら現行差分を確認して、意図しない変更が混ざっていないことを確かめる。

## 変更の実施

- 共通管理対象を変える場合は `.rulesync/` を編集する。
- `permissions` や `mcpServers` など自動反映できない設定だけ、対応する実ファイルを更新する。

## 生成と差分確認

```bash
rulesync generate
git diff -- README.md .cursor .claude .codex .gemini .rulesync
```

- 生成先との差分が意図どおりか確認する。
- 不整合がある場合は、生成先を見直す前に `.rulesync/` 側の記述を確認する。

## ホーム配下への反映

```bash
bash scripts/install.sh
```

- ホーム配下の symlink を更新したい場合だけ実行する。
- 実行後に `~/.cursor` や `~/.claude` のリンク先を確認する。

## トラブル時の復旧

- 生成結果がおかしい場合は、該当する生成先を見直してから `rulesync generate` を再実行する。
- ホーム反映で問題が起きた場合は `scripts/backup/<timestamp>/` を確認する。
- 手動反映設定が効かない場合は、コピー先ファイルと絶対パス指定を見直す。
