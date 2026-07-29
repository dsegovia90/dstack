# Repo Profile — digest-emails host app

_Illustrative: Step 1.7 output for this reference project. Prefer putting durable repo facts
into `CLAUDE.md` when you can — this file exists only for the dimensions that didn't already
have a home there when this project started._

## Coverage

| Dimension | Source |
|---|---|
| Stack (runtime, language, framework) | `CLAUDE.md` — see its "Stack" section |
| Conventions (file layout, naming) | `CLAUDE.md` — see its "Conventions" section |
| Auth pattern | **this file**, below — not yet documented in `CLAUDE.md` |
| Domain model overview | **this file**, below — not yet documented in `CLAUDE.md` |
| Test framework | `CLAUDE.md` — see its "Testing" section |

`CLAUDE.md` already covered three of five dimensions when Step 1.7 ran. Rather than block on a
larger `CLAUDE.md` rewrite mid-project, the user chose to consolidate the two missing
dimensions here and fold them into `CLAUDE.md` later — hence `repo_profile_location: mixed` in
`notes.md`'s front matter, instead of `claude-md` or `dstack-file`.

## Auth pattern

Session-based auth via the host app's existing `sessions` table; `req.user` is populated by
middleware upstream of every route this project touches. No new auth surface needed for the
digest feature — `digest/unsubscribe.ts`'s pause link is the one deliberate exception, and it's
*not* behind session auth by design (see `notes.md` Pass 2 — "no login required").

## Domain model overview

Existing entities relevant to this project: `users` and `savedItems` (what users bookmark).
This project adds two new tables — `digestPreferences`, `digestSends` — documented in full in
`notes.md`'s Pass 2 "Data model" section, not repeated here.

---

_Durable facts only. Feature-specific research — which exact files, which queries, which
policies a given ticket touches — happens scoped to that ticket instead of living here; see
`llm-coding-workflow.md`'s "Grounding" section for the reasoning behind the split._
