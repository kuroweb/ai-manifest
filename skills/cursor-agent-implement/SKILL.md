---
name: cursor-agent-implement
description: |
  Cursor CLI（`cursor-agent`）を使用してコードの実装・修正・リファクタリングを実行させる。読み取り専用の相談・レビューは cursor-agent スキルを使い、ファイル変更を伴う作業はこのスキルを使う。
  トリガー: "cursor-agent-implement", "cursor-agentに実装させて", "cursor-agentに修正させて", "cursor-agentで直して", "cursor-agentにやらせて"
  使用場面: (1) 機能実装、(2) バグ修正、(3) リファクタリング、(4) テスト追加、(5) レビュー指摘の反映
---

# Cursor CLI Implement

Cursor CLI をサブエージェントとして実行し、コード変更を完了させるスキル。相談・レビューのみの場合は `cursor-agent` スキルを使う。

## 実行コマンド

```bash
cursor-agent --workspace <project_directory> --print --force --trust --model composer-2.5-fast "<request>"
```

- `--plan` を付けないことで編集・コマンド実行が可能になる（read-only の `cursor-agent` スキルとの差分）
- `--force` で承認プロンプトによる停止を回避する（ヘッドレス実行のため）
- カレントディレクトリが対象プロジェクトのルートなら `--workspace` は省略可
- 実装タスクは長時間かかるため、実行時のタイムアウトは10分程度に設定する

## プロンプトの組み立て

cursor-agent はこちらの会話コンテキストを一切持たない。`<request>` に以下を含める：

1. **依頼内容と背景**: 対象ファイルパス・関数名・再現手順など、こちらで判明している情報はすべて渡す（再調査させない）
2. **制約**: 既存の振る舞いを変えない、対象外のファイルに触れない、など
3. **固定指示（末尾に必ず追加）**:

   > 確認や質問は不要です。提案に留めず、対象ファイルを実際に編集して変更を完了させてください。最後に変更したファイルと変更内容の要約を出力してください。

## 実行手順

1. 実行前に `git status` で作業ツリーの状態を記録する（cursor-agent の変更と既存の変更を区別するため）
2. 上記コマンドで cursor-agent を実行する（要: Cursor CLI の認証）
3. 実行後に `git diff` で変更内容を検証し、依頼と一致しているか確認する。依頼外の変更が混ざっていれば指摘する
4. cursor-agent の要約と `git diff` の確認結果をユーザーに報告する
