---
name: handover-resume
description: >
  `~/.docs/handovers/<project>/` の引き継ぎノートを読み込み、セッションの再開を補助する。
  例: handover-resume、/handover-resume。
  「引き継ぎ再開」「前回の続きから」「handoverを読み込んで」などの操作を行う際に使用する。
  ノートが複数あるときは、どれを読むかユーザーに選んでもらう。
---

# handover-resume

## できること

- 現在のプロジェクトの引き継ぎノートを一覧にする
- 選ばれたノートを読み込み、再開に必要な要点を返す

## いつ使うか

- `handover-resume`
- `/handover-resume`
- `引き継ぎ再開`
- `前回の続きから`
- `handoverを読み込んで`

## 手順

### Step 1: projectを決める

`handover-create`と同じ規則で決める。リポジトリ名を、ワークツリーでも同じ名前になるよう共通の`.git`ディレクトリの親から取る。

```bash
basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
```

Git管理外のディレクトリ、またはプロジェクト規約でGitコマンドが禁止されている場合は、カレントディレクトリ名を使う。

### Step 2: ノートを列挙する

```bash
ls -1r ~/.docs/handovers/<project>/*.md
```

ディレクトリが無い、または0件なら、引き継ぎノートが無いと伝えて通常の作業に戻る。

### Step 3: 読むノートを決める

1件ならそのノートを読む。

複数件なら、新しい順に並べてユーザーに選んでもらう。最新のノートを勝手に選ばない。

- 選択肢の提示には、エージェントが持つ選択UI（Claude Codeの`AskUserQuestion`など）を使う
- 選択UIが使えない、または選択肢を出し切れない場合は、番号付きリストで示し、番号かファイル名での回答を求める

```text
`~/.docs/handovers/<project>/` に引き継ぎノートが複数あります。どれを読み込みますか？
1. <filename1>
2. <filename2>
番号かファイル名で指定してください。
```

### Step 4: 読み込んで要点を返す

選ばれたノートを読み込み、読んだノートのパスと次の3点を返す。本文を長く転記しない。

- 今回やるべきこと
- 未完了タスク
- 注意事項（詰まりやすい点、決定事項、捨てた選択肢）

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
| `ls -1r ~/.docs/handovers/<project>/*.md` | ノートを新しい順に列挙する |
