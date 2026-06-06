# knowledge-accumulation-workflow

- **プロジェクト名:** ai-manifest
- **作成日:** 2026-06-06

## 概要

記事「Claude Code Evolutionary Memory」の考え方を取り入れ、知見を蓄積して `rules` / `skill` へ進化させるワークフローを整備する。
ただし初期スコープでは自動 Hook は採用せず、手動コマンドで `観察 -> 記憶 -> 進化` を回せる構成から始める。

## 実施計画

- ワークフローは `learn-daily` `learn-short` `learn-long` `learn-promote` の4コマンドで構成する。
- 保存先は `~/.docs/learn/` 配下の `daily-term` `short-term` `long-term` `promotions` とし、退避先は `daily-term/archive` `short-term/archive` `long-term/archive` `promotions/archive` とする。
- `learn-daily` は AI が会話ログ、ユーザー指摘、実行コマンド、編集内容から自動生成し、`daily-term/YYYY-MM-DD_HHMM_<agent>.md` に保存する。
- `learn-daily` の frontmatter は `agent` `created_at` `source_session` を持つ。`<agent>` は `claude` `cursor` `codex` を使い、同名衝突時は `_2` `_3` で回避する。
- `learn-daily` は `frontmatter + incident ごとの見出し` 形式とし、incident 見出しは短い要約文にする。本文見出しは `失敗・手戻り` `原因` `根拠` `次回の対策` とする。
- `learn-short` は未レビューの `daily-term` 全件を入力とし、テーマごとに `short-term/<theme-slug>.md` を生成する。各ファイルは `テーマ` `要約` `対象 daily-term 一覧` `繰り返しパターン` `long-term 候補理由` を持つ。
- `learn-long` は `short-term` のテーマごとに `long-term/<theme-slug>.md` を生成する。各ファイルは `テーマ` `抽象化した学び` `根拠となる short-term` `適用条件` `昇格候補（rules/skill）` を持つ。
- `learn-promote` は `long-term` から `rules` または `skill` への昇格候補を Markdown レポートとして `promotions` に出力する。初期スコープに Hook は含めない。
- `learn-promote` の初期昇格基準は `ユーザーの明示指摘が3回以上` または `long-term で同種テーマが3回以上強化された` のいずれかとする。
- `.codex/memories` は知見の一次保管先ではなく、rulesync で `rules` を展開した配布先として扱う。

## 次のアクション

- `learn-daily` `learn-short` `learn-long` `learn-promote` の実行コマンド仕様を定義する。
- `learn-promote` から `rules` / `skill` へ昇格するときの出力先と運用手順を確定する。
- `promotions/archive` を含め、各層配下に archive を置く。

## メモ

- 観察対象は `Claude Code` `Cursor` `Codex` の3系統とする。
- 各セッションから抽出する対象は、ユーザーの明示的な指摘と、エージェントの失敗・手戻りに限定する。
- `daily-term` の原本は残し、review 後は `daily-term/archive` へ移す運用を前提にする。

## 参照

- https://zenn.dev/tokium_dev/articles/claude-code-evolutionary-memory

## タスク

- [x] `~/.docs/learn/` 配下の構成を作成する
- [x] `learn-daily` のテンプレートと生成ルールを定義する
- [x] `learn-short` `learn-long` `learn-promote` のテンプレートを定義する
- [ ] 実行コマンド仕様を定義する
- [ ] 昇格フローを確認する

## テンプレート案

### learn-daily

```md
---
agent: <claude|cursor|codex>
created_at: <YYYY-MM-DDTHH:MM:SS+09:00>
source_session: <session-id>
---

# <YYYY-MM-DD_HHMM_<agent>>

## <incident-summary>

- **失敗・手戻り:** <何が起きたか>
- **原因:** <なぜ起きたか>
- **根拠:** <会話・コマンド・編集内容などの根拠>
- **次回の対策:** <次にどう避けるか>
```

### learn-short

```md
---
theme: <theme-slug>
created_at: <YYYY-MM-DDTHH:MM:SS+09:00>
source_daily_term:
  - <YYYY-MM-DD_HHMM_agent.md>
---

# <theme-slug>

## 要約

<重複テーマの短い要約>

## 対象 daily-term 一覧

- [<daily-term-file>](<path-or-name>)

## 繰り返しパターン

- <繰り返し現れる失敗・手戻り>

## long-term 候補理由

- <なぜ長期知見に上げる価値があるか>
```

### learn-long

```md
---
theme: <theme-slug>
created_at: <YYYY-MM-DDTHH:MM:SS+09:00>
source_short: <theme-slug>.md
---

# <theme-slug>

## 抽象化した学び

<再利用できる形に抽象化した知見>

## 根拠となる short-term

- [<theme-slug>.md](<path-or-name>)

## 適用条件

- <適用すべき状況>

## 昇格候補

- **rules:** <候補の有無>
- **skill:** <候補の有無>
- **理由:** <判断理由>
```

### learn-promote

```md
---
created_at: <YYYY-MM-DDTHH:MM:SS+09:00>
source_long:
  - <theme-slug>.md
---

# learn-promote report

## rules 候補

### <candidate-slug>

- **対象テーマ:** <theme-slug>
- **提案内容:** <rule として昇格したい内容>
- **根拠:** <どの long-term に基づくか>
- **昇格理由:** <なぜ rules が妥当か>

## skill 候補

### <candidate-slug>

- **対象テーマ:** <theme-slug>
- **提案内容:** <skill として昇格したい内容>
- **根拠:** <どの long-term に基づくか>
- **昇格理由:** <なぜ skill が妥当か>

## 見送り

### <theme-slug>

- **理由:** <今回は昇格しない理由>
```
- `learn-daily` `learn-short` `learn-long` `learn-promote` は独立スキルとして分ける。各スキルの description には明示コマンド名と自然文トリガーの両方を入れる。
- テンプレートの SoT は `.docs/learn/templates` とする。4スキルの `SKILL.md` / `references` はそこを参照し、テンプレート本文を重複保持しない。
- 4スキルの `SKILL.md` にはテンプレート本文を重複記載せず、短い要約だけを書く。完全テンプレートは `~/.docs/learn/templates/...` の絶対パスで参照する。
- 4スキルは既存 `learn` を置き換えず、`.rulesync/skills/learn-daily` `learn-short` `learn-long` `learn-promote` を新設して定義する。
- 既存の `learn` スキルは今回の設計対象から完全に外し、参照・互換性維持・置換検討も行わない。
- 4スキルの定義は `learn-daily` から着手する。入口を先に固め、後続スキルの前提を揃える。
- `learn-daily` は設計分岐の大半が埋まったため、次は `SKILL.md` 本文を実際に書く段階へ進む。
