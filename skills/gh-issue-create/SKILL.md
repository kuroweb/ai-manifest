---
name: gh-issue-create
description: >
  GitHub Issueを構造化して確認後に起票する。
  対象、重複、Issue typeを確認し、スキーマに沿って本文を作る。
  例: gh-issue-create、gh-issue-create --repo owner/repo。
  「Issueを作成」「Issueを起票」「チケットを切る」などの操作を行う際に使用する。
---

# gh-issue-create

## できること

- スキーマに沿ったタイトルと本文でGitHub Issueを起票する
- 重複Issueを起票前に確認する
- Issue typeを種類に合わせ、起票後の内容を検証する

## いつ使うか

- `gh-issue-create`
- `gh-issue-create --repo owner/repo`
- 新しいIssueとして要求を残すとき

## 手順

### Step 1: 対象を決める

対象リポジトリは`--repo owner/repo`で指定する。省略時はカレントディレクトリのリポジトリとする。

```bash
gh repo view <owner/repo> --json nameWithOwner --jq .nameWithOwner
```

対象リポジトリを省略した呼び出しでは、コマンドの`<owner/repo>`も省略する。

### Step 2: スキーマを読む

`gh-issue-schema`を読む。タイトルや本文を組む前に読む。

### Step 3: 本文に必要な情報を集める

Issueの種類を、バグ、機能追加、タスクから決める。

選んだ種類のテンプレートを埋められるところまで、会話、コード、GitHubから集める。

- バグは、概要、再現手順、期待する結果、実際の結果、環境、受け入れ条件を集める
- 機能追加は、概要、背景、期待する振る舞い、受け入れ条件を集める
- タスクは、概要、背景、受け入れ条件を集める

コードを調べるのは、カレントディレクトリが対象リポジトリのときだけにする。`--repo`の`owner/repo`がカレントと違う場合は、会話とGitHubから集める。コードでなければ確認できない事実は、不足情報として扱う。

コードから取るのは、本文に必要な事実に限る。現在の挙動、対象、既存の契約、エラー、完了条件を確認する。実装方法、ライブラリ、作業手順は本文に含めない。

### Step 4: 足りない情報を聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

- 種類が決まっていなければ、最初に聞く
- タイトルの対象を特定できなければ聞く
- バグの再現手順、期待する結果、実際の結果のうち、書けないものがあれば聞く
- 機能追加またはタスクの受け入れ条件を書けなければ聞く

### Step 5: タイトル、本文、Issue typeを組む

タイトルと本文は`gh-issue-schema`に従う。

Issue typeは、バグなら`Bug`、機能追加なら`Feature`、それ以外なら`Task`を候補にする。対象リポジトリのIssue type一覧を取得し、候補が存在するときだけ設定する。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name } } } }'
```

候補が無ければ、Issue typeを設定しない。

### Step 6: 起票前の重複を確認する

タイトルと本文を組んだあと、確認を求める前に一度検索する。タイトルと主要なキーワードを使い、openとclosedの両方を対象にする。

```bash
gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10 --json number,title,state,url
```

重複の可能性があるIssueを見つけたらURLと判断理由を示す。ユーザーがそれでも起票すると明示するまで次へ進まない。

### Step 7: 起票内容を出して確認する

対象リポジトリ、タイトル、本文、設定するIssue typeをチャットに出す。

ユーザーが認めたあとだけ次へ進む。修正指示があれば反映して再度確認する。確認前に起票しない。

### Step 8: 起票する

本文をリポジトリ外の一時ファイルへ書き、`--body-file`で渡す。複数行の本文を`--body`へ埋め込まない。

利用できるIssue typeがある場合だけ`--type`を付ける。コマンドが返すIssue URLを保持し、作成結果の識別子として使う。

```bash
gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]
```

実装しない。PRを作成しない。

### Step 9: 結果を検証する

作成時に得たURLを使って結果を取得する。

```bash
gh issue view <url> --repo <owner/repo> --json number,title,state,body,url,issueType
```

次を確認する。

- titleが確認済みのタイトルと一致する
- bodyが確認済みの本文と一致する
- Issue typeを設定した場合は、その値と一致する
- stateが`OPEN`である

一致しない場合は成功として扱わず、差異をユーザーへ返す。すべて一致したらIssue URLを返す。

## 安全条件

- ユーザー確認前にIssueを起票しない
- 重複の可能性があるIssueを、明示的な続行指示なしに起票しない
- 本文は`--body-file`で渡す
- 起票後の値を再取得して検証する

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
| `gh api graphql`（`issueTypes`） | 利用できるIssue typeを確認する |
| `gh issue list --repo <owner/repo> --search "<keywords>" --state all` | 起票前に重複Issueを探す |
| `gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file> [--type <type>]` | 確認済みの内容で起票する |
| `gh issue view <url> --repo <owner/repo> --json number,title,state,body,url,issueType` | 起票結果を検証する |
