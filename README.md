# ai-manifest

Cursor / Claude Code / Codex 向けのエージェント設定・スキルを一元管理するリポジトリ。

- エージェント設定の正本は `config/`。`config/.rulesync/` から生成し、`scripts/install.sh` でホーム配下へ symlink 反映する。
- スキルの正本は `skills/`。`gh skill install` で各エージェントへコピーする。

## リポジトリ構成

```
ai-manifest/
├── README.md
├── AGENTS.md            # 本リポジトリ作業時の運用境界。手動管理
├── CLAUDE.md            # @AGENTS.md を参照するエントリポイント
├── docs/                # 運用ガイドライン（skills / agent-config）
├── scripts/install.sh   # config/ → ホーム配下への symlink 反映
├── skills/              # スキル正本
└── config/
    ├── .rulesync/       # エージェント設定正本（rules / subagents）
    ├── .cursor/         # rulesync 生成物 + 手動管理ファイル
    ├── .claude/         # rulesync 生成物 + 手動管理ファイル
    ├── .codex/          # rulesync 生成物
    ├── .docs/           # 運用データ
    ├── .takt/           # taktのグローバル設定
    ├── .env             # MCPなどのシークレットを記述する
    ├── rulesync.jsonc
    ├── CLAUDE.md        # rulesync generate の成果物
    └── AGENTS.md        # rulesync generate の成果物
```

## クイックスタート

1. **依存パッケージをインストール**

   ```bash
   brew install rulesync gh
   ```

2. **リポジトリをクローン**

   ```bash
   git clone <repository-url>
   cd ai-manifest
   ```

3. **エージェント設定生成**

   ```bash
   cd config
   rulesync generate
   ```

4. **ローカル用ファイル**

   ```bash
   cp -n config/.env.example config/.env
   cp -n config/.cursor/mcp.json.example config/.cursor/mcp.json
   cp -n config/.cursor/hooks.json.example config/.cursor/hooks.json
   ```

5. **スキルインストール**

   利用するエージェントごとにリモートから `--scope user` で実行する。

   ```bash
   gh skill install kuroweb/ai-manifest --all --scope user --agent cursor --force
   gh skill install kuroweb/ai-manifest --all --scope user --agent claude-code --force
   gh skill install kuroweb/ai-manifest --all --scope user --agent codex --force
   ```

6. **ホーム配下に各種エージェント設定を反映**

   詳細は [docs/agent-config-guideline.md](docs/agent-config-guideline.md#生成とホーム反映) を参照。

   ```bash
   bash scripts/install.sh
   ```

7. **手動コピペが必要な設定を反映**

   詳細は [docs/agent-config-guideline.md](docs/agent-config-guideline.md#手動コピペでの反映) を参照。

8. **確認**

   ```bash
   ls -la ~/.cursor ~/.claude ~/.codex
   ls -la ~/.config/ai-manifest/.env
   gh skill list --scope user
   ```

## Skills 運用

一覧は [skills/README.md](skills/README.md)、運用手順は [docs/skills-guideline.md](docs/skills-guideline.md) を見る。

## エージェント設定運用

運用手順は [docs/agent-config-guideline.md](docs/agent-config-guideline.md) を見る。
