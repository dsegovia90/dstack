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
  `retro_cadence`, `vcs_shape`) live in the project's `notes.md` front matter — read them;
  they shape how this command presents its pick (see Steps 4–5) and how a finished ticket
  gets closed (Step 7).

## 2. Pick the project

List the projects under **`doc/dstack/`** (each subdirectory is a project).

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
2. **Spawn a new ticket** — add it to the DAG (Fork B: new line in `TODO.md` + new
   `tickets/<id>.md` stub, wired into `blocked-by`/`blocks`; Fork A: new linked Linear issue,
   wired via `blockedBy`/`blocks` per Step 4 below), then flip the finding file's `status` to
   `absorbed`.
3. **Dismiss** — record a one-line reason in the finding file itself, flip `status` to
   `dismissed`. No ticketing-backend touch needed for this outcome.

Do not proceed to Step 4 while any finding is still `status: new` — this is a hard gate, not a
suggestion. If there are none, say so briefly and continue.

## 4. Detect the ticketing fork, then read the DAG

**First, is anything `[~]` in-progress whose work has actually landed on disk** — the files
its detail names exist, its verification would pass — but that never got closed? Offer to run
Step 7 for it *before* picking anything new. An implemented-but-unclosed ticket is the
Keystone's failure mode in progress: the re-spec hasn't happened and the commit hasn't been
made, and every hour that passes makes the divergence harder to reconstruct.

Inside the project folder, check what's actually there:

- **`TODO.md` present → Fork B (local).** This is the default for solo/lighter-weight
  projects in this repo. Read `TODO.md` directly:
  - The **Tickets** section — one line per ticket (skeleton only; full detail lives in
    `tickets/<id>.md`), checkbox (`[ ]`/`[~]`/`[x]`/`[!]`, plus 🚧 for human-gated infra steps
    and 🎨 for tickets that touch user-visible UI), with `blocked-by` / `blocks`.
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
Do not proceed to planning or implementation until they choose. Once confirmed, for Fork B,
this is the point to actually fill in `tickets/<id>.md` (it was a stub until now) as part of
entering the Pass-4 micro-plan.

**Branch before code**, per `vcs_shape` (unset → `branch-per-project`):
- `branch-per-project`: be on `dstack/<project>` — cut it from `main`/`master` if it doesn't
  exist yet; otherwise just check it out.
- `branch-per-ticket`: cut a fresh branch from `main`/`master` — Fork B: `dstack/<project>/
  <id>-<short-slug>`; Fork A: **Linear's own branch name for the issue**, verbatim (the one it
  offers to copy — `branchName` via MCP), so Linear auto-links the branch and PR. **If an
  upstream dependency is done but its PR is still open**, ask the user, `AskUserQuestion`:
  **stack on that branch** *(recommended when they're the same author and the PR is close to
  merging — cut from the dependency's branch, open the PR against it, note "stacked on <id>
  (#N)" in the ticket)* or **wait** *(mark this ticket `[!]` with "waiting on #N to merge"
  and pick something else)*. Don't decide this silently — stacking is a real commitment.
- `trunk`: stay on `main`/`master`.

Never commit on `main`/`master` in either branch shape.

## 7. Close the ticket — re-spec, status, commit, PR

This step runs when the ticket's work is done, whenever that is — same session, or a later
`/dstack-ticket` that found it `[~]` and landed (Step 4). It is the Keystone made structural
for the human-driven path, exactly as `/dstack-yolo` Step 6 is for the autonomous one: one
closing action that does all of the following, in one commit, so re-spec can't be skipped.

1. **Verify first.** Run whatever proves the ticket — tests, the app. Failed verification
   means the ticket isn't done; don't close it.
2. **Re-spec to reality.** If what shipped diverged from the micro-plan, rewrite the ticket's
   detail to describe what was actually built — Fork B: `tickets/<id>.md` (a "Re-spec — what
   actually shipped" section, as in `examples/reference-project/tickets/D1.md`); Fork A: a
   **Linear comment first** narrating original-spec → actual-shipped → why, *then* update the
   description. Include the PR link in that comment once it exists (step 5).
3. **Status.** Fork B: flip to `[x]` in `TODO.md` (one line — the narrative lives in the
   ticket file) and append an Execution-log line (`- D2 done (as planned).` / `- D3 done —
   re-spec: …`), archiving older entries past ~10 lines. Fork A: move the Linear issue to done.
4. **Commit — one, with trailers.** Stage just this ticket's changes (code + ticket detail +
   `TODO.md`), one commit:

   ```
   D3: build digest content chronologically, cap at 20 items

   Dstack-Project: digest-emails
   Dstack-Ticket: D3
   ```

   Same id in the trailer for Fork A (`Dstack-Ticket: KAI-123`). Never rewrite this commit
   once pushed; never force-push. If this ticket needed more than one commit along the way,
   the *closing* commit is the one that carries the re-spec + status — the bundle is what
   matters, not the count.
5. **PR, per `vcs_shape`.** `branch-per-ticket`: push and open one — `gh pr create` with the
   commit subject as title and the ticket's re-spec section as body; base = `main` (or the
   dependency's branch, if stacked); record the PR number in the Execution log / Linear
   comment. `branch-per-project`: push; suggest a PR only at a phase boundary or close-out
   (alongside the retro suggestion). `trunk`: push; no PR.
6. **Hand back.** Say what shipped, what diverged, and — if `team_shape` is a team and the
   shape is `branch-per-ticket` — that the next *dependent* ticket should wait for this
   review to land rather than stack blind; the review is the re-spec forcing function.

What this step deliberately does **not** decide: merge strategy, who approves, CI gates,
release tagging. Those are the host repo's (`CLAUDE.md`); follow them, don't restate them.
