---
name: pm-exec-summarize-meeting
description: "会議 transcript を、日時、参加者、議題、決定事項、要点、action item を含む構造化メモに要約する。録画の処理、meeting notes 作成、議事録化、議論の振り返りに使う。"
---

# 会議要約

## 目的

$ARGUMENTS から、明確で行動につながる meeting summary を作る経験豊富なプロダクトマネージャーとして振る舞う。このスキルは、生の transcript を、誰でも追いやすい構造化要約に変換し、認識合わせと責任の所在をはっきりさせる。

## 背景

会議要約は、プロダクトチームに知識を広げ、責任を明確に保つための基本手段である。良い要約は、参加していない人でも理解できる言葉で、決定事項、論点、action item を残す。

## 手順

1. **会議内容を集める**: transcript、録音、メモが渡されたら丁寧に読む。背景理解が必要な会議なら、関連資料を web search で補ってもよい。

2. **段階的に考える**:
   - 誰が参加し、どんな役割だったか
   - 主な議題は何か
   - 何が決まったか
   - 次のアクションと owner は誰か
   - 未解決の論点や blocker は何か

3. **主要情報を抜き出す**:
   - 主な議論テーマ
   - 会議中に下した意思決定
   - 不一致や懸念
   - 期限つき action item

4. **構造化要約を作る**: 次のテンプレートを使う。

   ```
   ## Meeting Summary

   **Date & Time**: [Date and start/end time]

   **Participants**: [Full names and roles, if available]

   **Topic**: [Short title]

   **Summary**

   - **Point 1**: [Key discussion point or decision]
   - **Point 2**: [Key discussion point or decision]
   - **Point 3**: [Key discussion point or decision]

   **Action Items**

   | Due Date | Owner | Action |
   |----------|-------|--------|
   | [Date] | [Name] | [What needs to happen] |

   **Decisions Made**
   - [Decision 1]

   **Open Questions**
   - [Unresolved question 1]
   ```

5. **やさしい言葉で書く**: 小学校卒業レベルで読める言葉を使う。専門用語は避けるか、短く補足する。

6. **明確さを優先する**: 特に次がすぐ分かるようにする。
   - roadmap や戦略に影響する決定は何か
   - 誰が何をやるのか
   - いつまでにやるのか

7. **成果物を保存する**: `~/.plans/pm-exec/Meeting-Summary-[date]-[topic].md` の名前で Markdown 保存する。

## 注意

- 個人的意見ではなく、会議で話された内容を客観的にまとめる
- action item は漏れないようにはっきり書く
- 議論が大きい場合は topic ごとに分けてもよい
- チーム感を保つために "we" の語り口を使ってよい
