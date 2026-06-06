# worker-disk-pressure-mitigation

- **プロジェクト名:** infra
- **作成日:** 2026-06-06

## 概要

worker-1/2/3 の OS ディスク (`/`) 逼迫リスクを減らす。journal / syslog 等のログ肥大を調査し、Ansible で再発防止設定を配布、初回クリーンアップまで行う。

## 実施計画

### 合意事項

| 項目 | 内容 |
| --- | --- |
| 対象 | worker-1/2/3 の OS ディスク (`/`) のみ |
| 対象外 | `/storage-1`（Longhorn）、snap、docker-registry |
| 恒久化 | Ansible playbook（`playbooks/worker/`） |
| journald | `SystemMaxUse=500M`（drop-in） |
| logrotate | rsyslog に `maxsize 500M` 追加（`rotate 4` + `compress` 維持） |
| 初回 cleanup | playbook `--tags cleanup`（vacuum + logrotate -f） |

### 実装内容

1. **設定ファイル**（worker 共通、`files/workers/` を新設）
   - `etc/systemd/journald.conf.d/99-disk-limit.conf`
   - `etc/logrotate.d/rsyslog`（maxsize 追加版）

2. **playbook** — `playbooks/worker/log-disk-governance.yml`
   - tag `config`: 設定配布 + journald restart
   - tag `cleanup`: `journalctl --vacuum-size=500M` + `logrotate -f /etc/logrotate.d/rsyslog`

3. **docs** — `docs/worker-disk-log-check.md`（確認コマンド・適用手順・見るべき指標）

### 適用順序

```bash
cd ansible

# 1. ドライラン（worker-1）
ansible-playbook playbooks/worker/log-disk-governance.yml -K --check --limit worker-1

# 2. 設定適用（worker-1 → 全台）
ansible-playbook playbooks/worker/log-disk-governance.yml -K --limit worker-1 --tags config
ansible-playbook playbooks/worker/log-disk-governance.yml -K --tags config

# 3. クリーンアップ（worker-1 → 全台）
ansible-playbook playbooks/worker/log-disk-governance.yml -K --limit worker-1 --tags cleanup
ansible-playbook playbooks/worker/log-disk-governance.yml -K --tags cleanup

# 4. 確認
ansible workers -m shell -a "df -h /; du -sh /var/log /var/log/journal 2>/dev/null"
```

## 次のアクション

- なし（close 済み 2026-06-06）

### 適用後スナップショット（2026-06-06）

| ノード | `/` 使用率 | `/var/log` | syslog | syslog.1 | 適用前 `/` |
| --- | --- | --- | --- | --- | --- |
| worker-1 | 39% (46G/126G) | 3.2G | 24K | 2.4G | 42% |
| worker-2 | 39% (47G/126G) | 3.5G | 16K | 2.6G | 42% |
| worker-3 | 36% (44G/126G) | 4.1G | 4K | 3.1G | 41% |

**補足:** `syslog.1` は `delaycompress` により次回ローテーションまで非圧縮のまま。再発防止設定は有効。追加削減する場合は `gzip /var/log/syslog.1` で ~2–3G/台 削減可能。

**トラブル:** 初回 cleanup で logrotate が `/var/log` 権限エラー → `su root syslog` を rsyslog 設定に追加して解消。

## メモ

### 現状調査（2026-06-06、sudo なし）

| ノード | `/` 使用率 | `/var/log` | syslog 系 | journal | snap | その他 |
| --- | --- | --- | --- | --- | --- | --- |
| worker-1 | 42% (50G/126G) | 6.6G | ~5.5G | 1.7G | 8.2G | price-monitoring 376M |
| worker-2 | 42% (50G/126G) | 7.2G | ~5.3G | 1.5G | 8.2G | docker-registry 2.3G |
| worker-3 | 41% (49G/126G) | 9.0G | ~6.4G | 2.2G | 6.3G | — |

**主な発見:** syslog 肥大（weekly のみ・maxsize なし）> journal 上限未設定 > snap 等（今回対象外）

## 参照

- `~/.docs/issues/close/pve-disk-capacity-monitoring/issue.md`
- `docs/pve-vm-disk-resize.md`
- `docs/pve-disk-check.md`

## タスク

- [x] スコープ合意 — OS ディスク (`/`) のみ
- [x] 現状調査 — 2026-06-06 実施
- [x] リスク要因の洗い出し — syslog > journal
- [x] 対処方針合意 — ログ対策、500M 上限、cleanup tag
- [x] Ansible playbook / files / docs 作成
- [x] 適用・検証 — 2026-06-06 完了
