---
name: gh-issue-update
description: >
  スキル名と Issue 番号で呼ばれたときだけ、その GitHub Issue の内容を変える。
  変更内容に曖昧なところがあれば、会話・コード・GitHub から集め、足りないことだけ聞く。
  例: gh-issue-update 42、/gh-issue-update 42 owner/repo。
  「Issue を更新して」「内容を変えて」だけでは使わない。
  スキル名が無いときは使わない。
  スキル名のみなら番号を聞く。
  起票、読み込みだけ、実装、PR 作成では使わない。
---

# gh-issue-update

## できること

- 指定した GitHub Issue のタイトルと本文を変える
- 変更内容が会話に無ければ、何を変えるかを聞く
- 変更内容が曖昧なら、会話・コード・GitHub から集める
- 本文に書けないことだけ、一度に一つ聞く
- タイトルと本文をチャットに出して確認したあと、`gh issue edit` で更新する
- 更新後に Issue URL を返す

## いつ使うか

- `gh-issue-update <number>`
- `/gh-issue-update <number>`
- 第 2 引数に `owner/repo` があってもよい
- 「Issue を更新して」「内容を変えて」だけでは使わない
- スキル名が無いときは使わない
- スキル名のみなら番号を聞く

## 手順

### Step 1: 対象を決める

引数は Issue 番号が必須。スキル名だけで番号が無いときだけ止まって聞く。第 2 引数が `owner/repo`。省略時はカレントディレクトリのリポジトリ。

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

### Step 2: Issue を読む

本文を読む・直す前に `gh-issue-schema` を読む。

```bash
gh issue view <number> --repo <owner/repo>
```

```bash
gh pr list --repo <owner/repo> --search "<number>" --state open --limit 10
```

この Issue を扱う open PR があれば URL を出して、進むか待つ。

```bash
gh issue view <number> --repo <owner/repo> --json assignees,labels,title
```

他者が担当している、または `in-progress` があるなら知らせて、進むか待つ。勝手に進まない。

### Step 3: 変更内容を聞く

会話に変更内容があれば、それを使う。無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 4: 情報を集める

概要、背景、バージョン、受け入れ条件のうち、変えるところと、それに連動して直すところが書けるまで、会話・コード・GitHub から集める。変えない見出しは今の本文を残す。

コードを調べるのは、カレントディレクトリが対象リポジトリのときだけ。引数の `owner/repo` がカレントと違うときは、会話と GitHub から集める。コードでないと書けない事実は、足りないことにする。

コードから取るのは、本文に書く事実だけにする。今の挙動、対象、既存の契約、エラーを取る。「何が揃えば完了か」まで取る。差し方、ライブラリ、手順は書かない。

### Step 5: 足りないことを聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

種類（バグ / 機能追加 / それ以外）を変えるとき、種類が決まっていなければそれを最初に聞く。バグに変えるのにバージョンが会話に無ければ、それも聞く。

### Step 6: タイトルと本文を組む

更新後のタイトルと本文は `gh-issue-schema` に従う。今の本文が型に沿っている箇所は、変えないところを残す。空になった見出しは残さない。

機能追加のバージョンを書き直すときだけ、次で取る。

```bash
gh api repos/{owner}/{repo} --jq .default_branch
gh api repos/{owner}/{repo}/commits/<default_branch> --jq '.sha[0:7]'
```

### Step 7: タイトルと本文を出して確認する

タイトルと本文をチャットに出す。ユーザーが認めたあとだけ次へ進む。修正指示があれば直して、再度出す。確認前に更新しない。

### Step 8: 更新する

```bash
gh issue edit <number> --repo <owner/repo> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

本文は quoted heredoc。未展開の `${` を残さない。

種類が変わるときだけ、Issue type を更新する。バグは Bug、機能追加は Feature、それ以外は Task。リポジトリの type 一覧を取り、対応する id が無ければ type は変えない。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name id } } } }'
```

type を変える場合は、Issue の `node_id` と type の id で更新する。

```bash
gh api repos/{owner}/{repo}/issues/{number} --jq .node_id
gh api graphql -f query='mutation($id:ID!, $typeId:ID!) { updateIssue(input:{id:$id, issueTypeId:$typeId}) { issue { url issueType { name } } } }' -f id="<node_id>" -f typeId="<type_id>"
```

更新後、Issue URL を返す。実装しない。PR を出さない。

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view --json nameWithOwner --jq .nameWithOwner` | 対象リポジトリを特定する |
| `gh issue view <number> --repo <owner/repo>` | Issue を読む |
| `gh issue view <number> --json assignees,labels,title` | 担当と in-progress を見る |
| `gh pr list --search "<number>" --state open --limit 10` | この Issue の open PR |
| `gh api repos/{owner}/{repo} --jq .default_branch` | デフォルトブランチ名を取る |
| `gh api repos/{owner}/{repo}/commits/<default_branch> --jq '.sha[0:7]'` | 機能追加のバージョン用 short SHA を取る |
| `gh issue edit <number> --repo <owner/repo> --title "<title>" --body "..."` | 確認後にタイトルと本文を更新する |
| `gh api graphql` （`issueTypes`） | リポジトリの Issue type 一覧を取る |
| `gh api repos/{owner}/{repo}/issues/{number} --jq .node_id` | type 更新用の node_id を取る |
| `gh api graphql` （`updateIssue`） | 種類が変わるとき Issue type を変える |
