---
name: glab-mr-create-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、指定されたpush済みブランチからMerge Requestを作成する。
  diffを取るため先に空の下書きを作り、組んだタイトルと本文を入れてreadyにする。
  スキーマに沿って本文を作る。
  Gitと.gitには触れない。
  例: glab-mr-create-no-git --head feat/example --issue 123。
  「MRを作成」「マージリクエストを開く」「レビューのために送信」などの操作を、Gitコマンドを使わずに行う際に使用する。
---

# glab-mr-create-no-git

## できること

- Gitと`.git`を使わず、指定されたpush済みブランチからMerge Requestを作成する
- 本文を書く前に下書きを作り、そのdiffとコミットを取得する
- `glab-mr-schema` で本文を組み立てる
- 組んだタイトルと本文を、作成したMRへ入れてreadyにする
- 作成後のタイトル、本文、base、headを検証する

## いつ使うか

- `glab-mr-create-no-git`
- `glab-mr-create-no-git --head feat/example`
- `glab-mr-create-no-git --head feat/example --base develop`
- `glab-mr-create-no-git --head feat/example --issue 123`
- AIによるGitコマンド実行が禁止されたプロジェクトでMerge Requestを作成するとき
- GitLab上にpush済みのheadを明示してMerge Requestを作成するとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。`.git`を直接読んで同等の情報を取得しない。

プロジェクトとホストは、引数なしの`glab repo view`で取る。`glab mr`はカレントブランチに依存するため使わない。以降のAPIは`glab api`だけを使う。

APIパスに`:fullpath`、`:id`、`:namespace`、`:repo`、`:branch`を書かない。プレースホルダはカレントディレクトリのGit情報で展開される。

### Step 2: 対象プロジェクトとブランチを決める

対象プロジェクトとホストは、引数なしの`glab repo view`で取る。

```bash
glab repo view -F json --jq '{path:.path_with_namespace,default_branch:.default_branch,web_url:.web_url}'
```

`path`をプロジェクトパスにする。ホストは`web_url`から取る。スキームとパスを除く。ポートがあれば`host:port`。`default_branch`はデフォルトブランチである。

取得できなければ停止する。Gitコマンドや`.git`からは取らない。

以降の`glab api`には、ここで得たホストを`--hostname`で渡す。プロジェクトパスの`/`は`%2F`にする。例: `group/subgroup/project`は`group%2Fsubgroup%2Fproject`。

headは次の順で決める。

1. `--head`で指定されたpush済みブランチ
2. 会話で明示されたpush済みブランチ

headを特定できない場合はユーザーに聞く。ローカルブランチから推測しない。

baseは次の順で決める。

1. `--base`で指定されたブランチ
2. 会話で指定されたブランチ
3. `glab repo view`で得たデフォルトブランチ

baseとheadが同じ場合は停止する。

### Step 3: closeするIssueを確認する

closeするIssueは次の順で決める。

1. `--issue`で指定されたIssue
2. 会話で示されたIssue

### Step 4: 同じheadの既存MRを確認する

下書きMRを作成する前に、同じheadを使ったMRを確認する。`source_branch`の値はURLエンコードする。

```bash
glab api --hostname <host> --paginate "projects/<encoded-path>/merge_requests?state=all&source_branch=<encoded-head>"
```

JSONの`iid`、`state`、`draft`、`web_url`、`source_branch`、`target_branch`を見る。

- `opened`または`locked`のMRがあれば、新しいMRを作成せずURLを返す。タイトルや本文を変えるときは`glab-mr-update-no-git`を使う
- 既存の下書きMRをこのスキルで続けたいとユーザーが明示し、`source_branch`と`target_branch`が指定内容に一致する場合は、そのMRを再利用する。Step 5を飛ばしてStep 6へ進む
- `merged`または`closed`のMRがあれば、同じheadを再利用せず、新しいブランチを使う

### Step 5: 下書きMRを作成する

GitLabではタイトルが必須のため、完全に空のMRは作れない。仮タイトルは`Draft: <head>`とし、説明は空にする。GitLabはタイトル先頭の`Draft:`を下書きとして扱う。APIの真偽値だけでは下書きを指定できない。

仮タイトル、空の説明、base、headをJSONへ変換し、リポジトリ外の一時ファイルへ保存する。ファイル名は`.json`で終わるものにする。文字列を手作業でJSONエスケープせず、JSONを安全に生成できる手段を使う。

```json
{
  "title": "Draft: <head>",
  "description": "",
  "source_branch": "<head>",
  "target_branch": "<base>"
}
```

一時ファイルを`--input`へ渡し、GitLab APIで下書きMRを作成する。`glab mr create`は使わない。

```bash
glab api --hostname <host> --method POST -H "Content-Type: application/json" "projects/<encoded-path>/merge_requests" --input <payload-file>
```

作成に失敗した場合は自動で再試行しない。エラーを確認し、headが存在しない、baseとの差分がない、権限がないなどの原因をユーザーへ返す。

### Step 6: 作成したMRからdiffを取得する

作成時のレスポンスから`iid`を取得し、MRを取得する。

```bash
glab api --hostname <host> "projects/<encoded-path>/merge_requests/<iid>"
```

これは仮タイトルのMRの確認である。

- stateが`opened`
- draftが`true`
- source_branchがheadと一致する
- target_branchがbaseと一致する

一致しない場合はdiffを取得せず停止し、作成済みMRのURLと差異をユーザーへ返す。

一致した場合だけ、そのMRのコミットとdiffを取得する。

```bash
glab api --hostname <host> --paginate "projects/<encoded-path>/merge_requests/<iid>/commits"
glab api --hostname <host> --paginate "projects/<encoded-path>/merge_requests/<iid>/diffs?unidiff=true"
```

diffを取得できなければ本文を作らない。`collapsed`または`too_large`のファイルがある場合も、欠けたdiffを補わず停止する。現在のファイル内容や会話中の未push変更からdiffを補わない。

### Step 7: スキーマを読む

`glab-mr-schema`を読む。タイトルや本文を組む前に読む。

### Step 8: MR本文に必要な情報を集める

変更目的、変更内容、テスト内容が書けるところまで、会話、作成したMRのコミット、作成したMRのdiffから集める。

コミットは取得した`title`と`message`だけを使う。

- 変更目的は会話から取る。diffから推測しない
- 変更内容はMRのdiffにある事実だけを書く
- ローカルファイルや会話中の未push変更をMR本文へ含めない

### Step 9: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。

- 変更目的が会話に無ければ聞く

### Step 10: タイトルと本文を組む

本文は`glab-mr-schema`の文書構成で書く。書き方は`report-patterns`にも従う。

- 作成したMRのdiffにない変更を本文へ含めない

### Step 11: 可読性を確認する

更新の前に`report-patterns`を読み、Step 10のタイトルと本文がその書き方で読みやすくできるか確認する。できる箇所があれば、見出し構成と記載した事実は変えずに直す。

### Step 12: MRを更新する

組んだタイトルと本文をJSONへ変換し、リポジトリ外の一時ファイルへ保存する。

```json
{
  "title": "<title>",
  "description": "<body>"
}
```

一時ファイルを`--input`へ渡し、作成済みMRを更新する。更新は`PUT`である。

```bash
glab api --hostname <host> --method PUT -H "Content-Type: application/json" "projects/<encoded-path>/merge_requests/<iid>" --input <payload-file>
```

Issueを起票しない。コミットしない。pushしない。

### Step 13: 更新結果を検証する

更新されたMRを取得する。

```bash
glab api --hostname <host> "projects/<encoded-path>/merge_requests/<iid>"
```

次を確認する。

- stateが`opened`
- draftが`false`
- titleが組んだタイトルと一致する
- descriptionが組んだ本文と一致する
- source_branchがheadと一致する
- target_branchがbaseと一致する
- closeするIssueが、本文末尾の`Closes`行に書かれている

一致しない場合は成功として扱わず、差異とMR URLをユーザーへ返す。すべて一致したらMR URLを返す。一時ファイルは削除する。

## 安全条件

- 読み取り専用を含む`git`コマンドを実行しない
- Gitを内部で呼び出すツールを使わない
- `.git`を直接読んで禁止を迂回しない
- `glab mr`を使わない
- APIパスのプレースホルダを使わない
- `glab api`の`--hostname`は、`glab repo view`の`web_url`から取ったホストにする
- 対象プロジェクトとホストを`glab repo view`以外から取らない
- baseとheadをローカルブランチから推測しない
- 下書きMRを作る前にdiffを取得しない
- 同じheadのMRを重複して作成しない
- 作成したMR以外のdiffを本文作成に使わない
- MRのdiffにない変更を本文へ含めない
- `report-patterns`を読まずに更新しない
- 作成や更新に失敗しても、MRを無断で閉じたり削除したりしない

## スキル連携

| 状況 | 使用するスキル |
| --- | --- |
| Gitコマンドを実行できる | `glab-mr-create` |
| Gitコマンドを実行でき、既存MRを更新する | `glab-mr-update` |
| AIによるGitコマンド実行が禁止されている | `glab-mr-create-no-git` |
| AIによるGitコマンド実行が禁止され、既存MRを更新する | `glab-mr-update-no-git` |
| headがGitLabへpushされていない | ユーザーがpushした後に再開する |
| MR本文の型 | `glab-mr-schema` |
| 本文の書き方・可読性 | `report-patterns` |
| GitHubのPull Request | `gh-pr-create`または`gh-pr-create-no-git` |
