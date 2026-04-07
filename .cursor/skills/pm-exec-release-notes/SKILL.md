---
name: pm-exec-release-notes
description: チケット、PRD、changelog からユーザー向けの release notes を作る。新機能、改善、修正などのカテゴリで分かりやすく要約する。release notes 執筆、changelog 作成、更新告知、出荷内容の要約に使う。
---
## Release Notes 生成

技術寄りのチケット、PRD、内部 changelog を、整ったユーザー向け release notes に変換する。

### 背景

あなたは **$ARGUMENTS** の release notes を書いている。

ユーザーがファイル (JIRA export、Linear ticket、PRD、Git log、内部 changelog) を渡したら先に読む。プロダクト URL があるなら、必要に応じて web search でプロダクトと想定読者を把握する。

### 手順

1. **元情報を集める**: 渡されたチケット、changelog、説明文から次を抜き出す。
   - 何が変わったか (機能、改善、修正)
   - 誰に影響するか (対象ユーザー)
   - なぜ重要か (ユーザー価値)

2. **変更を分類する**:
   - **New Features**: 完全に新しい機能
   - **Improvements**: 既存機能の改善
   - **Bug Fixes**: 解消した不具合
   - **Breaking Changes**: ユーザーの対応が必要な変更 (移行、API 変更など)
   - **Deprecations**: 廃止予定または終了する機能

3. **各項目を書く**: 次の原則に従う。
   - 技術変更ではなくユーザー価値から書き始める
   - 専門用語、社内コードネーム、チケット番号は避ける
   - 1-3 文に収める
   - ユーザーが画像やスクリーンショットを渡したら必要に応じて使う

   **書き換え例**:
   - Technical: "Implemented Redis caching layer for dashboard API endpoints"
   - User-facing: "ダッシュボードの読み込みが最大 3 倍速くなり、待ち時間を減らして分析に集中しやすくなりました。"

   - Technical: "Fixed race condition in concurrent checkout flow"
   - User-facing: "高負荷時に一部の注文が失敗することがある問題を修正しました。"

4. **release notes の構成**:

   ```
   # [Product Name] — [Version / Date]

   ## New Features
   - **[Feature name]**: [何ができて、なぜ重要かを 1-2 文]

   ## Improvements
   - **[Area]**: [何が良くなり、どう役立つか]

   ## Bug Fixes
   - [ユーザー視点での不具合説明]

   ## Breaking Changes (if any)
   - **Action required**: [ユーザーがやるべきこと]
   ```

5. **トーンを合わせる**: B2B ならプロフェッショナル、コンシューマ向けなら親しみやすく、API なら開発者向けに寄せる。

成果物を保存する: `~/.plans/pm-exec/Release-Notes-[product-name]-[date].md` という名前の Markdown として保存する。
