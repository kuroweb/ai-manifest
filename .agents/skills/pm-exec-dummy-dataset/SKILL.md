---
name: pm-exec-dummy-dataset
description: >-
  列、制約、出力形式 (CSV、JSON、SQL、Python script)
  を指定して、現実味のあるダミーデータを作る。テストデータ作成、モックデータ構築、開発やデモ用サンプル生成に使う。
---
# ダミーデータセット生成

列、制約、出力形式を指定して、現実味のあるダミーデータセットを生成する。すぐ使えるデータファイル、または実行可能な生成スクリプトを作る。

**使いどころ:** テストデータ作成、サンプルデータ生成、開発用のリアルなモックデータ構築、検証環境への投入。

**引数:**

- `$PRODUCT`: プロダクト名またはシステム名
- `$DATASET_TYPE`: データ種別 (例: customer feedback, transactions, user profiles)
- `$ROWS`: 生成する行数 (既定: 100)
- `$COLUMNS`: 含めたい列やフィールド
- `$FORMAT`: 出力形式 (CSV, JSON, SQL, Python script)
- `$CONSTRAINTS`: 追加の制約や業務ルール

## 進め方

1. **データセット種別を特定する** - 対象ドメインを理解する
2. **列仕様を定義する** - 名前、型、値の範囲を決める
3. **件数を決める** - 必要なサンプル件数を確認する
4. **出力形式を選ぶ** - CSV、JSON、SQL INSERT、または Python script を選択する
5. **現実的なパターンを入れる** - データがもっともらしく見えるようにする
6. **業務制約を反映する** - ビジネスロジックや関係性を守る
7. **データまたはスクリプトを生成する** - すぐ使える出力を作る
8. **出力を検証する** - 品質と網羅性を確認する

## テンプレート: Python Script 出力

```python
import csv
import json
from datetime import datetime, timedelta
import random

# Configuration
ROWS = $ROWS
FILENAME = "$DATASET_TYPE.csv"

# Column definitions with realistic value generators
columns = {
    "id": "auto-increment",
    "name": "first_last_name",
    "email": "email",
    "created_at": "timestamp",
    # Add more columns...
}

def generate_dataset():
    """Generate realistic dummy dataset"""
    data = []
    for i in range(1, ROWS + 1):
        record = {
            "id": f"U{i:06d}",
            # Generate values based on column definitions
        }
        data.append(record)
    return data

def save_as_csv(data, filename):
    """Save dataset as CSV"""
    with open(filename, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)

if __name__ == "__main__":
    dataset = generate_dataset()
    save_as_csv(dataset, FILENAME)
    print(f"Generated {len(dataset)} records in {FILENAME}")
```

## データセット仕様の例

**Dataset Type:** Customer Feedback

**Columns:**

- feedback_id (auto-increment, U001, U002...)
- customer_name (realistic names)
- email (valid email format)
- feedback_date (dates last 90 days)
- rating (1-5 stars)
- category (Bug, Feature Request, Complaint, Praise)
- text (realistic feedback)
- product (electronics, clothing, home)

**Constraints:**

- Ratings skewed: 40% 5-star, 30% 4-star, 20% 3-star, 10% 1-2 star
- Bug category only with ratings 1-3
- Feature requests only with ratings 3-5
- Email domains realistic (gmail, yahoo, company.com)

## 成果物

- すぐ実行できる Python script または直接使えるデータファイル
- ヘッダーと整形が整った CSV
- 構造と型が正しい JSON
- DB に流し込める SQL INSERT 文
- 制約を満たしていることの確認
- 業務文脈に合った現実的な値
- データ生成ロジックの説明
- 利用開始のための簡単な手順

## 出力形式

**CSV:** 表形式で扱いやすく、スプレッドシートや DB への取り込みが容易

**JSON:** ネスト構造を持てるため、API や NoSQL 向け

**SQL:** 関係 DB にそのまま流し込める INSERT 文

**Python Script:** 大量データやカスタムロジックに対応しやすい生成スクリプト
