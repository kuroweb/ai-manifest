# ai-manifest

- Cursor / Claude Code / Codex 向け設定の一元管理リポジトリ。
- エージェント設定の正本は `config/` 配下。`config/.rulesync/` からルール・サブエージェントを生成し、`scripts/install.sh` でホーム配下へ反映する。
- スキルは `skills/` を正本とし、`gh skill install` で各エージェントへ反映する。

## リポジトリ構成

```
ai-manifest/
├── README.md
├── scripts/install.sh   # config/ → ホーム配下への symlink 反映
├── skills/              # スキル正本
└── config/              # エージェント設定正本
    ├── .rulesync/       # ルール・サブエージェント正本
    ├── .cursor/
    ├── .claude/
    ├── .codex/
    ├── .docs/
    ├── .takt/
    ├── .env             # ローカル用（git 管理外）
    ├── rulesync.jsonc
    ├── CLAUDE.md        # rulesync 生成物
    └── AGENTS.md        # rulesync 生成物
```

## クイックスタート

- 1: 依存パッケージインストール

  ```bash
  brew install rulesync gh
  ```

- 2: リポジトリ配置

  ```bash
  git clone <repository-url>
  cd ai-manifest
  ```

- 3: 各エージェント向けにファイル生成

  ```bash
  cd config
  rulesync generate
  ```

- 4: ローカル用ファイルを作成

  ```bash
  cp -n config/.env.example config/.env
  cp -n config/.cursor/mcp.json.example config/.cursor/mcp.json
  cp -n config/.cursor/hooks.json.example config/.cursor/hooks.json
  ```

- 5: スキルをインストール

  利用するエージェントごとに実行する。`--scope user` でホーム配下に配置し、`install.sh` と同じスコープに揃える。

  ```bash
  gh skill install . --from-local --all --scope user --agent cursor
  gh skill install . --from-local --all --scope user --agent claude-code
  gh skill install . --from-local --all --scope user --agent codex
  ```

  リモートから取得する場合:

  ```bash
  gh skill install kuroweb/ai-manifest --all --scope user --agent claude-code
  ```

- 6: ホーム配下に symlink を作成して反映

  ```bash
  bash scripts/install.sh
  ```

  > 既存の `~/.cursor` などがある場合は、自動的に `scripts/backup/<timestamp>/` に退避してからリンクを張り替える。

- 7: セットアップ後の確認

  ```bash
  ls -la ~/.cursor ~/.claude ~/.codex
  ls -la ~/.config/ai-manifest/.env
  gh skill list
  ```

## 日次ワークフロー

やりたいこと・改善したいことが浮かんだら **`/issue`** から始める。正本は `~/.docs/issues/<state>/<slug>/issue.md`。

```
/issue
  → 一言メモ → draft issue 作成
  → grill-me で検討
  → issue に実施計画を追記
  → ready 昇格（ユーザー確認）
  → 実装
  → close
```

| コマンド | 用途 |
| --- | --- |
| `/issue` | 新規・再開・着手の唯一の入口 |
| `/grill-me` | 検討フェーズ（`/issue` からも呼ぶ） |
| `/grill-with-docs` | ドメイン文書ありプロジェクト向け（明示時のみ） |
| `/plan-export` | Cursor plan モード等の成果物を `~/.docs/plans/` へ退避 |
| `/learn` | 知見抽出（必要なときに手動で呼ぶ） |
| `handover` | セッション境界の引き継ぎ（本フローとは別） |

issue の状態はディレクトリで管理する。

| 状態 | パス | 意味 |
| --- | --- | --- |
| `draft` | `~/.docs/issues/draft/` | 検討中 |
| `ready` | `~/.docs/issues/ready/` | 着手可能 |
| `close` | `~/.docs/issues/close/` | 完了 |

## 仕様

### 技術スタック

| 項目 | 内容 |
| --- | --- |
| OS | macOS / Linux |
| 必須 CLI | `rulesync`, `gh` |
| 対象エージェント | Cursor / Claude Code / Codex |
| 主な生成コマンド | `cd config && rulesync generate` |
| 主な反映コマンド | `bash scripts/install.sh`, `gh skill install` |

### rulesyncでの構成管理

- `config/.rulesync/` を正本として、各ツール向けのルール・サブエージェントを生成する。
- `rulesync generate` は `config/` で実行する（`config/rulesync.jsonc` の `outputRoots` が `.`）。
- 生成先ファイルは `rulesync generate` で上書きされる前提とする。
- スキルは rulesync の管理対象外。正本は `skills/` とする。

#### 共通管理するもの

| 管理ファイル | Cursor | Claude Code | Codex |
| --- | --- | --- | --- |
| `config/.rulesync/rules/global-policy.md` | `config/.cursor/rules/global-policy.mdc` | `config/CLAUDE.md` | `config/AGENTS.md` |
| `config/.rulesync/rules/` | `config/.cursor/rules` | `config/.claude/rules` | `config/AGENTS.md`（ルール統合） |
| `config/.rulesync/subagents/` | `config/.cursor/agents` | `config/.claude/agents` | `config/.codex/agents` |

#### 正本の扱い

- `config/.rulesync/` が Single Source of Truth（ルール・サブエージェント）。
- `skills/` が Single Source of Truth（スキル）。
- `config/.rulesync/` と生成先が矛盾する場合は `config/.rulesync/` を正とする。
- 生成先は手編集の保存場所ではなく、生成結果として扱う。

#### 禁止事項

- `rulesync generate` で生成されるファイルを直接編集しない。
- 生成を伴わずに生成先だけを整合調整しない。
- 意図が不明な大量再生成をしない。

### gh skill install によるスキル反映

- `skills/*/SKILL.md` 形式でスキルを管理する（[Agent Skills specification](https://agentskills.io/specification)）。
- `gh skill install` で各エージェントのスキルディレクトリへコピーする（symlink ではない）。
- 更新は `gh skill update --all` または `--from-local` で再インストールする。

#### よく使うコマンド

```bash
# ローカル変更を反映（開発中）
gh skill install . --from-local --all --scope user --agent claude-code -f

# インストール済みスキル一覧
gh skill list

# リモート更新を取り込む
gh skill update --all
```

### install.sh によるホーム配下への反映

- `bash scripts/install.sh` で、`config/` 内の管理対象をホーム配下へ symlink で反映する。
- 各エージェントがユーザースコープでそのまま利用できる状態を作る。
- スキルは `install.sh` の対象外。`gh skill install` で別途反映する。

#### symlink を張る対象

正本は `config/` 配下。ホーム側は各ツールの標準パス。

| ツール | 正本（リポジトリ） | ホーム（symlink 先） |
| --- | --- | --- |
| Cursor | `config/.cursor/mcp.json`<br>`config/.cursor/hooks.json`<br>`config/.cursor/rules`<br>`config/.cursor/agents`<br>`config/.cursor/scripts`<br>`config/.cursor/hooks` | `~/.cursor/...` |
| Claude Code | `config/CLAUDE.md`<br>`config/.claude/settings.json`<br>`config/.claude/rules`<br>`config/.claude/agents`<br>`config/.claude/scripts` | `~/.claude/...` |
| Codex | `config/AGENTS.md`<br>`config/.codex/agents` | `~/.codex/...` |
| TAKT | `config/.takt/config.yaml`<br>`config/.takt/workflows`<br>`config/.takt/facets` | `~/.takt/...` |
| User Tools | `config/.docs` | `~/.docs` |
| App Config | `config/.env` | `~/.config/ai-manifest/.env` |

#### backup の扱い

- 既存の `~/.cursor` などがある場合は、`scripts/backup/<timestamp>/` に退避してから張り替える。
- 反映前にローカル変更の退避が必要か確認する。

### install.sh だけでは反映できない設定

- 一部の設定値は symlink 管理に向かない。
- `install.sh` だけではホーム側へ反映されない設定がある。
- それらは手動コピペで取り込む。

#### 手動コピペが必要な設定

- `install.sh` 実行後も、ホーム側の実ファイルに反映されているとは限らない。
- ツール自身が更新する設定や、ローカル差分を持たせたい設定は手動運用する。

#### Cursor CLI permissions

- `config/.cursor/cli-config.permissions.json` を `~/.cursor/cli-config.json` へコピーして反映する。
- `~/.cursor/cli-config.json` は symlink 管理せず、コピペ運用とする。

#### Claude Code mcpServers

- `config/.claude/.claude.mcp.json` を `~/.claude.json` へコピーして反映する。
- `~/.claude.json` は Claude Code が直接更新するため、symlink 管理しない。
- `mcpServers.*.command` には絶対パスを使う。`~` や `$HOME` は使わない。

## 開発手順

### 変更前の確認

- 変更対象が `config/.rulesync/` 配下か、`skills/` 配下か、手動運用の実ファイルかを確認する。
- 生成先ファイルを直接編集しようとしていないか確認する。
- 必要なら現行差分を確認して、意図しない変更が混ざっていないことを確かめる。

### 変更の実施

- ルール・サブエージェントを変える場合は `config/.rulesync/` を編集する。
- スキルを変える場合は `skills/` を編集する。
- `permissions` や `mcpServers` など自動反映できない設定だけ、`config/` 内の対応ファイルを更新する。

### 生成と差分確認

```bash
cd config
rulesync generate
git diff -- README.md config/
```

- 生成先との差分が意図どおりか確認する。
- 不整合がある場合は、生成先を見直す前に `config/.rulesync/` 側の記述を確認する。

### ホーム配下への反映

```bash
bash scripts/install.sh
gh skill install . --from-local --all --scope user --agent claude-code -f
```

- ルール・サブエージェントの symlink を更新したい場合は `install.sh` を実行する。
- スキルを更新した場合は `gh skill install` を実行する。
- 実行後に `~/.cursor` や `~/.claude` のリンク先が `config/` 配下を指しているか、`gh skill list` を確認する。

### トラブル時の復旧

- 生成結果がおかしい場合は、`config/` で `rulesync generate` を再実行する。
- ホーム反映で問題が起きた場合は `scripts/backup/<timestamp>/` を確認する。
- 手動反映設定が効かない場合は、コピー先ファイルと絶対パス指定を見直す。
- スキルが反映されない場合は `gh skill list` でインストール先とエージェント指定を確認する。
