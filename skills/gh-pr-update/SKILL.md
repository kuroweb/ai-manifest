---
name: gh-pr-update
description: >
  スキル名で呼ばれたときだけ、指定したGitHub Pull Requestのタイトルと本文を確認後に更新する。
  対象リポジトリ、既存PR、そのPRの差分を確認し、gh-pr-schemaに沿って本文を作る。
  例: gh-pr-update --number 42、gh-pr-update --repo owner/repo --number 42。
  「PRを更新して」だけでは使わない。
  スキル名が無いときは使わない。
  `--number`が無いときは番号を聞く。
  AIによるGitコマンド実行が禁止されているプロジェクトでは使わず、gh-pr-update-no-gitを使用する。
  PRの新規作成、Issue起票、実装、コミット、pushは行わない。
---

# gh-pr-update

## できること

- 指定したGitHub Pull Requestの既存内容を保ちながら、要求された箇所を更新する
- 対象リポジトリ、既存PR、そのPRの差分を更新前に確認する
- `gh-pr-schema`に沿ってタイトルと本文を組み立てる
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `gh-pr-update --number <number>`
- `gh-pr-update --repo owner/repo --number <number>`
- 既存Pull Requestのタイトルや本文を変えるとき

## 手順

### Step 1: 対象を決める

対象リポジトリは`--repo owner/repo`で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

PR番号は`--number`で指定する。`--number`が無いときだけ止まって聞く。カレントディレクトリが対象リポジトリなら、現在のブランチのPRを候補として示してよい。番号をユーザーが認めるまで更新しない。

### Step 2: スキーマと既存PRを読む

`gh-pr-schema`を読む。タイトルや本文を組む前に読む。

既存PRを取得する。番号と`--repo`を省略しない。省略するとカレントブランチのPRを見に行く。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName,headRefOid
```

`OPEN`でなければ状態とURLを示し、ユーザーが続行を明示するまで待つ。

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 3: そのPRの差分を取る

本文の根拠は、そのPRに入っている差分だけにする。

対象リポジトリに対応するgit remoteを、remote URLの`owner/repo`から特定する。対応するremoteが無い場合は停止する。headは既存PRの`headRefName`、baseは`baseRefName`とする。

カレントディレクトリが対象リポジトリのとき、リモートの差分を取る。

```bash
git fetch <remote> <base> <head>
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<head>
git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b
git --no-pager diff <remote>/<base>...<remote>/<head>
```

ローカルHEADとリモートheadのSHAが違う場合は、未pushの差分を本文に含めない。その旨を伝えてから続行する。新しいコミットをPRへ載せてから本文を書くなら、`git-push`のあとで再開する。

カレントディレクトリが対象リポジトリでないときは、次で差分とコミットを取る。

```bash
gh pr diff <number> --repo <owner/repo>
gh pr view <number> --repo <owner/repo> --json commits
```

diffを取得できなければ本文を作らない。

### Step 4: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。変えない箇所については聞かない。

- 変更目的を書き換えるのに会話へ無ければ聞く。diffから推測しない
- closeするIssueを変更するときは、会話で示されたIssue番号を使う

### Step 5: タイトルと本文を組む

タイトルと本文は`gh-pr-schema`に従う。

要求された変更と整合に必要な変更だけを加える。既存本文がスキーマに沿っている箇所は残し、空になった見出しは残さない。

- PRのdiffにない変更を本文へ含めない

### Step 6: 更新前に確認する

対象リポジトリ、PR番号、タイトル、本文をチャットに出す。変更する箇所が分かるように示す。

ユーザーが認めたあとだけ更新する。修正指示があれば反映し、タイトルと本文を再度出す。確認前に更新しない。

### Step 7: PRを更新する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

番号と`--repo`を省略しない。base、draft、レビュアー、ラベル、担当者は変えない。

```bash
gh pr edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>
```

Issueを起票しない。コミットしない。pushしない。`gh pr ready`と`gh pr draft`は使わない。

### Step 8: 更新結果を検証する

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

一致しない場合は成功として扱わず、差異とPR URLを返す。すべて一致したらPR URLを返す。

## 安全条件

- ユーザー確認前にPRを更新しない
- `OPEN`でないPRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draft、レビュアー、ラベル、担当者を変えない
- PRのdiffにない変更を本文へ含めない
- 未pushのコミットを本文へ含めない
- 本文は`--body-file`で渡す
- 番号と`--repo`を省略しない
- 更新後の値を再取得して検証する

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| PR作成 | `gh-pr-create` |
| PR更新 | `gh-pr-update` |
| Gitコマンド禁止環境でPR作成 | `gh-pr-create-no-git` |
| Gitコマンド禁止環境でPR更新 | `gh-pr-update-no-git` |
| pushしてから本文を更新 | `git-push` → `gh-pr-update` |
| PR本文の型 | `gh-pr-schema` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view <owner/repo> --json nameWithOwner` | 対象リポジトリを確認する |
| `gh pr view <number> --repo <owner/repo> --json ...` | 既存PRと更新結果を確認する |
| `git fetch <remote> <base> <head>` | リモートのbaseとheadを取得する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadのSHAを確認する |
| `git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b` | PRに含まれるコミットを確認する |
| `git --no-pager diff <remote>/<base>...<remote>/<head>` | PRに含まれる差分を確認する |
| `gh pr diff <number> --repo <owner/repo>` | 対象リポジトリの外からPRの差分を確認する |
| `gh pr edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>` | 確認済みのタイトルと本文で更新する |
