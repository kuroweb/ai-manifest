---
name: handover-remove
description: >
  `~/.docs/handovers/<project>/` の引き継ぎノートから、ユーザーが選んだものを確認後に削除する。
  例: handover-remove、/handover-remove。
  「引き継ぎノートを削除」「handoverを消して」「古い引き継ぎを掃除して」などの操作を行う際に使用する。
  削除対象は必ずユーザーに選んでもらう。
---

# handover-remove

## できること

- 現在のプロジェクトの引き継ぎノートを一覧にする
- ユーザーが選んだノートを、確認後に削除する

## いつ使うか

- `handover-remove`
- `/handover-remove`
- `引き継ぎノートを削除`
- `handoverを消して`
- `古い引き継ぎを掃除して`

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

ディレクトリが無い、または0件なら、削除対象が無いと伝えて終わる。

### Step 3: 削除対象を選んでもらう

新しい順に並べ、削除するノートを選んでもらう。複数選択と`all`（全件）を受け付ける。

- 依頼文に対象（「古いもの」「全部」など）が含まれていても、該当するファイルを示して選んでもらう
- 1件しかない場合も選んでもらう
- 選択肢の提示には、エージェントが持つ選択UI（Claude Codeの`AskUserQuestion`など）を使う
- 選択UIが使えない、または選択肢を出し切れない場合は、番号付きリストで示し、番号かファイル名での回答を求める

```text
`~/.docs/handovers/<project>/` の引き継ぎノート:
1. <filename1>
2. <filename2>
削除するものを番号かファイル名で指定してください（複数可、`all`で全件）。
```

### Step 4: 削除前に確認する

選ばれたファイルのパスを並べ、削除してよいか確認する。承認されたら削除する。

```bash
rm <path1> <path2>
```

### Step 5: 結果を返す

削除したファイルのパスと、残っているノートの件数を返す。0件になった場合は、空になった`~/.docs/handovers/<project>/`も削除する。

```bash
rmdir ~/.docs/handovers/<project>
```

## 安全条件

- ユーザーが選んでいないノートを削除しない
- 確認を取らずに削除しない
- `~/.docs/handovers/<project>/`以外のファイルを削除しない

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
| `rm <path1> <path2>` | 選ばれたノートを削除する |
| `rmdir ~/.docs/handovers/<project>` | 空になったディレクトリを削除する |
