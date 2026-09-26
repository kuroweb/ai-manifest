# Skills 運用

- 正本は `skills/`。スキルの追加・変更はここだけ編集する。
- 形式は `skills/<name>/SKILL.md`（[Agent Skills specification](https://agentskills.io/specification)）。

## 初回反映

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

- インストール先は `--agent` ごとに決まる。`codex` は共有ディレクトリ `~/.agents/skills`（`cline` / `universal` / `warp` と共用）で、`~/.codex/skills` ではない。

  | agent | user scope のインストール先 |
  | --- | --- |
  | `cursor` | `~/.cursor/skills` |
  | `claude-code` | `~/.claude/skills` |
  | `codex` | `~/.agents/skills` |

## スキル更新

- リモートの更新をインストール済みスキルへ反映する。

  ```bash
  gh skill update --dir ~/.cursor/skills
  gh skill update --dir ~/.claude/skills
  gh skill update --dir ~/.agents/skills
  ```

## スキル編集

- 新規作成・既存スキルの改善は `skills/<name>/` を編集する。
- 反映前にインストール先を削除する（`gh skill install` は削除済みファイルを残すことがあるため）。

  ```bash
  rm -rf ~/.cursor/skills/<name>
  gh skill install . <name> --from-local --scope user --agent cursor --force

  rm -rf ~/.claude/skills/<name>
  gh skill install . <name> --from-local --scope user --agent claude-code --force

  rm -rf ~/.agents/skills/<name>
  gh skill install . <name> --from-local --scope user --agent codex --force
  ```

## スキル編集の注意

- `~/.claude/skills` 等のホーム配下スキルを直接編集しない。変更は `skills/` を編集し、上記の手順で反映する。
- 生成物やインストール先を正本として扱わない。
