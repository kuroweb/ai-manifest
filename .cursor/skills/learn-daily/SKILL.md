---
name: learn-daily
description: '`~/.docs/learn/daily-term/` に、セッションの失敗・手戻りを daily-term 原本として記録する。 `learn-daily` を明示したとき、または「daily-term に記録して」「このセッションを daily にして」「知見を daily-term に残して」のように daily-term への記録を求められたときは使う。'
---
# Learn Daily

`learn-daily` は、`Claude Code` `Cursor` `Codex` のセッションから観察結果を抽出し、`~/.docs/learn/daily-term/` に 1 セッション 1 ファイルで保存する。

このスキルが扱う観察対象は、ユーザーの明示的な指摘と、エージェントの失敗・手戻りだけ。
成功パターンの抽出は初期スコープに含めない。

## 保存先

- 出力先: `~/.docs/learn/daily-term/`
- テンプレート SoT: `~/.docs/learn/templates/daily-term.md`

## 入力ソース

必ず次を入力ソースに含める。

- 会話ログ
- 最終的なユーザー指摘
- 実行したコマンド
- 編集内容

会話だけを要約して終わらせない。原因や根拠の抽出に必要な行動ログまで見る。

## ファイル名規則

- `YYYY-MM-DD_<agent>.md`
- `<agent>` は `claude` `cursor` `codex`
- 同名ファイルが既にある場合は新規作成せず、既存ファイルを更新する

## frontmatter

最低限、次だけを持たせる。

- `agent`
- `created_at`

セッションの特定は frontmatter では行わない。ファイル名 `YYYY-MM-DD_<agent>.md` と `created_at` で足りる。
issue slug や session ID など、自動取得できない識別子は入れない。
会話ログへの逆引きが必要なら、incident の `根拠` に transcript パスやコマンド履歴を書く。

## 生成ルール

1. 現在のセッションから、ユーザーの明示的な指摘とエージェントの失敗・手戻りを抽出する。
2. 同一セッションの daily-term 原本がすでに存在するか確認する。
3. 存在しない場合は新規作成する。
4. 存在する場合は必ず既存ファイルを読んでから更新する。
5. 更新時は incident の追加と既存 incident の修正を許可する。
6. 原本全体を無差別に再生成して置き換えない。
7. 出力形式は `frontmatter + incident ごとの見出し` とする。
8. incident 見出しは短い要約文にする。
9. incident 本文は固定見出しの箇条書きにする。

## incident 本文

各 incident には必ず次の見出しを使う。

- `失敗・手戻り`
- `原因`
- `根拠`
- `次回の対策`

`根拠` は会話、コマンド、編集内容などから裏付けられる事実を書く。
推測だけで埋めない。

## テンプレート参照

完全テンプレートは `~/.docs/learn/templates/daily-term.md` を参照する。
`SKILL.md` にテンプレート全文を重複保持しない。

## 非責務

- `daily-term/archive/` への移動
- 重複テーマの整理
- `long-term` への抽象化
- `rules` / `skill` への昇格判断

これらはそれぞれ `learn-short` `learn-long` `learn-promote` の責務。
