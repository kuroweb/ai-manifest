---
name: handover-create
description: |
  セッション終了時や作業の区切りで引き継ぎノートを生成する。
  次のセッションに必要な情報のみを ~/.docs/handovers/<project>/ に記録する（Cursor / Claude Code / Codex 共通）。
  トリガー: セッション終了時、作業の区切り、`/handover-create`、「引き継ぎノートを作成」「handover」等。
---

# handover-create

## できること

- 今回のセッションの作業内容を振り返る
- 次のセッションに必要な情報だけを引き継ぎノートにまとめる
- `~/.docs/handovers/<project>/YYYY-MM-DD_HHmm.md` にノートを保存する

## いつ使うか

- セッション終了時、作業の区切り
- `引き継ぎノートを作成`
- `/handover-create`
- `handover`
- `引き継ぎして`

## 手順

### Step 1: セッションを振り返る

今回のセッションで行ったことを振り返る。

### Step 2: 保存先を確保する

`<project>`を決め、`~/.docs/handovers/<project>/`が存在しない場合は作成する。

`<project>`はリポジトリ名にする。ワークツリーでも同じ名前になるよう、共通の`.git`ディレクトリの親から取る。

```bash
basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
```

Git管理外のディレクトリ、またはプロジェクト規約でGitコマンドが禁止されている場合は、カレントディレクトリ名を使う。

### Step 3: ファイル名を決める

`YYYY-MM-DD_HHmm.md`にする（例: `2026-02-17_1430.md`）。既存ファイルと同名になる場合は末尾に`_2`などの連番を付ける。

### Step 4: ノートを書く

このステップの前に `references/handover-schema.md` でノートの型を確認し、その構成で書く。

## 禁止事項

- `references/handover-schema.md` を読まずにノートを書かない
