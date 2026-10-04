---
name: git-branch-create
description: >
  ローカルGitブランチを新規作成するスキル。
  ユーザーが「ブランチを作って」「新しいブランチを切って」など、
  ブランチ作成を依頼した場合に使用する。
  ユーザーが名前を指定した場合はその名前を使用し、指定がない場合は命名規則に従う候補を提示して選んでもらう。
  作成元はリポジトリのデフォルトブランチとし、--baseが指定された場合はそのブランチを使用する。
  作成元の参照はoriginのブランチを優先し、利用できない場合はローカルブランチを使用する。
---

# git-branch-create

## できること

- ブランチ名の候補を提示し、選択されたブランチ名と作成元を確定する
- ローカルブランチを新規作成する
- 作成結果を確認する

## いつ使うか

- `ブランチを作って`
- `新しいブランチを切って`
- `git-branch-create --base develop`
- `git-branch-naming`で決めた名前のブランチを作成するとき

## 手順

### Step 1: ブランチ名を確定する

ユーザーがブランチ名を指定している場合は、その名前を使用する。

指定がない場合は、`git-branch-naming`に従って候補を2〜4個作り、アンケート形式でユーザーに選ばせる。候補は確定前に`git-branch-naming`の検証パターンを満たしていることを確認する。

- 候補は`type`または説明が互いに異なるものにし、同じ意味の言い換えを並べない。
- 各候補には、その名前を選ぶ理由（type、Issue・チケットとの関連、説明の根拠）を1行で添える。
- 推奨する候補を先頭に置く。
- 選択肢の提示には、エージェントが持つ選択UI（Claude Codeの`AskUserQuestion`など）を使う。使えない場合は番号付きリストで提示し、番号または名前での回答を求める。
- どの候補も選ばれず、ユーザーが別の名前を示した場合はその名前を使用する。

作業内容から候補を1つも作れない場合は、推測せずユーザーにブランチ名を聞く。

### Step 2: 作成元を確定する

作成元は次の順で決定する。

1. `--base <branch>`で指定されたブランチ
2. リポジトリのデフォルトブランチ

`--base`が指定されていない場合は、次の順でデフォルトブランチを特定する。

1. `origin`のHEAD
2. ローカルの`origin/HEAD`

```bash
git ls-remote --symref origin HEAD
git symbolic-ref --short refs/remotes/origin/HEAD
```

どちらからも特定できない場合は停止する。`main`や`master`を推測しない。ローカルの`origin/HEAD`から取得した場合は、先頭の`origin/`を除いた名前を`<base>`とする。

### Step 3: 同名ブランチの存在を確認する

ローカルと`origin`の両方に同名ブランチがないか確認する。

```bash
git show-ref --verify --quiet refs/heads/<branch>
git ls-remote --exit-code --heads origin refs/heads/<branch>
```

いずれかに同名ブランチが存在する場合は作成せず、どこに存在するか（ローカル/リモート）を報告する。リモート確認自体に失敗した場合はその旨を報告し、次のステップへ進む。

### Step 4: 作成元の最新状態を取得する

作成元ブランチを`origin`から取得する。

```bash
git fetch origin <base>
```

fetchが成功した場合は、`origin/<base>`を`<base-ref>`とする。

fetchが失敗した場合は、原因にかかわらずローカルの`<base>`を確認する。

```bash
git show-ref --verify --quiet refs/heads/<base>
```

ローカルの`<base>`が存在すれば、fetchが失敗したことを報告し、`<base>`を`<base-ref>`とする。存在しなければ停止する。

### Step 5: ローカルブランチを作成する

確定した`<base-ref>`からローカルブランチを新規作成する。

```bash
git switch -c <branch> <base-ref>
```

### Step 6: 作成結果を確認する

```bash
git branch --show-current
git rev-parse --verify refs/heads/<branch>
```

作成したブランチへ切り替わっていることを確認し、ブランチ名、作成元、SHAを返す。

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| ブランチ名を決める | `git-branch-naming` |
| ブランチを作成 | `git-branch-naming` → `git-branch-create` |
| 指定された名前でブランチを作成 | `git-branch-create` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `git ls-remote --symref origin HEAD` | `origin`のデフォルトブランチを確認する |
| `git symbolic-ref --short refs/remotes/origin/HEAD` | ローカルの`origin/HEAD`からデフォルトブランチを確認する |
| `git show-ref --verify --quiet refs/heads/<branch>` | 同名のローカルブランチが存在するか確認する |
| `git ls-remote --exit-code --heads origin refs/heads/<branch>` | 同名のリモートブランチが存在するか確認する |
| `git fetch origin <base>` | `origin`から作成元ブランチを取得する |
| `git show-ref --verify --quiet refs/heads/<base>` | フォールバック先のローカルブランチが存在するか確認する |
| `git switch -c <branch> <base-ref>` | 確定した作成元からローカルブランチを作成する |
| `git branch --show-current` | 作成後に現在のブランチを確認する |
| `git rev-parse --verify refs/heads/<branch>` | 作成したブランチのSHAを確認する |
