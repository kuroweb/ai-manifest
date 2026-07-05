#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "$REPO_ROOT"

GENERATED_SKILL_DIRS=(
  "$HOME/.cursor/skills"
  "$HOME/.codex/skills"
  "$HOME/.claude/skills"
)

AGENTS=(
  "cursor"
  "codex"
  "claude-code"
)

for dir in "${GENERATED_SKILL_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    rm -rf "$dir"
    echo "Removed generated directory: $dir"
  else
    echo "Skip remove: $dir"
  fi
done

for agent in "${AGENTS[@]}"; do
  echo "Installing skills for agent: $agent"
  gh skill install . --from-local --all --agent "$agent" --scope user --force
done
