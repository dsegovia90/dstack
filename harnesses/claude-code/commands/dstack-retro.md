---
description: Produce a retrospective on a dstack project's real history — completions vs. plan, re-specs, blockers, findings, and what it suggests about improving the process itself
argument-hint: "[project]"
---

# dstack-retro: read the project's real history, not the plan

You are producing a **retrospective** for a dstack project — an honest account of how it
actually unfolded, read from primary sources (git history, the ticket files, findings, and for
Linear projects the issue/comment history), not from the aspirational plan. This is always a
**human-confirmed** artifact: you produce it, the human reviews it, nothing here rewrites
process or tickets automatically.

Read `llm-coding-workflow.md`'s "Retrospective — closing the loop on the loop" section first —
it explains why this exists and what a retro is for: a project-scoped honest account, plus
process-level observations that, if they recur across multiple projects, are the actual
evidence for whether `llm-coding-workflow.md` itself should change.

## 1. Pick the project

If `$ARGUMENTS` names a folder under `doc/dstack/`, that's the project — state which and move
on. Otherwise list projects under `doc/dstack/`. If exactly one, use it (state which). If
several, ask. An argument that matches nothing: say so, then ask.

## 2. Gather sources — detect the fork first

**Fork B (local `TODO.md` present):**
- `TODO.md` — current skeleton state, phases, roots.
- `execution-log-archive.md` (if present) + the inline Execution log in `TODO.md` — the full
  append-only history of ticket completions and re-specs.
- `tickets/*.md` — every ticket's re-spec narrative (this is where the real divergence detail
  lives — read all of them, not just the open ones).
- `findings/*.md` — every finding's `status` and, for dismissed ones, the reason recorded.
- `git log` filtered by trailer: `git log --all --grep "Dstack-Project: <project>"` (and
  `Dstack-Ticket:` per ticket if you need commit-level timing) — this is what makes project
  history findable even after a working branch has been merged and deleted.

**Fork A (Linear, `README.md`/`notes.md` with `KAI-####` links):**
- The doc's ticket set + DAG section for the skeleton.
- Linear issue history **live via MCP** — for each ticket, the issue's current description
  plus its full comment thread (this is where re-spec narratives live in this fork — see
  `SKILL.md` Step 3's Fork A re-spec convention). No local export step; if MCP access isn't
  available when this runs, say so plainly rather than producing a retro from stale/partial data.

**Both forks:** `git log -p -- doc/dstack/<project>/notes.md` — the doc's own edit history is
a timeline of how understanding evolved across Pass 1 → 2 → 3, independent of ticket execution.
Diff each revision to see what changed and roughly when, relative to ticket completions.

## 3. Produce the retro

Write `doc/dstack/<project>/retros/<date>-retro.md` with these sections, every claim traceable
to something you actually read in Step 2 — no re-deriving or guessing at what "probably"
happened:

- **Timeline** — ticket completions in actual order/dates, laid against the originally planned
  phases from Pass 3. Where the real order or pace diverged from the plan, say so plainly.
- **Divergence log** — every re-spec found (ticket-scoped, from `tickets/*.md` or Linear
  comments), each as: what was planned → what actually shipped → why, with a date/commit or
  Linear-comment reference. Pull this straight from the sources; don't summarize away the
  specifics.
- **Blockers** — every `[!]` (or Linear-equivalent) hit, what caused it, and how (or whether)
  it resolved.
- **Findings** — how many were absorbed (folded into a ticket vs. spawned as a new one) vs.
  dismissed, and for dismissed ones, whether the recorded reason still holds up in hindsight.
- **DAG growth** — tickets added mid-execution that weren't in the original Pass-3 set. Treat
  this list as data about where the macro planning passes underestimated the work, not as a
  problem to explain away.
- **Process observations** — compare this project's actual chunk sizes, warm/cold session
  pattern, blocker frequency, and re-spec timeliness (same-commit? same-day? multi-week?)
  against what `llm-coding-workflow.md` predicts. Name concrete, specific divergences — "chunk
  sizes ran long on tickets touching the DB layer" is useful; "planning could be better" is not.

## 4. Hand back to the human

Present the retro's **process observations** section directly in the conversation (not just
buried in the file) and explicitly suggest: if anything here seems like it'd recur on future
projects rather than being one-off, it belongs in the canonical dstack toolkit repo's
`meta/process-notes.md` (wherever that repo is checked out — this project's `.dstack-version`
file, if present, records which install it came from). Offer to draft the excerpt, but **do
not write into the toolkit repo yourself** — that file is deliberately human-curated, pasted in
deliberately after the human decides a pattern is real across more than this one project, not
auto-merged by this command.
