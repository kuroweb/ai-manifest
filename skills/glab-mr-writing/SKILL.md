---
name: glab-mr-writing
description: >
  GitLab Merge Requestのタイトルと本文を、型に沿って書く。
  他のスキルが読むよう指示したとき、またはユーザーが`glab-mr-writing`と明示したときに使う。
---

# glab-mr-writing

## できること

- `references/schema.md` の型に沿って、MRのタイトルと本文を書く
- 呼び出し元が取ったMRのコミットとdiffだけを、変更内容の根拠にする
- 既存MRを更新するときは、変える箇所だけを書き直す
- 書いたタイトルと本文を`report-patterns`で見直す

## いつ使うか

- 他のスキルが`glab-mr-writing`を読むよう指示したとき
- ユーザーが`glab-mr-writing`と明示したとき

## 手順

### Step 1: 型を読む

`references/schema.md` を読む。

### Step 2: 材料を集める

変更目的、変更内容、テスト内容が書けるところまで、会話、Issue、呼び出し元が取ったMRのコミットとdiffから集める。

- 変更目的は、型の変更目的の節に従って集める。diffから推測しない
- 変更内容は、MRのdiffにある事実だけを書く
- ローカルファイルや会話中の未push変更は、MRのdiffに無ければ使わない

既存MRを更新するときは、変える箇所と、それに連動して直す箇所だけを集める。

diffが無ければ本文を書かない。

### Step 3: 足りない情報を聞く

本文に書けない情報だけを、一度に一つ聞く。選択肢と推奨回答を出す。既存MRを更新するときは、変えない箇所については聞かない。

- 変更目的を書くのに必要な情報が無ければ聞く
- closeするIssueは、呼び出し元が決めたIssue、または会話で示されたIssue番号を使う

### Step 4: 書く

`references/schema.md` の型に沿って、タイトルと本文を書く。書き方は`report-patterns`にも従う。

既存MRを更新するときは、要求された変更と整合に必要な変更だけを加える。既存本文が型の見出し構成に沿っている箇所は残し、空になった見出しは残さない。

- 既存MRの`draft`がtrueで、ユーザーがreadyにすると明示していないときは、タイトル先頭の`Draft:`を残す。外すとGitLabはそのMRをreadyにする

### Step 5: 見直す

`report-patterns`を読み、Step 4のタイトルと本文がその書き方で読みやすくできるか確かめる。できる箇所があれば、見出し構成と記載した事実は変えずに直す。

## 安全条件

- `references/schema.md` と`report-patterns`を読まずに書かない
- MRのdiffにない変更を本文へ含めない
- 会話、Issue、コミット、diffで確かめていない事実を推測で書かない
- ユーザーの明示なしに`Draft:`を外さない

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| MR作成 | `glab-mr-create` |
| MR更新 | `glab-mr-update` |
| Gitコマンド禁止環境でMR作成 | `glab-mr-create-no-git` |
| Gitコマンド禁止環境でMR更新 | `glab-mr-update-no-git` |
| 本文の書き方・可読性 | `report-patterns` |
