# AGENTS.md

## ファイルの役割

| ファイル | 役割 |
| --- | --- |
| ルート `AGENTS.md`（このファイル） | 本リポジトリ作業時の運用境界。手動管理 |
| ルート `CLAUDE.md` | `@AGENTS.md` を参照するエントリポイント |
| `config/AGENTS.md` | Codex 向けルールの rulesync 生成物。`~/.codex/AGENTS.md` へ symlink |

# Skills 運用

- 正本は `skills/`。スキルの追加・変更はここだけ編集する。
- 形式は `skills/<name>/SKILL.md`（[Agent Skills specification](https://agentskills.io/specification)）。
- ホーム配下（`~/.claude/skills` 等）へは `gh skill install --from-local --force` でコピーされる。symlink ではない。`install.sh` の対象外。

## 初回反映

- リポジトリをクローンしたあと、利用するエージェントごとにインストールする。

  ```bash
  gh skill install . --from-local --all --scope user --agent cursor --force
  gh skill install . --from-local --all --scope user --agent claude-code --force
  gh skill install . --from-local --all --scope user --agent codex --force
  ```

- 確認: `gh skill list`

## スキル改修

- 新規作成・既存スキルの改善は `skills/<name>/` を編集する。
- 進め方は `skill-creator` スキルに従う。
- 編集後は利用するエージェントごとにインストールする。

  ```bash
  gh skill install . --from-local --all --scope user --agent <cursor|claude-code|codex> --force
  ```

## 禁止

- `~/.claude/skills` 等のホーム配下スキルを直接編集しない。変更は `skills/` → `gh skill install --from-local --force` で反映する。
- 生成物やインストール先を正本として扱わない。

# Config 運用

- ルール・サブエージェントの正本は `config/.rulesync/`。変更はここだけ編集する。
- `config/.cursor/`、`config/.claude/`、`config/.codex/`、`config/AGENTS.md`、`config/CLAUDE.md` は `rulesync generate` の生成物。直接編集しない。

## 初回反映

- リポジトリをクローンしたあと、生成してからホーム配下へ symlink 反映する。

  ```bash
  cd config && rulesync generate
  bash scripts/install.sh
  ```

- permissions / mcpServers など symlink 管理外の設定は、`config/` 内の対応ファイルを編集し、README の手順どおり手動コピペでホームへ反映する。
- 確認: `ls -la ~/.cursor ~/.claude ~/.codex`

## エージェント設定改修

- ルール・サブエージェントの追加・変更は `config/.rulesync/` を編集する。
- 編集後は生成する。

  ```bash
  cd config && rulesync generate
  ```

- `config/` 配下に新しい管理対象パスを追加したときは `bash scripts/install.sh` を再実行する。

## 禁止

- 生成物（`config/AGENTS.md` 含む）を直接編集しない。内容を変える場合は `config/.rulesync/` を編集してから `rulesync generate` する。
- 正本と生成物が矛盾する場合、正本（`config/.rulesync/`）を優先する。
