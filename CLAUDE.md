# Repo Instructions for Claude Code

This repository holds a geopolitical/economic risk model (`data/state.json`) rendered
by `dashboard.html`, updated once daily by a scheduled headless run.

## When running the daily update job

Follow `scripts/daily_update_prompt.md` exactly. Do not:
- Touch `dashboard.html` or the JSON schema — only field *values* inside
  `data/state.json` change day to day.
- Push directly to `main`. Always work on a `daily-update-*` branch and open a PR.
- Invent figures. Every numeric update needs a real, named source you actually
  retrieved this run.
- Silently discard the existing changelog. Append, never overwrite.

## When a human is working in this repo interactively

Normal Claude Code behavior applies — you can edit the dashboard, the schema, the
workflow, or the prompt itself if asked. The constraints above apply specifically to
the *unattended scheduled run*, not to interactive sessions with a human present.

## Context

This model was originally built through iterative human-AI analysis (transition
matrix + independent actor dynamics for Israel/Iran/China layered onto a war/economic
cascade). The daily job's purpose is to keep the *inputs* current, not to redo that
analytical work from scratch each day — see the prompt file for what's allowed to
move and by how much.
