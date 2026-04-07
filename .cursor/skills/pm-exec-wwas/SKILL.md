---
name: pm-exec-wwas
description: Why-What-Acceptance 形式で product backlog item を作る。独立性があり、価値があり、テスト可能で、戦略文脈を持つ item を作りたいときに使う。backlog item 作成、機能の work item 分解、WWA 形式の運用向け。
---
# Why-What-Acceptance (WWA)

Why-What-Acceptance 形式で product backlog item を作る。独立していて、価値があり、テスト可能で、戦略文脈が伝わる item にする。

**使いどころ:** backlog item 作成、product increment の定義、機能を work item に分解するとき、戦略意図をチームに伝えたいとき。

**引数:**

- `$PRODUCT`: プロダクト名またはシステム名
- `$FEATURE`: 新機能や新しい能力
- `$DESIGN`: デザインファイルへのリンク (Figma, Miro など)
- `$ASSUMPTIONS`: 前提や戦略文脈

## 進め方

1. **戦略的な Why を定義する** - 事業目標やチーム目標につなげる
2. **What を記述する** - 短く保ち、必要ならデザイン参照を入れる
3. **Acceptance Criteria を書く** - 詳細仕様ではなく、高レベルな完了条件にする
4. **独立性を確保する** - 任意順で開発できるようにする
5. **交渉可能に保つ** - 制約を固定しすぎず、会話の余地を残す
6. **価値を持たせる** - 各 item が顧客価値または事業価値を持つ
7. **テスト可能にする** - 結果が観測でき、確認できるようにする
8. **サイズを適切にする** - 1 sprint で見積もって終えられる大きさにする

## テンプレート

**Title:** [届けるもの]

**Why:** [戦略文脈やチーム目標につながる 1-2 文]

**What:** [短い説明とデザインリンク。最大 1-2 段落。詳細仕様ではなく、会話のための要約。]

**Acceptance Criteria:**

- [観測可能な結果 1]
- [観測可能な結果 2]
- [観測可能な結果 3]
- [観測可能な結果 4]

## 例

**Title:** リアルタイム支出トラッカーを実装する

**Why:** ユーザーは支出状況をすぐ把握できると、予算を意識した判断をしやすくなる。これは金融リテラシーを高め、使いすぎを減らす目標に直接つながる。

**What:** 支出を登録したら即時更新されるトラッカーを追加する。ユーザーの今週の支出と設定予算を比較して表示する。デザインは [Figma link] を参照。これは議論内容を思い出すための要約であり、詳細仕様は実装会話の中で詰める。

**Acceptance Criteria:**

- 支出登録後 2 秒以内に合計金額が更新される
- 予算進捗がプログレスバーで視覚的に示される
- 残予算がひと目で分かる
- 複数カテゴリの支出を正しく扱える

## 成果物

- 機能に対する backlog item 一式
- 各 item に Why、What、Acceptance Criteria の 3 セクションがあること
- 独立して任意順で開発できること
- 1 sprint で見積もりと完了ができるサイズであること
- チームが判断しやすい戦略文脈が明確であること
- 実装時の参考になるデザイン参照があること

---

### 参考

- [How to Write User Stories: The Ultimate Guide](https://www.productcompass.pm/p/how-to-write-user-stories)
