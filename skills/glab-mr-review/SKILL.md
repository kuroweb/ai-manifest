---
name: glab-mr-review
description: >
  指定したGitLab Merge Requestの差分と説明を読み、レビューは`code-reviewing`に任せる。
  例: glab-mr-review --mr 42。
  「MRをレビュー」「このMRをレビューして」「MRの差分を見て」などの操作を行う際に使用する。
  `--mr`が無いときはiidを聞く。
---

# glab-mr-review

## できること

- 指定したGitLab Merge Requestの説明とdiffを取得する
- レビューは`code-reviewing`に任せる

## いつ使うか

- `glab-mr-review --mr <iid>`
- 指定したMerge Requestの差分と説明をレビューするとき

GitHubのPull Requestには使わない。

## 手順

### Step 1: 対象を決める

対象プロジェクトは、引数なしの`glab repo view`で取る。

```bash
glab repo view -F json --jq '{path:.path_with_namespace,web_url:.web_url}'
```

`path`をプロジェクトパスにする。ホストは`web_url`から取る。スキームとパスを除く。ポートがあれば`host:port`。

MRのiidは`--mr`で指定する。`--mr`が無いときだけ止まって聞く。現在のブランチのMRを候補として示してよい。iidをユーザーが認めるまでレビューしない。

対象プロジェクトに対応するgit remoteを、remote URLのホストとプロジェクトパスから特定する。パス比較では末尾の`.git`を除く。対応するremoteが無い、または複数あって一意でない場合は停止する。

以降の`glab`には、そのremote URLを`--repo`で渡す。Self-Managedでもカレントディレクトリのホスト設定に依存しない。

### Step 2: MRの説明を読む

iidと`--repo`を省略しない。省略するとカレントブランチのMRを見に行く。

```bash
glab mr view <iid> --repo <remote-url> -F json
```

JSONの`title`、`description`、`state`、`draft`、`source_branch`、`target_branch`、`web_url`を見る。説明は`title`と`description`である。取得できなければ次へ進まない。

### Step 3: MRのdiffを取る

差分は、そのMRに入っているdiffだけにする。

```bash
glab mr diff <iid> --repo <remote-url> --color=never
```

diffを取得できなければ次へ進まない。現在のファイル内容や会話中の未push変更からdiffを補わない。

### Step 4: 変更目的を決める

変更目的は次の順で決める。

1. MRの`description`
2. 会話で示された変更目的
3. ユーザーに聞く

`description`が空なら、一度に一つ聞く。`title`だけで変更目的を補わない。diffから変更目的を推測しない。

説明とdiffが矛盾した場合は、自動解決せず確認する。

### Step 5: レビューする

`code-reviewing`を読む。評価、本文、返却はその手順に従う。

渡す情報は、Step 3のdiffとStep 4の変更目的である。`code-reviewing`にdiffの再取得と変更目的の聞き直しをさせない。

## 安全条件

- diffなしで`code-reviewing`に進まない
- `code-reviewing`を読まずにレビュー結果を組み立てない
- 変更目的をdiffから推測しない
- MRのタイトル、説明、レビューコメントを変更しない

## スキル連携

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| 指定したGitLab MRをレビューする | `glab-mr-review` → `code-reviewing` |
| 指定したGitHub PRをレビューする | `gh-pr-review` |
| ローカルブランチのdiffをgitで取る | `code-review` |
| Gitコマンドを実行せず、貼られたdiffをレビューする | `code-review-no-git` |
| レビュー | `code-reviewing` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `glab repo view -F json --jq '{path:.path_with_namespace,web_url:.web_url}'` | 対象プロジェクトを確認する |
| `glab mr view <iid> --repo <remote-url> -F json` | MRの説明とbase、headを確認する |
| `glab mr diff <iid> --repo <remote-url> --color=never` | MRのdiffを取得する |
