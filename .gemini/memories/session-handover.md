# セッション引き継ぎ

- セッション開始時にプロジェクトルートの `.handovers/` ディレクトリを確認し、ファイルが存在すれば最新のものを読み込む（Cursor / Claude Code / Codex / Gemini 共通）
- セッション終了時や作業の区切りでは handover スキルの実行を促す
