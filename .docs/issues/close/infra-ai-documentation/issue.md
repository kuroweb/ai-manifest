# infra-ai-documentation

- **プロジェクト名:** infra
- **作成日:** 2026-06-06
- **完了日:** 2026-06-06

## 概要

自宅サーバーインフラ管理リポジトリ（`infra`）向けに、AI エージェントが迷わず作業できるドキュメント・ルールを整備する。

**主な課題:** 人間向け `README.md`（1100 行超）と AI 向けルールの役割分担が曖昧で、エージェントが要点を拾えない。

## 実施計画

### 方針（合意済み）

- **README.md** — 初期構築手順書として据え置き（Proxmox / VM / K8s / VPS セットアップ等）
- **AI 向け** — 別ファイル（`.cursor/rules/` や `docs/`）に日常運用の要点を切り出す
- README と AI ルールの完全同期は求めない（役割分担で分離）

### AI ドキュメント構成（合意済み）

**2 層構成:**

| レイヤー | ファイル | 役割 |
| --- | --- | --- |
| L1 | `.rulesync/rules/overview.md`（新規） | リポジトリ全体像・境界・禁止事項・README/他リポジトリへの参照 |
| L2 | `.rulesync/rules/ansible-overview.md`（移行） | Ansible 運用の詳細（playbook、コマンド、設計原則） |

正本は `.rulesync/rules/*.md`。`rulesync generate` で各エージェント向けファイルに展開。L1 は短文（`root: true`）、L2 は詳細。

### 配布形式（合意済み）

- **rulesync 導入** — `.rulesync/` を正本とし、`rulesync generate` で各エージェント向けファイルを生成
- 生成先: `.cursor/rules/`、`CLAUDE.md`、`AGENTS.md`、`GEMINI.md` 等
- 生成物は直接編集しない（`ai-manifest` の運用方針に準拠）

### `.rulesync/rules/` のスコープ（合意済み）

**infra 固有のみ**（共通方針は `ai-manifest` のユーザースコープに任せる）:

| ファイル | 役割 |
| --- | --- |
| `overview.md` | リポジトリ全体像・境界・禁止事項・他リポジトリ参照 |
| `ansible-overview.md` | Ansible 運用詳細（既存 `.mdc` から移行） |
| `rulesync-source-of-truth.md` | rulesync 正本の編集境界 |

### ansible-overview 移行方針（合意済み）

**移行時に重複整理** — `overview.md` へ移す節を ansible-overview から削除してスリム化する。

`overview.md` へ移し、ansible-overview から削除する節:

- Repository Purpose / Directory Structure
- Managed Infrastructure（ホスト一覧・ネットワーク図）
- Connection Details（SSH ポート等の概要）
- Related Documentation（README / k8s / k8s-secret への参照）

ansible-overview に残す節:

- Ansible Configuration / Design Principles
- Command Execution Guide
- Common Playbooks
- Frequently Used Modules
- Development Guidelines
- Testing & Verification
- Important Notes / Troubleshooting

### Git 管理（合意済み）

- `rulesync generate` の出力物（`.cursor/rules/*.mdc`、`AGENTS.md`、`CLAUDE.md`、`GEMINI.md` 等）を **コミットする**
- 変更フロー: `.rulesync/` 編集 → `rulesync generate` → 生成物もまとめて commit
- `ai-manifest` の運用と揃える

### v1 スコープ（合意済み）

- rulesync 導入 + 3 ルールファイル整備 + generate + 生成物 commit
- README に「AI 向けドキュメント」節を短く追記（役割分担・generate 手順）
- **v1 に含めない:** skills / subagents、README の分割・薄型化、`docs/` への追加

### v1 実装手順

1. `rulesync init` + `rulesync.jsonc` 作成（`features: ["rules"]` のみ、`targets` は 4 エージェント）
2. `.rulesync/rules/rulesync-source-of-truth.md` を追加（`ai-manifest` から流用）
3. `.rulesync/rules/overview.md` を新規作成
   - `root: true`、短文・命令形
   - リポジトリ目的、ディレクトリ構成、管理対象インフラ、ネットワーク図
   - 他リポジトリ境界（`k8s` / `k8s-secret`）、`config/` は参照用（Ansible 未管理）
   - README の役割（初期構築のみ）、ansible-overview への参照
4. `.cursor/rules/ansible-overview.mdc` → `.rulesync/rules/ansible-overview.md` に移行・重複削除
5. `rulesync generate` 実行
6. 手書き `.cursor/rules/ansible-overview.mdc` を削除（生成物に置換）
7. README に「AI 向けドキュメント」節を追記
8. 生成物含め commit

### overview.md に含める要点（草案）

- このリポジトリが管理するもの / しないもの
- Ansible 管理対象は `k8s` グループ（master-1, worker-1/2/3）のみ
- `config/proxy-1/` は参照用（inventory 外）
- 初期構築手順は README を参照（AI が手順を README に追記しない）
- K8s マニフェストは別リポジトリ
- 本番クラスタへの影響に注意（netplan は `serial: 1`）

## 次のアクション

- [x] grill-me 完了
- [x] `rulesync init` + `rulesync.jsonc`
- [x] `.rulesync/rules/` 3 ファイル作成・移行
- [x] `rulesync generate`（手書き `.mdc` は生成物に置換）
- [x] README「AI 向けドキュメント」節追記
- [x] commit（手動）

## メモ

### 現状（2026-06-06 調査）

| 種別 | 有無 | 内容 |
| --- | --- | --- |
| `.cursor/rules/` | あり | `ansible-overview.mdc` のみ（Ansible/K8s 運用の詳細ルール） |
| `.rulesync/` | なし | — |
| `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` | なし | — |
| `README.md` | あり | 人間向けセットアップ手順（1100 行超） |
| `docs/` | 一部 | `tailscale-lxc-setup.md` のみ |

### 関連

- 別プロジェクト `ai-manifest` に `rulesync-overview-refinement` issue あり（rulesync 運用のベストプラクティス参考）
