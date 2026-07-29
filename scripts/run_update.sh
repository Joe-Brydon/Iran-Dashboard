#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT_FILE="$REPO_ROOT/scripts/daily_update_prompt.md"
LOG_FILE="$REPO_ROOT/scripts/last_run.json"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set. Refusing to run." >&2
  exit 1
fi

echo "Running daily update..."

claude -p "$(cat "$PROMPT_FILE")" \
  --output-format json \
  --permission-mode dontAsk \
  --allowedTools "WebSearch,WebFetch,Read,Edit(data/state.json)" \
  --max-turns 40 \
  --max-budget-usd 2.00 \
  > "$LOG_FILE"

echo "Run complete. Output saved to $LOG_FILE"
git -C "$REPO_ROOT" diff --stat data/state.json || true
