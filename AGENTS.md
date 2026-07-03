# AGENTS.md

本リポジトリで扱うファイルの役割。

| ファイル | 役割 |
| --- | --- |
| ルート `AGENTS.md`（このファイル） | 本リポジトリ作業時の運用境界。手動管理 |
| ルート `CLAUDE.md` | `@AGENTS.md` を参照するエントリポイント |
| `config/AGENTS.md` | Codex 向けルールの rulesync 生成物。`~/.codex/AGENTS.md` へ symlink |

# skills運用

- 正本は `skills/`。スキルの追加・変更はここだけ編集する。
- 形式は `skills/<name>/SKILL.md`（[Agent Skills specification](https://agentskills.io/specification)）。
- ホーム配下（`~/.claude/skills` 等）へは `gh skill install` でコピーされる。symlink ではない。`install.sh` の対象外。

## 開発

- `skills/` を編集したら、以下で project スコープに配置して試す。

  ```bash
  gh skill install . --from-local --all --scope project --agent <cursor|claude-code|codex>
  ```

- 新規作成や改善の進め方は `skill-creator` スキルに従う。

## 反映

- `skills/` を commit / push したあと、リモートから user スコープへインストールする。

  ```bash
  gh skill install kuroweb/ai-manifest --all --scope user --agent <cursor|claude-code|codex>
  ```

- 更新: `gh skill update --all --force`

## 禁止

- `~/.claude/skills` 等のホーム配下スキルを直接編集しない。変更は `skills/` → commit / push → `gh skill install` または `gh skill update` で反映する。
- 生成物やインストール先を正本として扱わない。

# config運用

- ルール・サブエージェントの正本は `config/.rulesync/`。変更はここだけ編集する。
- `config/.cursor/`、`config/.claude/`、`config/.codex/`、`config/AGENTS.md`、`config/CLAUDE.md` は `rulesync generate` の生成物。直接編集しない。

## 開発

- `config/.rulesync/` を編集したら生成する。

  ```bash
  cd config && rulesync generate
  ```

## 反映

- ホーム配下への symlink 反映:

  ```bash
  bash scripts/install.sh
  ```

- permissions / mcpServers など symlink 管理外の設定は、`config/` 内の対応ファイルを編集し、README の手順どおり手動コピペでホームへ反映する。

## 禁止

- 生成物（`config/AGENTS.md` 含む）を直接編集しない。内容を変える場合は `config/.rulesync/` を編集してから `rulesync generate` する。
- 正本と生成物が矛盾する場合、正本（`config/.rulesync/`）を優先する。
