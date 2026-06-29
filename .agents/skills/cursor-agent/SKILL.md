---
name: cursor-agent
description: >
  Cursor CLI（`cursor-agent`）を使用してコードや文言について相談・レビューを行う。

  トリガー: "cursor-agent", "cursor agent", "cursor-agentと相談", "cursor-agentに聞いて",
  "コードレビュー", "レビューして"

  使用場面: (1) 文言・メッセージの検討、(2) コードレビュー、(3) 設計の相談、(4) バグ調査、(5) 解消困難な問題の調査
---
# Cursor CLI

Cursor CLI を使用してコードレビュー・分析を実行するスキル。方針は `codex` スキルと同じく、**編集せず読み取り・提案に寄せる**（`--plan`）。

## 実行コマンド

**モデル使い分け**: 調査は **`composer-2-fast`**、レビューは **`gpt-5.3-codex`**。

- 調査向け: `cursor-agent --workspace <project_directory> --print --plan --trust --model composer-2-fast "<request>"`
- レビュー向け: `cursor-agent --workspace <project_directory> --print --plan --trust --model gpt-5.3-codex "<request>"`

カレントディレクトリが既に対象プロジェクトのルートなら、`--workspace` は省略できる（`--model` は必ず付与）。

## プロンプトのルール

**重要**: cursor-agent に渡すリクエストには、以下の指示を必ず含めること：

> 「確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。」

## パラメータ

| パラメータ | 説明 |
| --- | --- |
| `--model composer-2-fast` | 調査・原因特定・分析・棚卸し |
| `--model gpt-5.3-codex` | コードレビュー・評価系 |
| `--workspace <dir>` | 対象プロジェクトのディレクトリ（`codex` の `--cd` に相当） |
| `--print` | 非対話（ヘッドレス）で標準出力へ結果を出す |
| `--plan` | プラン／分析モード（編集しない。レビュー・調査向け） |
| `--trust` | `--print` 時にワークスペースを信頼し、対話プロンプトを避ける |
| `"<request>"` | 依頼内容（日本語可） |

## 使用例

**注意**: 各例では末尾に「確認不要、具体的な提案まで出力」の指示を含めている。

### コードレビュー

cursor-agent --workspace /path/to/project --print --plan --trust --model gpt-5.3-codex "このプロジェクトのコードをレビューして、改善点を指摘してください。確認や質問は不要です。具体的な修正案とコード例まで自主的に出力してください。"

### バグ調査

cursor-agent --workspace /path/to/project --print --plan --trust --model composer-2-fast "認証処理でエラーが発生する原因を調査してください。確認や質問は不要です。原因の特定と具体的な修正案まで自主的に出力してください。"

### アーキテクチャ分析

cursor-agent --workspace /path/to/project --print --plan --trust --model composer-2-fast "このプロジェクトのアーキテクチャを分析して説明してください。確認や質問は不要です。改善提案まで自主的に出力してください。"

### リファクタリング提案

cursor-agent --workspace /path/to/project --print --plan --trust --model composer-2-fast "技術的負債を特定し、リファクタリング計画を提案してください。確認や質問は不要です。具体的なコード例まで自主的に出力してください。"

### デザイン相談（UI/UX）

cursor-agent --workspace /path/to/project --print --plan --trust --model gpt-5.3-codex "あなたは世界トップクラスのUIデザイナーです。以下の観点からこのプロジェクトのUIを評価してください: (1) 視覚的階層構造とタイポグラフィ、(2) 余白・スペーシングのリズム、(3) カラーパレットのコントラストとアクセシビリティ、(4) インタラクションパターンの一貫性、(5) ユーザーの認知負荷の軽減。確認や質問は不要です。具体的な改善案をコード例付きで提示してください。"

cursor-agent --workspace /path/to/project --print --plan --trust --model composer-2-fast "UXリサーチャー兼デザイナーとして、このフォームのユーザビリティを分析してください。Nielsen の10ヒューリスティクスに基づき、(1) エラー防止の仕組み、(2) ユーザーの制御と自由度、(3) 一貫性と標準、(4) 認識vs記憶の負荷、(5) 柔軟性と効率性を評価してください。確認や質問は不要です。改善したTailwind CSSコードまで自主的に提示してください。"

## 実行手順

1. ユーザーから依頼内容を受け取る
2. 対象プロジェクトのディレクトリを特定する（現在のワーキングディレクトリまたはユーザー指定）
3. **プロンプトを作成する際、末尾に「確認や質問は不要です。具体的な提案まで自主的に出力してください。」を必ず追加する**
4. 上記コマンド形式で cursor-agent を実行（要: Cursor CLI の認証）
5. 結果をユーザーに報告
