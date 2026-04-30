---
name: issue-resumer
description: '`/issue-resume` 実行時に `~/.issues/` 配下（`close` を除く）から再開対象の issue を特定して読み込む。 `issue-creator` が作成した `~/.issues/<state>/<slug>/issue.md` を再開導線として扱い、 複数候補がある場合は必ずユーザーに対象を確認する。 トリガー: `/issue-resume`, 「issue再開」, 「前回のissueの続き」, 「issueを読み込んで」。'
---
# セッション再開（issue-resumer）

`/issue-resume` 実行時に、`~/.issues/` 配下の `draft` / `ready` issue を読み込んで作業再開を補助する。

## 実行フロー

### Step 1: issue 一覧を確認する

- `~/.issues/draft/` と `~/.issues/ready/` ディレクトリの存在を確認する
- `~/.issues/draft/*/issue.md` と `~/.issues/ready/*/issue.md` を列挙する

### Step 2: 候補数に応じて分岐する

- 候補が 0 件なら、再開可能な issue がない旨を伝えて通常進行する
- 候補が 1 件なら、その `issue.md` を読み込む
- 候補が複数件なら、どの issue を読むか必ずユーザーに確認する

### Step 3: 指定 issue を読み込んで共有する

- ユーザー指定の `issue.md` を読み込み、要点を簡潔に共有する

## ルール

### 複数候補時の扱い

- 勝手に最新ファイルを選ばない
- 必ずユーザーに確認してから読む
- 確認時は「番号または slug / ファイルパスで指定してほしい」と案内する

### 確認テンプレート

```text
`~/.issues/draft/` に issue が複数あります。どれを読み込みますか？
1. <slug1>/issue.md
2. <slug2>/issue.md
3. <slug3>/issue.md
番号、slug、またはファイルパスで指定してください。
```

### 出力ルール

- 読み込み後は次の 4 点を簡潔に共有する
  - issue の目的
  - 今回やるべきこと（次アクション）
  - 未完了タスク
  - 注意事項（詰まりやすい点・決定事項）
- issue 本文の長文転記は避ける

## サブコマンド

### `!draft`

- 対象 issue ディレクトリを `~/.issues/draft/<slug>/` へ移す。
- `issue.md` 以外の添付ファイルやメモも一緒に移動し、取りこぼさない。

### `!ready`

- 対象 issue ディレクトリを `~/.issues/ready/<slug>/` へ移す。
- `issue.md` 以外の添付ファイルやメモも一緒に移動し、取りこぼさない。

### `!close`

- 対象 issue ディレクトリを `~/.issues/close/<slug>/` へ移す。
- `issue.md` 以外の添付ファイルやメモも一緒に移動し、取りこぼさない。
