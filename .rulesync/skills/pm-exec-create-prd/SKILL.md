---
name: pm-exec-create-prd
description: "課題、目的、セグメント、価値提案、解決策、リリース計画を含む 8 セクションのテンプレートで PRD を作る。PRD 執筆、要件整理、機能仕様の作成、既存 PRD のレビューに使う。"
---

# PRD を作成する

## 目的

$ARGUMENTS のために包括的な Product Requirements Document (PRD) を作る、経験豊富なプロダクトマネージャーとして振る舞う。この文書は、プロダクトや機能の正式な仕様として、関係者の認識をそろえ、開発を導く役割を持つ。

## 背景

整理された PRD は、その施策で何を、なぜ、どうやるのかを明確に伝える。このスキルでは、エンジニア、デザイナー、リーダー、ステークホルダーにビジョンを伝えやすい 8 セクションのテンプレートを使う。

## 手順

1. **情報を集める**: ユーザーがファイルを渡したら丁寧に読む。調査資料、URL、顧客データに触れているなら、必要に応じて web search で文脈や市場理解を補う。

2. **段階的に考える**: 書き始める前に次を整理する。
   - どの課題を解くのか
   - 誰のために解くのか
   - 成功をどう測るのか
   - 制約と前提は何か

3. **PRD テンプレートを適用する**: 以下の 8 セクションで文書を作る。

   **1. Summary** (2-3 文)
   - この文書は何について書かれているか

   **2. Contacts**
   - 主要ステークホルダーの名前、役割、コメント

   **3. Background**
   - 背景: この取り組みは何か
   - なぜ今やるのか。何かが変わったのか
   - 最近になって実現可能になったことはあるか

   **4. Objective**
   - 目的は何か。なぜ重要か
   - 会社と顧客にどんな価値があるか
   - ビジョンや戦略とどう整合するか
   - Key Results: 成功をどう測るか (SMART な OKR 形式)

   **5. Market Segment(s)**
   - 誰のために作るのか
   - どんな制約があるか
   - 市場は属性ではなく、人の課題や job で定義する

   **6. Value Proposition(s)**
   - 顧客のどんな job / need を扱うか
   - 顧客は何を得るか
   - どんな pain を避けられるか
   - 競合よりどこを上手く解けるか
   - 必要に応じて Value Curve を使う

   **7. Solution**
   - 7.1 UX / Prototypes (ワイヤー、ユーザーフロー)
   - 7.2 Key Features (詳細な機能説明)
   - 7.3 Technology (必要な場合のみ)
   - 7.4 Assumptions (まだ未検証だが信じていること)

   **8. Release**
   - どれくらい時間がかかりそうか
   - 初回版と後続版の切り分けはどうするか
   - 正確な日付ではなく相対的な期間で書く

4. **やさしい言葉で書く**: 小学校卒業レベルで読める言葉を使う。専門用語は避け、短く明確な文で書く。

5. **出力を整える**: 見出しが明確な Markdown で、読みやすく整形された PRD として出す。

6. **成果物を保存する**: 十分な分量になったら `~/.plans/pm-exec/PRD-[product-name].md` という名前の Markdown に保存する。

## 注意

- できる限り具体的かつデータに基づいて書く
- 各セクションを全体戦略に結びつける
- 前提はチームが検証できるよう明確に示す
- 短くても必要十分な内容にする

---

### 参考

- [How to Write a Product Requirements Document? The Best PRD Template.](https://www.productcompass.pm/p/prd-template)
- [A Proven AI PRD Template by Miqdad Jaffer (Product Lead @ OpenAI)](https://www.productcompass.pm/p/ai-prd-template)
