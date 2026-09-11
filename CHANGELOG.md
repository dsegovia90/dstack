# Changelog

## 0.4.0 — unreleased

_See `meta/roadmap-0.4.md` for the full list of what's planned for this release and the
status of each item. Entries land here one PR at a time as each ships._

- **Diagrams — a tool, and one rigid convention.** Two separate things. **(A)** A fifth prep
  question, `diagrams: mermaid | ascii | none`, sets the notation Pass 2 uses when a section
  is shaped enough to earn a picture (a data model with three or more related tables, a
  multi-hop request path, a component map, a state machine); the rule is "draw when the
  picture is shorter than the paragraph it replaces," and the prose stays the decision.
  **(B)** The Pass 3 DAG is now *always* drawn in one fixed Mermaid shape — `flowchart TD`,
  one subgraph per phase, one edge per `blocked-by`, four verbatim `classDef` status classes
  whose node class *is* the checkbox state — and re-rendered in the same commit as every
  ticket state change, in both `notes.md` and `TODO.md`. The ticket one-liners remain the
  source of truth; the diagram is derived. The reference project's ASCII DAGs are converted.
  See `llm-coding-workflow.md`'s new "Diagrams" section.

## 0.3.0 — 2026-08-05

- **Design posture (Step 1.8)** — dstack previously had no place to affirmatively decide how
  much visual/UX rigor a project needs; it either got invented silently during Pass 2 or
  ignored entirely. New grounding step, same shape as the repo profile (Step 1.7): record
  whether the project has a visual surface at all, and if so whether an existing design
  system governs it, it's deliberately utility-only, or one needs establishing now before
  Pass 2 goes far. Persists as `design_posture` / `design_ground_rules_location` in `notes.md`
  front matter. Tickets touching UI get a non-blocking 🎨 marker (distinct from 🚧 — it doesn't
  pause autonomous execution) prompting a design-ground-rules check before close, surfaced in
  `TODO.md`'s status legend and both `dstack-ticket`/`dstack-yolo`. See
  `llm-coding-workflow.md`'s "Design posture" section for the full reasoning.
- **Open questions ledger** — Pass 1's "open questions carried to Pass 2" was loose prose with
  no way to distinguish a genuinely resolved question from an assumed one; the reference
  project's own `D4` blocker (a scheduler decision that "was never resolved," discovered only
  once it blocked a ticket) was exactly this failure mode. Open questions are now ledger rows
  (id, question, raised-in-pass) that must resolve to exactly one status before their owning
  pass finishes: **Resolved** (requires a citation to where the decision actually lives),
  **Deferred** (requires a named pass or ticket, not "later"), or **Dropped** (requires a
  reason). A **required confirmation pass** — run before starting Pass 2/Pass 3, and when a
  session resumes an existing project — re-opens every inherited "Resolved" citation and checks
  it actually answers the question, rather than trusting the label. Mirrors the findings-triage
  forcing function, aimed at claims instead of code. See `llm-coding-workflow.md`'s "Open
  questions" section; `examples/reference-project/notes.md` and `tickets/D4.md` now show the
  full lifecycle (raised → deferred → reconfirmed twice → arrived at its named target).

## 0.2.0 — 2026-08-05

- **Fork A findings gate** — Fork A (Linear) projects now get the same structural
  findings-triage reliability Fork B's `findings/` folder already had. Findings use the exact
  same in-repo `doc/dstack/<project>/findings/` convention for both forks; `dstack-ticket.md`
  Step 3 scans it before letting a ticket be picked, instead of asking the user to remember.
  Linear itself only ever sees the *outcome* of a triage decision (a new linked ticket, or a
  comment on an existing one) — never dstack's own pre-ticket bookkeeping.
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
