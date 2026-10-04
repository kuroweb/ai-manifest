---
name: handover-create
description: >
  次のセッション用の引き継ぎノートを `~/.docs/handovers/<project>/` に作成し、パスを返す。
  例: handover-create、/handover-create。
  「引き継ぎノートを作成」「handover」「引き継ぎして」などの操作や、セッション終了時・作業の区切りに使用する。
---

# handover-create

## できること

- 今回のセッションで次のセッションに必要な情報だけを引き継ぎノートにまとめる
- `~/.docs/handovers/<project>/YYYY-MM-DD_HHmm.md` に保存する
- 保存したノートのパスを返す

## いつ使うか

- `handover-create`
- `/handover-create`
- `引き継ぎノートを作成`
- `handover`
- `引き継ぎして`
- セッション終了時、作業の区切り

## 手順

### Step 1: projectを決める

リポジトリ名を`<project>`にする。ワークツリーでも同じ名前になるよう、共通の`.git`ディレクトリの親から取る。

```bash
basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
```

Git管理外のディレクトリ、またはプロジェクト規約でGitコマンドが禁止されている場合は、カレントディレクトリ名を使う。

### Step 2: 保存先を決める

`~/.docs/handovers/<project>/`が無ければ作成する。

```bash
mkdir -p ~/.docs/handovers/<project>
date +%Y-%m-%d_%H%M
```

ファイル名は`YYYY-MM-DD_HHmm.md`にする（例: `2026-02-17_1430.md`）。同名のファイルがある場合は末尾に`_2`などの連番を付ける。

### Step 3: ノートを書く

書く前に`references/handover-schema.md`でノートの型を確認する。今回のセッションを振り返り、その構成で書く。書き方は`report-patterns`に従う。

### Step 4: 可読性を確認する

保存する前に`report-patterns`を読み、Step 3の本文がその書き方で読みやすくできるか確認する。できる箇所があれば、内容とセクションの順は変えずに直す。

### Step 5: 保存してパスを返す

Step 4を経た本文をStep 2のパスに保存する。保存したノートのパスを、`~`を展開した絶対パスで返す。

## 安全条件

- `references/handover-schema.md`を読まずにノートを書かない
- `report-patterns`を読まずに可読性を確認しない
- 既存のノートを上書きしない

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| 引き継ぎノートを作成 | `handover-create` |
| 引き継ぎノートから再開 | `handover-resume` |
| 引き継ぎノートを削除 | `handover-remove` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"` | `<project>`を決める |
| `mkdir -p ~/.docs/handovers/<project>` | 保存先を作成する |
| `date +%Y-%m-%d_%H%M` | ファイル名の日時を取得する |
