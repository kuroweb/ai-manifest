---
name: gh-pr-create
description: >
  push済みブランチからGitHub Pull Requestを構造化して作成する。
  対象リポジトリ、base、head、既存PR、リモートとの差分を確認する。
  本文は`gh-pr-writing`で書く。
  例: gh-pr-create、gh-pr-create --issue 123。
  「PRを作成」「プルリクエストを開く」「レビューのために送信」などの操作を行う際に使用する。
---

# gh-pr-create

## できること

- push済みブランチからGitHub Pull Requestを作成する

## いつ使うか

- `gh-pr-create`
- `gh-pr-create --head feat/example`
- `gh-pr-create --head feat/example --base develop`
- `gh-pr-create --issue 123`
- push済みブランチからPull Requestを作成するとき

## 手順

### Step 1: 対象リポジトリとブランチを決める

対象リポジトリは、引数なしの`gh repo view`で取る。

```bash
gh repo view --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,default_branch:.defaultBranchRef.name}'
```

`repo`を`owner/repo`にする。`default_branch`はデフォルトブランチである。

以降の`gh`には、ここで得た`owner/repo`を`--repo`で渡す。

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. `gh repo view`で得たデフォルトブランチ

headは次の順で決める。

1. `--head`で指定されたリモートブランチ
2. 会話または直前の`git-push`で示されたリモートブランチ
3. 現在のローカルブランチが追跡するリモートブランチ
4. 現在のローカルブランチと同名のリモートブランチ

```bash
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git remote -v
```

headを一意に決められない場合はユーザーに聞く。baseとheadが同じ場合は停止する。

対象リポジトリに対応するgit remoteを、remote URLの`owner/repo`から特定する。対応するremoteが無い場合は停止する。

### Step 2: PRを作成できる状態か確認する

対象remoteのbaseを取得し、headがリモートに存在することを確認する。

```bash
git fetch <remote> <base>
git ls-remote --exit-code --heads <remote> refs/heads/<head>
```

headが存在しない場合は停止し、`git-push`でpushしてから再開する。

ローカルHEADとリモートheadのSHAを比較する。

```bash
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<head>
```

SHAが一致しない場合は停止する。ローカルが未push、リモートが先行、または別のコミットをheadとして選んでいるため、`gh-pr-create`では統合やpushを行わない。

リモートbaseとの差分コミット数を確認する。

```bash
git rev-list --count <remote>/<base>..HEAD
```

差分コミットが0なら停止する。

未コミットの変更がある場合は、その変更がPRに含まれないことを伝えて停止する。現在のpush済みコミットだけでPRを作成するとユーザーが明示した場合に限り続ける。

```bash
git status --porcelain
```

同じheadを使ったPRを、本文を作る前に確認する。

```bash
gh pr list --repo <owner/repo> --head <head> --state all --json number,state,url,headRefName,baseRefName
```

- `OPEN`のPRがあれば、新しいPRを作成せずURLを返す。タイトルや本文を変えるときは`gh-pr-update`を使う
- `MERGED`または`CLOSED`のPRがあれば、同じheadを再利用せず、新しいブランチを使う

### Step 3: closeするIssueを確認する

closeするIssueは次の順で決める。

1. `--issue`で指定されたIssue
2. 会話で示されたIssue

### Step 4: PRの差分を取る

PRに含まれるコミットとdiffを取る。

```bash
git --no-pager log <remote>/<base>..HEAD --format=%s%n%b
git --no-pager diff <remote>/<base>...HEAD
```

### Step 5: タイトルと本文を書く

`gh-pr-writing`で書く。根拠はStep 4のコミットとdiff、closeするIssueはStep 3のIssueにする。

### Step 6: PRを作成する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

```bash
gh pr create --repo <owner/repo> --base <base> --head <head> --title "<title>" --body-file <body-file>
```

Issueを起票しない。コミットしない。pushしない。

### Step 7: 作成結果を検証する

作成されたPRのタイトル、本文、base、head、URLを取得する。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,headRefName,baseRefName
```

次を確認する。

- stateが`OPEN`
- titleが書いたタイトルと一致する
- bodyが書いた本文と一致する
- headRefNameがheadと一致する
- baseRefNameがbaseと一致する
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらPR URLを返す。

## 禁止事項

- pushされていないheadからPRを作成しないこと
- ローカルHEADとリモートheadのSHAが異なる状態でPRを作成しないこと
- baseとの差分コミットがない状態でPRを作成しないこと
- 同じheadのopen、merged、closed PRがある場合は新しいPRを作成しないこと
- 本文を`--body`へ埋め込まないこと

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| PR作成 | `gh-pr-create` |
| PR更新 | `gh-pr-update` |
| Gitコマンド禁止環境でPR作成 | `gh-pr-create-no-git` |
| Gitコマンド禁止環境でPR更新 | `gh-pr-update-no-git` |
| pushしてPR作成 | `git-push` → `gh-pr-create` |
| コミットしてPR作成 | `git-commit` → `git-push` → `gh-pr-create` |
| PRの書き方 | `gh-pr-writing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `gh repo view --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,default_branch:.defaultBranchRef.name}'` | 対象リポジトリとデフォルトブランチを確認する |
| `git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'` | ローカルブランチのupstreamを確認する |
| `git fetch <remote> <base>` | リモートbaseを更新する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadの存在とSHAを確認する |
| `git rev-list --count <remote>/<base>..HEAD` | baseとの差分コミット数を確認する |
| `git --no-pager log <remote>/<base>..HEAD --format=%s%n%b` | PRに含まれるコミットを確認する |
| `git --no-pager diff <remote>/<base>...HEAD` | PRの変更内容を確認する |
| `gh pr list --repo <owner/repo> --head <head> --state all --json number,state,url,headRefName,baseRefName` | 同じheadの既存PRを確認する |
| `gh pr create --repo <owner/repo> --base <base> --head <head> --title "<title>" --body-file <body-file>` | 書いた内容でPRを作成する |
| `gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,headRefName,baseRefName` | 作成結果を検証する |
