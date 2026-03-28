---
name: claude
description: |
  Claude Code CLI（Anthropic）を使用してコードや文言について相談・レビューを行う。
  トリガー: "claude", "claudeと相談", "claudeに聞いて", "コードレビュー", "レビューして"
  使用場面: (1) 文言・メッセージの検討、(2) コードレビュー、(3) 設計の相談、(4) バグ調査、(5) 解消困難な問題の調査
---
# Claude

Claude Code CLIを使用してコードレビュー・分析を実行するスキル。

## 実行コマンド

**モデル使い分け**: 調査は **`sonnet`**、レビューは **`opus`**（Claude Code CLI の `--model` エイリアス）。

- 調査向け: `cd <project_directory> && claude -p --model sonnet --permission-mode dontAsk --tools Read,Grep,Glob "<request>"`
- レビュー向け: `cd <project_directory> && claude -p --model opus --permission-mode dontAsk --tools Read,Grep,Glob "<request>"`

## プロンプトのルール

**重要**: claudeに渡すリクエストには、以下の指示を必ず含めること：

> 「確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。」

## パラメータ

| パラメータ | 説明 |
| --- | --- |
| `--model sonnet` | 調査・原因特定・分析・棚卸し |
| `--model opus` | コードレビュー・評価系 |
| `-p` | 非対話モードで実行（print） |
| `--permission-mode dontAsk` | 確認を抑えた自動実行向け |
| `--tools Read,Grep,Glob` | 読み取り中心（分析・レビュー向け） |
| `"<request>"` | 依頼内容（日本語可） |

## 使用例

**注意**: 各例では末尾に「確認不要、具体的な提案まで出力」の指示を含めている。

### コードレビュー

cd /path/to/project && claude -p --model opus --permission-mode dontAsk --tools Read,Grep,Glob "このプロジェクトのコードをレビューして、改善点を指摘してください。確認や質問は不要です。具体的な修正案とコード例まで自主的に出力してください。"

### バグ調査

cd /path/to/project && claude -p --model sonnet --permission-mode dontAsk --tools Read,Grep,Glob "認証処理でエラーが発生する原因を調査してください。確認や質問は不要です。原因の特定と具体的な修正案まで自主的に出力してください。"

### アーキテクチャ分析

cd /path/to/project && claude -p --model sonnet --permission-mode dontAsk --tools Read,Grep,Glob "このプロジェクトのアーキテクチャを分析して説明してください。確認や質問は不要です。改善提案まで自主的に出力してください。"

### リファクタリング提案

cd /path/to/project && claude -p --model sonnet --permission-mode dontAsk --tools Read,Grep,Glob "技術的負債を特定し、リファクタリング計画を提案してください。確認や質問は不要です。具体的なコード例まで自主的に出力してください。"

### デザイン相談（UI/UX）

cd /path/to/project && claude -p --model opus --permission-mode dontAsk --tools Read,Grep,Glob "あなたは世界トップクラスのUIデザイナーです。以下の観点からこのプロジェクトのUIを評価してください: (1) 視覚的階層構造とタイポグラフィ、(2) 余白・スペーシングのリズム、(3) カラーパレットのコントラストとアクセシビリティ、(4) インタラクションパターンの一貫性、(5) ユーザーの認知負荷の軽減。確認や質問は不要です。具体的な改善案をコード例付きで提示してください。"

cd /path/to/project && claude -p --model sonnet --permission-mode dontAsk --tools Read,Grep,Glob "UXリサーチャー兼デザイナーとして、このフォームのユーザビリティを分析してください。Nielsen の10ヒューリスティクスに基づき、(1) エラー防止の仕組み、(2) ユーザーの制御と自由度、(3) 一貫性と標準、(4) 認識vs記憶の負荷、(5) 柔軟性と効率性を評価してください。確認や質問は不要です。改善したTailwind CSSコードまで自主的に提示してください。"

## 実行手順

1. ユーザーから依頼内容を受け取る
2. 対象プロジェクトのディレクトリを特定する（現在のワーキングディレクトリまたはユーザー指定）
3. **プロンプトを作成する際、末尾に「確認や質問は不要です。具体的な提案まで自主的に出力してください。」を必ず追加する**
4. 上記コマンド形式でClaudeを実行
5. 結果をユーザーに報告
