---
name: pm-exec-prioritization-frameworks
description: 9 個の優先順位付けフレームワークを、式、使いどころ、テンプレートつきで参照できるガイド。RICE、ICE、Kano、MoSCoW、Opportunity Score などを比較しながら、どの手法を使うか決めたいときに使う。
---
## 優先順位付けフレームワーク集

状況に合った優先順位付けフレームワークを選び、適用するための参照ガイド。

### 基本原則

顧客に解決策を設計させないこと。優先順位をつける対象は **機能ではなく問題 (opportunity)** である。

### Opportunity Score (Dan Olsen, *The Lean Product Playbook*)

顧客課題の優先順位付けに最も推奨されるフレームワーク。

各ニーズについて、顧客に **Importance** と **Satisfaction** を聞き、0-1 に正規化する。

関連する 3 つの式:

- **Current value** = Importance × Satisfaction
- **Opportunity Score** = Importance × (1 − Satisfaction)
- **Customer value created** = Importance × (S2 − S1), where S1 = satisfaction before, S2 = satisfaction after

Importance が高く、Satisfaction が低いほど Opportunity Score は高い。Importance と Satisfaction の散布図では左上が狙い目。機能ではなく顧客課題を優先できる。

### ICE Framework

施策やアイデアの優先順位付けに有効。価値だけでなく、リスクや経済性も考慮する。

- **I** (Impact) = Opportunity Score × 影響を受ける顧客数
- **C** (Confidence) = どれだけ自信があるか (1-10)。リスクを見る
- **E** (Ease) = 実装しやすさ (1-10)。経済性を見る

**Score** = I × C × E。高いほど優先。

### RICE Framework

ICE の Impact を 2 要素に分けたもの。大きい組織や、より細かい比較が必要なときに向く。

- **R** (Reach) = 影響を受ける顧客数
- **I** (Impact) = Opportunity Score (顧客 1 人あたり価値)
- **C** (Confidence) = どれだけ自信があるか (0-100%)
- **E** (Effort) = 実装工数 (person-months)

**Score** = (R × I × C) / E

### 9 つのフレームワーク概要

| Framework | Best For | Key Insight |
| ----------- | ---------- | ------------- |
| Eisenhower Matrix | 個人タスク | 緊急度と重要度で整理する。個人の PM タスク管理向け |
| Impact vs Effort | タスク / 施策 | 単純な 2×2。素早い仕分け向けで、戦略判断には弱い |
| Risk vs Reward | 施策 | Impact vs Effort に不確実性を加味したもの |
| **Opportunity Score** | 顧客課題 | **推奨。** Importance × (1 − Satisfaction)。0-1 正規化する |
| Kano Model | 期待値理解 | Must-be / Performance / Attractive など。理解向けで、優先順位付けそのものではない |
| Weighted Decision Matrix | 多要素の意思決定 | 評価軸に重みをつけて比較する。合意形成に向く |
| **ICE** | アイデア / 施策 | Impact × Confidence × Ease。素早い優先順位付け向け |
| **RICE** | 大規模なアイデア比較 | (Reach × Impact × Confidence) / Effort。ICE に Reach を追加 |
| MoSCoW | 要件整理 | Must / Should / Could / Won't。もともとはプロジェクト管理寄り |

### テンプレート

- [Opportunity Score intro (PDF)](https://drive.google.com/file/d/1ENbYPmk1i1AKO7UnfyTuULL5GucTVufW/view)
- [Importance vs Satisfaction Template — Dan Olsen (Google Slides)](https://docs.google.com/presentation/d/1jg-LuF_3QHsf6f1nE1f98i4C0aulnRNMOO1jftgti8M/edit#slide=id.g796641d975_0_3)
- [ICE Template (Google Sheets)](https://docs.google.com/spreadsheets/d/1LUfnsPolhZgm7X2oij-7EUe0CJT-Dwr-/edit?usp=share_link&ouid=111307342557889008106&rtpof=true&sd=true)
- [RICE Template (Google Sheets)](https://docs.google.com/spreadsheets/d/1S-6QpyOz5MCrV7B67LUWdZkAzn38Eahv/edit?usp=sharing&ouid=111307342557889008106&rtpof=true&sd=true)

---

### 参考

- [The Product Management Frameworks Compendium + Templates](https://www.productcompass.pm/p/the-product-frameworks-compendium)
- [Kano Model: How to Delight Your Customers Without Becoming a Feature Factory](https://www.productcompass.pm/p/kano-model-how-to-delight-your-customers)
- [Continuous Product Discovery Masterclass (CPDM)](https://www.productcompass.pm/p/cpdm) (video course)
