---
name: gh-issue-update
description: >
  指定したGitHub Issueを構造化して更新する。
  対象、既存Issue、担当状況、関連PR、Issue typeを確認し、本文は`gh-issue-writing`で書く。
  例: gh-issue-update --issue 42、gh-issue-update --repo owner/repo --issue 42。
  「Issueを更新」「Issueに追記」「Issueの内容を修正」などの操作を行う際に使用する。
  `--issue`が無いときは番号を聞く。
---

# gh-issue-update

## できること

- 指定したGitHub Issueの既存内容を保ちながら、要求された箇所を更新する
- 担当状況、関連PRを変更前に確認する
- Issue typeが使えるかを確かめ、更新後の内容を検証する

## いつ使うか

- `gh-issue-update --issue <number>`
- `gh-issue-update --repo owner/repo --issue <number>`
- 既存Issueに書いてある要求を変えるとき

## 手順

### Step 1: 対象を決める

対象リポジトリは`--repo owner/repo`で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

Issue番号は`--issue`で指定する。`--issue`が無いときだけ止まって聞く。

### Step 2: 既存Issueを読む

既存Issueと作業状況を一度に取得する。

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url,assignees,labels,issueType,closedByPullRequestsReferences
gh api user --jq .login
```

次に該当する場合は状況とURLを示し、ユーザーが続行を明示するまで待つ。

- Issueが閉じている
- このIssueをcloseするopen PRがある
- 現在のGitHubユーザー以外が担当している
- `in-progress`ラベルがある

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 3: タイトル、本文、Issue typeを書く

`gh-issue-writing`で書く。

### Step 4: Issue typeが使えるかを確かめる

Issue typeを変えるときだけ、対象リポジトリのIssue type一覧を取得し、書いたIssue typeが存在するときだけ設定する。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name } } } }'
```

存在しなければ、既存のIssue typeを変更しない。

### Step 5: 更新する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

Issue typeを変える場合だけ`--type`を付ける。

```bash
gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]
```

Issueの状態、担当者、ラベルは変更しない。実装しない。PRを作成しない。

### Step 6: 結果を検証する

`--issue`の値を使って結果を取得する。

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url,issueType
```

次を確認する。

- titleが書いたタイトルと一致する
- bodyが書いた本文と一致する
- Issue typeを変更した場合は、その値と一致する
- stateが変更前と一致する

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらIssue URLと、変更した箇所を返す。

## 禁止事項

- closed Issue、関連するopen PR、他者の担当、`in-progress`を無視して更新しないこと
- 更新対象外のタイトル、本文、Issue type、状態、担当者、ラベルを変えないこと
- 本文を`--body`へ埋め込まないこと
- 更新後の値を再取得せずに成功として扱わないこと

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| openなIssue一覧 | `gh-issue-list` |
| Issueを読むだけ | `gh-issue-load` |
| Issueを起票 | `gh-issue-create` |
| Issueを更新 | `gh-issue-update` |
| Issueの書き方 | `gh-issue-writing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `gh repo view <owner/repo> --json nameWithOwner` | 対象リポジトリを確認する |
| `gh issue view <number> --repo <owner/repo> --json ...` | 既存Issueと作業状況を確認する |
| `gh api user --jq .login` | 現在のGitHubユーザーを確認する |
| `gh api graphql`（`issueTypes`） | 利用できるIssue typeを確認する |
| `gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]` | 書いた内容で更新する |
| `gh issue view <number> --repo <owner/repo> --json number,title,state,body,url,issueType` | 更新結果を検証する |
