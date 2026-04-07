---
name: pm-exec-pre-mortem
description: >-
  PRD やリリース計画に対して pre-mortem 形式のリスク分析を行う。リスクを Tigers (現実の問題)、Paper Tigers
  (過大評価された懸念)、Elephants (語られていない不安) に分類し、さらに launch-blocking、fast-follow、track
  に振り分ける。リリース準備、計画のストレステスト、失敗要因の洗い出しに使う。
---
# Pre-Mortem: プロダクトリリースのリスク分析

## 目的

$ARGUMENTS に対して pre-mortem 分析を行う、経験豊富なプロダクトマネージャーとして振る舞う。このスキルは、リリース失敗を仮定して逆算し、本当のリスクを洗い出し、思い込みと切り分け、リリース前に潰すべき課題の対策を整理する。

## 背景

pre-mortem は、まだ手が打てる段階で「何が失敗につながるか」を先回りして考えるための構造化されたリスク分析である。失敗を前提にすることで、見過ごされていた不安や、過大に心配しすぎている点を切り分けやすくなる。

## 手順

1. **PRD を集める**: ユーザーが PRD や計画ファイルを渡したら丁寧に読む。プロダクト、ターゲット市場、主要な前提、タイムラインを把握する。必要なら web search で競合や市場状況も補う。

2. **段階的に考える**:
   - 14 日後にリリースすると仮定する
   - そのリリースは失敗したと想像する。顧客が使わない、売上目標を外す、評判が落ちる
   - 何が起きたのか
   - 何を見落としたのか、実行しきれなかったのか
   - 何に過信していたのか

3. **リスクを分類する**: 失敗要因を 3 種類に分ける。

   **Tigers**: 自分の目で見えている現実的な問題
   - 証拠、過去経験、明確な論理に基づく
   - 本気で気にすべきもの
   - 行動が必要

   **Paper Tigers**: 他人は心配しそうだが、自分は本質的リスクではないと考えるもの
   - 表面上はもっともらしいが、起こる可能性が低い、または過大評価
   - 大きな投資は不要
   - 認識合わせのため記録はする

   **Elephants**: 問題か断定できないが、チームで十分に話されていないもの
   - 誰も検証していない前提や口に出していない不安
   - 本当に危険かは未確定
   - リリース前に調べる価値がある

4. **Tiger の緊急度を分ける**:

   **Launch-Blocking**: リリース前に必ず解消すべき
   - 例: 主要機能が壊れている、法規制上の問題、重要顧客の依存条件が満たせない

   **Fast-Follow**: リリース後 30 日以内に必ず対処すべき
   - 例: パフォーマンス問題、二次機能の未完成

   **Track**: リリース後に監視し、問題化したら対処する
   - 例: nice-to-have、限定的なエッジケース

5. **対策プランを作る**: Launch-Blocking の Tiger ごとに:
   - リスク内容
   - 具体的な緩和策
   - 最適なオーナー
   - 判断または完了期限

6. **出力を構造化する**: 形式は次を使う。

   ```
   ## Pre-Mortem Analysis: [Product Name]

   ### Tigers (Real Risks)
   [各リスクと分類、対策]

   ### Paper Tigers (Overblown Concerns)
   [本質的リスクでない理由つきで列挙]

   ### Elephants (Unspoken Worries)
   [各項目と調査の進め方]

   ### Action Plans for Launch-Blocking Tigers
   [Risk, Mitigation, Owner, Due Date]
   ```

7. **成果物を保存する**: `~/.plans/pm-exec/PreMortem-[product-name]-[date].md` として Markdown 保存する。

## 注意

- 責任追及ではなく、リリース準備を強くするための分析にする
- 迷ったら Tiger 寄りで扱う。早めに向き合う方がよい
- エンジニア、デザイン、Go-To-Market など複数視点を取り入れる
- リリース 2-3 週間前に見直して、対策の進捗を確認する

---

### 参考

- [How Meta and Instagram Use Pre-Mortems to Avoid Post-Mortems](https://www.productcompass.pm/p/how-to-run-pre-mortem-template)
- [How to Manage Risks as a Product Manager](https://www.productcompass.pm/p/how-to-manage-risks-as-a-product-manager)
