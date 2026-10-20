---
name: git-switch-default
description: >
  現在の作業ツリーをリポジトリのデフォルトブランチへ切り替える。
  originのHEADからデフォルトブランチを特定し、mainやmasterは推測しない。
  未コミットの変更があるときは切り替えず、最新化はfast-forwardだけ行う。
  ユーザーが「デフォルトブランチに切り替えて」「デフォルトブランチに戻って」
  「mainに戻って」「masterに戻って」「作業ブランチから戻って」
  など、デフォルトブランチへ移ることを依頼した場合に使用する。
---

# git-switch-default

## できること

- リポジトリのデフォルトブランチを特定する
- 現在の作業ツリーをそのブランチへ切り替える
- ローカルが `origin` より遅れているときだけ fast-forward する
- 切り替え後のブランチ名と SHA を返す

## いつ使うか

- デフォルトブランチに切り替えて
- デフォルトブランチに戻って
- mainに戻って
- masterに戻って
- 作業ブランチから戻って
- デフォルト以外のブランチ名を指定して、そのブランチへ移るときは使わない
- 新しいブランチやワークツリーを作るときは使わない
- コミットや push の依頼では使わない

## 手順

### Step 1: 作業ツリーの状態を確認する

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --porcelain=v2 --branch
```

Gitリポジトリでなければ停止する。

`git status --porcelain=v2` に変更がある場合は切り替えない。未コミットの変更はデフォルトブランチへ持ち越される。ユーザーが変更を持ったまま切り替えるよう明示した場合に限り、変更を残したまま続けてよい。

`git branch --show-current` が空のときは detached HEAD として扱う。作業ツリーがきれいなら、このあとの切り替えは続けてよい。

### Step 2: デフォルトブランチを特定する

次の順で特定する。

1. `origin` の HEAD
2. ローカルの `origin/HEAD`

```bash
git ls-remote --symref origin HEAD
git symbolic-ref --short refs/remotes/origin/HEAD
```

`ref: refs/heads/<default> HEAD` の `<default>` をデフォルトブランチとする。どちらからも特定できない場合は停止する。`main` や `master` を推測しない。ローカルの `origin/HEAD` から取得した場合は、先頭の `origin/` を除いた名前を `<default>` とする。

ユーザーがブランチ名を言っている場合は、その名前と `<default>` を比べる。一致すれば続ける。一致しなければ切り替えず、解決したデフォルトブランチ名と、ユーザーが言った名前を返す。

### Step 3: origin から取得する

```bash
git fetch origin <default>
```

fetch が成功した場合は、`origin/<default>` を更新元にする。

fetch が失敗した場合は、ローカルの `<default>` を確認する。

```bash
git show-ref --verify --quiet refs/heads/<default>
```

ローカルの `<default>` が存在すれば、fetch が失敗したことを報告し、更新せず Step 4 へ進む。存在しなければ停止する。

### Step 4: 他のワークツリーを確認する

```bash
git worktree list --porcelain
```

`branch refs/heads/<default>` を持つ作業ツリーが、現在の `git rev-parse --show-toplevel` 以外にあれば切り替えない。そのパスを返す。現在の作業ツリーがすでに `<default>` なら、この確認は通過する。

### Step 5: ローカルと origin の関係を確認する

fetch が成功し、ローカルの `<default>` が存在する場合だけ確認する。

```bash
git rev-list --left-right --count origin/<default>...refs/heads/<default>
```

出力は `<behind> <ahead>` として扱う。

- `behind` と `ahead` がともに 0 なら、`origin` と一致している
- `behind` が 1 以上で `ahead` が 0 なら、fast-forward できる
- `ahead` が 1 以上で `behind` が 0 なら、ローカルに未 push のコミットがある
- `behind` と `ahead` がともに 1 以上なら、履歴が分岐している

ローカルの `<default>` がない場合は、この確認を省略する。作成時点で `origin/<default>` と同じコミットになる。

### Step 6: デフォルトブランチへ切り替える

現在のブランチがすでに `<default>` なら、切り替えコマンドは実行しない。

ローカルの `<default>` がある場合:

```bash
git switch <default>
```

ローカルになく、fetch が成功している場合:

```bash
git switch -c <default> --track origin/<default>
```

失敗した場合は停止する。stash、`reset`、`rebase` で切り替えを続けない。

### Step 7: 遅れているときだけ fast-forward する

次をすべて満たすときだけ更新する。

- fetch が成功している
- 現在のブランチが `<default>` である
- `behind` が 1 以上で `ahead` が 0 である
- 作業ツリーがきれいである。変更を持ったまま続けている場合は更新しない

```bash
git merge --ff-only origin/<default>
```

履歴が分岐している場合は merge しない。ローカルが先行している場合も merge せず、push もしない。

### Step 8: 結果を確認する

```bash
git branch --show-current
git rev-parse HEAD
git status --porcelain=v2 --branch
```

現在のブランチが `<default>` であることを確認する。違う場合は成功として扱わない。

次を返す。

- 切り替え前のブランチ。detached HEAD だった場合はその旨
- デフォルトブランチ名
- HEAD の SHA
- `origin` との関係。一致、fast-forward した、ローカルが先行、分岐のため更新していない、fetch できず更新していない、のいずれか
- 未コミットの変更を持ったまま続けた場合はその旨

## 禁止事項

- `main` や `master` をデフォルトブランチとして推測しないこと
- 未コミットの変更を、持ち込みの明示なしにデフォルトブランチへ移さないこと
- 変更を退避するために stash しないこと
- `reset --hard`、`rebase`、`pull` を使わないこと
- merge は `--ff-only` だけを使い、分岐した履歴は更新しないこと
- デフォルトブランチへ push しないこと
- ユーザーが言った名前がデフォルトブランチと違うときは、どちらへも切り替えないこと
- 他のワークツリーが使っているブランチへは切り替えないこと

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| デフォルトブランチへ戻る | `git-switch-default` |
| 戻ってからブランチを作る | `git-switch-default` → `git-branch-create` |
| ブランチを作る | `git-branch-naming` → `git-branch-create` |
| ワークツリーを作る | `wt-switch-create` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `git status --porcelain=v2 --branch` | 未コミットの変更とブランチ状態を確認する |
| `git branch --show-current` | 現在のブランチを確認する |
| `git ls-remote --symref origin HEAD` | `origin` のデフォルトブランチを確認する |
| `git symbolic-ref --short refs/remotes/origin/HEAD` | ローカルの `origin/HEAD` からデフォルトブランチを確認する |
| `git fetch origin <default>` | `origin` からデフォルトブランチを取得する |
| `git show-ref --verify --quiet refs/heads/<default>` | ローカルのデフォルトブランチが存在するか確認する |
| `git worktree list --porcelain` | 他の作業ツリーが同じブランチを使っていないか確認する |
| `git rev-list --left-right --count origin/<default>...refs/heads/<default>` | behind/ahead を確認する |
| `git switch <default>` | 既存のローカルブランチへ切り替える |
| `git switch -c <default> --track origin/<default>` | 追跡ブランチを作って切り替える |
| `git merge --ff-only origin/<default>` | 遅れているローカルを fast-forward する |
| `git rev-parse HEAD` | 切り替え後の SHA を確認する |
