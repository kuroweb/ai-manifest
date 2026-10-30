#!/usr/bin/env bash
# ワーカーが作業を止めるまで待つ。
# 使い方: wait-worker.sh <ワーカー名> [タイムアウト秒]
# 出力: {"name", "status"} のJSON。status は idle / done / blocked / unknown / timeout
set -euo pipefail

name="${1:?ワーカー名を指定する}"
timeout="${2:-1800}"

# codex などは作業の途中でも一瞬 done になるため、working 以外が続いたときだけ止まったとみなす
stable_secs=5

status=timeout
quiet=0
deadline=$((SECONDS + timeout))
while [ "$SECONDS" -lt "$deadline" ]; do
  current="$(herdr agent get "$name" | jq -r '.result.agent.agent_status')"
  if [ "$current" = working ]; then
    quiet=0
  else
    quiet=$((quiet + 1))
    if [ "$quiet" -ge "$stable_secs" ]; then
      status="$current"
      break
    fi
  fi
  sleep 1
done

jq -n --arg name "$name" --arg status "$status" '{name: $name, status: $status}'
