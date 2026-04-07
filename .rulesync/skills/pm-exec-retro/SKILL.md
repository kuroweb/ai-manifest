---
name: pm-exec-retro
description: "スプリントレトロを構造化して進め、良かったこと、良くなかったこと、優先度つきの改善アクションを owner と期限つきで整理する。レトロの実施、スプリント振り返り、チームフィードバックからのアクション化に使う。"
---

## Sprint Retrospective 支援

示唆を表に出し、実行可能な改善につなげる構造化レトロを行う。

### 背景

あなたは **$ARGUMENTS** のレトロを進行している。

ユーザーがスプリントデータ、ベロシティチャート、チームフィードバック、前回レトロのメモを渡したら先に読む。

### 手順

1. **レトロ形式を選ぶ**: 文脈に合わせて選ぶ。指定がなければ提案してよい。

   **Format A — Start / Stop / Continue**:
   - **Start**: 新しく始めるべきこと
   - **Stop**: やめるべきこと
   - **Continue**: 続けるべき良いこと

   **Format B — 4Ls (Liked / Learned / Lacked / Longed For)**:
   - **Liked**: 良かったこと
   - **Learned**: 学んだこと
   - **Lacked**: 足りなかったこと
   - **Longed For**: 欲しかったもの

   **Format C — Sailboat**:
   - **Wind**: 前に進めてくれた要因
   - **Anchor**: 足を引っ張った要因
   - **Rocks**: これからの危険
   - **Island**: 目指すゴール

2. **生のフィードバックがある場合**:
   - 似た内容をまとめてテーマ化する
   - よく出た話題を見つける
   - 感情の傾向 (苛立ち、勢い、混乱) を見る

3. **スプリント実績を分析する**:
   - Sprint goal は達成したか
   - Velocity と commitment の差はどうか
   - 発生した blocker と解決方法
   - コラボレーションの良し悪し

4. **優先度つきアクションを作る**:

   | Priority | Action Item | Owner | Deadline | Success Metric |
   | --- | --- | --- | --- | --- |
   | 1 | [具体的な改善] | [Name/Role] | [Date] | [効いたと判断する方法] |

   - アクションは 2-3 個に絞る
   - 具体的で、担当を置けて、測定できるものにする
   - 前回のアクションがあれば、完了したか確認する

5. **レトロ要約を作る**:

   ```
   ## Sprint [X] Retrospective — [Date]

   ### Sprint Performance
   - Goal: [Achieved / Partially / Missed]
   - Committed: [X pts] | Completed: [Y pts]

   ### Key Themes
   1. [Theme] — [summary]

   ### Action Items
   1. [Action] — [Owner] — [By date]

   ### Carry-over from Last Retro
   - [Previous action] — [Status: Done / In Progress / Not Started]
   ```

成果物を保存する: `~/.plans/pm-exec/Retro-[team-name]-[date].md` という名前の Markdown で保存する。責任追及ではなく改善を目的とした建設的なトーンにする。
