---
name: learn-promote
description: '`~/.docs/learn/long-term/` の長期知見から、`rules` または `skill` への昇格候補を `~/.docs/learn/promotions/` にレポート出力する。 `learn-promote` を明示したとき、または「rules 候補を出して」「skill 候補を出して」「昇格判断して」のように昇格判断を求められたときは使う。'
---
# Learn Promote

`learn-promote` は、`~/.docs/learn/long-term/` の長期知見を読み、`rules` または `skill` への昇格候補レポートを `~/.docs/learn/promotions/` に出力する。

## 保存先

- 入力元: `~/.docs/learn/long-term/`
- 出力先: `~/.docs/learn/promotions/`
- テンプレート SoT: `assets/promotions.md`

## 入力条件

- 入力元は `long-term` だけに限定する。
- テーマごとの `long-term/<theme-slug>.md` を読む。
- `pain_count >= 3` を満たしたテーマだけを昇格候補として扱う。

## 昇格基準

- `pain_count >= 3`

基準を満たさないものは `見送り` として扱う。

## 基本ルール

1. `long-term` の内容を読み、`rules` 候補と `skill` 候補を整理する。
2. 出力は Markdown レポートとし、正本ファイルを自動生成しない。
3. `promotions/` に新規レポートを作る。
4. 候補だけでなく見送りも明示する。
5. `rules` と `skill` のどちらが妥当か、その理由も書く。

## 出力内容

レポートには少なくとも次を含める。

- `rules 候補`
- `skill 候補`
- `見送り`

各候補には少なくとも次を含める。

- `対象テーマ`
- `提案内容`
- `根拠`
- `昇格理由`

## テンプレート参照

完全テンプレートは `assets/promotions.md` を参照する。
`SKILL.md` にテンプレート全文を重複保持しない。

## 実行手順

1. 対象の `long-term` ファイルを読む。
2. `pain_count` を確認し、`>= 3` のものだけを候補として扱う。
3. `rules` 候補と `skill` 候補を整理する。
4. 見送りも含めて `promotions/` に Markdown レポートを出力する。
5. 出力後は、人が確認する前提で候補扱いに留める。

## 非責務

- `daily-term` の生成
- `long-term` の抽象化
- `promotions/archive/` への移動
- `rules` / `skill` 正本の自動更新

これらはそれぞれ `learn-daily` `learn-long` または別運用の責務。
