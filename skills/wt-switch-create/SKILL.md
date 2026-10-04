---
name: wt-switch-create
description: >
  `wt`（worktrunk）でGitワークツリーを新規作成し、移動コマンドを返すスキル。
  ユーザーが「ワークツリーを作って」「worktreeを切って」「wtで作業ブランチを作って」など、
  ワークツリーの作成を依頼した場合に使用する。
  ブランチ名は`git-branch-naming`に従って決め、作成後はユーザーが自分のシェルで実行する
  `cd`コマンドまたは`wt switch`コマンドを返す。作成元はデフォルトブランチとし、--baseが指定された場合はそのブランチを使用する。
---

# wt-switch-create

## できること

- ブランチ名を確定する
- `wt switch --create`でブランチとワークツリーを作成する
- 作成したワークツリーへ移動するコマンドを返す

## いつ使うか

- `ワークツリーを作って`
- `worktreeを切って`
- `wt-switch-create --base develop`

## 手順

### Step 1: ブランチ名を確定する

`git-branch-naming`に従う。

### Step 2: 作成元を確定する

`--base <branch>`が指定されていればそのブランチを使う。指定がなければ`wt`が使うデフォルトブランチに任せ、`--base`は付けない。

### Step 3: 既存のワークツリーを確認する

```bash
wt list --format=json
```

結果に`branch`が`<branch>`と一致する項目があれば作成しない。その項目の`path`を使ってStep 5へ進む。

### Step 4: ワークツリーを作成する

```bash
wt switch --create <branch> --no-cd
wt switch --create <branch> --base <base> --no-cd
```

`--base`が指定されている場合は2行目を使う。

- 同名ブランチがすでにあって失敗した場合は、作成せずその旨を報告する。ブランチだけ存在してワークツリーがないときは、`--create`を外した`wt switch <branch> --no-cd`で作成できることを添える。
- フックの承認を求められた場合は、`-y`や`--no-verify`で飛ばさず、承認が必要であることをユーザーに報告する。

### Step 5: ワークツリーのパスを取得する

```bash
wt list --format=json
```

`branch`が`<branch>`と一致する項目の`path`を読む。見つからなければ作成に失敗したとみなして報告する。

### Step 6: 移動コマンドを返す

ブランチ名、作成元、パスを示し、ユーザーが自分のシェルで実行するコマンドを2つ返す。

```bash
cd <path>
wt switch <branch>
```

- エージェント自身は移動しない。以降の作業をそのワークツリーで続けるときは、ユーザーに移動してもらうか、各コマンドへ`-C <path>`を付ける。

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| ワークツリーを作成 | `git-branch-naming` → `wt-switch-create` |
| 指定された名前でワークツリーを作成 | `wt-switch-create` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `wt list --format=json` | ワークツリーの一覧とパスを取得する |
| `wt switch --create <branch> --no-cd` | ブランチとワークツリーを作成する。シェルの移動はしない |
| `wt switch --create <branch> --base <base> --no-cd` | 作成元を指定して作成する |
| `wt switch <branch>` | 既存のワークツリーへ移動する（ユーザーが実行する） |
