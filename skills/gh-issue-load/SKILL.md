---
name: gh-issue-load
description: >
  スキル名と Issue 番号で呼ばれたときだけ、その GitHub Issue を読み込む。
  例: gh-issue-load --number 42、gh-issue-load --repo owner/repo --number 42。
  「Issue を読み込んで」「内容を見せて」だけでは使わない。
  スキル名が無いときは使わない。
  `--number` が無いときは番号を聞く。
  起票は gh-issue-create、更新は gh-issue-update を使う。実装、PR 作成では使わない。
---

# gh-issue-load

## できること

- 指定した GitHub Issue を読み込む
- タイトル、状態、本文をチャットに出す
- Issue URL を返す

## いつ使うか

- `gh-issue-load --number <number>`
- `gh-issue-load --repo owner/repo --number <number>`
- 「Issue を読み込んで」「内容を見せて」だけでは使わない
- スキル名が無いときは使わない
- `--number` が無いときは番号を聞く

## 手順

### Step 1: 対象を決める

対象リポジトリは `--repo owner/repo` で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの `<owner/repo>` も省略する。

Issue 番号は `--number` で指定する。`--number` が無いときだけ止まって聞く。

### Step 2: Issue を読み込む

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url
```

`--repo` はカレントディレクトリのリポジトリなら省略してよい。

タイトル、状態、本文をチャットに出す。Issue URL を返す。本文は書き換えない。起票、更新、実装、PR はしない。

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| Issueを読むだけ | `gh-issue-load` |
| Issueを起票 | `gh-issue-create` |
| Issueを更新 | `gh-issue-update` |
| Issue本文の型 | `gh-issue-schema` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner` | 対象リポジトリを特定する |
| `gh issue view <number> --repo <owner/repo> --json number,title,state,body,url` | Issue を読み込む |
