#!/bin/bash
# 標準入力からJSON形式のデータを読み込む
input=$(cat)

# DialDeck 向けに使用量（rate_limits）を書き出す
rate_limits=$(printf '%s' "$input" | jq -c '.rate_limits // empty')
if [ -n "$rate_limits" ]; then
    usage_dir="$HOME/Library/Application Support/DialDeck"
    mkdir -p "$usage_dir" &&
        usage_tmp=$(mktemp "$usage_dir/claude-rate-limits.json.XXXXXX") &&
        { printf '%s\n' "$rate_limits" > "$usage_tmp" &&
            mv "$usage_tmp" "$usage_dir/claude-rate-limits.json"; }
fi

# 各種情報を取得
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // "0"')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // "0"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')
duration_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // "0"')

# レイテンシを秒に変換（小数点1桁）
latency=$(echo "scale=1; $duration_ms / 1000" | bc)

# ステータスライン表示
echo "${model} | ${input_tokens}/${output_tokens} tokens | Context: ${used}% used | ${latency}s"
