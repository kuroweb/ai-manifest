---
name: glab-mr-update
description: >
  スキル名で呼ばれたときだけ、指定したGitLab Merge Requestのタイトルと本文を確認後に更新する。
  対象プロジェクト、既存MR、そのMRの差分を確認し、glab-mr-schemaに沿って本文を作る。
  例: glab-mr-update --number 42、glab-mr-update --repo group/project --number 42。
  「MRを更新して」だけでは使わない。
  スキル名が無いときは使わない。
  `--number`が無いときはiidを聞く。
  AIによるGitコマンド実行が禁止されているプロジェクトでは使わず、glab-mr-update-no-gitを使用する。
  MRの新規作成、Issue起票、実装、コミット、pushは行わない。
---

# glab-mr-update

## できること

- 指定したGitLab Merge Requestの既存内容を保ちながら、要求された箇所を更新する
- 対象プロジェクト、既存MR、そのMRの差分を更新前に確認する
- `glab-mr-schema`に沿ってタイトルと本文を組み立てる
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `glab-mr-update --number <iid>`
- `glab-mr-update --repo group/project --number <iid>`
- `glab-mr-update --repo group/subgroup/project --number <iid>`
- 既存Merge Requestのタイトルや本文を変えるとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: 対象を決める

対象プロジェクトは`--repo`で指定する。`group/project`、`group/subgroup/project`、またはURL。省略時はカレントディレクトリのリポジトリとする。URLの場合は末尾の`.git`を除いたパスをプロジェクトパスにする。

```bash
glab repo view <project> -F json --jq '{path:.path_with_namespace,base:.default_branch,web_url:.web_url}'
```

対象プロジェクトを省略した呼び出しでは、コマンドの`<project>`も省略する。

MRのiidは`--number`で指定する。`--number`が無いときだけ止まって聞く。

対象プロジェクトに対応するgit remoteを、remote URLのホストとプロジェクトパスから特定する。パス比較では末尾の`.git`を除く。対応するremoteが無い、または複数あって一意でない場合は停止する。カレントディレクトリが対象プロジェクトでない場合も停止する。

以降の`glab`には、そのremote URLを`--repo`で渡す。Self-Managedでもカレントディレクトリのホスト設定に依存しない。

### Step 2: スキーマと既存MRを読む

`glab-mr-schema`を読む。タイトルや本文を組む前に読む。

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

### Step 4: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。変えない箇所については聞かない。

- 変更目的を書き換えるのに会話へ無ければ聞く。diffから推測しない
- 関連Issueの扱いを変えるとき、closeするか参照だけにするか決まっていなければ聞く
- baseがデフォルトブランチで、候補が一つのときは`Closes`を推奨する
- 関連Issueの候補が無ければ、Issue番号を聞かない

### Step 5: タイトルと本文を組む

タイトルと本文は`glab-mr-schema`に従う。

要求された変更と整合に必要な変更だけを加える。既存本文がスキーマに沿っている箇所は残し、空になった見出しは残さない。

- baseがデフォルトブランチでない場合は`Closes`を書かない
- closeしないIssueは`Related:`で書く
- 関連Issueが無ければ見出しごと省く
- MRのdiffにない変更を本文へ含めない
- 本文の行を`/`で始めない
- `draft`がtrueで、ユーザーがreadyにすると明示していないときは、タイトル先頭の`Draft:`を残す。外すとGitLabはそのMRをreadyにする

### Step 6: 更新前に確認する

対象プロジェクト、iid、タイトル、本文をチャットに出す。変更する箇所が分かるように示す。draftを維持するときは、そのことも出す。

ユーザーが認めたあとだけ更新する。修正指示があれば反映し、タイトルと本文を再度出す。確認前に更新しない。

### Step 7: MRを更新する

本文をリポジトリ外の一時ファイルへ書き、`--description-file`で渡す。複数行の本文を`--description`へ埋め込まない。

iidを省略しない。省略するとカレントブランチのMRを更新する。

```bash
glab mr update <iid> --repo <remote-url> --title "<title>" --description-file <body-file> --yes
```

`--push`、`--fill`、`--fill-commit-body`、`--draft`、`--ready`、`--target-branch`は使わない。

Issueを起票しない。コミットしない。pushしない。

### Step 8: 更新結果を検証する

```bash
glab mr view <iid> --repo <remote-url> -F json
```

次を確認する。

- titleが確認済みのタイトルと一致する
- descriptionが確認済みの本文と一致する
- stateが更新前と一致する
- draftが更新前と一致する
- source_branchが更新前と一致する
- target_branchが更新前と一致する
- closeするIssueが、本文末尾の`Closes`行に一件ずつ書かれている

一致しない場合は成功として扱わず、差異とMR URLを返す。すべて一致したらMR URLを返す。

## 安全条件

- ユーザー確認前にMRを更新しない
- `opened`でないMRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draftを変えない
- ユーザーの明示なしに`Draft:`を外さない
- MRのdiffにない変更を本文へ含めない
- 未pushのコミットを本文へ含めない
- 本文は`--description-file`で渡す
- 本文の行を`/`で始めない
- iidと`--repo`を省略しない
- `--push`、`--fill`、`--ready`を使わない
- 更新後の値を再取得して検証する

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| MR作成 | `glab-mr-create` |
| MR更新 | `glab-mr-update` |
| Gitコマンド禁止環境でMR作成 | `glab-mr-create-no-git` |
| Gitコマンド禁止環境でMR更新 | `glab-mr-update-no-git` |
| pushしてから本文を更新 | `git-push` → `glab-mr-update` |
| MR本文の型 | `glab-mr-schema` |
| GitHubのPull Request | `gh-pr-update` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `glab repo view <project> -F json --jq '{path:.path_with_namespace,base:.default_branch,web_url:.web_url}'` | 対象プロジェクトとデフォルトブランチを確認する |
| `glab mr view <iid> --repo <remote-url> -F json` | 既存MRと更新結果を確認する |
| `git fetch <remote> <base> <head>` | リモートのbaseとheadを取得する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadのSHAを確認する |
| `git --no-pager log <remote>/<base>..<remote>/<head> --format=%s%n%b` | MRに含まれるコミットを確認する |
| `git --no-pager diff <remote>/<base>...<remote>/<head>` | MRに含まれる差分を確認する |
| `glab mr update <iid> --repo <remote-url> --title "<title>" --description-file <body-file> --yes` | 確認済みのタイトルと本文で更新する |
