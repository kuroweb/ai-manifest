# スキル

正本はこのディレクトリ。手順の詳細は各 `SKILL.md`。運用は [docs/skills-guideline.md](../docs/skills-guideline.md)。

## Git

| スキル | すること |
|---|---|
| [git-commit](git-commit/SKILL.md) | 変更を意味のある単位でコミットする |
| [git-commit-no-git](git-commit-no-git/SKILL.md) | Gitコマンドを実行せず、コミット手順を作る |
| [git-push](git-push/SKILL.md) | 既存コミットをリモートへ push する |

## GitHub Issue

| スキル | すること |
|---|---|
| [gh-issue-create](gh-issue-create/SKILL.md) | Issueを確認後に起票する |
| [gh-issue-update](gh-issue-update/SKILL.md) | 既存Issueのタイトルと本文を確認後に更新する |
| [gh-issue-load](gh-issue-load/SKILL.md) | 指定したIssueを読み込む |
| [gh-issue-schema](gh-issue-schema/SKILL.md) | Issueのタイトルと本文の型。起票と更新が読む |

## GitHub Pull Request

| スキル | すること |
|---|---|
| [gh-pr-create](gh-pr-create/SKILL.md) | push済みブランチからPRを確認後に作成する |
| [gh-pr-update](gh-pr-update/SKILL.md) | 既存PRのタイトルと本文を確認後に更新する |
| [gh-pr-create-no-git](gh-pr-create-no-git/SKILL.md) | Gitコマンドを実行せず、PRを作成する |
| [gh-pr-update-no-git](gh-pr-update-no-git/SKILL.md) | Gitコマンドを実行せず、既存PRのタイトルと本文を更新する |
| [gh-pr-schema](gh-pr-schema/SKILL.md) | PRのタイトルと本文の型。作成と更新が読む |

## GitLab Merge Request

| スキル | すること |
|---|---|
| [glab-mr-create](glab-mr-create/SKILL.md) | push済みブランチからMRを確認後に作成する |
| [glab-mr-update](glab-mr-update/SKILL.md) | 既存MRのタイトルと本文を確認後に更新する |
| [glab-mr-create-no-git](glab-mr-create-no-git/SKILL.md) | Gitコマンドを実行せず、MRを作成する |
| [glab-mr-update-no-git](glab-mr-update-no-git/SKILL.md) | Gitコマンドを実行せず、既存MRのタイトルと本文を更新する |
| [glab-mr-schema](glab-mr-schema/SKILL.md) | MRのタイトルと本文の型。作成と更新が読む |

## 調査

| スキル | すること |
|---|---|
| [bug-cause-report](bug-cause-report/SKILL.md) | 不具合が今のコードのどこで、なぜ起きるかを調べてレポートにする |
| [can-implement-report](can-implement-report/SKILL.md) | やりたいことが今のコードで実装できるかを調べてレポートにする |
| [report-patterns](report-patterns/SKILL.md) | レポートの記述パターン。他のスキルが読む |

## 設計と文章

| スキル | すること |
|---|---|
| [grill-me](grill-me/SKILL.md) | プランが固まるまで質問する |
| [grill-with-docs](grill-with-docs/SKILL.md) | プランを既存の用語と文書に突き合わせ、決まったら CONTEXT.md と ADR を更新する |
| [intent-based-dedup](intent-based-dedup/SKILL.md) | 字面ではなく意図で、コードを共通化するか判断する |
| [law-of-demeter](law-of-demeter/SKILL.md) | 連鎖呼び出しを減らし、直接の相手とだけ話す設計にする |
| [stop-ai-slop-jp](stop-ai-slop-jp/SKILL.md) | AIで書いた日本語を、人が書いた文章に戻す |

## セッション

| スキル | すること |
|---|---|
| [handover](handover/SKILL.md) | 次のセッション用の引き継ぎノートを書く |
| [handover-resume](handover-resume/SKILL.md) | 引き継ぎノートを読み込んで再開する |
| [plan-export](plan-export/SKILL.md) | 固めたプランを `~/.docs/plans` に保存する |

## スキル自体

| スキル | すること |
|---|---|
| [skill-creator](skill-creator/SKILL.md) | スキルを作り、直し、説明文のトリガー精度を測る |
