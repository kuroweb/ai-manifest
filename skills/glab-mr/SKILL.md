---
name: glab-mr
description: >
  スキル名で呼ばれたときだけ、push済みブランチからGitLab Merge Requestを構造化して確認後に作成する。
  対象プロジェクト、base、head、既存MR、リモートとの差分を確認し、references/mr-schema.mdに沿って本文を作る。
  例: glab-mr、/glab-mr group/project、glab-mr group/subgroup/project --head feat/example --base develop。
  「MRを作って」「マージリク出して」だけでは使わない。
  スキル名が無いときは使わない。
  AIによるGitコマンド実行が禁止されているプロジェクトでは使わず、glab-mr-no-gitを使用する。
  Issue起票、実装、コミット、pushは行わない。
---

# glab-mr

## できること

- push済みブランチからGitLab Merge Requestを作成する
- 対象プロジェクト、base、head、既存MR、差分コミットを作成前に確認する
- `references/mr-schema.md`に沿ってタイトルと本文を組み立てる
- 作成後のタイトル、本文、base、headを検証する

## いつ使うか

- `glab-mr`
- `glab-mr group/project`
- `glab-mr group/subgroup/project --head feat/example`
- `glab-mr group/project --head feat/example --base develop`
- push済みブランチからMerge Requestを作成するとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: 対象プロジェクトとブランチを決める

対象プロジェクトは引数のプロジェクトパスまたはURL。パスは `group/project` または `group/subgroup/project`。省略時はカレントディレクトリのリポジトリとする。

```bash
glab repo view <project> -F json --jq '{path:.path_with_namespace,base:.default_branch,web_url:.web_url}'
```

対象プロジェクトを省略した呼び出しでは、コマンドの`<project>`も省略する。

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. 対象プロジェクトのデフォルトブランチ

headは次の順で決める。

1. `--head`で指定されたリモートブランチ
2. 会話または直前の`git-push`で示されたリモートブランチ
3. 現在のローカルブランチが追跡するリモートブランチ
4. 現在のローカルブランチと同名のリモートブランチ

```bash
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git remote -v
```

headを一意に決められない場合はユーザーに聞く。baseとheadが同じ場合は停止する。

対象プロジェクトに対応するgit remoteを、remote URLのホストとプロジェクトパスから特定する。パス比較では末尾の`.git`を除く。対応するremoteが無い、または複数あって一意でない場合は停止する。

以降の`glab`には、そのremote URLを`--repo`で渡す。Self-Managedでもカレントディレクトリのホスト設定に依存しない。

### Step 2: MRを作成できる状態か確認する

対象remoteのbaseを取得し、headがリモートに存在することを確認する。

```bash
git fetch <remote> <base>
git ls-remote --exit-code --heads <remote> refs/heads/<head>
```

headが存在しない場合は停止し、`git-push`でpushしてから再開する。

カレントディレクトリが対象プロジェクトの場合は、ローカルHEADとリモートheadのSHAを比較する。

```bash
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<head>
```

SHAが一致しない場合は停止する。ローカルが未push、リモートが先行、または別のコミットをheadとして選んでいるため、`glab-mr`では統合やpushを行わない。

リモートbaseとの差分コミット数を確認する。

```bash
git rev-list --count <remote>/<base>..HEAD
```

差分コミットが0なら停止する。

未コミットの変更がある場合は、その変更がMRに含まれないことを伝えて停止する。現在のpush済みコミットだけでMRを作成するとユーザーが明示した場合に限り続ける。

```bash
git status --porcelain
```

同じheadを使ったMRを、本文を作る前に確認する。

```bash
glab mr list --repo <remote-url> --source-branch <head> --all -F json
```

JSONの`iid`、`state`、`web_url`、`source_branch`、`target_branch`を見る。

- `opened`または`locked`のMRがあれば、URLを返して作成しない
- `merged`または`closed`のMRがあれば、同じheadを再利用せず、新しいブランチを使う

### Step 3: スキーマを読む

`references/mr-schema.md`を読む。タイトルや本文を組む前に読む。

### Step 4: MR本文に必要な情報を集める

変更目的、変更内容、テスト内容、関連Issueが書けるところまで、会話、コミット、差分、GitLabから集める。

```bash
git --no-pager log <remote>/<base>..HEAD --format=%s%n%b
git --no-pager diff <remote>/<base>...HEAD
```

- 変更目的は会話から取る。差分から推測しない
- 変更内容は差分にある事実だけを書く
- テスト内容は`references/mr-schema.md`に従い、差分にあるテストの追加・変更から取る
- Issue番号の候補は、会話、head名、コミットメッセージから取る
- Issue番号の候補があるだけでは、closeするIssueとして扱わない

### Step 5: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。

- 変更目的が会話に無ければ聞く
- Issueをcloseするか参照だけにするか決まっていなければ聞く
- baseがデフォルトブランチで、候補が一つのときは`Closes`を推奨する
- 関連Issueの候補が無ければ、Issue番号を聞かない

### Step 6: タイトルと本文を組む

タイトルと本文は`references/mr-schema.md`に従う。

- baseがデフォルトブランチでない場合は`Closes`を書かない
- closeしないIssueは`Related:`で書く
- 関連Issueが無ければ見出しごと省く
- 未コミットの変更を本文に含めない
- 本文の行を`/`で始めない

### Step 7: 作成前に確認する

タイトルと本文をチャットに出す。ユーザーが認めたあとだけ作成する。

修正指示があれば反映し、タイトルと本文を再度出す。確認前にMRを作成しない。

### Step 8: MRを作成する

本文をリポジトリ外の一時ファイルへ書き、`--description-file`で渡す。複数行の本文を`--description`へ埋め込まない。

```bash
glab mr create --repo <remote-url> --source-branch <head> --target-branch <base> --title "<title>" --description-file <body-file> --yes
```

`--push`、`--fill`、`--fill-commit-body`、`--draft`、`--web`、`--template`、`--create-source-branch`、`--no-editor`は使わない。これらはpush、ブラウザ、ローカルテンプレート、プロンプトへ進む。

Issueを起票しない。コミットしない。pushしない。フォークから上流へのMRは作らない。

### Step 9: 作成結果を検証する

作成コマンドの出力からMRのURLとiidを取る。作成されたMRのタイトル、本文、base、headを取得する。

```bash
glab mr view <iid> --repo <remote-url> -F json
```

次を確認する。

- stateが`opened`
- draftが`false`
- titleが確認済みのタイトルと一致する
- descriptionが確認済みの本文と一致する
- source_branchがheadと一致する
- target_branchがbaseと一致する
- closeするIssueが、本文末尾の`Closes`行に一件ずつ書かれている

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらMR URLを返す。

## 安全条件

- pushされていないheadからMRを作成しない
- ローカルHEADとリモートheadのSHAが異なる状態でMRを作成しない
- baseとの差分コミットがない状態でMRを作成しない
- 同じheadのopened、locked、merged、closed MRがある場合は新しいMRを作成しない
- 未コミットの変更をMR本文へ含めない
- ユーザー確認前にMRを作成しない
- 本文は`--description-file`で渡す
- 本文の行を`/`で始めない
- `--push`や`--fill`でpushしない

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| MR作成 | `glab-mr` |
| Gitコマンド禁止環境でMR作成 | `glab-mr-no-git` |
| pushしてMR作成 | `git-push` → `glab-mr` |
| コミットしてMR作成 | `git-commit` → `git-push` → `glab-mr` |
| GitHubのPull Request | `gh-pr` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `glab repo view <project> -F json --jq '{path:.path_with_namespace,base:.default_branch,web_url:.web_url}'` | 対象プロジェクトとデフォルトブランチを確認する |
| `git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'` | ローカルブランチのupstreamを確認する |
| `git fetch <remote> <base>` | リモートbaseを更新する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadの存在とSHAを確認する |
| `git rev-list --count <remote>/<base>..HEAD` | baseとの差分コミット数を確認する |
| `git --no-pager log <remote>/<base>..HEAD --format=%s%n%b` | コミットとIssue候補を確認する |
| `git --no-pager diff <remote>/<base>...HEAD` | MRの変更内容を確認する |
| `glab mr list --repo <remote-url> --source-branch <head> --all -F json` | 同じheadの既存MRを確認する |
| `glab mr create --repo <remote-url> --source-branch <head> --target-branch <base> --title "<title>" --description-file <body-file> --yes` | 確認済み内容でMRを作成する |
| `glab mr view <iid> --repo <remote-url> -F json` | 作成結果を検証する |
