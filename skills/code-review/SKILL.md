---
name: code-review
description: >
  マージ先と作業ブランチのdiffをgitで取得し、レビューは`code-reviewing`に任せる。
  `--base`はマージ先、`--head`は作業ブランチとして使う。
  例: code-review、code-review --head feat/example --base develop。
  「コードレビューして」「diffをレビューして」「変更差分の懸念を確認して」などの操作を行う際に使用する。
---

# code-review

## できること

- gitで三点比較のdiffを取得する
- レビューは`code-reviewing`に任せる

## いつ使うか

- `code-review`
- `code-review --head feat/example`
- `code-review --head feat/example --base develop`
- コードレビューして
- diffをレビューして
- 変更差分の懸念を確認して

## 手順

### Step 1: baseとheadを決める

baseはマージ先、headは作業ブランチである。

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. ユーザーに聞く

headは次の順で決める。

1. `--head`で指定されたブランチ
2. 会話で指定されたブランチ
3. 現在のローカルブランチ

3の場合は次で取得する。

```bash
git branch --show-current
```

headを一意に決められない場合はユーザーに聞く。baseとheadが同じ場合は停止する。

足りないブランチは、一度に一つ聞く。

### Step 2: diffを取得する

三点比較のフルdiffを取得する。pagerを避けるため`--no-pager`を付ける。

```bash
git --no-pager diff <base>...<head>
```

`<base>`はStep 1で決めたマージ先、`<head>`はStep 1で決めた作業ブランチで埋める。

diffが会話に既にある場合でも、ブランチが不明、または三点比較の全体か判断できない場合は、上記コマンドを再実行する。

diffが取得できるまで次へ進まない。

### Step 3: レビューする

`code-reviewing`を読む。評価、本文、返却はその手順に従う。

渡す情報は、Step 2のdiffである。変更目的の確認は`code-reviewing`に任せる。

## 安全条件

- diffなしで`code-reviewing`に進まない
- `code-reviewing`を読まずにレビュー結果を組み立てない
- baseとheadが同じ場合はレビューしない

## スキル連携

| 状況 | 使用するスキル |
| --- | --- |
| ローカルブランチのdiffをgitで取る | `code-review` |
| レビュー | `code-reviewing` |
| AIによるGitコマンド実行が禁止されている | `code-review-no-git` |
| 指定したGitHub PRをレビューする | `gh-pr-review` |
| 指定したGitLab MRをレビューする | `glab-mr-review` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `git branch --show-current` | 現在のローカルブランチを確認する |
| `git --no-pager diff <base>...<head>` | 三点比較のフルdiffを取得する |
