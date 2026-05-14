---
paths:
  - .rulesync/**
  - .claude/**
  - .cursor/**
  - .codex/**
  - .gemini/**
  - AGENTS.md
  - CLAUDE.md
  - GEMINI.md
---
# Rulesync Source of Truth

- `.rulesync/` が存在する場合は、`.rulesync/` を正本として扱う。
- ルール・スキル・サブエージェントを変更するときは `.rulesync/` のみ編集する。
- `rulesync generate` の出力物（`AGENTS.md` / `CLAUDE.md` / `GEMINI.md`、各エージェント向け rules・memories など）は直接編集しない。
- 内容を変更するときは `.rulesync/` を修正してから `rulesync generate` を実行する。
- `.rulesync/` と生成物が矛盾する場合は `.rulesync/` を正とする。
