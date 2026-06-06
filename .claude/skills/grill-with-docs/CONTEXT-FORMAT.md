# CONTEXT.md フォーマット

## 構成

```md
# {コンテキスト名}

{このコンテキストが何で、なぜ存在するかを1〜2文で説明する。}

## Language

**Order**:
{用語の1〜2文の説明}
_Avoid_: Purchase, transaction

**Invoice**:
納品後に顧客へ送る支払い請求。
_Avoid_: Bill, payment request

**Customer**:
注文を行う個人または組織。
_Avoid_: Client, buyer, account
```

## ルール

- **意見を持つ。** 同じ概念に複数の語があるときは、最適な一つを選び、他は `_Avoid_` に列挙する。
- **定義は簡潔に。** 最大1〜2文。何をするかではなく、何であるかを定義する。
- **このプロジェクトのコンテキストに固有の用語だけを含める。** 一般的なプログラミング概念（タイムアウト、エラー型、ユーティリティパターンなど）は、たとえプロジェクトで広く使っていても含めない。用語を追加する前に問う：これはこのコンテキスト固有の概念か、一般的なプログラミング概念か？ 前者だけが該当する。
- **自然なクラスタが現れたら小見出しでグループ化する。** すべての用語が単一の領域に属するなら、フラットなリストでよい。

## 単一コンテキスト vs 複数コンテキストのリポジトリ

**単一コンテキスト（ほとんどのリポジトリ）：** リポジトリルートに `CONTEXT.md` を1つ置く。

**複数コンテキスト：** リポジトリルートに `CONTEXT-MAP.md` を置き、コンテキスト一覧、各コンテキストの場所、相互関係を記載する：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — 顧客注文の受付と追跡
- [Billing](./src/billing/CONTEXT.md) — 請求書の発行と支払い処理
- [Fulfillment](./src/fulfillment/CONTEXT.md) — 倉庫のピッキングと出荷管理

## Relationships

- **Ordering → Fulfillment**: Ordering が `OrderPlaced` イベントを発行し、Fulfillment がそれを消費してピッキングを開始する
- **Fulfillment → Billing**: Fulfillment が `ShipmentDispatched` イベントを発行し、Billing がそれを消費して請求書を生成する
- **Ordering ↔ Billing**: `CustomerId` と `Money` の共有型
```

スキルはどちらの構成かを推論する：

- `CONTEXT-MAP.md` があれば、それを読んでコンテキストを特定する
- ルートの `CONTEXT.md` だけなら、単一コンテキスト
- どちらもなければ、最初の用語が解決されたときにルートの `CONTEXT.md` を遅延作成する

複数コンテキストがある場合、現在のトピックがどれに関係するか推論する。不明なら質問する。
