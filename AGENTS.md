Please also reference the following rules as needed. The list below is provided in TOON format, and `@` stands for the project root directory.

rules[5]:
  - path: @.codex/memories/answer-style.md
    description: 回答は前置きを省き、結論ファーストで率直に伝える
    applyTo[1]: **/*
  - path: @.codex/memories/avoiding-ambiguous-suffixes.md
    description: 曖昧なサフィックスを避ける：型・モジュール命名で責務と境界を明確にする
    applyTo[1]: **/*
  - path: @.codex/memories/explain-skill-selection.md
    description: スキル呼び出し前に選択スキルと理由を明示するルール
    applyTo[1]: **/*
  - path: @.codex/memories/learning-before-coding.md
    description: コーディング前の学習：新しいコードを書く前に既存実装を分析する
    applyTo[1]: **/*
  - path: @.codex/memories/less-is-more.md
    description: "Less Is More: 過剰設計を避け、シンプルで保守しやすいコードを書く"
    applyTo[1]: **/*

# Overview

## rulesync（正本と生成物）

- このリポジトリでは `.rulesync/` を正本として扱う。
- ルール・スキル・サブエージェントを変更するときは `.rulesync/` のみ編集する。
- `rulesync generate` の出力物（`AGENTS.md` / `CLAUDE.md` / `GEMINI.md`、各エージェント向け rules・memories など）は直接編集しない。
- 内容を変更するときは `.rulesync/` を修正してから `rulesync generate` を実行する。
- `.rulesync/` と生成物が矛盾する場合は `.rulesync/` を正とする。
