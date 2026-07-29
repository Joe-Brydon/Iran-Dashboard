#!/usr/bin/env bash
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT_FILE="$REPO_ROOT/scripts/daily_update_prompt.md"
LOG_FILE="$REPO_ROOT/scripts/last_run.json"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set. Refusing to run." >&2
  exit 1
fi

echo "Running daily update..."

claude -p "$(cat "$PROMPT_FILE")" \
  --output-format stream-json \
  --verbose \
  --permission-mode dontAsk \
  --allowedTools "WebSearch,WebFetch,Read,Edit(data/state.json)" \
  --max-turns 40 \
  --max-budget-usd 2.00 \
  | tee "$LOG_FILE"

CLAUDE_EXIT=${PIPESTATUS[0]}
echo "Claude Code process exit status: $CLAUDE_EXIT"

if git -C "$REPO_ROOT" diff --quiet -- data/state.json; then
  echo "No changes were made to data/state.json."
  if [ "$CLAUDE_EXIT" -ne 0 ]; then
    echo "No changes AND a non-zero exit -- treating this as a genuine failure."
    exit 1
  fi
  echo "No material change today -- treating as a successful no-op run."
  exit 0
else
  echo "data/state.json was updated -- proceeding regardless of exit code $CLAUDE_EXIT."
  git -C "$REPO_ROOT" diff --stat data/state.json
  exit 0
fi
