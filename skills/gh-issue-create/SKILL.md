---
name: gh-issue-create
description: >
  GitHub Issueを構造化して起票する。
  対象、重複、Issue typeを確認し、本文は`gh-issue-writing`で書く。
  例: gh-issue-create、gh-issue-create --repo owner/repo。
  「Issueを作成」「Issueを起票」「チケットを切る」などの操作を行う際に使用する。
---

# gh-issue-create

## できること

- GitHub Issueを起票する
- 重複しそうな既存Issueがあれば、起票前に知らせる

## いつ使うか

- `gh-issue-create`
- `gh-issue-create --repo owner/repo`
- 新しいIssueとして要求を残すとき

## 手順

### Step 1: 対象を決める

対象リポジトリは`--repo owner/repo`で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

### Step 2: タイトル、本文、Issue typeを書く

`gh-issue-writing`で書く。

### Step 3: Issue typeが使えるかを確かめる

対象リポジトリのIssue type一覧を取得し、書いたIssue typeが存在するときだけ設定する。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name } } } }'
```

存在しなければ、Issue typeを設定しない。

### Step 4: 起票前の重複を確認する

タイトルと本文を書いたあと、起票する前に一度検索する。タイトルと主要なキーワードを使い、openとclosedの両方を対象にする。

```bash
gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10 --json number,title,state,url
```

重複の可能性があるIssueを見つけたらURLと判断理由を示す。ユーザーがそれでも起票すると明示するまで次へ進まない。

### Step 5: 起票する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

利用できるIssue typeがある場合だけ`--type`を付ける。コマンドが返すIssue URLを保持し、作成結果の識別子として使う。

```bash
gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]
```

実装しない。PRを作成しない。

### Step 6: 結果を検証する

作成時に得たURLを使って結果を取得する。

```bash
gh issue view <url> --repo <owner/repo> --json number,title,state,body,url,issueType
```

次を確認する。

- titleが書いたタイトルと一致する
- bodyが書いた本文と一致する
- Issue typeを設定した場合は、その値と一致する
- stateが`OPEN`である

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらIssue URLを返す。

## 禁止事項

- 重複の可能性があるIssueを、明示的な続行指示なしに起票しないこと
- 本文を`--body`へ埋め込まないこと
- 起票後の値を再取得せずに成功として扱わないこと

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
| `gh api graphql`（`issueTypes`） | 利用できるIssue typeを確認する |
| `gh issue list --repo <owner/repo> --search "<keywords>" --state all` | 起票前に重複Issueを探す |
| `gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]` | 書いた内容で起票する |
| `gh issue view <url> --repo <owner/repo> --json number,title,state,body,url,issueType` | 起票結果を検証する |
