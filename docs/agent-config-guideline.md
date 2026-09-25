# エージェント設定運用

- rules / subagents の正本は `config/.rulesync/`。変更はここだけ編集する。
- それ以外は `config/` 内の該当ファイルを直接編集する。
- `rulesync generate` で各エージェント向けに生成し、`scripts/install.sh` でホームへ symlink 反映する。

## config/ の構成

凡例: `→` は `install.sh` の symlink、`手動 →` は手動コピペ、`generate` は `rulesync generate` の成果物。

```
config/
├── .rulesync/                         # rules / subagents 正本
├── .cursor/
│   ├── agents/                        # generate → ~/.cursor/agents/
│   ├── rules/                         # generate → ~/.cursor/rules/
│   ├── scripts/                       # → ~/.cursor/scripts/
│   ├── hooks/                         # → ~/.cursor/hooks/
│   ├── mcp.json                       # → ~/.cursor/mcp.json
│   ├── hooks.json                     # → ~/.cursor/hooks.json
│   └── cli-config.json                # 手動 → ~/.cursor/cli-config.json
├── .claude/
│   ├── agents/                        # generate → ~/.claude/agents/
│   ├── rules/                         # generate → ~/.claude/rules/
│   ├── scripts/                       # → ~/.claude/scripts/
│   ├── settings.json                  # → ~/.claude/settings.json
│   └── .claude.mcp.json               # 手動 → ~/.claude.json
├── .codex/
│   ├── agents/                        # generate → ~/.codex/agents/
│   └── config.toml                    # 手動 → ~/.codex/config.toml
├── .takt/
│   ├── config.yaml                    # → ~/.takt/config.yaml
│   ├── workflows/                     # → ~/.takt/workflows/
│   └── facets/                        # → ~/.takt/facets/
├── .docs/                             # → ~/.docs
├── .env                               # → ~/.config/ai-manifest/.env
├── CLAUDE.md                          # generate → ~/.claude/CLAUDE.md
├── AGENTS.md                          # generate → ~/.codex/AGENTS.md
└── rulesync.jsonc
```

## rules / subagents

### 正本の編集

- 変更は `config/.rulesync/` のみ。生成物は触らない。

### 生成とホーム反映

- 編集後に生成する。初回や新規パス追加時だけ `install.sh` で symlink を張る。

  ```bash
  (cd config && rulesync generate)
  bash scripts/install.sh
  ```

- 既存の symlink がある場合、生成だけでホーム側に反映される。

### 生成物を正本にしない

- 直接編集しない。gitignore 済み。
  - `config/.cursor/rules`、`config/.cursor/agents`
  - `config/.claude/rules`、`config/.claude/agents`
  - `config/.codex/agents`
  - `config/AGENTS.md`、`config/CLAUDE.md`
- 正本と矛盾する場合、正本（`config/.rulesync/`）を優先する。

## rules / subagents 以外

- rulesync 対象外。`config/` 内の該当ファイルを直接編集する。
- symlink 対象は内容変更が即反映。手動コピペ対象だけ別途コピーする。

### 対象ファイルの編集

- `config/` 内を直接編集する。
  - 直接編集 + symlink: `settings.json`、`scripts/`、`hooks/`、`mcp.json`、`hooks.json`、`.takt/`、`.docs/`、`.env` など
  - 手動コピペ: `cli-config.json`、`.claude.mcp.json`、`config.toml`

### symlink での反映

- 初回、または新しい管理対象パス追加時は symlink を張る。

  ```bash
  bash scripts/install.sh
  ```

- ホーム側のエントリが `config/` 配下を指していることを確認する。

  ```bash
  ls -la ~/.cursor/agents ~/.cursor/rules ~/.claude/agents ~/.claude/rules ~/.codex/agents
  ls -la ~/.cursor/mcp.json ~/.claude/settings.json ~/.config/ai-manifest/.env
  ```

### 手動コピペでの反映

ツール側が書き換えるファイルは symlink せず、必要なときだけコピーする。

- `config/.cursor/cli-config.json` → `~/.cursor/cli-config.json`
- `config/.claude/.claude.mcp.json` → `~/.claude.json`
- `config/.codex/config.toml` → `~/.codex/config.toml`
- `mcpServers.*.command` には絶対パスを使う（`~` や `$HOME` 不可）

## install.sh のバックアップ仕様

- すでに正しいリンクならスキップする。
- 既存がありリンク先が違うときは、自動的に `scripts/backup/<timestamp>/` へ退避してから張り替える。
