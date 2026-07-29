# Iran War Risk Dashboard — Auto-Updating

A daily-refreshed transition-probability model (5 states, Israel/Iran/China actor
dynamics, live economic variables) built from iterative analysis, kept current by a
scheduled Claude Code run that opens a PR each day for human review.

## What's here

```
data/state.json                        # the model's current state — dashboard.html reads this
dashboard.html                         # renders data/state.json, no build step needed
scripts/daily_update_prompt.md         # exact instructions the daily job follows
scripts/run_update.sh                  # wrapper that invokes `claude -p` headlessly
.github/workflows/daily-update.yml     # cron schedule + PR creation
CLAUDE.md                              # repo-level guardrails Claude Code reads automatically
```

## Setup (one-time)

1. Push this folder to a new GitHub repo.
2. In the repo's Settings → Secrets and variables → Actions, add:
   - `ANTHROPIC_API_KEY` — an API key from console.anthropic.com (this uses the API,
     not a Claude.ai subscription, since it's unattended/scheduled automation).
3. Enable GitHub Pages (Settings → Pages → Deploy from a branch → `main`, root) if you
   want a persistent public URL for `dashboard.html`. You'll need `state.json` on
   `main` too, so Pages picks it up after each PR merge.
4. The workflow runs daily at 13:00 UTC by default — edit the cron line in
   `.github/workflows/daily-update.yml` to change that.
5. Test it manually first: Actions tab → "Daily Iran War Risk Model Update" →
   "Run workflow", rather than waiting a day to see if it works.

## The review step is intentional, not a placeholder

Every scheduled run opens a pull request instead of committing to `main` directly.
Nothing publishes until a human merges it. This was a deliberate design choice from
the original analysis this dashboard is built from: the probability judgments in
`transition_matrix` and `actors` are analytical calls, not calculations, and an
unattended process should not be the last check on something this consequential.

## Previewing the dashboard locally

`dashboard.html` fetches `data/state.json` via `fetch()`, which browsers block under
the `file://` protocol. Serve it over local HTTP instead of double-clicking it:

```bash
cd iran-dashboard && python3 -m http.server 8000
# then open http://localhost:8000/dashboard.html
```

## Local testing without waiting for the schedule

```bash
export ANTHROPIC_API_KEY=sk-ant-...
bash scripts/run_update.sh
git diff data/state.json    # review before committing
```

## Known limitations, stated plainly

- The daily job can only move the model as much as `daily_update_prompt.md` allows.
  It's deliberately conservative (small transition-matrix nudges, no schema changes)
  precisely because a fully "re-reason from scratch daily" version would likely
  produce inconsistent day-to-day drift.
- Source reliability is not automatically verified. The `confidence` field on each
  changelog entry is Claude's own self-reported confidence, not an independent check
  — read it critically, not as ground truth.
- This is a judgment-aid, not a forecasting system with a track record. Treat the
  transition matrix ordinally (what's more/less likely relative to other cells), not
  as calibrated point probabilities.
