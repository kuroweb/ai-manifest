# pve-disk-capacity-monitoring

- **プロジェクト名:** infra
- **作成日:** 2026-06-06

## 概要

pve-1 / pve-2（Proxmox VE ホスト）のディスク容量を把握し、枯渇前に気づけるようにしたい。

## 実施計画

**方針: D → A**（まず現状確認、足りなければ手動確認手順を infra に残す）

1. MacBook から pve-1 / pve-2 に SSH し、ディスク容量の現状を取得する
2. 確認コマンドと見るべき指標を `docs/` に手順として文書化する
3. VM OS ディスク逼迫（vm-101/102/103 disk-0）を 64G → 128G に拡張
4. 定期監視・アラートは今回スコープ外（必要になったら別 issue）

**SSH 接続:** `root@192.168.0.50` / `root@192.168.0.60`、ポート 22、パスワード認証

## 次のアクション

- なし（close）

## 成果物（infra リポジトリに残置）

- `docs/pve-disk-check.md` — PVE 容量確認手順
- `docs/pve-vm-disk-resize.md` — VM OS ディスク拡張手順（汎用＋本環境例）

## メモ

### 拡張後スナップショット（2026-06-06）

| ノード | VMID | `sda` | `/` 使用率 | 拡張前 |
| --- | --- | --- | --- | --- |
| worker-1 | 101 | 128G | 42% (50G/126G) | 83% |
| worker-2 | 102 | 128G | 42% (50G/126G) | 84% |
| worker-3 | 103 | 128G | 41% (49G/126G) | 81% |

worker-3 の `resize2fs` 時に `Failed to add inotify watch for /run/udev: Too many open files` が出たが、リサイズ自体は成功。

- 容量確認: `docs/pve-disk-check.md`
- ディスク拡張: `docs/pve-vm-disk-resize.md`

## タスク

- [x] 方針合意（D → A）
- [x] SSH 接続方法確定（root + パスワード、port 22）
- [x] 手順文書化（A）— `docs/pve-disk-check.md`
- [x] 現状確認（D）— 2026-06-06 実施
- [x] 拡張手順書作成 — `docs/pve-vm-disk-resize.md`
- [x] 拡張事前確認（scsi0 / sda2）
- [x] VM OS ディスク拡張（§1〜3）— 2026-06-06 完了
