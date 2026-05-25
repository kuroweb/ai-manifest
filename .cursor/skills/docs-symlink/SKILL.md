---
name: docs-symlink
description: 'プロジェクト直下の `.docs` を `~/.docs` への symlink にする（実体は `~/.docs`）。 トリガー: `/docs-symlink`、「.docs をリンクして」「docs symlink」等。'
---
# .docs リンク

`<project>/.docs` → `~/.docs`（実体はホーム側）

## 手順

プロジェクトルートで実行する。

```bash
[[ -L .docs && "$(readlink .docs)" == "$HOME/.docs" ]] && ls -la .docs && exit 0
[[ -L "$HOME/.docs" && "$(readlink "$HOME/.docs")" == "$PWD/.docs" ]] && rm "$HOME/.docs"
[[ -d .docs && ! -L .docs ]] && mv .docs "$HOME/.docs"
mkdir -p "$HOME/.docs"
ln -sfn "$HOME/.docs" .docs
ls -la .docs
```
