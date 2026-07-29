#!/usr/bin/env bash
# Runs the daily update as a headless Claude Code job.
# Expects ANTHROPIC_API_KEY to be set in the environment (via GitHub Actions secret
# or your local shell). Intended to be called from CI, not run interactively.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT_FILE="$REPO_ROOT/scripts/daily_update_prompt.md"
LOG_FILE="$REPO_ROOT/scripts/last_run.json"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set. Refusing to run." >&2
  exit 1
fi

echo "Running daily update at $(date -u +%Y-%m-%dT%H:%M:%SZ)..."

# --output-format json gives structured output (session id, usage, cost) for logging.
# --allowedTools scopes this run to web search/fetch and editing state.json only —
# it should not need general shell or arbitrary file-edit access.
claude -p "$(cat "$PROMPT_FILE")" \
  --output-format json \
  --allowedTools "WebSearch,WebFetch,Read,Edit(data/state.json)" \
  > "$LOG_FILE"

echo "Run complete. Structured output saved to $LOG_FILE"
echo "Diff of data/state.json:"
git -C "$REPO_ROOT" diff --stat data/state.json || true
