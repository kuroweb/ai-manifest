---
name: learn-short
description: '`~/.docs/learn/daily-term/` の未レビュー原本を重複テーマごとに整理し、`~/.docs/learn/short-term/` に short-term ファイルを作る。 `learn-short` を明示したとき、または「short-term に整理して」「daily-term をまとめて」「重複テーマを整理して」のように short-term への整理を求められたときは使う。'
---
# Learn Short

`learn-short` は、`~/.docs/learn/daily-term/` の未レビュー原本を読み、テーマごとに `~/.docs/learn/short-term/<theme-slug>.md` を作る。

## 保存先

- 入力元: `~/.docs/learn/daily-term/`
- 出力先: `~/.docs/learn/short-term/`
- archive: `~/.docs/learn/daily-term/archive/`
- テンプレート SoT: `~/.docs/learn/templates/short-term.md`

## 入力条件

- 未レビュー原本だけを対象にする。
- 未レビュー判定は `daily-term/archive/` に移動していないことを基準にする。
- review 済みの原本は入力に含めない。

## 基本ルール

1. `daily-term` 原本を読み、重複テーマを特定する。
2. テーマごとに `short-term/<theme-slug>.md` を作る。
3. 既存の `<theme-slug>.md` がある場合は、必ず読んでから追記・更新する。
4. テーマごと 1 ファイルの原則を崩さない。
5. review が完了した `daily-term` 原本は `daily-term/archive/` へ移す。

## short-term に持たせる内容

各テーマファイルには、少なくとも次を含める。

- `テーマ`
- `要約`
- `対象 daily-term 一覧`
- `繰り返しパターン`
- `long-term 候補理由`

## テンプレート参照

完全テンプレートは `~/.docs/learn/templates/short-term.md` を参照する。
`SKILL.md` にテンプレート全文を重複保持しない。

## 実行手順

1. `~/.docs/learn/daily-term/` 配下の未レビュー原本を列挙する。
2. 各ファイルの incident を読み、重複テーマをまとめる。
3. テーマごとに `short-term/<theme-slug>.md` の新規作成または更新を行う。
4. 更新後、処理対象にした `daily-term` 原本を `daily-term/archive/` へ移す。
5. 移動前に内容を失っていないか確認する。

## 非責務

- `daily-term` 原本の生成
- `long-term` への抽象化
- `rules` / `skill` への昇格判断

これらはそれぞれ `learn-daily` `learn-long` `learn-promote` の責務。
