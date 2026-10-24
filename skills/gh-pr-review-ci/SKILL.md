---
name: gh-pr-review-ci
description: >
  CIなど対話できない環境で、指定したGitHub Pull Requestの差分と説明を読み、レビューは`code-reviewing`に任せる。
  ユーザーに聞き返さずにレビューする。
  例: gh-pr-review-ci --pr 42。
  Claude Code ActionなどのワークフローからPRを自動レビューする際に使用する。
  対話セッションでのPRレビューには`gh-pr-review`を使う。
---

# gh-pr-review-ci

## できること

- CIなど対話できない環境で、聞き返さずにGitHub Pull Requestをレビューする

## いつ使うか

- `gh-pr-review-ci --pr <number>`
- Claude Code ActionなどのCIからPull Requestをレビューするとき

対話セッションでは`gh-pr-review`を使う。GitLabのMerge Requestには使わない。

## 手順

### Step 1: 対象を決める

対象リポジトリは、引数なしの`gh repo view`で取る。

```bash
gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'
```

`repo`を`owner/repo`にする。以降の`gh`には、ここで得た`owner/repo`を`--repo`で渡す。

PR番号は`--pr`で指定する。`--pr`が無ければレビューせず、`--pr`が必要なことを最終回答として返して終える。

### Step 2: PRの説明を読む

番号と`--repo`を省略しない。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName
```

説明は`title`と`body`である。取得できなければレビューせず、エラー内容を最終回答として返して終える。

### Step 3: PRのdiffを取る

差分は、そのPRに入っているdiffだけにする。

```bash
gh pr diff <number> --repo <owner/repo>
```

diffを取得できなければレビューせず、エラー内容を最終回答として返して終える。差分が大きすぎるとGitHub APIがdiffを返さないことがある。現在のファイル内容からdiffを補わない。

### Step 4: 変更目的を決める

変更目的はPRの`body`から取る。`title`だけで変更目的を補わない。diffから変更目的を推測しない。

`body`が空なら、変更目的は「未記載」として次へ進む。

### Step 5: レビューする

`code-reviewing`を読む。評価と本文はその手順に従う。

渡す情報は、Step 3のdiff、Step 4の変更目的、次の条件である。

- 対話できない環境である。ユーザーに聞く手順では聞かない

`code-reviewing`にdiffの再取得をさせない。このStepの本文は最終回答にしない。

### Step 6: レビューコメントを投稿する

`references/pr-comment.md` を読み、その型でレビューコメントを投稿する。

投稿するのはその型だけにする。最終回答もその型だけにする。

### Step 7: 指摘事項をインラインコメントで投稿する

`references/inline-comment.md` を読み、その型で、`code-reviewing` の指摘事項を `mcp__github_inline_comment__create_inline_comment` で投稿する。1つの対象箇所につき1コメントにする。

次をすべて満たす指摘だけを投稿する。

- `対象ファイル` に行番号がある。`[path]:[開始]` または `[path]:[開始]-[終了]`
- その行が、Step 3 で取った diff の、そのファイルの変更後側に出ている。範囲のときは `[開始]` と `[終了]` の両方が出ている

`path` は対象ファイルのパスにする。行が1行のときは `line` を `[開始]` にする。範囲のときは `startLine` を `[開始]`、`line` を `[終了]` にする。`side` は `RIGHT`、`confirmed` は `true` にする。`commit_id` は渡さない。

## 禁止事項

- ユーザーに聞き返さないこと
- diffなしで`code-reviewing`に進まないこと
- `code-reviewing`を読まずにレビュー結果を組み立てないこと
- `references/pr-comment.md` を読まずにレビューコメントを投稿しないこと
- `references/inline-comment.md` を読まずにインラインコメントを投稿しないこと
- 変更目的をdiffから推測しないこと
- PRのタイトル、本文、レビューコメントを変更しないこと
- 折りたたむときに、本文の文言を変えないこと

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| CIから指定したGitHub PRをレビューする | `gh-pr-review-ci` → `code-reviewing` |
| 対話セッションで指定したGitHub PRをレビューする | `gh-pr-review` |
| レビュー | `code-reviewing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `gh repo view --json nameWithOwner --jq '{repo:.nameWithOwner}'` | 対象リポジトリを確認する |
| `gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,isDraft,headRefName,baseRefName` | PRの説明とbase、headを確認する |
| `gh pr diff <number> --repo <owner/repo>` | PRのdiffを取得する |
