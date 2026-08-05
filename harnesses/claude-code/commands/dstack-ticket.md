---
description: Pick the next sensible dstack ticket from a project's DAG and confirm with the user
---

# dstack: choose the next ticket

You are helping pick the **next ticket to work on** for a "dstack" project, following our
planning-first engineering process. Do this conversationally — propose, then let the user
confirm, correct, or discuss before any code is written.

## 1. Internalize the process

Read **`llm-coding-workflow.md`** (repo root) and treat it as our engineering process. Key
points for this command:

- One living design doc per project, advanced through Passes 1–3; tickets are satellites
  chained into a **dependency DAG** (`blocked-by` / `blocks`).
- **Roots** = tickets with no unmet dependencies → where work can start.
- **Independent branches** = parallelizable work.
- Picking a ticket means picking a node whose upstream dependencies are all **done**.
- The per-ticket Pass-4 micro-plan (plan mode) happens *after* this command, once the
  ticket is confirmed — do **not** start implementing here.
- Pass 3 forks ticketing two ways (see `SKILL.md` Step 3) — **Fork A (Linear)** or
  **Fork B (local `TODO.md`)**. This command works for either; it auto-detects which one a
  project uses rather than assuming Linear. Do not ask the user which fork — detect it from
  the files present.
- Prep-question answers (`team_shape`, `risk_tolerance`, `resumability_cadence`,
  `retro_cadence`) live in the project's `notes.md` front matter — read them; they shape how
  this command presents its pick (see Steps 4–5).

## 2. Pick the project

List the projects under **`doc/dstack/`** (each subdirectory is a project).

- If there is exactly **one**, use it (state which one you're using).
- If there are **multiple**, ask the user which project we're working on. Do not guess.

## 3. Scan for un-triaged findings — before anything else

An un-triaged finding must be surfaced **before** computing the eligible frontier below.
Present each one and get the user to choose one of the three legal outcomes — fold into an
existing ticket, spawn a new ticket, or dismiss with a one-line reason. How to check, and what
each outcome means mechanically, depends on the ticketing fork:

- **Fork B (local `TODO.md`)** — check the project's `findings/` folder for anything with
  `status: new`.
  1. **Fold into an existing ticket** — edit `tickets/<id>.md`, citing the finding, flip
     `status` to `absorbed`.
  2. **Spawn a new ticket** — new line in `TODO.md` + new `tickets/<id>.md` stub, wired into
     `blocked-by`/`blocks`, flip `status` to `absorbed`.
  3. **Dismiss** — record a one-line reason in the finding file itself, flip `status` to
     `dismissed`.

- **Fork A (Linear)** — query Linear for open findings: issues in **Triage** status carrying
  the **`dstack-finding`** label, scoped to this project's own Linear project (per its
  `notes.md`/`README.md` Pass-3 record — don't default to another project's team/project ID).
  Also surface any unscoped (no-project) `dstack-finding` issues in Triage — for those, "does
  this belong to this project?" is the first triage question.
  1. **Fold into an existing ticket** — leave a Linear **comment** on the target ticket citing
     the finding (comment first, never silently overwrite the description — same discipline as
     the re-spec rule in Step 4 below), then mark the finding issue **Duplicate** of that
     ticket.
  2. **Spawn a new ticket** — create a new linked Linear issue in the DAG (wired via
     `blockedBy`/`blocks`, per Step 4 below), then move the finding out of Triage into
     **Backlog**/**On-deck** with the project set.
  3. **Dismiss** — move the finding to **Canceled**, with a one-line reason left as a comment.

Do not proceed to Step 4 while any finding is still open (Fork B: `status: new`; Fork A:
**Triage**) — this is a hard gate, not a suggestion. If there are none, say so briefly and
continue.

## 4. Detect the ticketing fork, then read the DAG

Inside the project folder, check what's actually there:

- **`TODO.md` present → Fork B (local).** This is the default for solo/lighter-weight
  projects in this repo. Read `TODO.md` directly:
  - The **Tickets** section — one line per ticket (skeleton only; full detail lives in
    `tickets/<id>.md`), checkbox (`[ ]`/`[~]`/`[x]`/`[!]`, plus 🚧 for human-gated infra steps),
    with `blocked-by` / `blocks`.
  - The **DAG** section — the diagram, declared **roots**, and **Phases** table.
  - Checkboxes are a **hint, not ground truth** — status drifts. Before treating an upstream
    ticket as done, sanity-check against the **code on disk** (does the file/dependency/route
    the ticket describes actually exist?), not just the checkbox. There is no Linear lookup
    in this fork — skip it entirely, and never treat a missing Linear issue as a blocker here.
  - A 🚧-tagged ticket needing external infra is still eligible to be *picked and discussed* —
    just flag the human-gate plainly when presenting it (see Step 6).
  - Only read the **chosen** ticket's `tickets/<id>.md` in full once it's picked — for
    presenting alternatives in Step 6, the one-liners in `TODO.md` are enough; don't burn
    context pre-reading every candidate's deep file.

- **No `TODO.md`, but a `README.md` with `KAI-####` links → Fork A (Linear).** Open the
  project's `README.md`/`notes.md` (the master living design doc) and find:
  - The **§ Ticket set** — checkboxes with `KAI-####` (or equivalent) Linear links and a
    one-line title each — no inline scope/acceptance; Linear is the sole source of that detail.
  - The **Execution phasing & dependency DAG** section — edges, roots, topological phases.
  - Treat checkboxes as a hint, not ground truth — verify real state via `linear:get_issue`.
    Use the Linear team/project referenced in *this project's own* living doc (its Pass-3
    ticketing-fork decision should name the team); do not default to a team ID from another
    project or repo. If the doc doesn't name one and it's genuinely ambiguous, ask once.
  - A ticket is **done** only if Linear says so.

- **Neither file found:** the project hasn't reached Pass 3 yet (no groomed ticket set) —
  say so and suggest running `/dstack` to finish Pass 3 first.

## 5. Determine the next sensible ticket

From the DAG, compute the **eligible frontier**: open tickets whose every upstream dependency
is done. Among those, prefer:

1. The **lowest topological phase** (P0 before P1, etc.).
2. **Unblocking power** — a ticket that unblocks the most downstream work breaks ties.
3. **Continuity** — if a parallel "spine" is already in flight, favor continuing it (chain
   warm context) unless a root is more valuable.

If the frontier is empty because something upstream is only *half* done, say so explicitly and
name the blocker.

## 6. Share and confirm

Present your choice to the user with:

- **The ticket**: id (`KAI-####` for Fork A, or the local id like `V1` for Fork B), title,
  and its phase. Call out a 🚧 human-gate if present.
- **Why it's next**: which upstream deps are satisfied, what it unblocks downstream.
- **Alternatives**: any other tickets on the eligible frontier (especially parallelizable
  branches). If `team_shape` is `small-team` or `larger-team`, frame these explicitly as things
  a teammate could pick up right now, not just a redirect option for the same person; for
  `solo`, frame them as a plain redirect.
- If this is a Fork B project, briefly note that `/dstack-yolo` is the autonomous
  plan-implement-loop version of this pick, in case the user wants to hand off to that
  instead of just confirming and stopping here.

Then explicitly prompt the user to **confirm, correct the choice, or discuss** — and wait.
Do not proceed to planning or implementation until they choose. Once confirmed, for Fork B,
this is the point to actually fill in `tickets/<id>.md` (it was a stub until now) as part of
entering the Pass-4 micro-plan.
