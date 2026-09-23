---
name: gh-pr-create-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、指定されたpush済みブランチからPull Requestを作成する。
  diffを取るため先に空の下書きを作り、確認済みのタイトルと本文を入れてreadyにする。
  スキル名で呼ばれたときだけ使用し、Gitと.gitには触れない。
  例: gh-pr-create-no-git --repo owner/repo --head feat/example、gh-pr-create-no-git --repo owner/repo --head feat/example --base develop。
  「PRを作って」「プルリク出して」だけでは使わない。Gitコマンドを実行できるプロジェクトではgh-pr-createを使う。
  既存PRの更新はgh-pr-update-no-gitを使う。
  Issue起票、実装、コミット、pushは行わない。
---

# gh-pr-create-no-git

## できること

- Gitと`.git`を使わず、指定されたpush済みブランチからPull Requestを作成する
- 本文を書く前に下書きを作り、そのdiffとコミットを取得する
- `gh-pr-schema`に沿ってタイトルと本文を組み立てる
- 確認済みのタイトルと本文を、作成したPRへ入れてreadyにする
- 作成後のタイトル、本文、base、headを検証する

## いつ使うか

- `gh-pr-create-no-git`
- `gh-pr-create-no-git --repo owner/repo --head feat/example`
- `gh-pr-create-no-git --repo owner/repo --head feat/example --base develop`
- AIによるGitコマンド実行が禁止されたプロジェクトでPull Requestを作成するとき
- GitHub上にpush済みのheadを明示してPull Requestを作成するとき

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。Gitを内部で呼び出すツールや、`.git`を直接読んで同等の情報を取得する方法も使わない。

`gh`には対象リポジトリを常に`owner/repo`で明示し、カレントディレクトリのGit情報へ依存させない。

### Step 2: 対象リポジトリとブランチを決める

対象リポジトリは`--repo owner/repo`で指定された値を使う。省略されている場合は、Gitから推測せずユーザーに聞く。

headは次の順で決める。

1. `--head`で指定されたpush済みブランチ
2. 会話で明示されたpush済みブランチ

headを特定できない場合はユーザーに聞く。ローカルブランチから推測しない。

対象リポジトリとデフォルトブランチをGitHubから取得する。

```bash
gh repo view <owner/repo> --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,base:.defaultBranchRef.name}'
```

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. 対象リポジトリのデフォルトブランチ

baseとheadが同じ場合は停止する。

### Step 3: 同じheadの既存PRを確認する

下書きPRを作成する前に、同じheadを使ったPRを確認する。

```bash
gh pr list --repo <owner/repo> --head <head> --state all --json number,state,isDraft,url,headRefName,baseRefName
```

- `OPEN`のPRがあれば、新しいPRを作成せずURLを返す。タイトルや本文を変えるときは`gh-pr-update-no-git`を使う
- 既存の下書きPRをこのスキルで続けたいとユーザーが明示し、baseとheadが指定内容に一致する場合は、そのPRを再利用する。Step 4とStep 5を飛ばしてStep 6へ進む
- `MERGED`または`CLOSED`のPRがあれば、同じheadを再利用せず、新しいブランチを使う

### Step 4: 下書きPRの作成許可を得る

下書きPRは外部状態を変更する。作成前に次をユーザーへ提示する。

- 対象リポジトリ
- base
- head
- 仮タイトル
- 空の本文で下書きPRを作ること
- 下書きでも通知、Webhook、GitHub Actionsなどが動く可能性
- ローカルの未pushコミットと未コミット変更は確認できず、PRに含まれないこと

GitHubではタイトルが必須のため、完全に空のPRは作れない。仮タイトルは`Draft: <head>`とし、本文は空にする。

ユーザーがこの内容での下書きPR作成を明示的に認めたあとだけ次へ進む。

### Step 5: 下書きPRを作成する

仮タイトル、空の本文、base、head、`draft: true`をJSONへ変換し、リポジトリ外の一時ファイルへ保存する。文字列を手作業でJSONエスケープせず、JSONを安全に生成できる手段を使う。

```json
{
  "title": "Draft: <head>",
  "body": "",
  "base": "<base>",
  "head": "<head>",
  "draft": true
}
```

一時ファイルを`--input`へ渡し、GitHub APIで下書きPRを作成する。`gh pr create`は使わない。

```bash
gh api --method POST "repos/<owner>/<repo>/pulls" --input <payload-file>
```

作成に失敗した場合は自動で再試行しない。エラーを確認し、headが存在しない、baseとの差分がない、権限がないなどの原因をユーザーへ返す。

### Step 6: 作成したPRからdiffを取得する

作成時のレスポンスからPR番号を取得し、対象リポジトリを明示してPRの状態とコミットを取得する。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName,commits
```

これは仮タイトルのPRの確認である。

- stateが`OPEN`
- isDraftが`true`
- headRefNameがheadと一致する
- baseRefNameがbaseと一致する

一致しない場合はdiffを取得せず停止し、作成済みPRのURLと差異をユーザーへ返す。

一致した場合だけ、そのPRのdiffを取得する。

```bash
gh pr diff <number> --repo <owner/repo>
```

diffを取得できなければ本文を作らない。現在のファイル内容や会話中の未push変更からdiffを補わない。

### Step 7: スキーマを読む

`gh-pr-schema`を読む。タイトルや本文を組む前に読む。

### Step 8: PR本文に必要な情報を集める

変更目的、変更内容、テスト内容、関連Issueが書けるところまで、会話、作成したPRのコミット、作成したPRのdiffから集める。

- 変更目的は会話から取る。diffから推測しない
- 変更内容はPRのdiffにある事実だけを書く
- テスト内容は`gh-pr-schema`に従い、diffにあるテストの追加・変更から取る
- Issue番号の候補は、会話、head名、コミットメッセージから取る
- Issue番号の候補があるだけでは、closeするIssueとして扱わない
- ローカルファイルや会話中の未push変更をPR本文へ含めない

### Step 9: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。

- 変更目的が会話に無ければ聞く
- Issueをcloseするか参照だけにするか決まっていなければ聞く
- baseがデフォルトブランチで、候補が一つのときは`Closes`を推奨する
- 関連Issueの候補が無ければ、Issue番号を聞かない

### Step 10: タイトルと本文を組む

タイトルと本文は`gh-pr-schema`に従う。

- baseがデフォルトブランチでない場合は`Closes`を書かない
- closeしないIssueは`Related:`で書く
- 関連Issueが無ければ見出しごと省く
- 作成したPRのdiffにない変更を本文へ含めない

### Step 11: 更新前に確認する

タイトルと本文をチャットへ出す。更新後に下書きを解除してreadyにすることと、そのときレビュー依頼と通知が飛ぶことをあわせて出す。

ユーザーが認めたあとだけPRを更新する。

修正指示があれば反映し、タイトルと本文を再度出す。確認前に仮タイトルと空の本文を変更しない。

### Step 12: PRを更新する

確認済みのタイトルと本文をJSONへ変換し、リポジトリ外の一時ファイルへ保存する。

```json
{
  "title": "<title>",
  "body": "<body>"
}
```

一時ファイルを`--input`へ渡し、作成済みPRを更新する。

```bash
gh api --method PATCH "repos/<owner>/<repo>/pulls/<number>" --input <payload-file>
```

Issueを起票しない。コミットしない。pushしない。

RESTの更新では下書きは解除できない。タイトルと本文を先に反映し、一致したあとだけreadyにする。

### Step 13: 内容が一致したらreadyにする

更新されたPRを取得する。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName
```

次が一致する場合だけreadyにする。

- stateが`OPEN`
- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- headRefNameがheadと一致する
- baseRefNameがbaseと一致する

一つでも違えばreadyにせず、差異とPR URLを返す。

一致したら、番号と`--repo`を省略せずreadyにする。省略するとカレントブランチのPRを見に行き、Gitに依存する。

```bash
gh pr ready <number> --repo <owner/repo>
```

同じ取得コマンドで、更新後のPRを再度確認する。

- stateが`OPEN`
- isDraftが`false`
- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- headRefNameがheadと一致する
- baseRefNameがbaseと一致する
- closeするIssueが、本文末尾の`Closes`行に一件ずつ書かれている

一致しない場合は成功として扱わず、差異とPR URLをユーザーへ返す。すべて一致したらPR URLを返す。一時ファイルは削除する。

## 安全条件

- 読み取り専用を含む`git`コマンドを実行しない
- Gitを内部で呼び出すツールを使わない
- `.git`を直接読んで禁止を迂回しない
- 下書きPRを作る前にdiffを取得しない
- 対象リポジトリ、base、headをGitから推測しない
- 同じheadのPRを重複して作成しない
- ユーザー確認前に下書きPRを作成しない
- 作成したPR以外のdiffを本文作成に使わない
- PRのdiffにない変更を本文へ含めない
- ユーザー確認前に仮タイトルと空の本文を更新しない
- タイトルと本文が確認済みの内容と一致する前にreadyにしない
- 作成や更新に失敗しても、PRを無断で閉じたり削除したりしない

## スキル連携

| 状況 | 使用するスキル |
|---|---|
| Gitコマンドを実行できる | `gh-pr-create` |
| Gitコマンドを実行でき、既存PRを更新する | `gh-pr-update` |
| AIによるGitコマンド実行が禁止されている | `gh-pr-create-no-git` |
| AIによるGitコマンド実行が禁止され、既存PRを更新する | `gh-pr-update-no-git` |
| headがGitHubへpushされていない | ユーザーがpushした後に再開する |
| PR本文の型 | `gh-pr-schema` |
