---
name: gh-pr-update
description: >
  指定したGitHub Pull Requestのタイトルと本文を更新する。
  対象リポジトリ、既存PR、そのPRの差分を確認する。
  本文は`gh-pr-writing`で書く。
  例: gh-pr-update --pr 42。
  「PRを更新」「PRの説明を修正」「PRのタイトルを変更」などの操作を行う際に使用する。
  `--pr`が無いときは番号を聞く。
---

# gh-pr-update

## できること

- 指定したGitHub Pull Requestの既存内容を保ちながら、要求された箇所を更新する
- 対象リポジトリ、既存PR、そのPRの差分を更新前に確認する
- タイトルと本文は`gh-pr-writing`で書く
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `gh-pr-update --pr <number>`
- 既存Pull Requestのタイトルや本文を変えるとき

## 手順

### Step 1: 対象を決める

対象リポジトリは、引数なしの`gh repo view`で取る。

```bash
gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'
```

`repo`を`owner/repo`にする。以降の`gh`には、ここで得た`owner/repo`を`--repo`で渡す。

PR番号は`--pr`で指定する。`--pr`が無いときだけ止まって聞く。現在のブランチのPRを候補として示してよい。番号をユーザーが認めるまで更新しない。

### Step 2: 既存PRを読む

既存PRを取得する。番号と`--repo`を省略しない。省略するとカレントブランチのPRを見に行く。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName,headRefOid
```

`OPEN`でなければ状態とURLを示し、ユーザーが続行を明示するまで待つ。

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 3: そのPRの差分を取る

本文の根拠は、そのPRに入っている差分だけにする。

対象リポジトリに対応するgit remoteを、remote URLの`owner/repo`から特定する。対応するremoteが無い場合は停止する。headは既存PRの`headRefName`、baseは`baseRefName`とする。

```bash
git fetch <remote> <base> <head>
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<head>
git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b
git --no-pager diff <remote>/<base>...<remote>/<head>
```

ローカルHEADとリモートheadのSHAが違う場合は、未pushの差分を本文に含めない。その旨を伝えてから続行する。新しいコミットをPRへ載せてから本文を書くなら、`git-push`のあとで再開する。

diffを取得できなければ本文を作らない。

### Step 4: タイトルと本文を書く

`gh-pr-writing`で書く。既存PRはStep 2で読んだもの、根拠はStep 3のコミットとdiffにする。

### Step 5: PRを更新する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

番号と`--repo`を省略しない。base、draft、レビュアー、ラベル、担当者は変えない。

```bash
gh pr edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>
```

Issueを起票しない。コミットしない。pushしない。`gh pr ready`と`gh pr draft`は使わない。

### Step 6: 更新結果を検証する

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

一致しない場合は成功として扱わず、差異とPR URLを返す。すべて一致したらPR URLと、変更した箇所を返す。

## 安全条件

- `OPEN`でないPRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draft、レビュアー、ラベル、担当者を変えない
- 未pushのコミットを本文へ含めない
- 本文は`--body-file`で渡す
- 番号と`--repo`を省略しない
- 更新後の値を再取得して検証する

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| PR作成 | `gh-pr-create` |
| PR更新 | `gh-pr-update` |
| Gitコマンド禁止環境でPR作成 | `gh-pr-create-no-git` |
| Gitコマンド禁止環境でPR更新 | `gh-pr-update-no-git` |
| pushしてから本文を更新 | `git-push` → `gh-pr-update` |
| PRの書き方 | `gh-pr-writing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'` | 対象リポジトリを確認する |
| `gh pr view <number> --repo <owner/repo> --json ...` | 既存PRと更新結果を確認する |
| `git fetch <remote> <base> <head>` | リモートのbaseとheadを取得する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadのSHAを確認する |
| `git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b` | PRに含まれるコミットを確認する |
| `git --no-pager diff <remote>/<base>...<remote>/<head>` | PRに含まれる差分を確認する |
| `gh pr edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>` | 書いたタイトルと本文で更新する |
