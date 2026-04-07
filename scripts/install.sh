#!/usr/bin/env bash
set -euo pipefail

# リポジトリルート（.claude, .cursor 等のソースがあるディレクトリ）
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_BASE="$SCRIPT_DIR/backup/$(date +%Y%m%d%H%M%S)"

shopt -s dotglob nullglob

path_exists() {
  local path="$1"
  [ -e "$path" ] || [ -L "$path" ]
}

backup_path() {
  local dest="$1"
  local backup_dir="$2"
  local name="$3"

  mkdir -p "$backup_dir"
  echo "Backing up existing $name to $backup_dir"
  cp -R "$dest" "$backup_dir/$name.$(date +%Y%m%d%H%M%S)"
}

# ファイルのシンボリックリンクを作成する関数
link_file() {
  local target_dir="$1"
  local name="$2"
  local src="$REPO_ROOT/$target_dir/$name"
  local dest="$HOME/$target_dir/$name"
  local backup_dir="$BACKUP_BASE/$target_dir"

  if [ ! -e "$src" ]; then
    echo "Warning: Source file does not exist: $src (skipping)"
    return 0
  fi

  if path_exists "$dest"; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "Already linked: $dest -> $(readlink "$dest")"
    else
      backup_path "$dest" "$backup_dir" "$name"
      ln -sfn "$src" "$dest"
      echo "Linked $dest -> $src"
    fi
  else
    ln -sfn "$src" "$dest"
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

  if [ ! -d "$src" ]; then
    echo "Warning: Source directory does not exist: $src (skipping)"
    return 0
  fi

  if path_exists "$dest"; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "Already linked: $dest -> $(readlink "$dest")"
    else
      backup_path "$dest" "$backup_dir" "$name"
      rm -rf "$dest"
      ln -sfn "$src" "$dest"
      echo "Linked $dest -> $src"
    fi
  else
    ln -sfn "$src" "$dest"
    echo "Linked $dest -> $src"
  fi
}

ensure_directory() {
  local dir="$1"
  local backup_dir="$2"
  local label="$3"

  if [ -L "$dir" ]; then
    if [[ "$(readlink "$dir")" == "$REPO_ROOT/"* ]]; then
      echo "Replacing repo-managed symlink with directory: $dir"
      rm "$dir"
    else
      backup_path "$dir" "$backup_dir" "$label"
      rm "$dir"
    fi
  elif [ -e "$dir" ] && [ ! -d "$dir" ]; then
    backup_path "$dir" "$backup_dir" "$label"
    rm -f "$dir"
  fi

  mkdir -p "$dir"
}

link_entries() {
  local tool_dir="$1"
  local entry_name="$2"
  local repo_entry_dir="$REPO_ROOT/$tool_dir/$entry_name"
  local home_tool_dir="$HOME/$tool_dir"
  local home_entry_dir="$home_tool_dir/$entry_name"
  local backup_dir="$BACKUP_BASE/$tool_dir"
  local src
  local dest
  local name
  local target

  if [ ! -d "$repo_entry_dir" ]; then
    echo "Warning: Entry directory does not exist: $repo_entry_dir (skipping)"
    return 0
  fi

  mkdir -p "$home_tool_dir"
  ensure_directory "$home_entry_dir" "$backup_dir" "$entry_name"

  for dest in "$home_entry_dir"/*; do
    [ -e "$dest" ] || [ -L "$dest" ] || continue
    [ -L "$dest" ] || continue

    name="$(basename "$dest")"
    target="$(readlink "$dest")"

    case "$target" in
      "$repo_entry_dir"/*)
        if [ ! -e "$repo_entry_dir/$name" ] || [ "$target" != "$repo_entry_dir/$name" ]; then
          rm "$dest"
          echo "Removed stale $entry_name link: $dest"
        fi
        ;;
    esac
  done

  for src in "$repo_entry_dir"/*; do
    [ -e "$src" ] || continue

    name="$(basename "$src")"
    dest="$home_entry_dir/$name"

    if path_exists "$dest"; then
      if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Already linked $entry_name: $dest -> $(readlink "$dest")"
      else
        backup_path "$dest" "$backup_dir/$entry_name" "$name"
        rm -rf "$dest"
        ln -s "$src" "$dest"
        echo "Linked $entry_name: $dest -> $src"
      fi
    else
      ln -s "$src" "$dest"
      echo "Linked $entry_name: $dest -> $src"
    fi
  done
}

# ~/.claude にシンボリックリンクを作成
echo "Setting up .claude..."
mkdir -p "$HOME/.claude"
link_entries ".claude" "agents"
link_entries ".claude" "rules"
link_entries ".claude" "skills"
link_entries ".claude" "scripts"
link_file ".claude" "settings.json"
echo ""

# ~/.cursor にシンボリックリンクを作成
echo "Setting up .cursor..."
mkdir -p "$HOME/.cursor"
link_entries ".cursor" "agents"
link_entries ".cursor" "rules"
link_entries ".cursor" "skills"
link_entries ".cursor" "scripts"
link_directory ".cursor" "hooks"
link_file ".cursor" "mcp.json"
link_file ".cursor" "hooks.json"
echo ""

# ~/.codex にシンボリックリンクを作成
echo "Setting up .codex..."
mkdir -p "$HOME/.codex"
link_entries ".codex" "agents"
link_entries ".codex" "memories"
link_entries ".codex" "skills"
echo ""

# ~/.gemini にシンボリックリンクを作成
echo "Setting up .gemini..."
mkdir -p "$HOME/.gemini"
link_entries ".gemini" "memories"
link_entries ".gemini" "skills"
link_directory ".gemini" "policies"
link_file ".gemini" "settings.json"
echo ""

# ~/.takt/config.yaml ← リポの .takt_global/config.yaml（GlobalConfig 正本）
echo "Setting up .takt..."
mkdir -p "$HOME/.takt"
ln -sfn "$REPO_ROOT/.takt_global/config.yaml" "$HOME/.takt/config.yaml"
echo "Linked $HOME/.takt/config.yaml -> $REPO_ROOT/.takt_global/config.yaml"
echo ""

# ~/.handovers にシンボリックリンクを作成
echo "Setting up .handovers..."
ln -sfn "$REPO_ROOT/.handovers" "$HOME/.handovers"
echo ""

# ~/.issues にシンボリックリンクを作成
echo "Setting up .issues..."
ln -sfn "$REPO_ROOT/.issues" "$HOME/.issues"
echo ""

# ~/.plans にシンボリックリンクを作成
echo "Setting up .plans..."
ln -sfn "$REPO_ROOT/.plans" "$HOME/.plans"
echo ""

# ~/.learned にシンボリックリンクを作成
echo "Setting up .learned..."
ln -sfn "$REPO_ROOT/.learned" "$HOME/.learned"
echo ""

# ~/.config/ai-manifest/.env にシンボリックリンクを作成
echo "Setting up .config/ai-manifest/.env..."
mkdir -p "$HOME/.config/ai-manifest"
ln -sfn "$REPO_ROOT/.env" "$HOME/.config/ai-manifest/.env"
echo ""
