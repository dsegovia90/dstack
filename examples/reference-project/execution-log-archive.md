# Digest Emails — Execution log archive

Full, append-only history. `TODO.md` keeps only the most recent ~10 lines inline for a warm
session; older entries move here and are never pruned. `/dstack-retro` reads this file in full;
day-to-day ticket picking only ever needs the tail in `TODO.md`.

- Project started, Pass 1 written — 2026-06-01.
- Pass 2 written — 2026-06-01.
- Pass 3 written, DAG generated, `tickets/` stubs + `findings/` folder created — 2026-06-02.
- D1 picked (root, phase 1) — 2026-06-02.
- D1 done — re-spec: added `timezone` per-user rather than assuming a single app-wide send
  time, after realizing during the micro-plan that "Monday morning" means different things
  across users. See `tickets/D1.md`. — 2026-06-03.
- D2 picked (phase 2, parallel with D3) — 2026-06-03.
