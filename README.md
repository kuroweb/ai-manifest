# ai-manifest

Cursor / Claude Code / Codex 向けのルール・サブエージェント・スキルを一元管理するリポジトリ。

- エージェント設定の正本は `config/`。`config/.rulesync/` から生成し、`scripts/install.sh` でホーム配下へ symlink 反映する。
- スキルの正本は `skills/`。`gh skill install` で各エージェントへコピーする。

## リポジトリ構成

```
ai-manifest/
├── README.md
├── scripts/install.sh   # config/ → ホーム配下への symlink 反映
├── skills/              # スキル正本
└── config/              # エージェント設定正本
    ├── .rulesync/       # ルール・サブエージェント正本（Single Source of Truth）
    ├── .cursor/
    ├── .claude/
    ├── .codex/
    ├── .docs/           # issue / handover / learn など運用データ
    ├── .takt/
    ├── .env             # ローカル用（git 管理外）
    ├── rulesync.jsonc
    ├── CLAUDE.md        # rulesync 生成物
    └── AGENTS.md        # rulesync 生成物
```

| パス | 役割 |
| --- | --- |
| `config/.rulesync/` | ルール・サブエージェントの正本。ここだけ編集する |
| `config/.cursor/` など | `rulesync generate` の生成先。直接編集しない |
| `skills/` | スキルの正本 |
| `scripts/install.sh` | `config/` を `~/.cursor` などへ symlink する |

`install.sh` 実行後、`~/.docs` は `config/.docs` を指す。issue や handover の実行時パスは `~/.docs/...` で記述する。

## クイックスタート

### 1. 依存パッケージをインストール

```bash
brew install rulesync gh
```

### 2. リポジトリをクローン

```bash
git clone <repository-url>
cd ai-manifest
```

### 3. ルール・サブエージェント生成

```bash
cd config
rulesync generate
```

### 4. ローカル用ファイル

```bash
cp -n config/.env.example config/.env
cp -n config/.cursor/mcp.json.example config/.cursor/mcp.json
cp -n config/.cursor/hooks.json.example config/.cursor/hooks.json
```

### 5. スキルインストール

利用するエージェントごとに `--scope user` で実行する。

```bash
gh skill install . --from-local --all --scope user --agent cursor
gh skill install . --from-local --all --scope user --agent claude-code
gh skill install . --from-local --all --scope user --agent codex
```

リモートから取得する場合:

```bash
gh skill install kuroweb/ai-manifest --all --scope user --agent claude-code
```

### 6. ホーム配下へ反映

```bash
bash scripts/install.sh
```

- 既存の `~/.cursor` などがある場合は、`scripts/backup/<timestamp>/` に退避してからリンクを張り替える。
- 手動コピペが必要な設定（permissions / mcpServers）は「install.sh だけでは反映できない設定」を参照。

### 7. 確認

```bash
ls -la ~/.cursor ~/.claude ~/.codex
ls -la ~/.config/ai-manifest/.env
gh skill list
```

## 仕様

### rulesync

- 正本: `config/.rulesync/`
- 実行場所: `config/`（`config/rulesync.jsonc` の `outputRoots` が `.`）
- 生成先は上書き前提。生成物を直接編集しない。

| 管理ファイル | Cursor | Claude Code | Codex |
| --- | --- | --- | --- |
| `config/.rulesync/rules/global-policy.md` | `config/.cursor/rules/global-policy.mdc` | `config/CLAUDE.md` | `config/AGENTS.md` |
| `config/.rulesync/rules/` | `config/.cursor/rules` | `config/.claude/rules` | `config/AGENTS.md`（ルール統合） |
| `config/.rulesync/subagents/` | `config/.cursor/agents` | `config/.claude/agents` | `config/.codex/agents` |

- 正本と生成先が矛盾する場合は `config/.rulesync/` を正とする。意図が不明な大量再生成は避ける。

### gh skill install

- 形式: `skills/*/SKILL.md`（[Agent Skills specification](https://agentskills.io/specification)）
- 反映方法: 各エージェントのスキルディレクトリへコピー（symlink ではない）
- 更新: `gh skill update --all` または `--from-local` で再インストール

```bash
gh skill install . --from-local --all --scope user --agent claude-code -f
gh skill list
gh skill update --all
```

### install.sh

- `bash scripts/install.sh` で `config/` 内の管理対象をホーム配下へ symlink する。スキルは対象外。

| ツール | 正本（リポジトリ） | ホーム（symlink 先） |
| --- | --- | --- |
| Cursor | `config/.cursor/mcp.json`, `hooks.json`, `rules`, `agents`, `scripts`, `hooks` | `~/.cursor/...` |
| Claude Code | `config/CLAUDE.md`, `config/.claude/settings.json`, `rules`, `agents`, `scripts` | `~/.claude/...` |
| Codex | `config/AGENTS.md`, `config/.codex/agents` | `~/.codex/...` |
| TAKT | `config/.takt/config.yaml`, `workflows`, `facets` | `~/.takt/...` |
| User Tools | `config/.docs` | `~/.docs` |
| App Config | `config/.env` | `~/.config/ai-manifest/.env` |

- 既存ファイルがある場合は `scripts/backup/<timestamp>/` に退避してから張り替える。

### install.sh だけでは反映できない設定

- symlink 管理に向かない設定は手動コピペで取り込む。

**Cursor CLI permissions:**

- `config/.cursor/cli-config.permissions.json` → `~/.cursor/cli-config.json`
- `~/.cursor/cli-config.json` は symlink 管理しない

**Claude Code mcpServers:**

- `config/.claude/.claude.mcp.json` → `~/.claude.json`
- `~/.claude.json` は Claude Code が直接更新するため symlink 管理しない
- `mcpServers.*.command` には絶対パスを使う（`~` や `$HOME` 不可）

## 運用

### 日次ワークフロー（issue）

| コマンド | 用途 |
| --- | --- |
| `/issue` | 新規・再開・着手の唯一の入口 |
| `/grill-me` | 検討フェーズ（`/issue` からも呼ぶ） |
| `/plan-export` | plan 成果物を `~/.docs/plans/` へ退避 |
| `/learn-daily` | セッションの失敗・手戻りを `~/.docs/learn/daily-term/` に記録 |
| `/learn-long` | `daily-term` をテーマ別に抽象化して `~/.docs/learn/long-term/` へ更新 |
| `/learn-promote` | `long-term` から rules / skill 昇格候補を `~/.docs/learn/promotions/` に出力 |
| `handover` | セッション境界の引き継ぎ |

### 設定変更

- 変更前に、対象が `config/.rulesync/`・`skills/`・手動運用ファイルのどれかを確認する。

  | 変更対象 | 手順 |
  | --- | --- |
  | ルール・サブエージェント | `config/.rulesync/` を編集 → `cd config && rulesync generate` |
  | スキル | `skills/` を編集 → `gh skill install . --from-local --all --scope user --agent <agent> -f` |
  | permissions / mcpServers | `config/` 内の対応ファイルを編集 → 手動コピペでホーム側へ反映 |
  | symlink 対象 | 上記生成後 → `bash scripts/install.sh` |

- 生成と差分確認

  ```bash
  cd config
  rulesync generate
  git diff -- README.md config/
  ```

- 反映後、`~/.cursor` や `~/.claude` のリンク先が `config/` 配下を指しているか、`gh skill list` で確認する。

### トラブル時

| 症状 | 対処 |
| --- | --- |
| 生成結果がおかしい | `config/` で `rulesync generate` を再実行。生成先ではなく `config/.rulesync/` を確認 |
| ホーム反映で問題 | `scripts/backup/<timestamp>/` を確認 |
| 手動反映が効かない | コピー先ファイルと絶対パス指定を見直す |
| スキルが反映されない | `gh skill list` でインストール先と `--agent` 指定を確認 |
