---
name: gh-issue
description: >
  スキル名で呼ばれたときだけ、GitHub Issue を構造化して確認後に起票または更新する。
  番号が無ければ起票する。番号があれば、その Issue の内容を変える。
  起票前に、スキーマの見出しが書けるところまで情報を集め、重複 Issue を検索する。
  更新時、変更内容に曖昧なところがあれば、会話・コード・GitHub から集め、足りないことだけ聞く。
  例: gh-issue、/gh-issue owner/repo、gh-issue 42、/gh-issue 42 owner/repo。
  「Issue を作って」「起票して」「チケット切って」「Issue を更新して」「内容を変えて」だけでは使わない。
  スキル名が無いときは使わない。
  読み込みだけ、実装、PR 作成では使わない。
---

# gh-issue

## できること

- スキーマに沿ったタイトルと本文で、GitHub Issue を起票する
- スキーマに沿ったタイトルと本文で、指定した Issue を更新する

## いつ使うか

- 新しい Issue として要求を残すとき
- 既存 Issue に書いてある要求を変えるとき

## 手順

### Step 1: 対象を決める

数字の Issue 番号があれば更新。無ければ起票。

対象リポジトリは、起票なら第 1 引数の `owner/repo`、更新なら第 2 引数の `owner/repo`。省略時はカレントディレクトリのリポジトリ。

更新なら、引数の Issue 番号を対象にする。

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

### Step 2: スキーマを読み、更新なら Issue と変更内容を決める

`references/issue-schema.md` を読む。本文を読む・直す前に読む。

更新なら、Issue を読む。

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url
```

```bash
gh pr list --repo <owner/repo> --search "<number>" --state open --limit 10
```

この Issue を扱う open PR があれば URL を出して、進むか待つ。

```bash
gh issue view <number> --repo <owner/repo> --json assignees,labels,title
```

他者が担当している、または `in-progress` があるなら知らせて、進むか待つ。勝手に進まない。

更新なら、会話に変更内容があれば、それを使う。無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 3: 情報を集める

起票なら、概要、背景、バージョン、受け入れ条件が書けるところまで、会話・コード・GitHub から集める。

更新なら、概要、背景、バージョン、受け入れ条件のうち、変えるところと、それに連動して直すところが書けるまで、会話・コード・GitHub から集める。変えない見出しは今の本文を残す。

コードを調べるのは、カレントディレクトリが対象リポジトリのときだけ。引数の `owner/repo` がカレントと違うときは、会話と GitHub から集める。コードでないと書けない事実は、足りないことにする。

コードから取るのは、本文に書く事実だけにする。今の挙動、対象、既存の契約、エラーを取る。「何が揃えば完了か」まで取る。差し方、ライブラリ、手順は書かない。

### Step 4: 足りないことを聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

起票で種類（バグ / 機能追加 / それ以外）が決まっていないときは、それを最初に聞く。バグでバージョンが会話に無ければ、それも聞く。

更新で種類を変えるとき、種類が決まっていなければそれを最初に聞く。バグに変えるのにバージョンが会話に無ければ、それも聞く。

### Step 5: タイトルと本文を組む

タイトルと本文は `references/issue-schema.md` に従う。

更新なら、今の本文が型に沿っている箇所は、変えないところを残す。空になった見出しは残さない。

機能追加のバージョンは、起票なら次で取る。更新なら、機能追加のバージョンを書き直すときだけ取る。

```bash
gh api repos/{owner}/{repo} --jq .default_branch
gh api repos/{owner}/{repo}/commits/<default_branch> --jq '.sha[0:7]'
```

### Step 6: 起票なら重複を探す

起票なら、見出しが書けるようになってから、確認の前に一度だけ探す。タイトルとキーワードで、開いている Issue も閉じている Issue も探す。

```bash
gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10
```

`--repo` はカレントディレクトリのリポジトリなら省略してよい。

重複らしきものがあれば止めて URL を出す。ユーザーが「それでも切る」と言うまで次へ進まない。

### Step 7: タイトルと本文を出して確認する

タイトルと本文をチャットに出す。ユーザーが認めたあとだけ次へ進む。修正指示があれば直して、再度出す。確認前に起票しない。確認前に更新しない。

### Step 8: 起票または更新する

本文をリポジトリ外の一時ファイルへ書き、`--body-file` で渡す。複数行の本文を `--body` の引数に埋め込まない。

起票なら、次で起票する。

```bash
gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file>
```

更新なら、次で更新する。

```bash
gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>
```

Issue type は種類から決める。バグは Bug、機能追加は Feature、それ以外は Task。

起票なら、リポジトリの type 一覧を取り、対応する id が無ければ type は付けない。type を付ける場合は、起票後に Issue の `node_id` と type の id で更新する。

更新なら、種類が変わるときだけ Issue type を変える。そのとき type 一覧を取り、対応する id が無ければ type は変えない。

type を付ける、または変えるときだけ、次を使う。

```bash
gh api graphql -f query='{ repository(owner:"<owner>", name:"<repo>") { issueTypes(first:20) { nodes { name id } } } }'
```

```bash
gh api repos/{owner}/{repo}/issues/{number} --jq .node_id
gh api graphql -f query='mutation($id:ID!, $typeId:ID!) { updateIssue(input:{id:$id, issueTypeId:$typeId}) { issue { url issueType { name } } } }' -f id="<node_id>" -f typeId="<type_id>"
```

起票後または更新後、次でタイトル、本文、状態、URL を確認する。

```bash
gh issue view <number> --repo <owner/repo> --json number,title,state,body,url
```

Issue URL を返す。実装しない。PR を出さない。

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view --json nameWithOwner --jq .nameWithOwner` | 対象リポジトリを特定する |
| `gh issue view <number> --repo <owner/repo> --json number,title,state,body,url` | Issue の内容と変更結果を読む |
| `gh issue view <number> --json assignees,labels,title` | 担当と in-progress を見る |
| `gh pr list --search "<number>" --state open --limit 10` | この Issue の open PR |
| `gh api repos/{owner}/{repo} --jq .default_branch` | デフォルトブランチ名を取る |
| `gh api repos/{owner}/{repo}/commits/<default_branch> --jq '.sha[0:7]'` | 機能追加のバージョン用 short SHA を取る |
| `gh issue list --repo <owner/repo> --search "<keywords>" --state all --limit 10` | 起票前に重複 Issue を探す |
| `gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file>` | 確認後に起票する |
| `gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>` | 確認後にタイトルと本文を更新する |
| `gh api graphql` （`issueTypes`） | リポジトリの Issue type 一覧を取る |
| `gh api repos/{owner}/{repo}/issues/{number} --jq .node_id` | type 更新用の node_id を取る |
| `gh api graphql` （`updateIssue`） | Issue type を付ける、または種類が変わるとき変える |
