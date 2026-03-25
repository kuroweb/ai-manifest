---
name: audit-codex-direct
description: 特定ファイルを OpenAI Codex CLI に送って独立した監査・レビューを行う
---
# Codex 直接ファイル監査

## あなたのタスク

ユーザーは Git diff ではなく、特定のファイル群を監査したい。ファイルパスが渡される場合もあれば、会話の文脈から対象ファイルを特定すべき場合もある。

1. 監査対象のファイルを特定する。ユーザーがパスを指定しているならそれを使う。指定がない場合は、会話の文脈から最も relevant なファイルを判断する。

2. 各ファイルが何をしているか、またなぜ監査対象なのかを簡潔に要約する。

3. 以下のコマンドを実行する。`<FILE_PATHS>` にはスペース区切りのファイル一覧を入れ、`<FILE_SUMMARY>` には各ファイルの役割を簡潔に記述する:

    ```bash
    codex exec -m "gpt-5.4" -c 'model_reasoning_effort="xhigh"' -c 'service_tier="fast"' --dangerously-bypass-approvals-and-sandbox -C "$(pwd)" "You are a READ-ONLY code reviewer. Read and review the following files: <FILE_PATHS>. Review them for: bugs, security issues, performance problems, logic errors, and style concerns. Be specific about file names and line numbers. You may read other files in the repo and run tests to verify your findings. SAFETY RULES: Do NOT delete files, edit existing files, change branches, checkout, reset, revert, amend, or undo commits. Do NOT run git push, git checkout, git reset, git clean, rm, or any destructive command. You may create temporary files if needed for debugging. Your job is strictly to READ and REPORT. Do a deep audit and think from first principles. Leave no question unanswered. Here is context about the files: <FILE_SUMMARY>"
    ```

4. **提示する前に、すべての指摘事項を検証すること。** 監査役である Codex は限定的な文脈しか持たない。プロジェクトのビジョン、戦略目標、アーキテクチャ上の意図は把握していない。そのため、誤解に基づく重大な問題を捏造したり、意図的な設計判断を過剰に重大視したりすることがある。Codex が返した各指摘について、必ず以下を行う:
   - 実際のソースコードを確認し、その問題が幻覚や読み違いではなく、本当に存在するか確かめる。
   - ローカルの戦略・計画ドキュメント（例: `agents.md`, `README.md`, `CLAUDE.md`, `current_*.md`、またはリポジトリ内や `/doc/` フォルダ内の類似ドキュメント、`DEV_JOURNAL.md` など）を確認し、その指摘が明示されたプロジェクト意図と矛盾していないか見る。
   - 「これは本当のバグか、それとも Codex が文脈を誤解しているだけか？」および「たとえ本当でも、意味のある問題か、それとも些末なスタイル上のノイズか？」と自問する。
   - 「実在する」かつ「意味がある」の両方を満たさない指摘があれば、それもユーザーには共有するが、そう判断した理由を明示して明確にラベル付けする。

5. 検証済みの指摘事項をユーザーに提示する。それぞれについて、なぜ正当な指摘だと判断したのかを簡潔に添える。Codex が問題なしと判断した場合、あるいはすべての指摘が検証で棄却された場合も、その旨を伝える。

6. 検証済みのフィードバックのうち、どれか対応したいものがあるかユーザーに尋ねる。
