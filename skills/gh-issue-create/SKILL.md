---
name: gh-issue-create
description: >
  スキル名で呼ばれたときだけ、GitHub Issue を構造化して確認後に起票する。
  起票前に、スキーマの見出しが書けるところまで情報を集め、重複 Issue を検索する。
  例: gh-issue-create、/gh-issue-create owner/repo。
  「Issue を作って」「起票して」「チケット切って」だけでは使わない。
  スキル名が無いときは使わない。
  更新、実装、PR 作成では使わない。
---

# gh-issue-create

## できること

- GitHub Issue のタイトルと本文を組み立てる
- 起票前に、会話・コード・GitHub からスキーマの見出しが書けるところまで集める
- 起票前に重複 Issue を探す
- タイトルと本文をチャットに出して確認したあと、`gh issue create` で起票する
- リポジトリが対応していれば Issue type を付ける
- 起票後に Issue URL を返す

## いつ使うか

- `gh-issue-create`
- `/gh-issue-create`
- 第 1 引数に `owner/repo` があってもよい
- 「Issue を作って」「起票して」「チケット切って」だけでは使わない
- スキル名が無いときは使わない

## 手順

### Step 1: 対象を決める

対象リポジトリは引数の `owner/repo`。省略時はカレントディレクトリのリポジトリ。

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

### Step 2: 情報を集める

`gh-issue-schema` を読む。

概要、背景、バージョン、受け入れ条件が書けるところまで、会話・コード・GitHub から集める。

コードを調べるのは、カレントディレクトリが対象リポジトリのときだけ。引数の `owner/repo` がカレントと違うときは、会話と GitHub から集める。コードでないと書けない事実は、足りないことにする。

コードから取るのは、本文に書く事実だけにする。今の挙動、対象、既存の契約、エラーを取る。「何が揃えば完了か」まで取る。差し方、ライブラリ、手順は書かない。

### Step 3: 足りないことを聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

種類（バグ / 機能追加 / それ以外）が決まっていないときは、それを最初に聞く。バグでバージョンが会話に無ければ、それも聞く。

### Step 4: タイトルと本文を組む

タイトルと本文は `gh-issue-schema` に従う。機能追加のバージョンは、次で取る。

```bash
gh api repos/{owner}/{repo} --jq .default_branch
gh api repos/{owner}/{repo}/commits/<default_branch> --jq '.sha[0:7]'
```

### Step 5: 重複を探す

見出しが書けるようになってから、確認の前に一度だけ探す。タイトルとキーワードで、開いている Issue も閉じている Issue も探す。

```bash
gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10
```

`--repo` はカレントディレクトリのリポジトリなら省略してよい。

重複らしきものがあれば止めて URL を出す。ユーザーが「それでも切る」と言うまで次へ進まない。

### Step 6: タイトルと本文を出して確認する

タイトルと本文をチャットに出す。ユーザーが認めたあとだけ次へ進む。修正指示があれば直して、再度出す。確認前に起票しない。

### Step 7: 起票する

```bash
gh issue create --repo <owner/repo> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Issue type は種類から決める。バグは Bug、機能追加は Feature、それ以外は Task。リポジトリの type 一覧を取り、対応する id が無ければ type は付けない。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name id } } } }'
```

type を付ける場合は、起票後に Issue の `node_id` と type の id で更新する。

```bash
gh api repos/{owner}/{repo}/issues/{number} --jq .node_id
gh api graphql -f query='mutation($id:ID!, $typeId:ID!) { updateIssue(input:{id:$id, issueTypeId:$typeId}) { issue { url issueType { name } } } }' -f id="<node_id>" -f typeId="<type_id>"
```

起票後、Issue URL を返す。

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view --json nameWithOwner --jq .nameWithOwner` | 対象リポジトリを特定する |
| `gh api repos/{owner}/{repo} --jq .default_branch` | デフォルトブランチ名を取る |
| `gh api repos/{owner}/{repo}/commits/<default_branch> --jq '.sha[0:7]'` | 機能追加のバージョン用 short SHA を取る |
| `gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10` | 重複 Issue を探す |
| `gh issue create --repo <owner/repo> --title "<title>" --body "..."` | 確認後に起票する |
| `gh api graphql` （`issueTypes`） | リポジトリの Issue type 一覧を取る |
| `gh api repos/{owner}/{repo}/issues/{number} --jq .node_id` | type 更新用の node_id を取る |
| `gh api graphql` （`updateIssue`） | Issue type を付ける |
