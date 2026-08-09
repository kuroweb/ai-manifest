# ai-manifest

Cursor / Claude Code / Codex 向けのエージェント設定・スキルを一元管理するリポジトリ。

- エージェント設定の正本は `config/`。`config/.rulesync/` から生成し、`scripts/install.sh` でホーム配下へ symlink 反映する。
- スキルの正本は `skills/`。`gh skill install` で各エージェントへコピーする。

## リポジトリ構成

```
ai-manifest/
├── README.md
├── AGENTS.md            # 本リポジトリ作業時の運用境界。手動管理
├── CLAUDE.md            # @AGENTS.md を参照するエントリポイント
├── scripts/install.sh   # config/ → ホーム配下への symlink 反映
├── skills/              # スキル正本
└── config/
    ├── .rulesync/       # エージェント設定正本
    ├── .cursor/         # rulesync generate の成果物
    ├── .claude/         # rulesync generate の成果物
    ├── .codex/          # rulesync generate の成果物
    ├── .docs/           # 運用データ
    ├── .takt/           # taktのグローバル設定
    ├── .env             # MCPなどのシークレットを記述する
    ├── rulesync.jsonc
    ├── CLAUDE.md        # rulesync generate の成果物
    └── AGENTS.md        # rulesync generate の成果物
```

## クイックスタート

1. **依存パッケージをインストール**

   ```bash
   brew install rulesync gh
   ```

2. **リポジトリをクローン**

   ```bash
   git clone <repository-url>
   cd ai-manifest
   ```

3. **エージェント設定生成**

   ```bash
   cd config
   rulesync generate
   ```

4. **ローカル用ファイル**

   ```bash
   cp -n config/.env.example config/.env
   cp -n config/.cursor/mcp.json.example config/.cursor/mcp.json
   cp -n config/.cursor/hooks.json.example config/.cursor/hooks.json
   ```

5. **スキルインストール**

   利用するエージェントごとにリモートから `--scope user` で実行する。

   ```bash
   gh skill install kuroweb/ai-manifest --all --scope user --agent cursor
   gh skill install kuroweb/ai-manifest --all --scope user --agent claude-code
   gh skill install kuroweb/ai-manifest --all --scope user --agent codex
   ```

6. **ホーム配下に各種エージェント設定を反映**

   ```bash
   bash scripts/install.sh
   ```

7. **手動コピペが必要な設定を反映**

   permissions / mcpServers は [手動で取り込む設定（permissions / mcpServers）](#手動で取り込む設定permissions--mcpservers) を参照。

8. **確認**

   ```bash
   ls -la ~/.cursor ~/.claude ~/.codex
   ls -la ~/.config/ai-manifest/.env
   gh skill list
   ```

## rulesyncでエージェント設定を管理する

- 正本: `config/.rulesync/`
- 実行場所: `config/`（`config/rulesync.jsonc` の `outputRoots` が `.`）
- 生成先は上書き前提。生成物を直接編集しない。

| 管理ファイル | Cursor | Claude Code | Codex |
| --- | --- | --- | --- |
| `config/.rulesync/rules/global-policy.md` | `config/.cursor/rules/global-policy.mdc` | `config/CLAUDE.md` | `config/AGENTS.md` |
| `config/.rulesync/rules/` | `config/.cursor/rules` | `config/.claude/rules` | `config/AGENTS.md`（ルール統合） |
| `config/.rulesync/subagents/` | `config/.cursor/agents` | `config/.claude/agents` | `config/.codex/agents` |

- 正本と生成先が矛盾する場合は `config/.rulesync/` を正とする。意図が不明な大量再生成は避ける。

### ホーム配下へ設定を反映する

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

### 手動で取り込む設定（permissions / mcpServers）

- symlink 管理に向かない設定は手動コピペで取り込む。

#### Cursor CLI permissions

- `config/.cursor/cli-config.permissions.json` → `~/.cursor/cli-config.json`
- `~/.cursor/cli-config.json` は symlink 管理しない

#### Claude Code mcpServers

- `config/.claude/.claude.mcp.json` → `~/.claude.json`
- `~/.claude.json` は Claude Code が直接更新するため symlink 管理しない
- `mcpServers.*.command` には絶対パスを使う（`~` や `$HOME` 不可）

## gh skill でスキルを各エージェントへ配布する

- 形式: `skills/*/SKILL.md`（[Agent Skills specification](https://agentskills.io/specification)）
- 反映方法: GitHub リポジトリから各エージェントのスキルディレクトリへコピー

### リモートからインストールする

```bash
gh skill install kuroweb/ai-manifest --all --scope user --agent cursor -f
gh skill install kuroweb/ai-manifest --all --scope user --agent claude-code -f
gh skill install kuroweb/ai-manifest --all --scope user --agent codex -f
gh skill list
```

### インストール済みスキルを更新する

```bash
gh skill update --all
```

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
  | エージェント設定 | `config/.rulesync/` を編集 → `cd config && rulesync generate` |
  | スキル | `skills/` を編集 → push → `gh skill install kuroweb/ai-manifest --all --scope user --agent <agent> -f` |
  | permissions / mcpServers | `config/` 内の対応ファイルを編集 → 手動コピペでホーム側へ反映 |

- `bash scripts/install.sh` の再実行が必要なのは初回セットアップ時、または `config/` 配下に新しい管理対象パスを追加したときのみ。既存の symlink はファイル内容の変更を自動的に反映するため、ルール編集のたびに実行する必要はない。

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
