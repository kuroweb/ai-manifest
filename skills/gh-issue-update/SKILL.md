---
name: gh-issue-update
description: >
  スキル名で呼ばれたときだけ、指定したGitHub Issueを構造化して確認後に更新する。
  対象、既存Issue、担当状況、関連PR、Issue typeを確認し、gh-issue-schemaに沿って本文を作る。
  例: gh-issue-update --issue 42、gh-issue-update --repo owner/repo --issue 42。
  「Issueを更新して」だけでは使わない。
  スキル名が無いときは使わない。
  `--issue`が無いときは番号を聞く。
---

# gh-issue-update

## できること

- 指定したGitHub Issueの既存内容を保ちながら、要求された箇所を更新する
- 担当状況、関連PRを変更前に確認する
- Issue typeを種類に合わせ、更新後の内容を検証する

## いつ使うか

- `gh-issue-update --issue <number>`
- `gh-issue-update --repo owner/repo --issue <number>`
- 既存Issueに書いてある要求を変えるとき

## 手順

### Step 1: 対象を決める

対象リポジトリは`--repo owner/repo`で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

Issue番号は`--issue`で指定する。`--issue`が無いときだけ止まって聞く。

### Step 2: スキーマと既存Issueを読む

`gh-issue-schema`を読む。タイトルや本文を組む前に読む。

既存Issueと作業状況を一度に取得する。

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

変える箇所と、それに連動して直す箇所が書けるまで集める。変えないタイトル、本文、Issue typeは既存値を残す。

コードを調べるのは、カレントディレクトリが対象リポジトリのときだけにする。`--repo`の`owner/repo`がカレントと違う場合は、会話とGitHubから集める。コードでなければ確認できない事実は、不足情報として扱う。

コードから取るのは、本文に必要な事実に限る。現在の挙動、対象、既存の契約、エラー、完了条件を確認する。実装方法、ライブラリ、作業手順は本文に含めない。

### Step 4: 足りない情報を聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

- 種類を変える場合に新しい種類が決まっていなければ聞く
- タイトルの対象を特定できなければ聞く
- バグの再現手順、期待する結果、実際の結果のうち、書けないものがあれば聞く
- 機能追加またはタスクの受け入れ条件を書けなければ聞く

### Step 5: タイトル、本文、Issue typeを組む

タイトルと本文は`gh-issue-schema`に従う。

要求された変更と整合に必要な変更だけを加える。既存本文がスキーマに沿っている箇所は残し、空になった見出しは残さない。

Issueの種類を変えるときだけ、バグなら`Bug`、機能追加なら`Feature`、それ以外なら`Task`を候補にする。種類を変えないときは既存のIssue typeを残す。対象リポジトリのIssue type一覧を取得し、候補が存在するときだけ設定する。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name } } } }'
```

候補が無ければ、既存のIssue typeを変更しない。

### Step 6: 更新内容を出して確認する

対象リポジトリ、タイトル、本文、設定後のIssue typeをチャットに出す。変更する箇所が分かるように示す。

ユーザーが認めたあとだけ次へ進む。修正指示があれば反映して再度確認する。確認前に更新しない。

### Step 7: 更新する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

Issue typeを変える場合だけ`--type`を付ける。

```bash
gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]
```

Issueの状態、担当者、ラベルは変更しない。実装しない。PRを作成しない。

### Step 8: 結果を検証する

`--issue`の値を使って結果を取得する。

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url,issueType
```

次を確認する。

- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- Issue typeを変更した場合は、その値と一致する
- stateが変更前と一致する

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらIssue URLを返す。

## 安全条件

- ユーザー確認前にIssueを更新しない
- closed Issue、関連するopen PR、他者の担当、`in-progress`を無視して更新しない
- 更新対象外のタイトル、本文、Issue type、状態、担当者、ラベルを変えない
- 本文は`--body-file`で渡す
- 更新後の値を再取得して検証する

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
| `gh repo view <owner/repo> --json nameWithOwner` | 対象リポジトリを確認する |
| `gh issue view <number> --repo <owner/repo> --json ...` | 既存Issueと作業状況を確認する |
| `gh api user --jq .login` | 現在のGitHubユーザーを確認する |
| `gh api graphql`（`issueTypes`） | 利用できるIssue typeを確認する |
| `gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]` | 確認済みの内容で更新する |
| `gh issue view <number> --repo <owner/repo> --json number,title,state,body,url,issueType` | 更新結果を検証する |
