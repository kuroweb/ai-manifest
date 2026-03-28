#!/bin/sh
set -e
# リポジトリルート（.claude, .cursor 等のソースがあるディレクトリ）
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_BASE="$SCRIPT_DIR/backup/$(date +%Y%m%d%H%M%S)"

# ファイルのシンボリックリンクを作成する関数
link_file() {
  local target_dir="$1"
  local name="$2"
  local src="$REPO_ROOT/$target_dir/$name"
  local dest="$HOME/$target_dir/$name"
  local backup_dir="$BACKUP_BASE/$target_dir"

  # ソースファイルの存在チェック
  if [ ! -e "$src" ]; then
    echo "Warning: Source file does not exist: $src (skipping)"
    return 0
  fi

  if [ -e "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "Already linked: $dest -> $(readlink "$dest")"
    else
      mkdir -p "$backup_dir"
      echo "Backing up existing $name to $backup_dir"
      cp "$dest" "$backup_dir/$name.$(date +%Y%m%d%H%M%S)"
      ln -sf "$src" "$dest"
      echo "Linked $dest -> $src"
    fi
  else
    ln -sf "$src" "$dest"
    echo "Linked $dest -> $src"
  fi
}

# ディレクトリのシンボリックリンクを作成する関数
link_directory() {
  local target_dir="$1"
  local name="$2"
  local src="$REPO_ROOT/$target_dir/$name"
  local dest="$HOME/$target_dir/$name"
  local backup_dir="$BACKUP_BASE/$target_dir"

  # ソースディレクトリの存在チェック
  if [ ! -d "$src" ]; then
    echo "Warning: Source directory does not exist: $src (skipping)"
    return 0
  fi

  if [ -e "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "Already linked: $dest -> $(readlink "$dest")"
    else
      mkdir -p "$backup_dir"
      echo "Backing up existing $name directory to $backup_dir"
      cp -R "$dest" "$backup_dir/$name.$(date +%Y%m%d%H%M%S)"
      rm -rf "$dest"
      ln -sf "$src" "$dest"
      echo "Linked $dest -> $src"
    fi
  else
    ln -sf "$src" "$dest"
    echo "Linked $dest -> $src"
  fi
}

# ~/.claude にシンボリックリンクを作成
echo "Setting up .claude..."
mkdir -p "$HOME/.claude"
link_file ".claude" "settings.json"
link_file ".claude" "settings.local.json"
link_directory ".claude" "rules"
link_directory ".claude" "skills"
link_directory ".claude" "agents"
link_directory ".claude" "scripts"
echo ""

# ~/.cursor にシンボリックリンクを作成
echo "Setting up .cursor..."
mkdir -p "$HOME/.cursor"
link_file ".cursor" "mcp.json"
link_file ".cursor" "hooks.json"
link_directory ".cursor" "rules"
link_directory ".cursor" "skills"
link_directory ".cursor" "agents"
link_directory ".cursor" "scripts"
link_directory ".cursor" "hooks"
echo ""

# ~/.codex にシンボリックリンクを作成
echo "Setting up .codex..."
mkdir -p "$HOME/.codex"
link_directory ".codex" "agents"
link_directory ".codex" "memories"
link_directory ".codex" "skills"
echo ""

# ~/.takt/config.yaml ← リポの .takt_global/config.yaml（GlobalConfig 正本）
echo "Setting up .takt..."
mkdir -p "$HOME/.takt"
GLOBAL_CFG_SRC="$REPO_ROOT/.takt_global/config.yaml"
for legacy in \
  "$REPO_ROOT/.takt/config.yaml" \
  "$REPO_ROOT/.takt/config.global.yaml" \
  "$REPO_ROOT/takt/config.global.yaml" \
  "$REPO_ROOT/takt/config.yaml"
do
  if [ -L "$HOME/.takt/config.yaml" ] && [ "$(readlink "$HOME/.takt/config.yaml")" = "$legacy" ]; then
    rm -f "$HOME/.takt/config.yaml"
    ln -sf "$GLOBAL_CFG_SRC" "$HOME/.takt/config.yaml"
    echo "Replaced legacy ~/.takt/config.yaml link -> .takt_global/config.yaml"
    break
  fi
done
if [ ! -e "$HOME/.takt/config.yaml" ]; then
  ln -sf "$GLOBAL_CFG_SRC" "$HOME/.takt/config.yaml"
  echo "Linked $HOME/.takt/config.yaml -> $GLOBAL_CFG_SRC"
fi
echo ""

# ~/.gemini にシンボリックリンクを作成
echo "Setting up .gemini..."
mkdir -p "$HOME/.gemini"
link_directory ".gemini" "memories"
link_directory ".gemini" "skills"
echo ""

# ~/.handovers にシンボリックリンクを作成
echo "Setting up .handovers..."
ln -sfn "$REPO_ROOT/.handovers" "$HOME/.handovers"
echo ""

# ~/.issues にシンボリックリンクを作成
echo "Setting up .issues..."
ln -sfn "$REPO_ROOT/.issues" "$HOME/.issues"
echo ""

# ~/.learned にシンボリックリンクを作成
echo "Setting up .learned..."
mkdir -p "$REPO_ROOT/.learned"
ln -sfn "$REPO_ROOT/.learned" "$HOME/.learned"
echo ""

# ~/.config/ai-manifest/.env にシンボリックリンクを作成
echo "Setting up .config/ai-manifest/.env..."
mkdir -p "$HOME/.config/ai-manifest"
ln -sfn "$REPO_ROOT/.env" "$HOME/.config/ai-manifest/.env"
echo ""
