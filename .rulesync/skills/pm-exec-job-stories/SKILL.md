---
name: pm-exec-job-stories
description: "'When [situation], I want to [motivation], so I can [outcome]' 形式で、受け入れ条件つきの job story を作る。job story 作成、JTBD 形式の backlog item 整理、ユーザー状況と動機の表現に使う。"
---
# Job Stories

`When [situation], I want to [motivation], so I can [outcome]` 形式で job story を作る。ユーザーの状況と望む結果に焦点を当てた受け入れ条件つきの story を出力する。

**使いどころ:** job story 作成、ユーザーの状況や動機の整理、JTBD 形式の backlog item 作成、役割より文脈を重視したいとき。

**引数:**

- `$PRODUCT`: プロダクト名またはシステム名
- `$FEATURE`: job story に分解したい新機能
- `$DESIGN`: デザインファイルへのリンク (Figma, Miro など)
- `$CONTEXT`: ユーザー状況や job のシナリオ

## 進め方

1. **トリガーになる状況を特定する**
2. **その行動の裏にある動機を定義する**
3. **ユーザーが達成したい結果を明確にする**
4. **JTBD で考える**: 役割ではなく、片づけたい job に注目する
5. **結果が達成できたと判断できる受け入れ条件を書く**
6. **観測できて測定できる言葉を使う**
7. **必要ならデザインやプロトタイプにリンクする**
8. **詳細な受け入れ条件つきで job story を出す**

## テンプレート

**Title:** [達成したい結果]

**Description:** When [situation], I want to [motivation], so I can [outcome].

**Design:** [デザインファイルへのリンク]

**Acceptance Criteria:**

1. [状況が正しく認識される]
2. [システムが望む動機を支援する]
3. [進捗やフィードバックが見える]
4. [結果に効率よく到達できる]
5. [エッジケースが自然に扱われる]
6. [連携や通知が正しく動く]

## 例

**Title:** 週ごとのおやつ代を把握する

**Description:** When おやつ用の週予算を考えるとき, I want to これまでにいくら使ったかをすぐ確認したい, so I can 週末前にお金が足りなくならないようにしたい.

**Design:** [Figma link]

**Acceptance Criteria:**

1. `Weekly Spending Overview` セクションで支出サマリーを表示する
2. 支出登録後にリアルタイムで更新される
3. 週予算に対する 0-100% の進捗バーが表示される
4. 残予算が目立つ色で示される
5. カテゴリ別の詳細な支出内訳が見られる
6. 予算の 80% 到達時に通知する
7. 木曜夕方時点で 90% に達していたら週末向けリマインドを出す
8. 詳細内訳に簡単に移動できる

## 成果物

- 機能に対する job story 一式
- 各 story が `When... I want... so I can...` 形式で書かれていること
- outcome に焦点を当てた 6-8 個の受け入れ条件
- ユーザーの状況と動機を中心にした story
- デザインやプロトタイプへの明確なリンク

---

### 参考

- [Jobs-to-be-Done Masterclass with Tony Ulwick and Sabeen Sattar](https://www.productcompass.pm/p/jobs-to-be-done-masterclass-with) (video course)
