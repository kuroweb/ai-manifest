---
name: glab-mr-update
description: >
  指定したGitLab Merge Requestのタイトルと本文を確認後に更新する。
  対象プロジェクト、既存MR、そのMRの差分を確認する。
  `.gitlab/merge_request_templates` があればその構成で、無ければスキーマに沿って本文を作る。
  例: glab-mr-update --mr 42。
  「MRを更新」「MRの説明を修正」「MRのタイトルを変更」などの操作を行う際に使用する。
  `--mr`が無いときはiidを聞く。
---

# glab-mr-update

## できること

- 指定したGitLab Merge Requestの既存内容を保ちながら、要求された箇所を更新する
- 対象プロジェクト、既存MR、そのMRの差分を更新前に確認する
- `.gitlab/merge_request_templates` があればその構成で、無ければ `glab-mr-schema` で本文を組み立てる
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
- closeするIssueを変更するときは、会話で示されたIssue番号を使う

### Step 5: タイトルと本文を組む

本文の前に、プロジェクトルートの`.gitlab/merge_request_templates`を見る。

`.md`が無いときは、本文は`glab-mr-schema`の文書構成で書く。あるときはそのファイルを構成にする。`Default.md`があればそれを使う。1件ならそれを使う。複数で`Default.md`が無ければ、ファイル名を一度聞いてから使う。

テンプレートの見出しの並びで書く。意味が近い節は、`glab-mr-schema`のその節の書き方で埋める。書き方は`report-patterns`にも従う。

要求された変更と整合に必要な変更だけを加える。既存本文が採用した見出し構成に沿っている箇所は残し、空になった見出しは残さない。

- MRのdiffにない変更を本文へ含めない
- `draft`がtrueで、ユーザーがreadyにすると明示していないときは、タイトル先頭の`Draft:`を残す。外すとGitLabはそのMRをreadyにする

### Step 6: 可読性を確認する

ユーザー確認の前に`report-patterns`を読み、Step 5のタイトルと本文がその書き方で読みやすくできるか確認する。できる箇所があれば、採用した見出し構成と記載した事実は変えずに直す。

### Step 7: 更新前に確認する

対象プロジェクト、iid、タイトル、本文をチャットに出す。変更する箇所が分かるように示す。draftを維持するときは、そのことも出す。

ユーザーが認めたあとだけ更新する。修正指示があれば反映し、タイトルと本文を再度出す。確認前に更新しない。

### Step 8: MRを更新する

本文をリポジトリ外の一時ファイルへ書き、`--description-file`で渡す。複数行の本文を`--description`へ埋め込まない。

iidを省略しない。省略するとカレントブランチのMRを更新する。

```bash
glab mr update <iid> --repo <remote-url> --title "<title>" --description-file <body-file> --yes
```

`--push`、`--fill`、`--fill-commit-body`、`--draft`、`--ready`、`--target-branch`は使わない。

Issueを起票しない。コミットしない。pushしない。

### Step 9: 更新結果を検証する

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
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異とMR URLを返す。すべて一致したらMR URLを返す。

## 安全条件

- ユーザー確認前にMRを更新しない
- `report-patterns`を読まずにユーザー確認へ進まない
- `opened`でないMRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draftを変えない
- ユーザーの明示なしに`Draft:`を外さない
- MRのdiffにない変更を本文へ含めない
- 未pushのコミットを本文へ含めない
- 本文は`--description-file`で渡す
- iidと`--repo`を省略しない
- `--push`、`--fill`、`--ready`を使わない
- 更新後の値を再取得して検証する

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| MR作成 | `glab-mr-create` |
| MR更新 | `glab-mr-update` |
| Gitコマンド禁止環境でMR作成 | `glab-mr-create-no-git` |
| Gitコマンド禁止環境でMR更新 | `glab-mr-update-no-git` |
| pushしてから本文を更新 | `git-push` → `glab-mr-update` |
| MR本文の型 | `glab-mr-schema` |
| 本文の書き方・可読性 | `report-patterns` |
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
| `glab mr update <iid> --repo <remote-url> --title "<title>" --description-file <body-file> --yes` | 確認済みのタイトルと本文で更新する |
