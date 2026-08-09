# AGENTS.md

## Skills 運用

- 正本は `skills/`。スキルの追加・変更はここだけ編集する。
- 形式は `skills/<name>/SKILL.md`（[Agent Skills specification](https://agentskills.io/specification)）。

### 初回反映

- 利用するエージェントごとにリモートからインストールする。

  ```bash
  gh skill install kuroweb/ai-manifest --all --scope user --agent cursor --force
  gh skill install kuroweb/ai-manifest --all --scope user --agent claude-code --force
  gh skill install kuroweb/ai-manifest --all --scope user --agent codex --force
  ```

- 各スキルが `cursor` / `claude-code` / `codex` の user scope に入っていることを確認する。

  ```bash
  gh skill list --scope user
  ```

### スキル更新

- リモートの更新をインストール済みスキルへ反映する。

  ```bash
  gh skill update --dir ~/.cursor/skills
  gh skill update --dir ~/.claude/skills
  gh skill update --dir ~/.codex/skills
  ```

### スキル編集

- 新規作成・既存スキルの改善は `skills/<name>/` を編集する。
- 反映前にインストール先を削除する（`gh skill install` は削除済みファイルを残すことがあるため）。

  ```bash
  rm -rf ~/.cursor/skills/<name>
  gh skill install . <name> --from-local --scope user --agent cursor --force

  rm -rf ~/.claude/skills/<name>
  gh skill install . <name> --from-local --scope user --agent claude-code --force

  rm -rf ~/.codex/skills/<name>
  gh skill install . <name> --from-local --scope user --agent codex --force
  ```

### スキル編集の注意

- `~/.claude/skills` 等のホーム配下スキルを直接編集しない。変更は `skills/` を編集し、上記の手順で反映する。
- 生成物やインストール先を正本として扱わない。

## エージェント設定運用（rules / subagents）

- 正本は `config/.rulesync/`。rules / subagents の変更はここだけ編集する。
- `rulesync generate` で各エージェント向けに生成し、symlink 経由でホームへ届く。

### 正本の編集

- 変更は `config/.rulesync/` のみ。生成物は触らない。

### 生成とホーム反映

- 編集後に生成する。初回や新規パス追加時だけ `install.sh` で symlink を張る。

  ```bash
  cd config && rulesync generate
  bash scripts/install.sh
  ```

- 既存の symlink がある場合、生成だけでホーム側に反映される。
- 生成物は直接編集しない。gitignore 済み。
  - `config/.cursor/rules`、`config/.cursor/agents`
  - `config/.claude/rules`、`config/.claude/agents`
  - `config/.codex/agents`
  - `config/AGENTS.md`、`config/CLAUDE.md`
- 正本と生成物が矛盾する場合、正本（`config/.rulesync/`）を優先する。

## エージェント設定運用（rules / subagents以外）

- rulesync 対象外。`config/` 内の該当ファイルを直接編集する。
- symlink 対象は内容変更が即反映。permissions / mcpServers だけ手動コピペ。

### 対象ファイルの編集

- `config/` 内を直接編集する。
  - 直接編集 + symlink: `.cursorignore`、`.claude/settings.json`、`scripts/`、`mcp.json` / `hooks.json` など
  - 手動コピペ: permissions / mcpServers（README 参照）

### symlink / 手動コピペでの反映

- 初回、または新しい管理対象パス追加時は symlink を張る。

  ```bash
  bash scripts/install.sh
  ```

- permissions / mcpServers は README の手順どおり手動コピペでホームへ反映する。
- `~/.cursor` / `~/.claude` / `~/.codex` が `config/` 配下への symlink になっていることを確認する。

  ```bash
  ls -la ~/.cursor ~/.claude ~/.codex
  ```
