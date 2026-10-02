---
name: code-review-no-git
description: >
  AIによるGitコマンド実行が禁止されたリポジトリで、ユーザーが貼ったdiffを受け取り、レビューは`code-reviewing`に任せる。
  エージェントはgitを実行しない。
  例: code-review-no-git、code-review-no-git --head feat/example --base develop。
  「コードレビューして」「diffをレビューして」「変更差分の懸念を確認して」などの操作を、Gitコマンドを使わずに行う際に使用する。
---

# code-review-no-git

## できること

- Gitと`.git`を使わず、チャットへ貼られたdiffを受け取る
- レビューは`code-reviewing`に任せる

## いつ使うか

- `code-review-no-git`
- `code-review-no-git --head feat/example`
- `code-review-no-git --head feat/example --base develop`
- AIによるGitコマンド実行が禁止されたリポジトリでコードレビューするとき

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。`.git`を直接読んで同等の情報を取得しない。

### Step 2: baseとheadを決める

baseはマージ先、headは作業ブランチである。

headは次の順で決める。

1. `--head`で指定されたブランチ
2. 会話で明示されたブランチ

headを特定できない場合は、完成形のコマンドを提示し、実行後にclipboardの内容を貼ってもらう。ローカルブランチから推測しない。

```bash
git branch --show-current | pbcopy
```

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. ユーザーに聞く

baseとheadが同じ場合は停止する。

足りないブランチは、一度に一つ聞く。

### Step 3: diffを受け取る

完成形のコマンドを提示し、フルdiffを貼ってもらう。

```bash
git --no-pager diff <base>...<head> | pbcopy
```

`<base>`はStep 2で決めたマージ先、`<head>`はStep 2で決めた作業ブランチで埋めて出す。

diffが会話に既にある場合でも、ブランチが不明、または三点比較の全体か判断できない場合は、上記コマンドの再実行と貼り直しを依頼する。

diffが届くまで次へ進まない。

### Step 4: レビューする

`code-reviewing`を読む。評価、本文、返却はその手順に従う。

渡す情報は、Step 3で受け取ったdiffである。変更目的の確認は`code-reviewing`に任せる。

## 安全条件

- 読み取り専用を含む`git`コマンドを実行しない
- `.git`を直接読んで禁止を迂回しない
- ターミナルやIDEからdiffを読み取って進めない
- ワークスペースのファイルを直接読んで差分を推測しない
- diffなしで`code-reviewing`に進まない
- `code-reviewing`を読まずにレビュー結果を組み立てない
- baseとheadを、指定も会話も無い状態で推測しない
- baseとheadが同じ場合はレビューしない

## スキル連携

| 状況 | 使用するスキル |
| --- | --- |
| AIによるGitコマンド実行が禁止されている | `code-review-no-git` |
| レビュー | `code-reviewing` |
| ローカルブランチのdiffをgitで取る | `code-review` |
| 指定したGitHub PRをレビューする | `gh-pr-review` |
| 指定したGitLab MRをレビューする | `glab-mr-review` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `git branch --show-current \| pbcopy` | 現在のローカルブランチをclipboardへ入れる |
| `git --no-pager diff <base>...<head> \| pbcopy` | 三点比較のフルdiffをclipboardへ入れる |
