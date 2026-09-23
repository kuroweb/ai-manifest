---
name: gh-issue
description: >
  スキル名で呼ばれたときだけ、GitHub Issueを構造化して確認後に起票または更新する。
  `--number`が無ければ起票し、あれば指定したIssueを更新する。
  対象、既存Issue、担当状況、関連PR、重複、Issue typeを確認し、references/issue-schema.mdに沿って本文を作る。
  例: gh-issue、gh-issue --repo owner/repo、gh-issue --number 42、gh-issue --repo owner/repo --number 42。
  「Issueを作って」「起票して」「チケット切って」「Issueを更新して」だけでは使わない。
  スキル名が無いときは使わない。
  読み込みだけ、実装、PR作成では使わない。
---

# gh-issue

## できること

- スキーマに沿ったタイトルと本文でGitHub Issueを起票する
- 指定したGitHub Issueの既存内容を保ちながら、要求された箇所を更新する
- 担当状況、関連PR、重複Issueを変更前に確認する
- Issue typeを種類に合わせ、起票または更新後の内容を検証する

## いつ使うか

- `gh-issue`
- `gh-issue --repo owner/repo`
- `gh-issue --number <number>`
- `gh-issue --repo owner/repo --number <number>`
- 新しいIssueとして要求を残すとき
- 既存Issueに書いてある要求を変えるとき

## 手順

### Step 1: 対象と操作を決める

対象リポジトリは`--repo owner/repo`で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

`--number`があれば、その番号のIssueを更新する。無ければ起票する。

### Step 2: スキーマと既存Issueを読む

`references/issue-schema.md`を読む。タイトルや本文を組む前に読む。

更新なら、既存Issueと作業状況を一度に取得する。

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url,assignees,labels,issueType,closedByPullRequestsReferences
gh api user --jq .login
```

次に該当する場合は状況とURLを示し、ユーザーが続行を明示するまで待つ。

- Issueが閉じている
- このIssueをcloseするopen PRがある
- 現在のGitHubユーザー以外が担当している
- `in-progress`ラベルがある

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 3: 本文に必要な情報を集める

Issueの種類を、バグ、機能追加、タスクから決める。

起票なら、選んだ種類のテンプレートを埋められるところまで、会話、コード、GitHubから集める。

- バグは、概要、再現手順、期待する結果、実際の結果、再現時のコミットSHAと環境、受け入れ条件を集める
- 機能追加は、概要、背景、期待する振る舞い、受け入れ条件を集める
- タスクは、概要、背景、受け入れ条件を集める

更新なら、変える箇所と、それに連動して直す箇所が書けるまで集める。変えないタイトル、本文、Issue typeは既存値を残す。

コードを調べるのは、カレントディレクトリが対象リポジトリのときだけにする。`--repo`の`owner/repo`がカレントと違う場合は、会話とGitHubから集める。コードでなければ確認できない事実は、不足情報として扱う。

コードから取るのは、本文に必要な事実に限る。現在の挙動、対象、既存の契約、エラー、完了条件を確認する。実装方法、ライブラリ、作業手順は本文に含めない。

### Step 4: 足りない情報を聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

- 起票で種類が決まっていなければ、最初に聞く
- 更新で種類を変える場合に新しい種類が決まっていなければ聞く
- タイトルの対象を特定できなければ聞く
- バグの再現手順、期待する結果、実際の結果、再現時のコミットSHAのうち、書けないものがあれば聞く
- 機能追加またはタスクの受け入れ条件を書けなければ聞く

### Step 5: タイトル、本文、Issue typeを組む

タイトルと本文は`references/issue-schema.md`に従う。

更新では、要求された変更と整合に必要な変更だけを加える。既存本文がスキーマに沿っている箇所は残し、空になった見出しは残さない。

バグの環境を新しく書くとき、対象リポジトリがカレントディレクトリで、そのHEADで不具合を確認したならshort SHAを取得する。

```bash
git rev-parse --short HEAD
git status --porcelain
```

現在のHEADが再現時点でない場合や、対象リポジトリがカレントディレクトリと異なる場合は、現在のHEADやデフォルトブランチのSHAで代用せず、再現時のSHAをユーザーに聞く。未コミットの変更が再現に影響する場合は、その状態を環境へ記載する。

起票時のIssue typeは、バグなら`Bug`、機能追加なら`Feature`、それ以外なら`Task`を候補にする。更新では、Issueの種類を変えるときだけ新しい種類から候補を決め、種類を変えないときは既存値を残す。対象リポジトリのIssue type一覧を取得し、候補が存在するときだけ設定する。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name } } } }'
```

起票で候補が無ければ、Issue typeを設定しない。更新で候補が無ければ、既存のIssue typeを変更しない。

### Step 6: 起票前の重複を確認する

起票の場合だけ、タイトルと本文を組んだあと、確認を求める前に一度検索する。タイトルと主要なキーワードを使い、openとclosedの両方を対象にする。

```bash
gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10 --json number,title,state,url
```

重複の可能性があるIssueを見つけたらURLと判断理由を示す。ユーザーがそれでも起票すると明示するまで次へ進まない。

### Step 7: 変更内容を出して確認する

対象リポジトリ、操作、タイトル、本文、設定後のIssue typeをチャットに出す。更新では、変更する箇所が分かるように示す。

ユーザーが認めたあとだけ次へ進む。修正指示があれば反映して再度確認する。確認前に起票または更新しない。

### Step 8: 起票または更新する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

起票では、利用できるIssue typeがある場合だけ`--type`を付ける。コマンドが返すIssue URLを保持し、作成結果の識別子として使う。

```bash
gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]
```

更新では、Issue typeを変える場合だけ`--type`を付ける。

```bash
gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]
```

Issueの状態、担当者、ラベルは変更しない。実装しない。PRを作成しない。

### Step 9: 結果を検証する

起票では作成時に得たURL、更新では`--number`の値を使って結果を取得する。

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,state,body,url,issueType
```

次を確認する。

- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- Issue typeを設定または変更した場合は、その値と一致する
- 更新ではstateが変更前と一致する
- 起票ではstateが`OPEN`である

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらIssue URLを返す。

## 安全条件

- ユーザー確認前にIssueを起票または更新しない
- 重複の可能性があるIssueを、明示的な続行指示なしに起票しない
- closed Issue、関連するopen PR、他者の担当、`in-progress`を無視して更新しない
- 更新対象外のタイトル、本文、Issue type、状態、担当者、ラベルを変えない
- 本文は`--body-file`で渡す
- 起票または更新後の値を再取得して検証する

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| Issueを読むだけ | `gh-issue-load` |
| Issueを起票 | `gh-issue` |
| Issueを更新 | `gh-issue --number <number>` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view <owner/repo> --json nameWithOwner` | 対象リポジトリを確認する |
| `gh issue view <number> --repo <owner/repo> --json ...` | 既存Issueと作業状況を確認する |
| `gh api user --jq .login` | 現在のGitHubユーザーを確認する |
| `git rev-parse --short HEAD` | バグを確認した現在のコミットSHAを取得する |
| `git status --porcelain` | 再現に影響する未コミットの変更を確認する |
| `gh api graphql`（`issueTypes`） | 利用できるIssue typeを確認する |
| `gh issue list --repo <owner/repo> --search "<keywords>" --state all` | 起票前に重複Issueを探す |
| `gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]` | 確認済みの内容で起票する |
| `gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]` | 確認済みの内容で更新する |
| `gh issue view <number-or-url> --repo <owner/repo> --json number,title,state,body,url,issueType` | 起票または更新結果を検証する |
