---
name: gh-issue-list
description: >
  スキル名で呼ばれたときだけ、openなGitHub Issueの一覧を出す。
  例: gh-issue-list、gh-issue-list --repo owner/repo。
  「Issue一覧を見せて」「openなIssueは」だけでは使わない。
  スキル名が無いときは使わない。
---

# gh-issue-list

## できること

- open な GitHub Issue の一覧をチャットに出す
- 各 Issue の番号、タイトル、ラベル、更新日、URL を返す

## いつ使うか

- `gh-issue-list`
- `gh-issue-list --repo owner/repo`
- 「Issue一覧を見せて」「openなIssueは」だけでは使わない
- スキル名が無いときは使わない

## 手順

### Step 1: 対象を決める

対象リポジトリは `--repo owner/repo` で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの `<owner/repo>` も省略する。

### Step 2: open な Issue を取得する

本文は取らない。1件の本文が必要なら `gh-issue-load` を使う。

```bash
gh issue list --repo <owner/repo> --state open --limit 100 --json number,title,labels,updatedAt,url
```

`--repo` はカレントディレクトリのリポジトリなら省略してよい。

取得件数が 100 のときは、上限に達したので続きがあるかもしれないと伝える。

### Step 3: 一覧を出す

対象リポジトリと件数を先に書く。0件なら、open な Issue はないと返して終わる。

1件以上なら、更新日の新しい順に次の表で出す。ラベルが無いセルは空にする。更新日は `updatedAt` の日付（YYYY-MM-DD）にする。

| # | タイトル | ラベル | 更新日 |
|---|---|---|---|
| [#番号](url) | タイトル | ラベル名をカンマ区切り | YYYY-MM-DD |

起票、更新、クローズ、実装、PR はしない。

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| openなIssue一覧 | `gh-issue-list` |
| Issueを読むだけ | `gh-issue-load` |
| Issueを起票 | `gh-issue-create` |
| Issueを更新 | `gh-issue-update` |
| Issue本文の型 | `gh-issue-schema` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner` | 対象リポジトリを特定する |
| `gh issue list --repo <owner/repo> --state open --limit 100 --json number,title,labels,updatedAt,url` | open な Issue を取得する |
