---
name: gh-issue-load
description: >
  スキル名と Issue 番号で呼ばれたときだけ、その GitHub Issue を読み込む。
  例: gh-issue-load 42、/gh-issue-load 42 owner/repo。
  「Issue を読み込んで」「内容を見せて」だけでは使わない。
  スキル名が無いときは使わない。
  スキル名のみなら番号を聞く。
  起票、更新、実装、PR 作成では使わない。
---

# gh-issue-load

## できること

- 指定した GitHub Issue を読み込む
- タイトル、状態、本文をチャットに出す
- Issue URL を返す

## いつ使うか

- `gh-issue-load <number>`
- `/gh-issue-load <number>`
- 第 2 引数に `owner/repo` があってもよい
- 「Issue を読み込んで」「内容を見せて」だけでは使わない
- スキル名が無いときは使わない
- スキル名のみなら番号を聞く

## 手順

### Step 1: 対象を決める

引数は Issue 番号が必須。スキル名だけで番号が無いときだけ止まって聞く。第 2 引数が `owner/repo`。省略時はカレントディレクトリのリポジトリ。

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

### Step 2: Issue を読み込む

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url
```

`--repo` はカレントディレクトリのリポジトリなら省略してよい。

タイトル、状態、本文をチャットに出す。Issue URL を返す。本文は書き換えない。起票、更新、実装、PR はしない。

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view --json nameWithOwner --jq .nameWithOwner` | 対象リポジトリを特定する |
| `gh issue view <number> --repo <owner/repo> --json number,title,state,body,url` | Issue を読み込む |
