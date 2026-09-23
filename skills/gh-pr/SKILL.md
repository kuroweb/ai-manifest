---
name: gh-pr
description: >
  スキル名で呼ばれたときだけ、push済みブランチからGitHub Pull Requestを構造化して確認後に作成する。
  対象リポジトリ、base、head、既存PR、リモートとの差分を確認し、references/pr-schema.mdに沿って本文を作る。
  例: gh-pr、/gh-pr owner/repo、gh-pr owner/repo --head feat/example --base develop。
  「PRを作って」「プルリク出して」だけでは使わない。
  スキル名が無いときは使わない。
  Issue起票、実装、コミット、pushは行わない。
---

# gh-pr

## できること

- push済みブランチからGitHub Pull Requestを作成する
- 対象リポジトリ、base、head、既存PR、差分コミットを作成前に確認する
- `references/pr-schema.md`に沿ってタイトルと本文を組み立てる
- 作成後のタイトル、本文、base、headを検証する

## いつ使うか

- `gh-pr`
- `gh-pr owner/repo`
- `gh-pr owner/repo --head feat/example`
- `gh-pr owner/repo --head feat/example --base develop`
- push済みブランチからPull Requestを作成するとき

## 手順

### Step 1: 対象リポジトリとブランチを決める

対象リポジトリは引数の`owner/repo`。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,base:.defaultBranchRef.name}'
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. 対象リポジトリのデフォルトブランチ

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

対象リポジトリに対応するgit remoteを、remote URLの`owner/repo`から特定する。対応するremoteが無い場合は停止する。

### Step 2: PRを作成できる状態か確認する

対象remoteのbaseを取得し、headがリモートに存在することを確認する。

```bash
git fetch <remote> <base>
git ls-remote --exit-code --heads <remote> refs/heads/<head>
```

headが存在しない場合は停止し、`git-push`でpushしてから再開する。

カレントディレクトリが対象リポジトリの場合は、ローカルHEADとリモートheadのSHAを比較する。

```bash
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<head>
```

SHAが一致しない場合は停止する。ローカルが未push、リモートが先行、または別のコミットをheadとして選んでいるため、`gh-pr`では統合やpushを行わない。

リモートbaseとの差分コミット数を確認する。

```bash
git rev-list --count <remote>/<base>..HEAD
```

差分コミットが0なら停止する。

未コミットの変更がある場合は、その変更がPRに含まれないことを伝えて停止する。現在のpush済みコミットだけでPRを作成するとユーザーが明示した場合に限り続ける。

```bash
git status --porcelain
```

同じheadを使ったPRを、本文を作る前に確認する。

```bash
gh pr list --repo <owner/repo> --head <head> --state all --json number,state,url,headRefName,baseRefName
```

- `OPEN`のPRがあれば、URLを返して作成しない
- `MERGED`または`CLOSED`のPRがあれば、同じheadを再利用せず、新しいブランチを使う

### Step 3: スキーマを読む

`references/pr-schema.md`を読む。タイトルや本文を組む前に読む。

### Step 4: PR本文に必要な情報を集める

変更目的、変更内容、テスト内容、関連Issueが書けるところまで、会話、コミット、差分、GitHubから集める。

```bash
git --no-pager log <remote>/<base>..HEAD --format=%s%n%b
git --no-pager diff <remote>/<base>...HEAD
```

- 変更目的は会話から取る。差分から推測しない
- 変更内容は差分にある事実だけを書く
- テスト内容は`references/pr-schema.md`に従い、差分にあるテストの追加・変更から取る
- Issue番号の候補は、会話、head名、コミットメッセージから取る
- Issue番号の候補があるだけでは、closeするIssueとして扱わない

### Step 5: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。

- 変更目的が会話に無ければ聞く
- Issueをcloseするか参照だけにするか決まっていなければ聞く
- baseがデフォルトブランチで、候補が一つのときは`Closes`を推奨する
- 関連Issueの候補が無ければ、Issue番号を聞かない

### Step 6: タイトルと本文を組む

タイトルと本文は`references/pr-schema.md`に従う。

- baseがデフォルトブランチでない場合は`Closes`を書かない
- closeしないIssueは`Related:`で書く
- 関連Issueが無ければ見出しごと省く
- 未コミットの変更を本文に含めない

### Step 7: 作成前に確認する

タイトルと本文をチャットに出す。ユーザーが認めたあとだけ作成する。

修正指示があれば反映し、タイトルと本文を再度出す。確認前にPRを作成しない。

### Step 8: PRを作成する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

```bash
gh pr create --repo <owner/repo> --base <base> --head <head> --title "<title>" --body-file <body-file>
```

Issueを起票しない。コミットしない。pushしない。

### Step 9: 作成結果を検証する

作成されたPRのタイトル、本文、base、head、URLを取得する。

```bash
gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,headRefName,baseRefName
```

次を確認する。

- stateが`OPEN`
- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- headRefNameがheadと一致する
- baseRefNameがbaseと一致する
- closeするIssueが、本文末尾の`Closes`行に一件ずつ書かれている

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらPR URLを返す。

## 安全条件

- pushされていないheadからPRを作成しない
- ローカルHEADとリモートheadのSHAが異なる状態でPRを作成しない
- baseとの差分コミットがない状態でPRを作成しない
- 同じheadのopen、merged、closed PRがある場合は新しいPRを作成しない
- 未コミットの変更をPR本文へ含めない
- ユーザー確認前にPRを作成しない
- 本文は`--body-file`で渡す

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| PR作成 | `gh-pr` |
| pushしてPR作成 | `git-push` → `gh-pr` |
| コミットしてPR作成 | `git-commit` → `git-push` → `gh-pr` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view <owner/repo> --json nameWithOwner,defaultBranchRef` | 対象リポジトリとデフォルトブランチを確認する |
| `git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'` | ローカルブランチのupstreamを確認する |
| `git fetch <remote> <base>` | リモートbaseを更新する |
| `git ls-remote --heads <remote> refs/heads/<head>` | リモートheadの存在とSHAを確認する |
| `git rev-list --count <remote>/<base>..HEAD` | baseとの差分コミット数を確認する |
| `git --no-pager log <remote>/<base>..HEAD --format=%s%n%b` | コミットとIssue候補を確認する |
| `git --no-pager diff <remote>/<base>...HEAD` | PRの変更内容を確認する |
| `gh pr list --repo <owner/repo> --head <head> --state all --json number,state,url,headRefName,baseRefName` | 同じheadの既存PRを確認する |
| `gh pr create --repo <owner/repo> --base <base> --head <head> --title "<title>" --body-file <body-file>` | 確認済み内容でPRを作成する |
| `gh pr view <number> --repo <owner/repo> --json number,url,title,body,state,headRefName,baseRefName` | 作成結果を検証する |
