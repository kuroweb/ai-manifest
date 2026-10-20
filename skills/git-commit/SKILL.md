---
name: git-commit
description: >
  ワーキングディレクトリの変更をConventional Commitsに従ってコミットするスキル。
  意味のある変更単位ごとにステージングし、日本語でコミットメッセージを作成する。
  co-authorやエージェント名をコミットメッセージに含めない。
  ユーザーが「コミットして」「変更をコミット」「git commit」「commitして」
  「この変更をコミット」「コミットメッセージを書いて」「コミットお願い」
  などコミット関連のリクエストをした場合に必ず使用すること。
---

# git-commit

## できること

- ワーキングディレクトリの変更を、意味のある単位ごとにコミットする
- Conventional Commitsに従った日本語のコミットメッセージを書く
- 作成したコミットと、残っている未コミット変更を返す

## いつ使うか

- `コミットして`
- `変更をコミット`
- `コミットメッセージを書いて`
- AIによるGitコマンド実行が禁止されているときは使わない。`git-commit-no-git`を使う
- pushやPull Request作成には使わない

## 手順

### Step 1: 直近のコミット履歴を確認する

プロジェクトのコミットスタイルを把握するため、直近の履歴を確認する。

```bash
git log --oneline -10
```

### Step 2: 変更内容を確認する

ワーキングディレクトリの状態を確認する。`-uall`フラグは大規模リポジトリでメモリ問題を起こす可能性があるため使わないこと。

```bash
git status
git diff
git diff --staged
```

### Step 3: 意味のある単位でステージングする

変更を意味のある単位ごとにステージングする。`git add -A` や `git add .` で無条件に全ファイルを追加してはならない。対象ファイルを個別に指定すること。

```bash
git add <対象ファイルやディレクトリ>
```

以下のファイルはコミットに含めないこと：

- `.env` やクレデンシャル情報を含むファイル
- ユーザーが明示的に除外を指示したファイル

一つのコミットに含める変更が論理的に独立した複数の変更を含む場合は、複数のコミットに分割することを検討する。

### Step 4: コミットメッセージを作成してコミットする

Conventional Commitsの形式に従い、日本語でコミットメッセージを作成する。

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body（必要な場合）>
EOF
)"
```

**コミットメッセージのルール:**

- **Conventional Commits形式**: `type(scope): description`
  - type: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build` など
  - scope: 変更の影響範囲（省略可）
  - description: 変更内容の簡潔な説明
- **日本語で記述する**
- **co-authorやエージェント名（"Claude Code"など）をコミットメッセージに含めない**
- 変更の「何を」ではなく「なぜ」を重視する
- descriptionは命令形で書く（例：「追加した」ではなく「追加する」）

### Step 5: コミットを確認する

コミットが正しく行われたかを確認する。

```bash
git log --oneline -5
```

作成したコミットの短縮 SHA、メッセージ、残っている未コミット変更を返す。

## 禁止事項

- `--no-verify`でフックをスキップしないこと
- フックが失敗したときに`--amend`で直さないこと。原因を修正して新しいコミットを作成する
- ブランチの作成・切り替えをしないこと

## スキル連携

依頼に複数の操作が含まれる場合は、次の順で各スキルを使う。

| ユーザーの依頼 | ワークフロー |
| --- | --- |
| コミット | `git-commit` |
| Gitコマンド禁止環境でコミット案を作成 | `git-commit-no-git` |
| コミットして push | `git-commit` → `git-push` |
| コミットして PR 作成 | `git-commit` → `git-push` → `gh-pr-create` |
| コミットして MR 作成 | `git-commit` → `git-push` → `glab-mr-create` |
| PRを更新 | `gh-pr-update` |
| MRを更新 | `glab-mr-update` |

## コマンドリファレンス

| コマンド | 用途 |
| --- | --- |
| `git log --oneline -10` | 直近のコミットスタイルを確認する |
| `git status` | ワーキングディレクトリの状態を確認する |
| `git diff` / `git diff --staged` | 変更内容を確認する |
| `git add <対象ファイルやディレクトリ>` | 対象を個別に指定してステージングする |
| `git commit -m "<message>"` | コミットする |
| `git log --oneline -5` | 作成したコミットを確認する |
