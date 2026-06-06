---
name: learn-long
description: '`~/.docs/learn/short-term/` のテーマ整理結果を読み、再利用可能な長期知見として `~/.docs/learn/long-term/` に抽象化する。 `learn-long` を明示したとき、または「long-term に上げて」「抽象化した学びにして」「short-term から長期知見にして」のように long-term への昇格を求められたときは使う。'
---
# Learn Long

`learn-long` は、`~/.docs/learn/short-term/` のテーマ整理結果を読み、テーマごとに `~/.docs/learn/long-term/<theme-slug>.md` を作る。

## 保存先

- 入力元: `~/.docs/learn/short-term/`
- 出力先: `~/.docs/learn/long-term/`
- テンプレート SoT: `~/.docs/learn/templates/learn-long.md`

## 入力条件

- 入力元は `short-term` だけに限定する。
- `daily-term` を直接読んで long-term を作らない。
- テーマ単位で `short-term/<theme-slug>.md` を読む。

## 基本ルール

1. 対象の `short-term/<theme-slug>.md` を読む。
2. 同じ slug の `long-term/<theme-slug>.md` があれば、必ず読んでから更新する。
3. テーマごと 1 ファイルの原則を崩さない。
4. `short-term` の具体的な事象列を、そのまま写経せず再利用可能な知見へ抽象化する。
5. `learn-promote` が判断できるよう、昇格候補の見立てまで持たせる。

## long-term に持たせる内容

各テーマファイルには、少なくとも次を含める。

- `テーマ`
- `抽象化した学び`
- `根拠となる short-term`
- `適用条件`
- `昇格候補（rules/skill）`

## テンプレート参照

完全テンプレートは `~/.docs/learn/templates/learn-long.md` を参照する。
`SKILL.md` にテンプレート全文を重複保持しない。

## 実行手順

1. 対象テーマの `short-term/<theme-slug>.md` を読む。
2. 繰り返しパターンと long-term 候補理由を確認する。
3. 複数セッション・複数エージェントでも再利用できる粒度まで学びを抽象化する。
4. `long-term/<theme-slug>.md` を新規作成または更新する。
5. `rules` / `skill` の候補有無と、その判断理由を記録する。

## 非責務

- `daily-term` の生成
- `short-term` のテーマ整理
- `rules` / `skill` への最終昇格判断

これらはそれぞれ `learn-daily` `learn-short` `learn-promote` の責務。
