# frontend-tailwind4-daisyui5-migration

- **プロジェクト名:** price-monitoring
- **作成日:** 2026-05-23

## 概要

フロントエンド（`volumes/frontend`）の Tailwind CSS を v4 系、daisyUI を v5 系へ移行する。両者はセット前提（daisyUI 5 は Tailwind 4 専用）。事前調査済み。

## 現状

| パッケージ | バージョン |
|------------|------------|
| tailwindcss | 3.4.19（固定） |
| daisyui | ^4.12.24（lock: 4.12.24） |
| postcss | tailwindcss + autoprefixer |
| next | ^14.2.3（App Router） |

主な設定ファイル:

- `app/globals.css` — `@import "tailwindcss/base|components|utilities"`
- `postcss.config.js` — `tailwindcss`, `autoprefixer`
- `tailwind.config.ts` — content、daisyUI プラグイン、`themes: ['light', 'dark']`、`gradient-radial` / `gradient-conic`（未使用の可能性）

## 移行先

| パッケージ | 目標 |
|------------|------|
| tailwindcss | 4.x（npm latest: 4.3.0 付近） |
| daisyui | 5.x（npm latest: 5.5.20 付近） |
| 追加 | `@tailwindcss/postcss` |
| 削除候補 | `autoprefixer`（v4 に内包） |

## 推奨手順（公式）

1. `tailwind.config.ts` から daisyUI（plugins / daisyui 設定 / daisyui の content パス）を除去
2. `npx @tailwindcss/upgrade` を実行し diff をレビュー
3. パッケージ更新・`postcss.config` を `@tailwindcss/postcss` に変更
4. `globals.css` を `@import "tailwindcss";` + `@plugin "daisyui" { themes: light --default, dark; }` に変更
5. `tailwind.config.ts` の残設定を `@theme` へ移行（不要なら削除）
6. daisyUI v4→v5 のクラス変更を反映
7. `npm run build` / `npm run lint` / 画面 QA

参照:

- [daisyUI 5 upgrade guide](https://daisyui.com/docs/upgrade/)
- [Tailwind CSS — Install with Next.js](https://tailwindcss.com/docs/guides/nextjs)

## 影響範囲（コード）

daisyUI クラスを約 30 ファイルで使用。主な修正対象:

| パターン | 対応 |
|----------|------|
| `input-bordered` / `textarea-bordered` | 削除（v5 ではボーダーがデフォルト）。16 ファイル前後・機械的置換可 |
| `modal-toggle` / `modal-box` / `modal-backdrop` | 4 モーダル（商品作成・更新、カテゴリ、Backmarket）— 動作確認必須 |
| `join` / `join-item` | 継続利用可 |
| `data-theme='dark'`（`Layout.tsx`） | `@plugin` のテーマ設定と整合確認 |
| `btn-group` / `input-group` | 未使用 |

その他: `@apply` なし。`recharts` / `react-toastify` は直接影響なし。

## 依存の更新

- `eslint-plugin-tailwindcss` を 3.18.x へ（peer: Tailwind 3/4 対応）
- `eslint-config-next` 13.5.6 は別件（今回スコープ外でも可）

## リスク

- フォーム・モーダルの見た目差分（手動 QA 必須）
- Tailwind v4 のユーティリティリネーム（upgrade ツールで大半対応、残りはビジュアル確認）
- CI: `volumes/frontend/**` 変更で frontend イメージ再ビルド

## タスク

- [x] `tailwind.config.ts` から daisyUI を外し `npx @tailwindcss/upgrade` を実行
- [x] `package.json` / lock を更新（tailwindcss 4、daisyui 5、`@tailwindcss/postcss`、autoprefixer 削除）
- [x] `globals.css` / `postcss.config` を v4 構成に変更
- [x] `input-bordered` / `textarea-bordered` を一括置換
- [ ] モーダル 4 箇所の動作・見た目確認（ブラウザ QA）
- [ ] 管理画面・商品画面・レイアウトのビジュアル QA（ブラウザ QA）
- [x] `npm run build` / `npm run lint` 通過
- [ ] `eslint-plugin-tailwindcss` — v4 未対応のため一旦削除。代替は別 issue 検討

## 実施メモ（2026-05-23）

- tailwindcss **4.3.0** / daisyui **5.5.20** / @tailwindcss/postcss **4.3.0**
- `tailwind.config.ts` は ESLint 用の content 定義のみ（`@config` で globals.css から参照）
- upgrade ツールがテーブル 5 ファイルのクラス名を自動移行
- `eslint-plugin-tailwindcss` は `Could not resolve tailwindcss` のため extends から除外しアンインストール
