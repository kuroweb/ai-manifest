---
name: pm-exec-user-stories
description: 3 C's (Card, Conversation, Confirmation) と INVEST を使って、説明、デザインリンク、受け入れ条件つきの user story を作る。user story 作成、機能の分解、backlog item 化、受け入れ条件定義に使う。
---
# User Stories

3 C's (Card, Conversation, Confirmation) と INVEST に沿って user story を作る。説明、デザインリンク、受け入れ条件つきで構造化して出力する。

**使いどころ:** user story 作成、機能を story に分解したいとき、backlog item を作るとき、受け入れ条件を定義したいとき。

**引数:**

- `$PRODUCT`: プロダクト名またはシステム名
- `$FEATURE`: story に分解したい新機能
- `$DESIGN`: デザインファイルへのリンク (Figma, Miro など)
- `$ASSUMPTIONS`: 主要な前提や補足文脈

## 進め方

1. **機能を分析する** - 渡されたデザインや文脈を読む
2. **ユーザーロールと journey を特定する**
3. **3 C's を適用する**:
   - Card: 短いタイトルと 1 行説明
   - Conversation: 意図の説明
   - Confirmation: 明確な受け入れ条件
4. **INVEST を守る**: Independent, Negotiable, Valuable, Estimable, Small, Testable
5. **やさしい言葉を使う** - 小学校卒業レベルで読める表現にする
6. **デザインリンクを入れる** - 実装やレビュー時の参照にする
7. **構造化された user story として出す**

## テンプレート

**Title:** [機能名]

**Description:** As a [user role], I want to [action], so that [benefit].

**Design:** [デザインファイルへのリンク]

**Acceptance Criteria:**

1. [明確で検証可能な条件]
2. [観測できる挙動]
3. [システムが正しく検証すること]
4. [エッジケースの扱い]
5. [性能やアクセシビリティの観点]
6. [連携ポイント]

## 例

**Title:** Recently Viewed Section

**Description:** As an Online Shopper, I want to 商品ページで `Recently viewed` セクションを見たい, so that 気になった商品を見返しやすくしたい.

**Design:** [Figma link]

**Acceptance Criteria:**

1. 過去に少なくとも 1 商品を見たユーザーには、商品ページ下部に `Recently viewed` セクションを表示する
2. session 内で初めて見た商品ページでは表示しない
3. 現在見ている商品は一覧に含めない
4. 商品カードまたはサムネイルには画像、タイトル、価格を表示する
5. 各カードに閲覧時刻を示す情報を表示する (例: `Viewed 5 minutes ago`)
6. 商品カードを押すと対応する商品ページへ遷移する

## 成果物

- その機能に必要な user story 一式
- 各 story に title、description、design link、4-6 個の受け入れ条件を含むこと
- 独立して任意順で開発できること
- 1 sprint で扱えるサイズであること
- 関連するデザイン資料への参照があること

---

### 参考

- [How to Write User Stories: The Ultimate Guide](https://www.productcompass.pm/p/how-to-write-user-stories)
