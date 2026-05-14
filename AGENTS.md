Please also reference the following rules as needed. The list below is provided in TOON format, and `@` stands for the project root directory.

rules[5]:
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
  - path: @.codex/memories/rulesync-source-of-truth.md
    description: .rulesync があるリポジトリで .rulesync を正本として扱う
    applyTo[8]: .rulesync/**,.claude/**,.cursor/**,.codex/**,.gemini/**,AGENTS.md,CLAUDE.md,GEMINI.md

# Global Policy

## 回答スタイル

- 挨拶・前置き・段階報告・絵文字禁止。結論ファースト
- 指摘すべきことは率直に指摘

## コード説明のルール

### 指摘対応時

指摘内容の説明と妥当性の評価を行い、変更前の問題点・変更内容・変更後のコードの意図と内容を説明する。

### コード変更時

変更前と変更後で何が変わるのか、それぞれのコードの意図と内容を説明する。

### 新規コード作成時

コードがない状態とある状態で何が変わるのか（何の問題を解決するか）、コードの意図と内容を説明する。
