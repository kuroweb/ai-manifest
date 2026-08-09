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

### スキル改修

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

### 禁止事項

- `~/.claude/skills` 等のホーム配下スキルを直接編集しない。変更は `skills/` を編集し、上記の手順で反映する。
- 生成物やインストール先を正本として扱わない。

## エージェント設定運用

- エージェント設定の正本は `config/.rulesync/`。変更はここだけ編集する。
- `config/.cursor/`、`config/.claude/`、`config/.codex/`、`config/AGENTS.md`、`config/CLAUDE.md` は `rulesync generate` の生成物。直接編集しない。

### 初回反映

- リポジトリをクローンしたあと、生成してからホーム配下へ symlink 反映する。

  ```bash
  cd config && rulesync generate
  bash scripts/install.sh
  ```

- permissions / mcpServers など symlink 管理外の設定は、`config/` 内の対応ファイルを編集し、README の手順どおり手動コピペでホームへ反映する。
- `~/.cursor` / `~/.claude` / `~/.codex` が `config/` 配下への symlink になっていることを確認する。

  ```bash
  ls -la ~/.cursor ~/.claude ~/.codex
  ```

### エージェント設定改修

- エージェント設定の追加・変更は `config/.rulesync/` を編集する。
- 編集後は生成する。

  ```bash
  cd config && rulesync generate
  ```

- `config/` 配下に新しい管理対象パスを追加したときは `bash scripts/install.sh` を再実行する。

### 禁止事項

- 生成物（`config/AGENTS.md` 含む）を直接編集しない。内容を変える場合は `config/.rulesync/` を編集してから `rulesync generate` する。
- 正本と生成物が矛盾する場合、正本（`config/.rulesync/`）を優先する。
