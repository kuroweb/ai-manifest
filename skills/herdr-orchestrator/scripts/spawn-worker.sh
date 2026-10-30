#!/usr/bin/env bash
# ワーカー用のタブを作り、ワーカーエージェントを起動する。
# 使い方: spawn-worker.sh [--cwd <ディレクトリ>] <ワーカー名> <エージェントの種類> [エージェントの引数...]
# 出力: {"name", "kind", "cwd", "tab_id", "pane_id", "status"} のJSON
set -euo pipefail

if [ "${HERDR_ENV:-}" != 1 ]; then
  echo "herdrの管理下のペインで実行していない" >&2
  exit 1
fi

cwd="$PWD"
if [ "${1:-}" = --cwd ]; then
  cwd="${2:?--cwd にディレクトリを指定する}"
  shift 2
fi
if [ ! -d "$cwd" ]; then
  echo "ディレクトリが無い: $cwd" >&2
  exit 1
fi
cwd="$(cd "$cwd" && pwd)"

name="${1:?ワーカー名を指定する}"
kind="${2:?エージェントの種類を指定する}"
shift 2

created="$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$cwd" --label "$name" --no-focus)"
tab_id="$(jq -r '.result.tab.tab_id' <<<"$created")"
pane_id="$(jq -r '.result.root_pane.pane_id' <<<"$created")"
# 起動に失敗したら、作ったタブを残さない
trap 'herdr tab close "$tab_id" >/dev/null' EXIT

# 作ったばかりのペインはシェルの起動前で agent_pane_busy になるため、少し待って再試行する
status=ready
for _ in $(seq 20); do
  if err="$(herdr agent start "$name" --kind "$kind" --pane "$pane_id" -- "$@" 2>&1 >/dev/null)"; then
    break
  fi
  if grep -q '"agent_not_ready"' <<<"$err"; then
    # 起動時のダイアログで止まっている。名前は残るので、呼び出し側が画面を読んで対応する
    status=blocked
    err=""
    break
  fi
  if ! grep -q '"agent_pane_busy"' <<<"$err"; then
    echo "$err" >&2
    exit 1
  fi
  sleep 0.5
done
if [ -n "$err" ]; then
  echo "$err" >&2
  exit 1
fi

# herdrが認識しないフォルダの信頼確認（cursorなど）は idle と判定されるため、画面から見つける。
# ダイアログ内で文が折り返されるので、改行と枠線をつないでから照合する
if [ "$status" = ready ] &&
  herdr agent read "$name" --source visible | tr '\n│' '  ' | tr -s ' ' |
  grep -qiE 'trust (this|the) (workspace|folder|directory)'; then
  status=blocked
fi

trap - EXIT
jq -n --arg name "$name" --arg kind "$kind" --arg cwd "$cwd" --arg tab_id "$tab_id" --arg pane_id "$pane_id" \
  --arg status "$status" \
  '{name: $name, kind: $kind, cwd: $cwd, tab_id: $tab_id, pane_id: $pane_id, status: $status}'
