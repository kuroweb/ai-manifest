---
name: gh-pr
description: >
  スキル名で呼ばれたときだけ、GitHub Pull Request を構造化して確認後に作成する。
  作成前に、スキーマの見出しが書けるところまで情報を集め、同じブランチの PR を探す。
  例: gh-pr、/gh-pr owner/repo。
  「PR を作って」「プルリク出して」だけでは使わない。
  スキル名が無いときは使わない。
  起票、実装、コミットでは使わない。
---

# gh-pr

## できること

- スキーマに沿ったタイトルと本文で、GitHub Pull Request を作成する

## いつ使うか

- いまのブランチから Pull Request を出すとき

## 手順

### Step 1: 対象を決める

対象リポジトリは引数の `owner/repo`。省略時はカレントディレクトリのリポジトリ。ベースはデフォルトブランチ。会話で別のベースが指定されていればそれに従う。

```bash
gh repo view --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,base:.defaultBranchRef.name}'
```

カレントディレクトリが対象リポジトリのとき、今のブランチを見る。

```bash
git branch --show-current
git status --porcelain
git rev-list --count <base>..HEAD
```

デフォルトブランチにいる、detached、ベースとの差分コミットが 0 なら止まる。ブランチは作らない。

未コミットの変更があれば知らせて、進むか待つ。コミットはしない。未コミットを本文の変更として書かない。

### Step 2: スキーマを読む

`references/pr-schema.md` を読む。本文を組む前に読む。

### Step 3: 情報を集める

変更目的、変更内容、テスト内容、関連 Issue が書けるところまで、会話・差分・GitHub から集める。

差分を調べるのは、カレントディレクトリが対象リポジトリのときだけ。引数の `owner/repo` がカレントと違うときは、会話と GitHub から集める。差分でないと書けない事実は、足りないことにする。

```bash
git --no-pager log <base>..HEAD --format=%s%n%b
git --no-pager diff <base>...HEAD
```

本文に書く事実は、diff と会話から取る。diff にない事実は書かない。

変更目的は diff から決めない。テスト内容は、diff にあるテストの追加・変更から取る。無ければ `- なし` にする。

Issue 番号の候補は、会話、ブランチ名、コミットメッセージから取る。候補があるだけでは、完了するとも言及だけとも扱わない。

### Step 4: 足りないことを聞く

本文に書けないことだけ、一度に一つ聞く。選択肢と推奨回答を出す。推奨でよければ本文に使い、別案ならそれに従う。

変更目的が会話に無いときは、それを聞く。

ベースがデフォルトブランチで、候補が完了するか言及だけかが決まらないときは、それを聞く。候補が一つで完了するなら `Closes` を推奨する。書く行が無ければ、見出しごと省く。番号が無いときは聞かない。

### Step 5: タイトルと本文を組む

タイトルと本文は `references/pr-schema.md` に従う。

### Step 6: 既存 PR を探す

見出しが書けるようになってから、確認の前に一度だけ探す。

```bash
gh pr list --repo <owner/repo> --head <branch> --state open --json url --jq '.[].url'
```

`--repo` はカレントディレクトリのリポジトリなら省略してよい。

同じブランチの open PR があれば止めて URL を出す。作成はしない。

### Step 7: タイトルと本文を出して確認する

タイトルと本文をチャットに出す。ユーザーが認めたあとだけ次へ進む。修正指示があれば直して、再度出す。確認前に push しない。確認前に作成しない。

### Step 8: 作成する

カレントディレクトリが対象リポジトリのときだけ、確認後にリモートへ出す。

```bash
git push -u origin HEAD
```

push が失敗したら PR は作らない。force push しない。

```bash
gh pr create --repo <owner/repo> --base <base> --head <branch> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

本文は quoted heredoc。未展開の `${` を残さない。

作成後、PR URL を返す。実装しない。コミットしない。Issue は起票しない。

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `gh repo view --json nameWithOwner,defaultBranchRef --jq '{repo:.nameWithOwner,base:.defaultBranchRef.name}'` | 対象リポジトリとデフォルトブランチを取る |
| `git branch --show-current` | 今のブランチを取る |
| `git status --porcelain` | 未コミットの有無を見る |
| `git rev-list --count <base>..HEAD` | ベースとの差分コミット数を取る |
| `git --no-pager log <base>..HEAD --format=%s%n%b` | コミットの題と本文から変化と Issue 番号の候補を取る |
| `git --no-pager diff <base>...HEAD` | PR の差分を取る |
| `gh pr list --repo <owner/repo> --head <branch> --state open --json url` | 同じブランチの open PR を探す |
| `git push -u origin HEAD` | 確認後にブランチをリモートへ出す |
| `gh pr create --repo <owner/repo> --base <base> --head <branch> --title "<title>" --body "..."` | 確認後に PR を作成する |
