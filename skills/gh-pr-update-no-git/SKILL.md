---
name: gh-pr-update-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、指定したPull Requestのタイトルと本文を確認後に更新する。
  Gitと.gitには触れない。
  例: gh-pr-update-no-git --repo owner/repo --pr 42。
  「PRを更新」「PRの説明を修正」「PRのタイトルを変更」などの操作を、Gitコマンドを使わずに行う際に使用する。
  `--repo`または`--pr`が無いときは聞いてから進む。
---

# gh-pr-update-no-git

## できること

- Gitと`.git`を使わず、指定したPull Requestの既存内容を保ちながら、要求された箇所を更新する
- そのPRのdiffとコミットだけを本文の根拠にする
- `gh-pr-schema`に沿ってタイトルと本文を組み立てる
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `gh-pr-update-no-git --repo owner/repo --pr <number>`
- AIによるGitコマンド実行が禁止されたプロジェクトで、既存Pull Requestのタイトルや本文を変えるとき

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。Gitを内部で呼び出すツールや、`.git`を直接読んで同等の情報を取得する方法も使わない。

`gh`には対象リポジトリとPR番号を常に明示し、カレントディレクトリのGit情報へ依存させない。番号を省略した`gh pr view`や`gh pr edit`は使わない。

### Step 2: 対象を決める

対象リポジトリは`--repo owner/repo`で指定された値を使う。省略されている場合は、Gitから推測せずユーザーに聞く。

PR番号は`--pr`で指定する。無いときはユーザーに聞く。ローカルブランチから推測しない。

対象リポジトリをGitHubから確認する。

```bash
gh repo view <owner/repo> --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,base:.defaultBranchRef.name}'
```

### Step 3: スキーマと既存PRを読む

`gh-pr-schema`を読む。タイトルや本文を組む前に読む。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName,commits
```

`OPEN`でなければ状態とURLを示し、ユーザーが続行を明示するまで待つ。

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 4: そのPRのdiffを取る

```bash
gh pr diff <number> --repo <owner/repo>
```

diffを取得できなければ本文を作らない。現在のファイル内容や会話中の未push変更からdiffを補わない。

### Step 5: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。変えない箇所については聞かない。

- 変更目的を書き換えるのに会話へ無ければ聞く。diffから推測しない
- closeするIssueを変更するときは、会話で示されたIssue番号を使う

### Step 6: タイトルと本文を組む

タイトルと本文は`gh-pr-schema`に従う。

要求された変更と整合に必要な変更だけを加える。既存本文がスキーマに沿っている箇所は残し、空になった見出しは残さない。

- そのPRのdiffにない変更を本文へ含めない

### Step 7: 更新前に確認する

対象リポジトリ、PR番号、タイトル、本文をチャットに出す。変更する箇所が分かるように示す。

ユーザーが認めたあとだけ更新する。修正指示があれば反映し、タイトルと本文を再度出す。確認前に更新しない。

### Step 8: PRを更新する

確認済みのタイトルと本文をJSONへ変換し、リポジトリ外の一時ファイルへ保存する。文字列を手作業でJSONエスケープせず、JSONを安全に生成できる手段を使う。

```json
{
  "title": "<title>",
  "body": "<body>"
}
```

`base`、`head`、`draft`、`state`はJSONへ入れない。

```bash
gh api --method PATCH "repos/<owner>/<repo>/pulls/<number>" --input <payload-file>
```

Issueを起票しない。コミットしない。pushしない。`gh pr ready`と`gh pr draft`は使わない。

### Step 9: 更新結果を検証する

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName
```

次を確認する。

- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- stateが更新前と一致する
- isDraftが更新前と一致する
- headRefNameが更新前と一致する
- baseRefNameが更新前と一致する
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異とPR URLを返す。すべて一致したらPR URLを返す。一時ファイルは削除する。

## 安全条件

- 読み取り専用を含む`git`コマンドを実行しない
- Gitを内部で呼び出すツールを使わない
- `.git`を直接読んで禁止を迂回しない
- 対象リポジトリとPR番号をGitから推測しない
- 番号や`--repo`を省略した`gh pr`コマンドを使わない
- ユーザー確認前にPRを更新しない
- `OPEN`でないPRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draftを変えない
- そのPRのdiffにない変更を本文へ含めない
- 作成や更新に失敗しても、PRを無断で閉じたり削除したりしない

## スキル連携

| 状況 | 使用するスキル |
|---|---|
| Gitコマンドを実行できる | `gh-pr-update` |
| AIによるGitコマンド実行が禁止されている | `gh-pr-update-no-git` |
| PRを新規作成する | `gh-pr-create`または`gh-pr-create-no-git` |
| PR本文の型 | `gh-pr-schema` |
