---
name: git-push
description: >
  ローカルコミットを安全にリモートへ push する。
  upstream、ahead/behind、リモートのデフォルトブランチ、push 先ブランチを確認し、通常 push と初回 push を扱う。
  ユーザーが「pushして」「リモートへ送って」「コミットをpush」
  「変更をリモートに反映して」など、既存コミットの push を依頼した場合に使用する。
  コミット作成、Pull Request 作成、タグの push は行わない。
---

# git-push

## できること

- 既存のローカルコミットを、意図したリモートブランチへ push する
- upstream の有無に応じて、通常 push または初回 push を行う
- リモートとの差分を確認し、削除済みブランチや分岐した履歴への push を止める
- push 後にローカルとリモートの SHA が一致したことを確認する

## いつ使うか

- `pushして`
- `リモートへ送って`
- `コミットをpushして`
- `変更をリモートに反映して`
- `git-commit`で作成したコミットをリモートへ送るとき
- 未コミットの変更をコミットするときは使わない
- Pull RequestやMerge Requestを作成するときは使わない

## 手順

### Step 1: ローカルの状態を確認する

```bash
git branch --show-current
git status --porcelain=v2 --branch
git remote -v
git branch -vv
```

次の場合はpushしない。

- ブランチ名が空でdetached HEADになっている
- リモートがない
- 未コミットの変更がある

未コミットの変更はpushされない。既存コミットだけをpushするようユーザーが明示した場合に限り、未コミットの変更を残したまま続けてよい。

### Step 2: push先を決める

upstreamを確認する。

```bash
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
```

upstreamがある場合は、そのリモートとリモートブランチをpush先にする。upstreamがない場合は、リモートとpush先ブランチを決める。

- リモートが1つなら、そのリモートを使う
- リモートが複数あり、会話や既存設定から決められない場合はユーザーに聞く
- push先ブランチの指定がなければ、ローカルと同じブランチ名を使う
- ローカルと異なるブランチ名へ送る場合は、その名前をユーザーが明示している必要がある

リモートURLと、リモートのHEADが指すデフォルトブランチをGitで確認する。

```bash
git remote get-url <remote>
git ls-remote --symref <remote> HEAD
```

`ref: refs/heads/<default-branch> HEAD`の`<default-branch>`をデフォルトブランチとして扱う。取得できない場合は、会話やリポジトリ設定から判断できるときだけその値を使う。判断できなければユーザーに聞き、デフォルトブランチを推測しない。

push先が`main`、`master`、またはリポジトリのデフォルトブランチなら停止する。ユーザーが直接pushを明示していても実行しない。ローカルのデフォルトブランチから別名のリモートブランチへ送ることはできる。

### Step 3: リモートの状態を確認する

upstreamがある場合は、リモート追跡ブランチを更新してahead/behindを確認する。

```bash
git ls-remote --exit-code --heads <remote> refs/heads/<remote-branch>
git fetch <remote> <remote-branch>
git rev-list --left-right --count '@{upstream}'...HEAD
git --no-pager log --oneline '@{upstream}'..HEAD
```

upstreamとして設定されたリモートブランチが存在しない場合は停止する。削除済みブランチを同じ名前で作り直さない。

`git rev-list`の出力は`<behind> <ahead>`として扱う。

- `ahead`が0なら、送るコミットがないため終了する
- `behind`が1以上なら停止する
- `behind`と`ahead`がともに1以上なら、履歴が分岐していることを伝える
- `behind`が0で`ahead`が1以上なら続ける

upstreamがない場合は、リモートのデフォルトブランチとの差分を確認する。

```bash
git fetch <remote> <default-branch>
git rev-list --count <remote>/<default-branch>..HEAD
git --no-pager log --oneline <remote>/<default-branch>..HEAD
```

差分コミットが0ならpushしない。

### Step 4: pushする

通常pushでは、dry runが成功してからpushする。

```bash
git push --dry-run
git push
```

upstreamがなく、ローカルと同名のリモートブランチへ初回pushする場合:

```bash
git push --dry-run <remote> HEAD:<branch>
git push -u <remote> HEAD:<branch>
```

ローカルと異なる名前のリモートブランチへ送る場合は、ローカルブランチのupstreamを変更しない。

```bash
git push --dry-run <remote> HEAD:<remote-branch>
git push <remote> HEAD:<remote-branch>
```

dry runが失敗した場合はpushしない。認証エラー、存在しないリモート、non-fast-forward、ブランチ保護など、表示された原因を返す。

force pushが必要な場合は通常pushを中止する。ユーザーがforce pushを明示した場合に限り、対象リモートブランチをfetchし直し、上書きされるコミットを示してから`--force-with-lease`を使う。

```bash
git fetch <remote> <remote-branch>
git push --force-with-lease <remote> HEAD:<remote-branch>
```

`main`、`master`、デフォルトブランチにはforce pushしない。`--force`は使わない。

### Step 5: push結果を確認する

```bash
git status --porcelain=v2 --branch
git rev-parse HEAD
git ls-remote --heads <remote> refs/heads/<remote-branch>
```

ローカルHEADとリモートブランチのSHAが一致することを確認する。一致しなければ成功として扱わない。

次を返す。

- push先のリモートとブランチ
- pushしたコミット数
- リモートブランチのSHA
- 残っている未コミット変更の有無

## 安全条件

- `main`、`master`、デフォルトブランチへ直接pushしない
- upstreamとして設定されたリモートブランチが削除されていたらpushしない
- behindまたは分岐しているブランチへ通常pushしない
- push先が曖昧な状態でpushしない
- dry runが失敗した状態でpushしない
- force pushには`--force-with-lease`を使い、`--force`は使わない
- タグはpushしない

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| コミット | `git-commit` |
| push | `git-push` |
| コミットしてpush | `git-commit` → `git-push` |
| pushしてPR作成 | `git-push` → `gh-pr` |
| コミットしてPR作成 | `git-commit` → `git-push` → `gh-pr` |

## コマンドリファレンス

| コマンド | 用途 |
|---|---|
| `git status --porcelain=v2 --branch` | 変更、upstream、ahead/behindを確認する |
| `git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'` | upstreamを確認する |
| `git ls-remote --symref <remote> HEAD` | リモートのデフォルトブランチを確認する |
| `git ls-remote --exit-code --heads <remote> refs/heads/<remote-branch>` | upstreamのリモートブランチが存在することを確認する |
| `git fetch <remote> <remote-branch>` | push直前のリモート状態を取得する |
| `git rev-list --left-right --count '@{upstream}'...HEAD` | behind/aheadを確認する |
| `git push --dry-run` | 通常pushを事前確認する |
| `git push -u <remote> HEAD:<branch>` | 同名ブランチへ初回pushする |
| `git push <remote> HEAD:<remote-branch>` | upstreamを変えずに別名ブランチへ送る |
| `git push --force-with-lease <remote> HEAD:<remote-branch>` | 明示されたforce pushを安全に行う |
| `git ls-remote --heads <remote> refs/heads/<remote-branch>` | push後のリモートSHAを確認する |
