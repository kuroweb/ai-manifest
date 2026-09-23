---
name: git-commit-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、ユーザーが取得したGitの出力を基に、
  変更を意味のある単位へ分け、Conventional Commitsに従う日本語のコミット手順を作る。
  スキル名で呼ばれたとき、またはプロジェクト規約がAIのGitコマンド実行を禁止している状態でコミットを依頼されたときに使用する。
  AIは読み取り専用を含むGitコマンドを一切実行せず、必要なコマンドをユーザーへ提示する。
  通常どおりGitコマンドを実行できるプロジェクトではgit-commitを使う。
---

# git-commit-no-git

## できること

- Gitの状態と差分を取得するコマンドをユーザーへ提示する
- ユーザーが貼り付けたGit出力、またはユーザーが生成した`diff.md`を読み取る
- 確認できた差分を意味のあるコミット単位へ分ける
- ファイルを個別指定したステージングコマンドを作る
- Conventional Commitsに従った日本語のコミットメッセージと実行コマンドを作る
- ユーザーが実行したコミットの結果を、貼り付けられた確認結果から判定する

## いつ使うか

- `git-commit-no-git`
- AIによるGitコマンド実行がプロジェクト規約で禁止されているとき
- Gitの取得と操作をユーザーが行い、AIはコミット手順だけを作るとき
- Gitコマンドを実行できるプロジェクトでは使わない
- pushやPull Request作成には使わない

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示とユーザーの依頼を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドをAI自身が実行しない。Gitを内部で呼び出すツールや、`.git`を直接読んで同等の情報を取得する方法も使わない。

### Step 2: ユーザーにGitの状態と差分を取得してもらう

ユーザーが現在のGit出力を提示済みなら、その情報を使う。提示されていなければ、次のコマンドをそのままユーザーへ返し、ユーザー自身に実行してもらう。

クリップボードへ取得する場合:

```bash
{
  git --no-pager status
  echo '--- unstaged ---'
  git --no-pager diff
  echo '--- staged ---'
  git --no-pager diff --staged
  echo '--- untracked ---'
  git ls-files --others --exclude-standard -z | while IFS= read -r -d '' file; do
    git --no-pager diff --no-index -- /dev/null "$file" || true
  done
} | pbcopy
```

出力が大きい場合は、ユーザーに次のコマンドで`diff.md`を生成してもらう。

```bash
{
  git --no-pager status
  echo '--- unstaged ---'
  git --no-pager diff
  echo '--- staged ---'
  git --no-pager diff --staged
  echo '--- untracked ---'
  git ls-files --others --exclude-standard -z -- ':!diff.md' | while IFS= read -r -d '' file; do
    git --no-pager diff --no-index -- /dev/null "$file" || true
  done
} > diff.md
```

ユーザーが貼り付けた出力、または生成したと明示した`diff.md`が届くまで、コミット案を作らない。

### Step 3: 取得された差分を確認する

提示されたGit出力から、次を確認する。

- 現在のブランチ
- staged、unstaged、untrackedの各変更
- 変更されたファイルと変更内容
- 実施済みの検証
- `.env`、認証情報、秘密鍵、トークンなどの混入

現在のファイル内容や、このセッションで行った編集から差分を推測しない。ターミナルやIDEに表示されたGitの状態を直接読み取ったものとして扱わない。

出力が途中で切れている場合や、対象ファイルの差分が不足している場合は、コミット案を作らず、必要なパスを指定した取得コマンドをユーザーへ提示する。

```bash
git --no-pager diff -- path/to/file | pbcopy
git --no-pager diff --staged -- path/to/file | pbcopy
```

秘密情報を検出した場合はコミット対象から外すよう伝え、その値を回答へ転載しない。

### Step 4: コミット単位とステージング手順を作る

一つの目的として説明できる変更を一つのコミットにまとめる。目的が独立している変更は分ける。

各コミットについて、対象ファイルを個別に指定したステージングコマンドを提示する。`git add -A`と`git add .`は提示しない。

```bash
git add -- path/to/file path/to/another-file
```

一つのファイルに複数の目的が混在する場合は、ユーザーに`git add -p -- path/to/file`を使う選択肢を提示する。AI自身はステージングしない。

### Step 5: staged差分を再確認する

ユーザーがステージングを実行した後、次のコマンドを提示し、実際にコミットされる差分を取得してもらう。

```bash
git --no-pager diff --staged | pbcopy
```

貼り付けられたstaged差分が意図したコミット単位と一致するまで、コミットコマンドを作らない。空の差分、余分な変更、秘密情報がある場合はその問題を伝える。

### Step 6: コミットコマンドを作る

確認済みのstaged差分に対して、Conventional Commitsの形式で日本語のメッセージを作る。

```text
<type>(<scope>): <description>

<body（必要な場合）>
```

- typeは`feat`、`fix`、`docs`、`style`、`refactor`、`test`、`chore`、`ci`、`perf`、`build`などから選ぶ
- scopeは変更の影響範囲が明確な場合だけ付ける
- descriptionは変更理由が伝わる命令形にする
- co-authorやエージェント名を含めない
- bodyはdescriptionだけでは理由や制約が伝わらない場合だけ付ける

メッセージと、ユーザーが実行する完全なコマンドを提示する。

```bash
git commit -m "<type>(<scope>): <description>"
```

本文が必要な場合は複数の`-m`を使う。AI自身はコミットしない。

### Step 7: コミット結果を確認する

ユーザーに次のコマンドを実行してもらい、結果を貼り付けてもらう。

```bash
{
  git --no-pager log -1 --oneline
  git --no-pager status --short
} | pbcopy
```

貼り付けられた結果から、コミットのSHA、メッセージ、残っている未コミット変更を報告する。結果が提示される前にコミット成功やSHAを報告しない。

複数のコミットへ分ける場合は、次のコミットについてStep 4から繰り返す。

## 禁止事項

- 読み取り専用を含む`git`コマンドをAI自身が実行しない
- Gitを内部で呼び出すツールを使わない
- `.git`を直接読んで禁止を迂回しない
- 現在のファイル内容や会話履歴からGit差分を推測しない
- ユーザーが生成したと確認できない`diff.md`を差分として扱わない
- ステージング、コミット、push、履歴変更をAI自身が行わない
- `git add -A`と`git add .`を提示しない
- 確認できていない変更をコミット案へ含めない
- 秘密情報をコミット対象や回答へ含めない
- ユーザーの確認結果なしにコミット完了やSHAを報告しない

## スキル連携

| 状況 | 使用するスキル |
|---|---|
| Gitコマンドを実行できる | `git-commit` |
| AIによるGitコマンド実行が禁止されている | `git-commit-no-git` |
| push、Pull RequestとMerge Requestの作成・更新 | このスキルでは扱わない |
