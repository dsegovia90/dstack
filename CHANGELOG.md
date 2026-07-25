# Changelog

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
