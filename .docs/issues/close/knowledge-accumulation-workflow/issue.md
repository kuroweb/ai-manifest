# knowledge-accumulation-workflow

- **プロジェクト名:** ai-manifest
- **作成日:** 2026-06-06

## 概要

記事「Claude Code Evolutionary Memory」の考え方を取り入れ、知見を蓄積して `rules` / `skill` へ進化させるワークフローを整備する。
ただし初期スコープでは自動 Hook は採用せず、手動スキルで `観察 -> 記憶 -> 進化` を回せる構成から始める。

## 実施計画

- ワークフローは `learn-daily` `learn-long` `learn-promote` の3スキルで構成する。
- 保存先は `~/.docs/learn/` 配下の `daily-term` `long-term` `promotions` とし、退避先は `daily-term/archive` `long-term/archive` `promotions/archive` とする。
- テンプレートの SoT は各スキル配下の `assets/` とする。スキル本文はテンプレート全文を持たず、対応する `assets/*.md` を参照する。
- `learn-daily` は AI が会話ログ、ユーザー指摘、実行コマンド、編集内容から観察結果を抽出し、`daily-term/YYYY-MM-DD_HHMM_<agent>.md` に保存する。
- `learn-daily` の frontmatter は `agent` `created_at` を持つ。`<agent>` は `claude` `cursor` `codex` を使い、必要に応じて既存ファイルを更新する。
- `learn-daily` は `frontmatter + incident ごとの見出し` 形式とし、incident 見出しは短い要約文にする。本文見出しは `失敗・手戻り` `原因` `根拠` `次回の対策` とする。
- `learn-long` は未処理の `daily-term` 全件を読み、テーマごとに `long-term/<theme-slug>.md` を新規作成または更新する。処理済みの `daily-term` は `daily-term/archive/` へ移す。
- `long-term` は `theme` `created_at` `source_daily_term` `pain_count` を持ち、本文に `抽象化した学び` `根拠となる daily-term` `適用条件` `昇格候補` `pain_log` を持つ。
- 同じテーマに新しい `daily-term` が紐づいたとき、`learn-long` は `pain_count` を増やし、`pain_log` に再発内容を追記する。
- `learn-promote` は `long-term` を読み、`pain_count >= 3` を満たしたテーマだけを `rules` または `skill` 候補として `promotions/` に Markdown レポート出力する。
- `learn-promote` は候補レポートを出すだけで、`rules` / `skill` の正本を自動更新しない。
- `.codex/memories` は知見の一次保管先ではなく、rulesync で `rules` を展開した配布先として扱う。

## 次のアクション

- `learn-long` の `pain_count` / `pain_log` 更新ルールを実運用しながら見直す。
- `learn-promote` の `rules` / `skill` 候補フォーマットを実データで検証する。
- 不要になった `~/.docs/learn/short-term/` を削除する。

## メモ

- 観察対象は `Claude Code` `Cursor` `Codex` の3系統とする。
- 各セッションから抽出する対象は、ユーザーの明示的な指摘と、エージェントの失敗・手戻りに限定する。
- `daily-term` は観察の原本、`long-term` は pain の蓄積を持つ長期知見、`promotions` は昇格候補レポートとして扱う。

## 参照

- https://zenn.dev/tokium_dev/articles/claude-code-evolutionary-memory

## タスク

- [x] `~/.docs/learn/` 配下の初期構成を作成する
- [x] `learn-daily` のテンプレートと生成ルールを定義する
- [x] `learn-long` を `daily-term -> long-term` 構成へ更新する
- [x] `learn-promote` を `pain_count >= 3` 構成へ更新する
- [x] テンプレート SoT を3スキル構成に合わせて更新する
- [x] `rulesync generate` で再反映する
