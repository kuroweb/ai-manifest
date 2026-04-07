---
name: pm-exec-stakeholder-map
description: Power / Interest の 2 軸で stakeholder map を作り、象限ごとのコミュニケーション方針と communication plan を作る。stakeholder 管理、リリース準備、部門横断アラインメント、関係者対応の設計に使う。
---
## Stakeholder Mapping & Communication Plan

Power × Interest のマトリクスでステークホルダーを整理し、各グループ向けのコミュニケーション計画を作る。

### 背景

あなたは **$ARGUMENTS** の stakeholder map を作る支援をしている。

ユーザーが組織図、企画概要、チーム一覧を渡したら先に読む。プロダクトや施策の説明があるなら、そこから想定されるステークホルダーも補う。

### 手順

1. **ステークホルダーを洗い出す**: 経営、開発リード、デザイナー、マーケ、営業、サポート、法務、財務、外部パートナー、エンドユーザーなどを列挙する。

2. **2 軸で分類する**:
   - **Power** (High / Low): 意思決定、リソース、成果にどれだけ影響できるか
   - **Interest** (High / Low): この施策にどれだけ直接影響されるか、どれだけ関心が高いか

3. **Power × Interest に配置する**:

   | | High Interest | Low Interest |
   | --- | --- | --- |
   | **High Power** | **Manage Closely** — 定期 1:1、意思決定に巻き込む、早めに意見を取る | **Keep Satisfied** — 定期更新、重要課題だけ escalte する |
   | **Low Power** | **Keep Informed** — 定例共有、demo 招待、feedback 収集 | **Monitor** — 必要時だけの軽い共有 |

4. **各象限ごとに提案する**:
   - コミュニケーション頻度 (daily, weekly, bi-weekly, monthly)
   - 形式 (1:1, email, Slack, meeting, dashboard)
   - 伝えるべきメッセージ
   - 放置したときのリスク

5. **communication plan の表を作る**:

   | Stakeholder | Role | Power | Interest | Strategy | Frequency | Channel | Key Message |
   | --- | --- | --- | --- | --- | --- | --- | --- |

6. **対立しそうな関係を明示する**: 利害がぶつかる人たちを挙げ、整合の取り方を提案する。

段階的に考え、stakeholder map を `~/.plans/pm-exec/Stakeholder-Map-[initiative-name].md` という名前の Markdown 文書として保存する。

---

### 参考

- [The Product Management Frameworks Compendium + Templates](https://www.productcompass.pm/p/the-product-frameworks-compendium)
- [Team Topologies: A Handbook to Set and Scale Product Teams](https://www.productcompass.pm/p/team-topologies-a-handbook-to-set)
