# AGENTS.md

## Skills 運用

- 正本は `skills/`。スキルの追加・変更はここだけ編集する。
- 運用手順は `docs/skills-guideline.md` を読む。

## エージェント設定運用

- rules / subagents は `config/.rulesync/`、それ以外は `config/` を直接編集する。
- 運用手順は `docs/agent-config-guideline.md` を読む。

## Cursor Cloud specific instructions

- `rulesync` はインストール済み。生成は `cd config && rulesync generate`。
- `scripts/install.sh` はホーム配下のエージェント設定をこのリポジトリへ張り替える。Cloud Agent では実行しない。
