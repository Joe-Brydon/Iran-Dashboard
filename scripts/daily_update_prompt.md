# Daily Update Task — Iran War Risk Dashboard

You are running unattended, once per day, with no human watching this specific run.
Your job is narrow: update `data/state.json` based on what has genuinely changed in the
last 24-48 hours, and nothing else. Do not redesign the model, add new states, or rewrite
the actor profiles unless a change is substantively justified by new information.

## Step 1 — Research (scale to what's actually moving)

Check, in this order, and stop early if a category has no material change:

1. **War status**: any new strikes, ceasefires, MoUs, breakdowns, or statements from
   Trump, Iran's government, or CENTCOM in the last 48 hours.
2. **Oil & physical supply**: Brent/WTI price, any EIA data on US SPR or commercial
   inventory levels, OPEC+ spare capacity commentary, Houthi/Bab al-Mandeb status,
   Hormuz transit reports.
3. **Rates & credit**: any Fed statements or meeting outcomes, 10-year Treasury yield,
   any private-credit/BDC stress reporting, AI-capex commentary from hyperscaler
   earnings or BIS/IMF releases.
4. **The four actors**: any material Israeli political development (coalition,
   election polling, Netanyahu-Trump relationship), any Iranian leadership/regime
   stability news (Mojtaba Khamenei, IRGC factional activity, protests), any Chinese
   diplomatic or economic posture change (Wang Yi statements, oil import data,
   US-China relationship signals), and any US domestic political development
   affecting Trump's freedom of action (post-midterm House control, War Powers
   Resolution activity, Pentagon/CENTCOM readiness or interceptor-stock reporting).
5. **Taiwan Strait tension**: any new Chinese military activity (live-fire drills,
   coastguard patrols, PLA-Russia joint exercises), Taiwan defense-budget or
   legislative developments, or chip-fab (TSMC) exposure news. This is tracked as an
   independent watch item, not yet wired into the transition matrix as a numeric
   input — do not invent a linkage between Taiwan events and the five war states
   unless something explicitly connects them (e.g., a chip-supply shock tied
   directly to the Iran war's energy effects on Taiwanese fabs, which does belong in
   `ai_capex_credit` instead).

Use no more than ~15-20 searches total. If nothing material changed in a category,
say so explicitly in the changelog rather than inventing a cosmetic edit.

## Step 2 — Update rules for `data/state.json`

- **`economic_snapshot`**: update numeric fields directly from source data (EIA, FRED,
  or a reputable financial news source that cites the underlying figure). Do not
  estimate or interpolate — if you can't find a real number, leave the old one and
  note it as stale in the changelog.
- **`live_variables`**: update `status` and `detail` only when the underlying
  situation has actually moved (e.g., the Fed decision resolves, a new AI-sector
  stress signal emerges). Update `last_checked` regardless.
- **`war_cycle_history`**: only append a new entry if a genuine cycle transition
  occurred (a ceasefire, a breakdown, a new pause) — not for every strike.
- **`current_state_estimate`**: you may move this between states I-V, but you must
  write a one-sentence rationale citing what changed. Do not move it more than one
  state away from the prior estimate in a single day without an extraordinary,
  clearly-cited justification (e.g., a confirmed dual-chokepoint closure).
- **`transition_matrix`**: treat these as slow-moving. Do not adjust more than 2-3
  cells per day, and only by a few percentage points, unless something structurally
  significant happened (a state actor's stance genuinely changed, not just a news
  cycle). Rebalance each row so it still sums to 1.0 after any edit.
- **`actors`**: update `lean_pct` or the text fields only on real news about that
  actor specifically. Do not touch an actor's profile because of war news alone —
  the whole point of modeling them independently is that they don't move in lockstep
  with the war. This now includes `us` (Trump administration/Congress dynamics) —
  hold it to the same standard: only update on genuine US-domestic-political news,
  not on every war headline.

## Step 3 — Always append to `meta.changelog`

Every run adds exactly one entry:
```json
{
  "date": "YYYY-MM-DD",
  "summary": "Plain-language summary of what changed and why, or 'No material change' if nothing did.",
  "confidence": "high | moderate | low",
  "human_reviewed": false
}
```
Use `"confidence": "low"` whenever a figure comes from a single source, an anonymous
official, or a source with an obvious incentive to shape the number (this mirrors a
gap flagged in the analysis this dashboard is built from — do not silently upgrade
confidence just because a number is convenient).

## Step 4 — Output

Do not push to `main` directly. Create a branch named `daily-update-YYYY-MM-DD`,
commit the updated `data/state.json`, and open a pull request titled
`Daily update: YYYY-MM-DD` with the changelog entry as the PR description. A human
merges it. This is a deliberate guardrail, not a limitation to work around.

## Hard limits

- Do not add, remove, or rename states, actors, or top-level JSON keys.
- Do not editorialize in `state.json` beyond the existing field structure.
- Do not fetch or cite sources you cannot name (no "reports suggest" without a
  specific outlet).
- If you are not confident enough to update a field, leave it unchanged and say so —
  a stale-but-honest number is better than a confident-but-fabricated one.
