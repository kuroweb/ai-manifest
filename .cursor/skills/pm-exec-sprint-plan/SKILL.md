---
name: pm-exec-sprint-plan
description: キャパシティ見積もり、story 選定、依存関係整理、リスク洗い出しを含めて sprint を計画する。sprint planning の準備、チームキャパシティ見積もり、story 選択、velocity と scope の調整に使う。
---
## Sprint Planning

チームのキャパシティを見積もり、story を選んで順序づけ、リスクを整理して sprint を計画する。

### 背景

あなたは **$ARGUMENTS** の sprint planning を支援している。

ユーザーが backlog、velocity データ、チーム一覧、前 sprint のレポートを渡したら先に読む。

### 手順

1. **チームキャパシティを見積もる**:
   - メンバー数と稼働可能日数 (PTO、会議、on-call など)
   - 直近 3 sprint の平均 velocity
   - 予期しない仕事、バグ、tech debt 向けに 15-20% の buffer を残す
   - story point または ideal hour で利用可能キャパシティを算出する

2. **story を見て選ぶ**:
   - 優先度の高い backlog から取る
   - 各 story が Definition of Ready を満たすか確認する
   - 事前 refinement が必要な story は印をつける
   - キャパシティに達したら追加を止める

3. **依存関係を整理する**:
   - story 同士や外部チームへの依存を洗い出す
   - 依存を踏まえて順序を決める
   - 外部依存と owner を明示する
   - critical path を見つける

4. **リスクと対策を整理する**:
   - 不確実性や複雑性が高い story
   - 遅れそうな外部依存
   - 特定個人に知識が偏っている箇所
   - 各リスクへの対策を出す

5. **sprint plan の要約を作る**:

   ```
   Sprint Goal: [成功状態を 1 文で表したもの]
   Duration: [2 weeks / 1 week / etc.]
   Team Capacity: [X story points]
   Committed Stories: [Y story points across Z stories]
   Buffer: [remaining capacity]

   Stories:
   1. [Story title] — [points] — [owner] — [dependencies]
   ...

   Risks:
   - [Risk] → [Mitigation]
   ```

6. **Sprint goal を定義する**: sprint が生み出す中心価値を、1 文で明確に表す。

段階的に考え、`~/.plans/pm-exec/Sprint-Plan-[team-name]-[sprint].md` という名前の Markdown で保存する。

---

### 参考

- [Product Owner vs Product Manager: What's the difference?](https://www.productcompass.pm/p/product-manager-vs-product-owner)
