---
name: git-branch-naming
description: >
  Gitブランチ名を、種類のプレフィックス（feat/fix/chore）、Issue・開発チケットとの関連付け、
  kebab-caseに基づいて提案・検証するときに使用する。
---

# Gitブランチ命名規則

一貫したブランチ命名により、変更の追跡とリポジトリの履歴の把握が容易になる。

リポジトリに既存の命名規則がある場合は、その規則を優先する。

## ブランチ名の形式

```text
{type}/{issue-or-ticket}-{short-description}
{type}/{short-description}
```

| 要素 | 形式 | 必須 | 例 |
|---|---|---|---|
| `type` | 小文字のプレフィックス | 必須 | `feat`、`fix` |
| `issue-or-ticket` | `#`を付けないIssue番号または開発チケットID | 管理対象がある場合 | `123`、`DEV-123` |
| `description` | 2〜5語のkebab-case | 必須 | `user-authentication` |

### 例

```text
# Issue番号あり（Issue・開発チケットが存在する場合はこちらを優先）
feat/123-oauth-login
fix/456-null-pointer-crash
chore/789-update-dependencies
docs/101-api-reference

# Issue番号なし（Issue・開発チケットが存在しない場合）
feat/oauth-integration
fix/memory-leak-cleanup
chore/update-eslint-config
refactor/auth-service-split
```

## ブランチの種類

| 種類 | 用途 | Conventional Commits |
|---|---|---|
| `feat/` | 新機能や新しい能力 | `feat:` |
| `fix/` | バグ修正 | `fix:` |
| `chore/` | 保守、依存関係、設定 | `chore:` |
| `docs/` | ドキュメントのみの変更 | `docs:` |
| `refactor/` | 振る舞いを変えないコード構造の変更 | `refactor:` |
| `test/` | テストの追加や更新 | `test:` |
| `ci/` | CI/CDパイプラインの変更 | `ci:` |
| `hotfix/` | 本番環境の緊急修正 | `fix:`（緊急性を伴う） |
| `release/` | リリース準備 | `chore:`または`release:` |

## ブランチ名を検証する

標準形式（数値のIssue番号、またはIssue番号なし）では、候補を確定する前に次のパターンで検証する。

```regex
^(feat|fix|chore|docs|refactor|test|ci|hotfix|release)/([0-9]+-)?[a-z0-9]+(-[a-z0-9]+)*$
```

外部チケットIDなど、標準形式に含まれない識別子にはこのパターンを適用しない。

有効:

- `feat/123-user-auth` ✓
- `fix/memory-leak` ✓
- `chore/update-deps` ✓

無効:

- `feature/user-auth` ✗（`feature`ではなく`feat`を使う）
- `fix/UserAuth` ✗（PascalCaseではなくkebab-caseを使う）
- `my-branch` ✗（種類のプレフィックスがない）
- `feat/fix_bug` ✗（アンダースコアではなくハイフンを使う）

## Issue・開発チケットとの関連付け

### Issue番号・開発チケットIDの扱い

| 状況 | 識別子を含めるか | 例 |
|---|---|---|
| GitHub Issuesで管理している作業 | 含める | `feat/123-add-oauth` |
| 外部システム（Jira、Notion）で管理している作業 | 含める | `feat/TASK-123-user-dashboard` |
| 調査やスパイク | 含めない | `chore/auth-approaches` |
| Issueがない軽微な修正 | 含めない | `fix/typo-readme` |
| Dependabotや自動生成されたPull Request | 含めない | `chore/bump-lodash` |

### 外部チケット管理システム

Jira、Notionなどを使う場合はチケットIDを含める。チケットIDの形式はこのスキルで定めず、利用するシステムに従う。

```text
feat/TASK-123-user-dashboard
fix/DEV-123-api-timeout
chore/PJ-789-update-sdk
```

## 説明部分の指針

### 良い説明

| パターン | 例 | 良い理由 |
|---|---|---|
| 操作 + 対象 | `add-oauth-login` | 何をするかが明確 |
| コンポーネント + 変更 | `auth-service-refactor` | 影響範囲を特定できる |
| バグ + コンテキスト | `null-pointer-user-save` | 問題の内容が分かる |

### 避けるもの

| アンチパターン | 問題 | 改善例 |
|---|---|---|
| `fix/bug` | 曖昧すぎる | `fix/123-login-validation` |
| `feat/new-feature` | 意味のある情報がない | `feat/user-dashboard` |
| `feat/john-working-on-stuff` | 変更内容を表していない | `feat/456-payment-flow` |
| `fix/issue-123` | 冗長で説明がない | `fix/123-timeout-error` |
| `feat/add-new-user-authentication-system-with-oauth` | 長すぎる | `feat/oauth-authentication` |

### 長さの指針

- 最小: typeやIssue番号の後に2語（`feat/123-user-auth`）
- 最大: 5語、全体で50文字未満
- 目安: 3〜4語（`feat/123-oauth-token-refresh`）

## ブランチ名チェックリスト

- [ ] 有効な種類のプレフィックス（`feat/`、`fix/`など）で始まっている
- [ ] 管理対象の作業にはIssue番号または開発チケットIDが含まれている
- [ ] 説明がkebab-caseになっている
- [ ] 説明が2〜5語になっている
- [ ] 全体が50文字未満になっている
- [ ] アンダースコア、空白、大文字が含まれていない

## スキル連携

| ユーザーの依頼 | ワークフロー |
|---|---|
| ブランチ名を決める | `git-branch-naming` |
| ブランチを作成 | `git-branch-naming` → `git-branch-create` |
| 指定された名前でブランチを作成 | `git-branch-create` |
