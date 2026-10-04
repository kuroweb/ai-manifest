---
name: gh-pr-review
description: >
  指定したGitHub Pull Requestの差分と説明を読み、レビューは`code-reviewing`に任せる。
  例: gh-pr-review --pr 42。
  「PRをレビュー」「このPRをレビューして」「PRの差分を見て」などの操作を行う際に使用する。
  `--pr`が無いときは番号を聞く。
---

# gh-pr-review

## できること

- 指定したGitHub Pull Requestの説明とdiffを取得する
- レビューは`code-reviewing`に任せる

## いつ使うか

- `gh-pr-review --pr <number>`
- 指定したPull Requestの差分と説明をレビューするとき

GitLabのMerge Requestには使わない。

## 手順

### Step 1: 対象を決める

対象リポジトリは、引数なしの`gh repo view`で取る。

```bash
gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'
```

`repo`を`owner/repo`にする。以降の`gh`には、ここで得た`owner/repo`を`--repo`で渡す。

PR番号は`--pr`で指定する。`--pr`が無いときだけ止まって聞く。現在のブランチのPRを候補として示してよい。番号をユーザーが認めるまでレビューしない。

### Step 2: PRの説明を読む

番号と`--repo`を省略しない。省略するとカレントブランチのPRを見に行く。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName
```

説明は`title`と`body`である。取得できなければ次へ進まない。

### Step 3: PRのdiffを取る

差分は、そのPRに入っているdiffだけにする。

```bash
gh pr diff <number> --repo <owner/repo>
```

diffを取得できなければ次へ進まない。現在のファイル内容や会話中の未push変更からdiffを補わない。

### Step 4: 変更目的を決める

変更目的は次の順で決める。

1. PRの`body`
2. 会話で示された変更目的
3. ユーザーに聞く

`body`が空なら、一度に一つ聞く。`title`だけで変更目的を補わない。diffから変更目的を推測しない。

説明とdiffが矛盾した場合は、自動解決せず確認する。

### Step 5: レビューする

`code-reviewing`を読む。評価、本文、返却はその手順に従う。

渡す情報は、Step 3のdiffとStep 4の変更目的である。`code-reviewing`にdiffの再取得と変更目的の聞き直しをさせない。

## 安全条件

- diffなしで`code-reviewing`に進まない
- `code-reviewing`を読まずにレビュー結果を組み立てない
- 変更目的をdiffから推測しない
- PRのタイトル、本文、レビューコメントを変更しない

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| 指定したGitHub PRをレビューする | `gh-pr-review` → `code-reviewing` |
| CIから指定したGitHub PRをレビューする | `gh-pr-review-ci` |
| 指定したGitLab MRをレビューする | `glab-mr-review` |
| ローカルブランチのdiffをgitで取る | `code-review` |
| Gitコマンドを実行せず、貼られたdiffをレビューする | `code-review-no-git` |
| レビュー | `code-reviewing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'` | 対象リポジトリを確認する |
| `gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName` | PRの説明とbase、headを確認する |
| `gh pr diff <number> --repo <owner/repo>` | PRのdiffを取得する |
