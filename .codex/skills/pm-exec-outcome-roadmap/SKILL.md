---
name: pm-exec-outcome-roadmap
description: >-
  機能中心のロードマップを、戦略意図が伝わる outcome 中心の形に変換する。施策を顧客・事業インパクトベースの文に書き換える。outcome
  roadmap へ移行したいとき、より戦略的なロードマップにしたいとき、機能一覧を outcome に置き換えたいときに使う。
---
# ロードマップを Outcome 中心に変換する

## 目的

$ARGUMENTS のロードマップを、output 中心 (機能ベース) から outcome 中心 (顧客価値・事業価値ベース) に切り替える支援をする、経験豊富なプロダクトマネージャーとして振る舞う。このスキルは、何を作るかではなく何を変えたいかが伝わるように施策を書き換える。

## 背景

機能中心のロードマップは、不要な精密さを生み、チームを成果ではなく機能に縛りやすい。outcome 中心のロードマップは、解く顧客課題と期待する事業価値を明確にし、実装の柔軟性と戦略思考を高める。

## 手順

1. **情報を集める**: 現在のロードマップがあれば丁寧に読む。戦略資料や会社目標に触れているなら、必要に応じて web search で全体方針との整合を補う。

2. **段階的に考える**:
   - 各施策で達成したい outcome は何か
   - どの顧客課題を解こうとしているか
   - どの事業指標が改善するのか
   - 顧客体験や事業にどんな影響があるか
   - 同じ outcome にもっと良い別手段はないか

3. **変換の進め方**: 各施策について:
   - **Output を特定する**: 計画中の機能やプロジェクトは何か
   - **Outcome を掘り出す**: なぜ作るのか。顧客や事業に何が起きるのか
   - **Outcome 文に書き換える**: 形式は次を使う

     ```
     Enable [customer segment] to [desired customer outcome] so that [business impact]
     ```

4. **変換例**:
   - **Output (Old)**: Q2: 高度な検索フィルタ、AI レコメンド、ダッシュボード再設計を実装
   - **Outcome (New)**:
     - Q2: 顧客が直感的な探索で商品を 50% 速く見つけられるようにする
     - Q2: パーソナライズされた AI 推薦により平均注文単価を 20% 上げる
     - Q2: オペレーターが全システムを監視しやすくなり、ダッシュボード表示時間を 80% 減らす

5. **出力を構造化する**: 変換後のロードマップには次を含める。
   - 四半期 / フェーズごとの元の施策
   - 各施策に対応する outcome 文
   - 成功を示す主要指標
   - 依存関係や順序メモ

6. **戦略文脈を添える**: 全体として次も加える。
   - company strategy とどう整合するか
   - 顧客ニーズに関する主要な前提
   - 具体日付ではなく四半期など柔軟なリリース枠

7. **成果物を保存する**: 分量が十分なら `~/.plans/pm-exec/Outcome-Roadmap-[year].md` という名前の Markdown に保存する。

## 注意

- outcome は検証できて測定できる形にする
- 1 つの outcome を複数の output で達成してもよい。機能一覧ではなく outcome に集中する
- outcome roadmap は変化に強い。柔軟性を前提にする
- どの outcome に結びつくか不明なら「それで何が変わるのか?」を顧客価値・事業価値まで掘る

---

### 参考

- [Product Vision vs Strategy vs Objectives vs Roadmap: The Advanced Edition](https://www.productcompass.pm/p/product-vision-strategy-goals-and)
- [Objectives and Key Results (OKRs) 101](https://www.productcompass.pm/p/okrs-101-advanced-techniques)
- [Business Outcomes vs Product Outcomes vs Customer Outcomes](https://www.productcompass.pm/p/business-outcomes-vs-product-outcomes)
