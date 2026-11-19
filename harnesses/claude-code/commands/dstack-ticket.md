---
description: Pick the next sensible dstack ticket from a project's DAG and confirm with the user
allowed-tools: Bash(./dstack-config:*)
argument-hint: "[project] [ticket-id | LINEAR-ID]"
---

# dstack: choose the next ticket

You are helping pick the **next ticket to work on** for a "dstack" project, following our
planning-first engineering process. Do this conversationally — propose, then let the user
confirm, correct, or discuss before any code is written.

## Config in effect

!`./dstack-config load`
## 0. Read the arguments

`$ARGUMENTS` may name a **project**, a **ticket**, or both (`project ticket`). Resolve in this
order, stopping at the first rule that matches:

1. **Nothing given** → the rest of this command runs exactly as written below.
2. **A folder name under `doc/dstack/`** → that project is selected; skip the "which project"
   question in Step 2.
3. **A local ticket id** (`D3`, `T12` — whatever ids the project's `TODO.md` uses) found in
   exactly one project's `TODO.md` → that project is selected **and** the ticket becomes the
   **proposed pick**. If the id appears in more than one project's `TODO.md`, ask which.
4. **A Linear identifier** (`KAI-123` — uppercase team key, dash, number) → Fork A. Find the
   project whose living doc links that issue; if none does, ask which project. The issue's
   live state comes from Linear MCP in Step 4 as usual — if MCP isn't available, say so
   plainly rather than guessing; nothing in the repo records Fork A status.
5. **Nothing matched** → say what was tried ("no project or ticket named `foo`") and fall
   through to the normal flow. Don't invent a match.

**A proposed ticket moves nothing that's a gate.** It still goes through the findings scan
(Step 3) first, and its dependencies are still checked — against the DAG *and* the code on
disk (Step 4). If an upstream dependency isn't genuinely done, say which one and present the
eligible frontier instead, exactly as if no argument had been given. If it *is* eligible,
present it in Step 6 with "you asked for this one" as the reason and the rest of the frontier
as alternatives — and still wait for confirmation. The argument saves a question; it never
skips a check.

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

If Step 0 already selected a project, use it (state which) and move on. Otherwise list the
projects under **`doc/dstack/`** (each subdirectory is a project).

- If there is exactly **one**, use it (state which one you're using).
- If there are **multiple**, ask the user which project we're working on. Do not guess.

## 3. Scan for un-triaged findings — before anything else

Check the project's **`doc/dstack/<project>/findings/`** folder for anything with
`status: new` — the same convention for **both** forks. Findings stay in-repo even for Fork A:
the ticketing backend only ever sees the *outcome* of a triage decision (a new linked ticket, or
a comment on an existing one), never dstack's own pre-ticket bookkeeping — Linear stays
unopinionated about a process concern that isn't its own.

Any finding with `status: new` must be surfaced and triaged **before** computing the eligible
frontier below. Present each one and get the user to choose one of the three legal outcomes:

1. **Fold into an existing ticket** — cite the finding and re-spec that ticket's scope now
   (Fork B: edit `tickets/<id>.md`; Fork A: leave a Linear **comment** on the target ticket
   citing the finding — comment first, never silently overwrite the description, same
   discipline as the re-spec rule in Step 4 below), then flip the finding file's `status` to
   `absorbed`.
2. **Spawn a new ticket** — add it to the DAG (Fork B: new row in `TODO.md`'s ticket table +
   new `tickets/<id>.md` stub, wired into `Blocked by`; Fork A: new linked Linear issue, wired
   via `blockedBy`/`blocks` per Step 4 below, plus its row in the doc's ticket table). Fill the
   new row's `Branch` as Pass 3 would (`.claude/skills/dstack/tickets-and-branches.md` § Branch
   names — Fork A: the new issue's `gitBranchName`). Then flip the finding file's `status` to
   `absorbed`.
3. **Dismiss** — record a one-line reason in the finding file itself, flip `status` to
   `dismissed`. No ticketing-backend touch needed for this outcome.

Do not proceed to Step 4 while any finding is still `status: new` — this is a hard gate, not a
suggestion. If there are none, say so briefly and continue.

## 4. Detect the ticketing fork, then read the DAG

Inside the project folder, check what's actually there:

- **`TODO.md` present → Fork B (local).** This is the default for solo/lighter-weight
  projects in this repo. Read `TODO.md` directly:
  - The **ticket table** under `## Tickets` — one row per ticket (skeleton only; full detail
    lives in `tickets/<id>.md`): `Ticket` (status box `[ ]`/`[~]`/`[x]`/`[!]`, id, and markers —
    🚧 human-gated, 🎨 touches user-visible UI, ✂ may split), `Branch`, `Scope`, `Blocked by`.
    The format is in `.claude/skills/dstack/tickets-and-branches.md`. An older project may
    still list one bullet per ticket instead — read either.
  - The **DAG** section — the diagram, declared **roots**, and **Phases** table.
  - Checkboxes are a **hint, not ground truth** — status drifts. Before treating an upstream
    ticket as done, sanity-check against the **code on disk** (does the file/dependency/route
    the ticket describes actually exist?), not just the checkbox. A done ticket whose PR isn't
    merged yet has its code on its own branch, not the trunk — look there
    (`git diff origin/<trunk>...<branch>`). There is no Linear lookup in this fork — skip it
    entirely, and never treat a missing Linear issue as a blocker here.
  - A 🚧-tagged ticket needing external infra is still eligible to be *picked and discussed* —
    just flag the human-gate plainly when presenting it (see Step 6).
  - Only read the **chosen** ticket's `tickets/<id>.md` in full once it's picked — for
    presenting alternatives in Step 6, the rows in `TODO.md` are enough; don't burn
    context pre-reading every candidate's deep file.

- **No `TODO.md`, but a `README.md` or `notes.md` with `KAI-####` links → Fork A (Linear).**
  Open the project's `README.md`/`notes.md` (the master living design doc) and find:
  - The **ticket set** — the ticket table (`tickets-and-branches.md`): each row's local id,
    `KAI-####` (or equivalent) Linear link, `Branch`, one-line `Scope`, and `Blocked by` — no
    inline scope/acceptance and no status; Linear is the sole source of both. An older doc may
    list bullets instead — read either, and ignore any boxes in it.
  - The **Execution phasing & dependency DAG** section — edges, roots, topological phases.
  - **Status comes only from Linear.** Read it fresh with one `list_issues` call for this
    project's issues per pick — that gives every ticket's state for the frontier. Never read
    status from the doc, and never tick a box in it. Use the Linear team/project referenced in *this project's own* living doc (its Pass-3
    ticketing-fork decision should name the team); do not default to a team ID from another
    project or repo. If the doc doesn't name one and it's genuinely ambiguous, ask once.
  - A ticket is **done** only if Linear says so.

- **Neither file found:** the project hasn't reached Pass 3 yet (no groomed ticket set) —
  say so and suggest running `/dstack` to finish Pass 3 first.

## 5. Determine the next sensible ticket

From the DAG, compute the **eligible frontier**: open tickets whose every upstream dependency
is done. If Step 0 proposed a ticket and it's on the frontier, it's the pick — skip the
ranking below but still list the rest of the frontier as alternatives in Step 6. If it's
*not* on the frontier, say why (which dependency is unmet, or it's already done/blocked) and
rank the frontier as normal. Among frontier tickets, prefer:

1. The **lowest topological phase** (P0 before P1, etc.).
2. **Unblocking power** — a ticket that unblocks the most downstream work breaks ties.
3. **Continuity** — if a parallel "spine" is already in flight, favor continuing it (chain
   warm context) unless a root is more valuable.

If the frontier is empty because something upstream is only *half* done, say so explicitly and
name the blocker.

## 6. Share and confirm

Present your choice to the user with:

- **The ticket**: id (`KAI-####` for Fork A, or the local id like `V1` for Fork B), title,
  and its phase. Call out a 🚧 human-gate if present, and a 🎨 marker if present — note that its
  micro-plan and close-out should check the work against the project's design ground rules
  (Step 1.8 in `SKILL.md`) before it's called done.
- **Why it's next**: which upstream deps are satisfied, what it unblocks downstream.
- **Alternatives**: any other tickets on the eligible frontier (especially parallelizable
  branches). If `team_shape` is `small-team` or `larger-team`, frame these explicitly as things
  a teammate could pick up right now, not just a redirect option for the same person; for
  `solo`, frame them as a plain redirect. If `team_shape` is unset in `notes.md`'s front
  matter, treat it as `solo` — the recommended default from Step 1.5 — rather than leaving the
  framing ambiguous.
- If this is a Fork B project, briefly note that `/dstack-yolo` is the autonomous
  plan-implement-loop version of this pick, in case the user wants to hand off to that
  instead of just confirming and stopping here.
- **Retro suggestion**: if the confirmed ticket starts a new topological phase relative to the
  last one worked, or the DAG is now empty (close-out), check `retro_cadence` (unset → treat as
  `per-phase`, the recommended default from Step 1.5). If it calls for a checkpoint here,
  suggest running `/dstack-retro` — a suggestion only, never automatic; the user can decline and
  keep going.

Then explicitly prompt the user to **confirm, correct the choice, or discuss** — and wait.
Do not proceed to planning or implementation until they choose.

## 7. Branch first — before any edit

Once the pick is confirmed, and before any file edit for it, run the **branch-first step** in
`.claude/skills/dstack/tickets-and-branches.md`: read the ticket's `Branch`, pick its parent
(an open blocker's branch, else the trunk), and create or check out that branch with the tool
`./dstack-config branching <project>` names. A `—` ticket has no branch; skip it. The
findings-triage edits from Step 3 move onto this branch with the ticket.

Only then: for Fork B, fill in `tickets/<id>.md` (a stub until now) and set the ticket to `[~]`
as part of entering the Pass-4 micro-plan. For Fork A, set the issue to the team's started
status in Linear (status type `started`, e.g. In Progress; names differ per team) — nothing in
the repo changes. If the micro-plan splits the ticket into more than
one PR, follow that file's rule 6.

When the work is done, it's **one PR for the ticket**: the first commit's subject is the PR
title (`[KAI-123] …` for Fork A, `D3: …` for Fork B), every commit carries the
`Dstack-Project:` / `Dstack-Ticket:` trailers, and `branch.submit` decides whether you open a
draft PR or print the command for the user — see that file's "One ticket, one PR". A Fork A
ticket's completed status is set in Linear (by Linear's GitHub integration when the PR merges,
if the team turned that on), never in the doc.
