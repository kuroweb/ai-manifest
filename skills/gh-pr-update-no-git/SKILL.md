---
name: gh-pr-update-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、指定したPull Requestのタイトルと本文を更新する。
  Gitと.gitには触れない。
  本文は`gh-pr-writing`で書く。
  例: gh-pr-update-no-git --pr 42。
  「PRを更新」「PRの説明を修正」「PRのタイトルを変更」などの操作を、Gitコマンドを使わずに行う際に使用する。
  `--pr`が無いときは聞いてから進む。
---

# gh-pr-update-no-git

## できること

- Gitコマンドを使わずに、GitHub Pull Requestのタイトルと本文の要求された箇所を更新する

## いつ使うか

- `gh-pr-update-no-git --pr <number>`
- AIによるGitコマンド実行が禁止されたプロジェクトで、既存Pull Requestのタイトルや本文を変えるとき

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。`.git`を直接読んで同等の情報を取得しない。

対象リポジトリは、引数なしの`gh repo view`で取る。以降の`gh`には、ここで得た`owner/repo`を`--repo`で渡す。`gh api`のパスにもその`owner/repo`を使う。番号を省略した`gh pr view`や`gh pr edit`は使わない。

### Step 2: 対象を決める

対象リポジトリは、引数なしの`gh repo view`で取る。

```bash
gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'
```

`repo`を`owner/repo`にする。

取得できなければ停止する。Gitコマンドや`.git`からは取らない。

PR番号は`--pr`で指定する。無いときはユーザーに聞く。ローカルブランチから推測しない。

### Step 3: 既存PRを読む

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

### Step 5: タイトルと本文を書く

`gh-pr-writing`で書く。既存PRはStep 3で読んだもの、根拠はStep 3のコミットとStep 4のdiffにする。

### Step 6: PRを更新する

書いたタイトルと本文をJSONへ変換し、リポジトリ外の一時ファイルへ保存する。文字列を手作業でJSONエスケープせず、JSONを安全に生成できる手段を使う。

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

### Step 7: 更新結果を検証する

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName
```

次を確認する。

- titleが書いたタイトルと一致する
- bodyが書いた本文と一致する
- stateが更新前と一致する
- isDraftが更新前と一致する
- headRefNameが更新前と一致する
- baseRefNameが更新前と一致する
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異とPR URLを返す。すべて一致したらPR URLと、変更した箇所を返す。一時ファイルは削除する。

## 禁止事項

- 読み取り専用を含む`git`コマンドを実行しないこと
- Gitを内部で呼び出すツールを使わないこと
- `.git`を直接読んで禁止を迂回しないこと
- 対象リポジトリを`gh repo view`以外から取らないこと
- PR番号をローカルブランチから推測しないこと
- 番号や`--repo`を省略した`gh pr`コマンドを使わないこと
- `OPEN`でないPRを、明示的な続行指示なしに更新しないこと
- 更新対象外のタイトル、本文、base、head、state、draftを変えないこと
- 作成や更新に失敗しても、PRを無断で閉じたり削除したりしないこと

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| Gitコマンドを実行できる | `gh-pr-update` |
| AIによるGitコマンド実行が禁止されている | `gh-pr-update-no-git` |
| PRを新規作成する | `gh-pr-create-no-git` |
| PRの書き方 | `gh-pr-writing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `gh repo view --json nameWithOwner` | 対象リポジトリを取る |
| `gh pr view <number> --repo <owner/repo> --json ...` | 既存PRの状態とコミットを取得する |
| `gh pr diff <number> --repo <owner/repo>` | PRのdiffを取得する |
| `gh api --method PATCH "repos/<owner>/<repo>/pulls/<number>" --input <payload-file>` | タイトルと本文を更新する |
