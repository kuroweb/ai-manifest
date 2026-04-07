---
name: pm-exec-brainstorm-okrs
description: >-
  会社目標に整合するチーム OKR を検討する。定性的な Objective と測定可能な Key Result を組み合わせた案を作る。四半期 OKR
  の策定、チーム目標と会社戦略の接続、Objective の草案作成、良い OKR の書き方整理に使う。
---
# チーム OKR のブレスト

## 目的

$ARGUMENTS に取り組むチームの Objectives and Key Results (OKRs) を定義する、経験豊富なプロダクトリーダーとして振る舞う。OKR は野心的で、測定可能で、全社戦略と明確につながっていなければならない。

## 背景

OKR は、心を動かす定性的な Objective と、測定可能な定量 Key Result を組み合わせることで、ビジョンと実行をつなぐ。このスキルは、戦略議論のたたき台として 3 つの異なる OKR 案を作る。

## ドメイン前提

**OKR** (Christina Wodtke, *Radical Focus*):

- **Objective** (Why, What, When): 定性的で、人を動かし、期限がある目標。通常は四半期単位。SMART であるべき。
- **Key Results** (How much): 定量指標とその目標値。通常は 3 つ。

**OKR、KPI、NSM は対立概念ではなく相互につながっている。** 関係を説明せずに比較表にしないこと。

- **Key Results** は常に定量指標を指し、その一部は KPI になりうる。
- **KPI** = 長期的に追う重要な定量指標。Key Result として使うことも、OKR の健全性を見るヘルスメトリクスとして使うことも、KPI の入力指標に対して Key Result を置くこともできる。
- **North Star Metric** = 顧客中心の単一 KPI。事業成功の先行指標。Key Result を使って NSM の期待変化を表現できる。

OKR の本質は次の 3 点にある。1) 1 つの明確で鼓舞する目標を置く。2) その達成方法はチームに委ねる。3) 進捗を継続的に見て、失敗から学び、改善する。

## 手順

1. **前提を集める**: ユーザーが会社目標、戦略資料、チーム状況をファイルで渡したら丁寧に読む。会社戦略に触れているなら、必要に応じて業界ベンチマークや近いプロダクトの事例を web search で補う。

2. **枠組みを理解する**: OKR は 2 つの要素でできている。
   - **Objective**: 進みたい方向を示す、定性的で鼓舞する目標
   - **Key Results**: Objective への進捗を測る、通常 3 つの定量指標

3. **段階的に考える**:
   - 会社戦略は何か
   - チームが最も大きく影響できる領域は何か
   - チームの取り組みはどう会社目標につながるか
   - 顧客と事業にとっての成功は何か

4. **3 つの OKR セットを作る**: $ARGUMENTS チーム向けに、性格の異なる 3 案を提示する。各セットでは:
   - 明確で鼓舞する Objective を 1 つ置く
   - ちょうど 3 つの Key Results を定義する
   - Key Results は次を満たす:
     - 数値で追える
     - 野心的だが現実的 (成功確率 60-70% 程度)
     - 会社戦略と整合する

5. **出力形式の例**:

   ```
   Objective: 新規ユーザーが迷わず価値に到達できるオンボーディング体験をつくる
   Key Results:
   - オンボーディング調査の CSAT を 75% 以上にする
   - 66% 以上のユーザーが 2 日以内に初期設定を完了する
   - 平均 time-to-value (TTV) を 20 分以下にする
   ```

6. **出力を構造化する**: 3 セットを同じ重みで提示する。各セットに含める:
   - Objective (1-2 文)
   - 3 つの Key Results (目標値つき)
   - 短い rationale (なぜ会社とチームに重要か)

7. **成果物を保存する**: 内容が十分大きければ `~/.plans/pm-exec/OKRs-[team-name]-[quarter].md` という名前の Markdown として保存する。

## 注意

- 各 Key Result は独立に測定できる形にする
- 「5 機能をリリースする」のような output 指標ではなく outcome に寄せる
- 3 案のうち 1 つだけが明らかに優れて見えないようにする
- データ取得前提が怪しい場合は仮定として明記する

---

### 参考

- [Objectives and Key Results (OKRs) 101](https://www.productcompass.pm/p/okrs-101-advanced-techniques)
- [OKR vs KPI: What's the Difference?](https://www.productcompass.pm/p/okr-vs-kpi-whats-the-difference)
- [Business Outcomes vs Product Outcomes vs Customer Outcomes](https://www.productcompass.pm/p/business-outcomes-vs-product-outcomes)
- [From Strategy to Objectives Masterclass](https://www.productcompass.pm/p/product-vision-strategy-objectives-course) (video course)
