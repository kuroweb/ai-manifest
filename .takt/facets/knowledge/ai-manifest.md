# ai-manifest リポジトリ知識

Cursor / Claude Code / Codex / Gemini CLI 向け設定を、リポジトリ内で一元管理する。正本は `.rulesync/` で、各ツール用ディレクトリは生成物か、対象外として別管理になる。

## 正本と生成物

| 区分 | パス | 説明 |
|------|------|------|
| 正本 | `.rulesync/rules/`, `.rulesync/skills/`, `.rulesync/subagents/` | ルール・スキル・サブエージェント定義。編集はここが前提。 |
| 生成物 | `.cursor/rules`, `.cursor/skills`, `.cursor/agents`, `.claude/rules`, `.claude/skills`, `.claude/agents`, `.codex/memories`, `.codex/skills`, `.codex/agents`, `.gemini/memories`, `.gemini/skills` | `rulesync generate` で上書きされる。内容を保ちたい場合は `.rulesync/` を直し、再生成する。 |
| TAKT 用 | `.takt/config.yaml`, `.takt/pieces/`, `.takt/facets/` | `config.yaml` に provider / model（`persona_providers`）と `provider_options`。ピース YAML はワークフロー定義。`bash scripts/install.sh` で `~/.takt/config.yaml` にもリンクされる。 |

## 変更時の手順

| 手順 | 内容 |
|------|------|
| 1 | `.rulesync/` 側を編集する。 |
| 2 | `rulesync generate` を実行する。 |
| 3 | ホームへ反映する場合は `bash scripts/install.sh` を実行する。 |

## 編集してよいもの・避けるもの

| パターン | 例 | 問題 |
|---------|-----|------|
| 正本のみ編集 | `.rulesync/skills/foo/SKILL.md` を変えてから generate | 意図どおり。 |
| 生成物を直接編集 | `.cursor/rules/*.mdc` だけ手で書き換え | 次回 `rulesync generate` で失われる。 |
| 対象外ファイル | `.cursor/mcp.json`, `.cursor/hooks.json`, `.claude/settings.json` など | rulesync のマッピング外。リポジトリ内の該当ファイルを直接編集する運用。 |

## rulesync の対応関係（要点）

| 正本 | 主な出力先 |
|------|------------|
| `.rulesync/rules/` | `.cursor/rules`, `.claude/rules`, `.codex/memories`, `.gemini/memories` |
| `.rulesync/skills/` | 各ツールの `skills/` |
| `.rulesync/subagents/` | `.cursor/agents`, `.claude/agents`, `.codex/agents` |

## 検証のヒント

1. 変更対象が `.rulesync/` 由来か、`README.md` の「対象外」かを先に分ける。
2. スキル・ルールの追従なら `.rulesync/` を正とし、`rulesync generate` 後に差分を確認する。
