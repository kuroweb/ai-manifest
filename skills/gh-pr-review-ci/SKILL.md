---
name: gh-pr-review-ci
description: >
  CIなど対話できない環境で、指定したGitHub Pull Requestの差分と説明を読み、レビューは`code-reviewing`に任せる。
  ユーザーに聞き返さず、確認が必要な点は判定`要確認`として結果に書く。
  例: gh-pr-review-ci --pr 42。
  Claude Code ActionなどのワークフローからPRを自動レビューする際に使用する。
  対話セッションでのPRレビューには`gh-pr-review`を使う。
---

# gh-pr-review-ci

## できること

- 指定したGitHub Pull Requestの説明とdiffを取得する
- レビューは`code-reviewing`に任せる
- 聞き返さずにレビュー結果を最終回答として返す

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

- 対話できない環境である。ユーザーに聞く手順では聞かず、判定を`要確認`にして、確認したい事項を総評に書く
- 変更目的が「未記載」なら、判定を`承認`にしない。PR本文に変更目的を書くよう総評で求める

`code-reviewing`にdiffの再取得をさせない。

### Step 6: 結果を返す

`code-reviewing`の本文を最終回答として返す。

PRへのコメント投稿は呼び出し元が行う。このスキルではコメントを投稿しない。

## 安全条件

- ユーザーに聞き返さない
- diffなしで`code-reviewing`に進まない
- `code-reviewing`を読まずにレビュー結果を組み立てない
- 変更目的をdiffから推測しない
- PRのタイトル、本文、レビューコメントを変更しない
- PRにコメントを投稿しない

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
