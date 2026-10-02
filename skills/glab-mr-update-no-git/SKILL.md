---
name: glab-mr-update-no-git
description: >
  AIによるGitコマンド実行が禁止されたプロジェクトで、指定したMerge Requestのタイトルと本文を確認後に更新する。
  Gitと.gitには触れない。
  `.gitlab/merge_request_templates` があればその構成で、無ければスキーマに沿って本文を作る。
  例: glab-mr-update-no-git --mr 42。
  「MRを更新」「MRの説明を修正」「MRのタイトルを変更」などの操作を、Gitコマンドを使わずに行う際に使用する。
  `--mr`が無いときは聞いてから進む。
---

# glab-mr-update-no-git

## できること

- Gitと`.git`を使わず、指定したMerge Requestの既存内容を保ちながら、要求された箇所を更新する
- そのMRのdiffとコミットだけを本文の根拠にする
- `.gitlab/merge_request_templates` があればその構成で、無ければ `glab-mr-schema` で本文を組み立てる
- 更新後のタイトル、本文、base、head、state、draftを検証する

## いつ使うか

- `glab-mr-update-no-git --mr <iid>`
- AIによるGitコマンド実行が禁止されたプロジェクトで、既存Merge Requestのタイトルや本文を変えるとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: Git操作の禁止範囲を確認する

プロジェクトの指示を読み、AIによるGitコマンド実行が禁止されていることを確認する。

このスキルでは、読み取り専用を含むすべての`git`コマンドを実行しない。`.git`を直接読んで同等の情報を取得しない。

プロジェクトとホストは、引数なしの`glab repo view`で取る。`glab mr`はカレントブランチに依存するため使わない。以降のAPIは`glab api`だけを使う。

APIパスに`:fullpath`、`:id`、`:namespace`、`:repo`、`:branch`を書かない。プレースホルダはカレントディレクトリのGit情報で展開される。

### Step 2: 対象を決める

対象プロジェクトとホストは、引数なしの`glab repo view`で取る。

```bash
glab repo view -F json --jq '{path:.path_with_namespace,web_url:.web_url}'
```

`path`をプロジェクトパスにする。ホストは`web_url`から取る。スキームとパスを除く。ポートがあれば`host:port`。

取得できなければ停止する。Gitコマンドや`.git`からは取らない。

MRのiidは`--mr`で指定する。無いときはユーザーに聞く。ローカルブランチから推測しない。

以降の`glab api`には、ここで得たホストを`--hostname`で渡す。プロジェクトパスの`/`は`%2F`にする。例: `group/subgroup/project`は`group%2Fsubgroup%2Fproject`。

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

本文の前に、プロジェクトルートの`.gitlab/merge_request_templates`を見る。

`.md`が無いときは、本文は`glab-mr-schema`の文書構成で書く。あるときはそのファイルを構成にする。`Default.md`があればそれを使う。1件ならそれを使う。複数で`Default.md`が無ければ、ファイル名を一度聞いてから使う。

テンプレートの見出しの並びで書く。意味が近い節は、`glab-mr-schema`のその節の書き方で埋める。書き方は`report-patterns`にも従う。

要求された変更と整合に必要な変更だけを加える。既存本文が採用した見出し構成に沿っている箇所は残し、空になった見出しは残さない。

- そのMRのdiffにない変更を本文へ含めない
- `draft`がtrueで、ユーザーがreadyにすると明示していないときは、タイトル先頭の`Draft:`を残す。外すとGitLabはそのMRをreadyにする

### Step 7: 可読性を確認する

ユーザー確認の前に`report-patterns`を読み、Step 6のタイトルと本文がその書き方で読みやすくできるか確認する。できる箇所があれば、採用した見出し構成と記載した事実は変えずに直す。

### Step 8: 更新前に確認する

対象プロジェクト、ホスト、iid、タイトル、本文をチャットに出す。変更する箇所が分かるように示す。draftを維持するときは、そのことも出す。

ユーザーが認めたあとだけ更新する。修正指示があれば反映し、タイトルと本文を再度出す。確認前に更新しない。

### Step 9: MRを更新する

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

### Step 10: 更新結果を検証する

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
- `glab api`の`--hostname`は、`glab repo view`の`web_url`から取ったホストにする
- 対象プロジェクトとホストを`glab repo view`以外から取らない
- iidをローカルブランチから推測しない
- ユーザー確認前にMRを更新しない
- `report-patterns`を読まずにユーザー確認へ進まない
- `opened`でないMRを、明示的な続行指示なしに更新しない
- 更新対象外のタイトル、本文、base、head、state、draftを変えない
- ユーザーの明示なしに`Draft:`を外さない
- そのMRのdiffにない変更を本文へ含めない
- 作成や更新に失敗しても、MRを無断で閉じたり削除したりしない

## スキル連携

| 状況 | 使用するスキル |
| --- | --- |
| Gitコマンドを実行できる | `glab-mr-update` |
| AIによるGitコマンド実行が禁止されている | `glab-mr-update-no-git` |
| MRを新規作成する | `glab-mr-create`または`glab-mr-create-no-git` |
| MR本文の型 | `glab-mr-schema` |
| 本文の書き方・可読性 | `report-patterns` |
| GitHubのPull Request | `gh-pr-update`または`gh-pr-update-no-git` |
