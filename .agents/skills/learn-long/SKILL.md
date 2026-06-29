---
name: learn-long
description: >
  `~/.docs/learn/daily-term/` の未処理原本を読み、テーマごとの長期知見として `~/.docs/learn/long-term/`
  に更新する。

  `learn-long` を明示したとき、または「long-term に上げて」「抽象化した学びにして」「daily-term から長期知見にして」のように
  long-term への昇格を求められたときは使う。
---
# Learn Long

`learn-long` は、`~/.docs/learn/daily-term/` の未処理原本を読み、テーマごとに `~/.docs/learn/long-term/<theme-slug>.md` を新規作成または更新する。

## 保存先

- 入力元: `~/.docs/learn/daily-term/`
- 出力先: `~/.docs/learn/long-term/`
- archive: `~/.docs/learn/daily-term/archive/`
- テンプレート SoT: `assets/long-term.md`

## 入力条件

- 未処理の `daily-term` 全件を入力にする。
- 未処理判定は `daily-term/archive/` に移動していないことを基準にする。
- 同じテーマに新しい `daily-term` が紐づいた場合は、既存 `long-term` を更新する。

## 基本ルール

1. 未処理の `daily-term` 原本を読み、重複テーマを特定する。
2. 同じ slug の `long-term/<theme-slug>.md` があれば、必ず読んでから更新する。
3. テーマごと 1 ファイルの原則を崩さない。
4. `daily-term` の具体的な事象列を、そのまま写経せず再利用可能な知見へ抽象化する。
5. 同じテーマに新しい `daily-term` が紐づいたときは `pain_count` を増やし、`pain_log` に再発内容を追記する。
6. `learn-promote` が判断できるよう、昇格候補の見立てまで持たせる。
7. 処理済みの `daily-term` は `daily-term/archive/` へ移す。

## long-term に持たせる内容

各テーマファイルには、少なくとも次を含める。

- `theme`
- `created_at`
- `source_daily_term`
- `pain_count`
- `抽象化した学び`
- `根拠となる daily-term`
- `適用条件`
- `昇格候補（rules/skill）`
- `pain_log`

## テンプレート参照

完全テンプレートは `assets/long-term.md` を参照する。
`SKILL.md` にテンプレート全文を重複保持しない。

## 実行手順

1. `~/.docs/learn/daily-term/` 配下の未処理原本を列挙する。
2. 各原本からテーマを抽出し、対応する `long-term/<theme-slug>.md` を新規作成または更新する。
3. 複数セッション・複数エージェントでも再利用できる粒度まで学びを抽象化する。
4. 既存テーマに新しい原本が紐づいた場合は `pain_count` を増やし、`pain_log` に再発内容を追記する。
5. `rules` / `skill` の候補有無と、その判断理由を記録する。
6. 処理済みの `daily-term` 原本を `daily-term/archive/` へ移す。

## 非責務

- `daily-term` の生成
- `rules` / `skill` への最終昇格判断

これらはそれぞれ `learn-daily` `learn-promote` の責務。
