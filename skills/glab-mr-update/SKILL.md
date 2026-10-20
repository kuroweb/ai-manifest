---
name: glab-mr-update
description: >
  指定したGitLab Merge Requestのタイトルと本文を更新する。
  対象プロジェクト、既存MR、そのMRの差分を確認する。
  本文は`glab-mr-writing`で書く。
  例: glab-mr-update --mr 42。
  「MRを更新」「MRの説明を修正」「MRのタイトルを変更」などの操作を行う際に使用する。
  `--mr`が無いときはiidを聞く。
---

# glab-mr-update

## できること

- 指定したGitLab Merge Requestの既存内容を保ちながら、要求された箇所を更新する
- 対象プロジェクト、既存MR、そのMRの差分を更新前に確認する
- タイトルと本文は`glab-mr-writing`で書く
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `glab-mr-update --mr <iid>`
- 既存Merge Requestのタイトルや本文を変えるとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: 対象を決める

対象プロジェクトは、引数なしの`glab repo view`で取る。

```bash
glab repo view -F json --jq '{path:.path_with_namespace,web_url:.web_url}'
```

`path`をプロジェクトパスにする。ホストは`web_url`から取る。スキームとパスを除く。ポートがあれば`host:port`。

MRのiidは`--mr`で指定する。`--mr`が無いときだけ止まって聞く。

対象プロジェクトに対応するgit remoteを、remote URLのホストとプロジェクトパスから特定する。パス比較では末尾の`.git`を除く。対応するremoteが無い、または複数あって一意でない場合は停止する。

以降の`glab`には、そのremote URLを`--repo`で渡す。Self-Managedでもカレントディレクトリのホスト設定に依存しない。

### Step 2: 既存MRを読む

```bash
glab mr view <iid> --repo <remote-url> -F json
```

JSONの`iid`、`state`、`draft`、`title`、`description`、`source_branch`、`target_branch`、`web_url`、`sha`を見る。

`opened`でなければ状態とURLを示し、ユーザーが続行を明示するまで待つ。

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 3: そのMRの差分を取る

headは`source_branch`、baseは`target_branch`とする。本文の根拠は、リモートに載っている差分だけにする。

```bash
git fetch <remote> <base> <head>
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<head>
git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b
git --no-pager diff <remote>/<base>...<remote>/<head>
```

ローカルHEADとリモートheadのSHAが違う場合は、未pushの差分を本文に含めない。その旨を伝えてから続行する。新しいコミットをMRへ載せてから本文を書くなら、`git-push`のあとで再開する。

diffを取得できなければ本文を作らない。

### Step 4: タイトルと本文を書く

`glab-mr-writing`で書く。既存MRはStep 2で読んだもの、根拠はStep 3のコミットとdiffにする。

### Step 5: MRを更新する

本文をリポジトリ外の一時ファイルへ書き、`--description-file`で渡す。複数行の本文を`--description`へ埋め込まない。

iidを省略しない。省略するとカレントブランチのMRを更新する。

```bash
glab mr update <iid> --repo <remote-url> --title "<title>" --description-file <body-file> --yes
```

`--push`、`--fill`、`--fill-commit-body`、`--draft`、`--ready`、`--target-branch`は使わない。

Issueを起票しない。コミットしない。pushしない。

### Step 6: 更新結果を検証する

```bash
glab mr view <iid> --repo <remote-url> -F json
```

次を確認する。

- titleが書いたタイトルと一致する
- descriptionが書いた本文と一致する
- stateが更新前と一致する
- draftが更新前と一致する
- source_branchが更新前と一致する
- target_branchが更新前と一致する
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異とMR URLを返す。すべて一致したらMR URLと、変更した箇所を返す。

## 禁止事項

- `opened`でないMRを、明示的な続行指示なしに更新しないこと
- 更新対象外のタイトル、本文、base、head、state、draftを変えないこと
- ユーザーの明示なしに`Draft:`を外さないこと
- 未pushのコミットを本文へ含めないこと
- 本文を`--description`へ埋め込まないこと
- iidと`--repo`を省略しないこと
- `--push`、`--fill`、`--ready`を使わないこと
- 更新後の値を再取得せずに成功として扱わないこと

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| MR作成 | `glab-mr-create` |
| MR更新 | `glab-mr-update` |
| Gitコマンド禁止環境でMR作成 | `glab-mr-create-no-git` |
| Gitコマンド禁止環境でMR更新 | `glab-mr-update-no-git` |
| pushしてから本文を更新 | `git-push` → `glab-mr-update` |
| MRの書き方 | `glab-mr-writing` |
| GitHubのPull Request | `gh-pr-update` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `glab repo view -F json --jq '{path:.path_with_namespace,web_url:.web_url}'` | 対象プロジェクトを確認する |
| `glab mr view <iid> --repo <remote-url> -F json` | 既存MRと更新結果を確認する |
| `git fetch <remote> <base> <head>` | リモートのbaseとheadを取得する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadのSHAを確認する |
| `git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b` | MRに含まれるコミットを確認する |
| `git --no-pager diff <remote>/<base>...<remote>/<head>` | MRに含まれる差分を確認する |
| `glab mr update <iid> --repo <remote-url> --title "<title>" --description-file <body-file> --yes` | 書いたタイトルと本文で更新する |
