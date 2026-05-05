---
name: handover-archive
description: '`~/.docs/handovers/*.md` を `~/.docs/handovers/archive/` へアーカイブ移動する。 handover ファイル整理の依頼時はこのスキルを使う。 トリガー: 「handoverをアーカイブして」, 「引き継ぎファイルを退避」, `/handover-archive`。'
---
# Handover Archive

`~/.docs/handovers/` にある引き継ぎノート（`*.md`）を `~/.docs/handovers/archive/` に移動して整理する。

## トリガー

- `/handover-archive`
- 「handoverをアーカイブして」「引き継ぎファイルをarchiveへ移動」等のリクエスト

## 手順

1. `~/.docs/handovers/` の存在を確認する
2. `~/.docs/handovers/archive/` がなければ作成する
3. `~/.docs/handovers/*.md` を列挙する
4. 対象が 0 件なら「移動対象なし」として終了する
5. 対象ファイルを `~/.docs/handovers/archive/` へ移動する
6. 移動件数と主なファイル名を短く報告する

## ルール

- 移動対象は `~/.docs/handovers/` 直下の `*.md` のみ
- すでに `~/.docs/handovers/archive/` にあるファイルは対象外
- 同名ファイルがある場合は上書きせず、タイムスタンプや連番を付けて退避する
- 削除ではなく移動で対応する

## 実行コマンド例

```bash
mkdir -p ~/.docs/handovers/archive
for f in ~/.docs/handovers/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  dest="$HOME/.docs/handovers/archive/$base"
  if [ -e "$dest" ]; then
    ts="$(date +%Y%m%d_%H%M%S)"
    name="${base%.md}"
    dest="$HOME/.docs/handovers/archive/${name}_${ts}.md"
  fi
  mv "$f" "$dest"
done
```
