# Changelog

## 0.2.0 — 2026-08-05

- **Fork A findings gate** — Fork A (Linear) projects now get the same structural
  findings-triage reliability Fork B's `findings/` folder already had. A `dstack-finding` label
  + Triage status marks an open finding in Linear; `dstack-ticket.md` Step 3 queries for it
  instead of asking the user to remember.
- **`dstack-update`** — installed into every target repo's root alongside the other vendored
  files. Fetches the latest source fresh (a shallow temp clone, no dependency on any
  pre-existing local checkout) and re-runs `install.sh` against itself, using the harness
  recorded in `.dstack-version`. Closes the "how do I actually get updates" gap — previously
  `install.sh` only worked from inside a local checkout of this repo.
- **Issue #1 remedy** — the clobber-risk warning in README.md now names the actual answer
  (repo-specific facts belong in `CLAUDE.md`/Step 1.7, not the vendored files), plus a new
  "Migrating a repo that already had dstack" section (extract → install → backfill front
  matter → split a fat `TODO.md`, with a token-frequency verification check for that last,
  riskiest step).
- **Stated fallbacks for unset prep answers** — `dstack-ticket.md` and the retro-suggestion
  logic (`dstack-yolo.md` Step 8) now explicitly document what happens when a prep question is
  unset in `notes.md` front matter (matching each question's Step 1.5 recommended default),
  parity with the fallback `dstack-yolo.md` already documented for `risk_tolerance`.

## 0.1.0 — 2026-07-25

Initial standalone release. Prior to this, dstack existed only as hand-copied files across
several repos (`wake`, `vanedoc`, `cairn`, `kairos`) with no shared source of truth and visible
drift between copies. This version consolidates those into one canonical spec + adapter split
and adds:

- **Two-resolution ticket detail** — `TODO.md`/the doc skeleton stays one line per ticket;
  deep scope/acceptance/re-spec content moves to `tickets/<id>.md`, created as stubs at
  DAG-generation time and filled in only when picked. Fixes the "single file balloons to
  hundreds of lines" failure mode observed in a real production project's dstack history.
- **Findings absorption** — a `findings/` convention plus a mandatory pre-step (in
  `dstack-ticket`/`dstack-yolo`) that scans for untriaged discoveries before the next ticket
  pick, so freestanding audits/reviews can't sit orphaned indefinitely the way they were
  observed to in that same project's history.
- **`/dstack-retro`** — a new command that reads a project's real git/ticket/findings history
  (not the aspirational plan) and produces a retrospective, feeding cross-project learnings
  back into `meta/process-notes.md`.
- **Prep questions** (team shape, risk tolerance, resumability cadence, retro cadence) — asked
  once per new project, parameterizing fork recommendation, plan-gate cadence, session-recap
  behavior, and retro timing.
- **`spec/` vs `harnesses/` split** — the process spec is harness-agnostic prose; only
  `harnesses/claude-code/` exists as a built adapter today, with `harnesses/_template/`
  documenting what a future adapter needs to provide.
- **`install.sh`** — a real, if intentionally minimal, install mechanism (plain copy + version
  stamp) replacing ad hoc hand-copying between repos.
- Fixed two dangling references carried over from the pre-standalone copies: a
  `doc/dstack/notes/` reference-example path that never existed anywhere, and reliance on an
  undocumented `/plan` command that was never actually defined (both now correctly point at
  `examples/reference-project/` and "enter plan mode directly," respectively).
