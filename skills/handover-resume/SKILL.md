---
name: handover-resume
description: |
  `/handover-resume` 実行時に `~/.docs/handovers/<project>/` から再開対象を特定して読み込む。
  `~/.docs/handovers/<project>/` に複数ファイルがある場合は、どれを読むか必ずユーザーにヒアリングする。
  トリガー: `/handover-resume`, 「引き継ぎ再開」, 「前回の続きから」, 「handoverを読み込んで」。
---
# セッション再開（handover-resume）

`/handover-resume` 実行時に、引き継ぎノートを読み込んでセッション再開を補助する。

## トリガー

- `/handover-resume`
- 「引き継ぎ再開」「前回の続き」「handoverを読み込んで」等のリクエスト

## 手順

1. `<project>` を決める（下記「project の決め方」）
2. `~/.docs/handovers/<project>/` ディレクトリの存在を確認する
3. `~/.docs/handovers/<project>/` 配下の `*.md` を列挙する
4. 候補が 0 件なら、引き継ぎノートがない旨を伝えて通常進行する
5. 候補が 1 件なら、そのファイルを読み込む
6. 候補が複数件なら、どのファイルを読むか必ずユーザーに確認する
7. ユーザー指定のファイルを読み込み、要点を簡潔に共有する

## project の決め方

`handover-create` と同じ規則で決める。リポジトリ名を、ワークツリーでも同じ名前になるよう共通の `.git` ディレクトリの親から取る。

```bash
basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
```

Git 管理外のディレクトリ、またはプロジェクト規約で Git コマンドが禁止されている場合は、カレントディレクトリ名を使う。

## 複数ファイル時のルール

- 勝手に最新ファイルを選ばない
- 必ずユーザーに確認してから読む
- 確認時は「番号またはファイル名で指定してほしい」と案内する

## 確認テンプレート

```text
`~/.docs/handovers/<project>/` に引き継ぎノートが複数あります。どれを読み込みますか？
1. <filename1>
2. <filename2>
3. <filename3>
番号かファイル名で指定してください。
```

## 出力ルール

- 読み込み後は次の 3 点を簡潔に共有する
  - 今回やるべきこと
  - 未完了タスク
  - 注意事項（詰まりやすい点・決定事項）
- 引き継ぎ本文の長文転記は避ける
