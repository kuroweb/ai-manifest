---
name: glab-mr-update-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、指定したMerge Requestのタイトルと本文を確認後に更新する。
  スキル名で呼ばれたときだけ使用し、Gitと.gitには触れない。
  例: glab-mr-update-no-git --repo group/project --mr 42 --hostname gitlab.example.com。
  「MRを更新して」だけでは使わない。Gitコマンドを実行できるプロジェクトではglab-mr-updateを使う。
  スキル名が無いときは使わない。
  `--repo`、`--mr`、`--hostname`が無いときは聞いてから進む。
  MRの新規作成、Issue起票、実装、コミット、pushは行わない。
---

# glab-mr-update-no-git

## できること

- Gitと`.git`を使わず、指定したMerge Requestの既存内容を保ちながら、要求された箇所を更新する
- そのMRのdiffとコミットだけを本文の根拠にする
- `glab-mr-schema`に沿ってタイトルと本文を組み立てる
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `glab-mr-update-no-git --repo group/project --mr <iid> --hostname gitlab.example.com`
- `glab-mr-update-no-git --repo group/subgroup/project --mr <iid> --hostname gitlab.example.com`
- AIによるGitコマンド実行が禁止されたプロジェクトで、既存Merge Requestのタイトルや本文を変えるとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。Gitを内部で呼び出すツールや、`.git`を直接読んで同等の情報を取得する方法も使わない。

`glab`は`glab api`だけを使う。`glab mr`はカレントブランチやカレントディレクトリのGitホストに依存するため使わない。

APIパスに`:fullpath`、`:id`、`:namespace`、`:repo`、`:branch`を書かない。プレースホルダはカレントディレクトリのGit情報で展開される。

プロジェクトとホストは引数で明示する。`--hostname`を必ず渡す。

### Step 2: 対象を決める

対象プロジェクトは`--repo`で指定された値を使う。`group/project`、`group/subgroup/project`、または`https://<host>/<path>`。省略されている場合は、Gitから推測せずユーザーに聞く。URLの場合は末尾の`.git`を除いたパスをプロジェクトパスにする。

MRのiidは`--mr`で指定する。無いときはユーザーに聞く。ローカルブランチから推測しない。

ホストは次の順で決める。

1. `--hostname`
2. `--repo`がURLなら、そのホスト。ポートがあれば`host:port`
3. 会話で指定されたホスト

決まらなければユーザーに聞く。Git remoteやカレントディレクトリからは取らない。`--hostname`にはスキームとパスを含めない。

対象プロジェクトとデフォルトブランチをGitLab APIから取得する。プロジェクトパスの`/`は`%2F`にする。例: `group/subgroup/project`は`group%2Fsubgroup%2Fproject`。

```bash
glab api --hostname <host> "projects/<encoded-path>"
```

レスポンスの`path_with_namespace`、`default_branch`、`web_url`を使う。

### Step 3: スキーマと既存MRを読む

`glab-mr-schema`を読む。タイトルや本文を組む前に読む。

```bash
glab api --hostname <host> "projects/<encoded-path>/merge_requests/<iid>"
```

JSONの`iid`、`state`、`draft`、`title`、`description`、`source_branch`、`target_branch`、`web_url`、`sha`を見る。

`opened`でなければ状態とURLを示し、ユーザーが続行を明示するまで待つ。

更新内容が会話に無ければ、何を変えるかを聞く。変更内容が決まるまで次へ進まない。

### Step 4: そのMRのdiffを取る

```bash
glab api --hostname <host> --paginate "projects/<encoded-path>/merge_requests/<iid>/commits"
glab api --hostname <host> --paginate "projects/<encoded-path>/merge_requests/<iid>/diffs?unidiff=true"
```

コミットは取得した`title`と`message`だけを使う。

diffを取得できなければ本文を作らない。`collapsed`または`too_large`のファイルがある場合も、欠けたdiffを補わず停止する。現在のファイル内容や会話中の未push変更からdiffを補わない。

### Step 5: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。変えない箇所については聞かない。

- 変更目的を書き換えるのに会話へ無ければ聞く。diffから推測しない
- closeするIssueを変更するときは、会話で示されたIssue番号を使う

### Step 6: タイトルと本文を組む

タイトルと本文は`glab-mr-schema`に従う。

要求された変更と整合に必要な変更だけを加える。既存本文がスキーマに沿っている箇所は残し、空になった見出しは残さない。

- そのMRのdiffにない変更を本文へ含めない
- 本文の行を`/`で始めない
- `draft`がtrueで、ユーザーがreadyにすると明示していないときは、タイトル先頭の`Draft:`を残す。外すとGitLabはそのMRをreadyにする

### Step 7: 更新前に確認する

対象プロジェクト、ホスト、iid、タイトル、本文をチャットに出す。変更する箇所が分かるように示す。draftを維持するときは、そのことも出す。

ユーザーが認めたあとだけ更新する。修正指示があれば反映し、タイトルと本文を再度出す。確認前に更新しない。

### Step 8: MRを更新する

確認済みのタイトルと本文をJSONへ変換し、リポジトリ外の一時ファイルへ保存する。ファイル名は`.json`で終わるものにする。文字列を手作業でJSONエスケープせず、JSONを安全に生成できる手段を使う。

```json
{
  "title": "<title>",
  "description": "<body>"
}
```

`source_branch`、`target_branch`、`state_event`はJSONへ入れない。更新は`PUT`である。

```bash
glab api --hostname <host> --method PUT -H "Content-Type: application/json" "projects/<encoded-path>/merge_requests/<iid>" --input <payload-file>
```

Issueを起票しない。コミットしない。pushしない。

### Step 9: 更新結果を検証する

```bash
glab api --hostname <host> "projects/<encoded-path>/merge_requests/<iid>"
```

次を確認する。

- titleが確認済みのタイトルと一致する
- descriptionが確認済みの本文と一致する
- stateが更新前と一致する
- draftが更新前と一致する
- source_branchが更新前と一致する
- target_branchが更新前と一致する
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異とMR URLを返す。すべて一致したらMR URLを返す。一時ファイルは削除する。

## 安全条件

- 読み取り専用を含む`git`コマンドを実行しない
- Gitを内部で呼び出すツールを使わない
- `.git`を直接読んで禁止を迂回しない
- `glab mr`を使わない
- APIパスのプレースホルダを使わない
- `--hostname`を省略しない
- 対象プロジェクト、ホスト、iidをGitから推測しない
- ユーザー確認前にMRを更新しない
- `opened`でないMRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draftを変えない
- ユーザーの明示なしに`Draft:`を外さない
- そのMRのdiffにない変更を本文へ含めない
- 作成や更新に失敗しても、MRを無断で閉じたり削除したりしない
- 本文の行を`/`で始めない

## スキル連携

| 状況 | 使用するスキル |
|---|---|
| Gitコマンドを実行できる | `glab-mr-update` |
| AIによるGitコマンド実行が禁止されている | `glab-mr-update-no-git` |
| MRを新規作成する | `glab-mr-create`または`glab-mr-create-no-git` |
| MR本文の型 | `glab-mr-schema` |
| GitHubのPull Request | `gh-pr-update`または`gh-pr-update-no-git` |
