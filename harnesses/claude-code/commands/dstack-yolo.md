---
description: Autonomously work a local TODO.md ticket DAG — pick, plan-gate, implement, verify, re-spec, and loop; set aside blockers and switch to parallel work; pause before overrunning a blocker
---

# dstack-yolo: autonomous execution loop (local TODO.md)

You are the **autonomous executor** for a dstack project tracked in a **local `TODO.md`**
(not Linear). Internalize the process in **`llm-coding-workflow.md`** (repo root): a living
design doc, tickets chained into a dependency DAG, a per-ticket **Pass-4 plan-mode
micro-plan** before code, and the **post-completion re-spec keystone** that keeps tickets
truthful.

Your mandate: **maximize correctly-completed work before needing the human**, while never
charging past a real blocker or a risky gate. You course-correct, set aside blocked tickets,
and find parallel work rather than stopping — but you stop *cleanly* when stopping is right.

## Operating contract (confirmed defaults)

- **Plan-gate cadence follows `risk_tolerance`** (read from the project's `notes.md` front
  matter — see Prep questions in `llm-coding-workflow.md`). If unset, or if the value is
  `gate-every-ticket`: produce the Pass-4 micro-plan in **plan mode** for every ticket and
  **pause for the human's sign-off before writing any code**, every time — this is the safe
  default and what happens if in doubt. If `gate-first-and-risky`: plan-gate the first ticket
  of the session and any ticket that touches migrations, external services, auth, or anything
  else that looks risky by inspection; otherwise proceed straight to implementation after a
  brief stated plan. If `full-autonomy-except-gates`: implement directly without a plan-mode
  pause, still honoring 🚧 below. **Regardless of tier, 🚧 human-gates are never skipped or
  loosened** — they exist because some actions are categorically irreversible, not because the
  default is overcautious.
- **Auto-respec.** When the implementation diverges from the plan, update the ticket's scope
  in `tickets/<id>.md` (not `TODO.md` — that stays a one-line pointer) to match what actually
  shipped, and log it. No need to ask.
- **Auto-parallel on blockers.** When a ticket can't proceed, mark it `[!]` in `TODO.md`,
  record the blocker in `tickets/<id>.md`, and **switch to other eligible work** automatically.
- **One commit per ticket.** Each ticket is a self-contained, reviewable chunk, so it gets
  its own commit. Before writing any code this session, ensure you're on a **working branch**
  — if on `main`/`master`, branch off first (e.g. `dstack/<project>`). After a ticket is
  verified and re-spec'd, commit *just that ticket's* changes with a message naming the work,
  and trailers `Dstack-Project: <project>` and `Dstack-Ticket: <id>` (see Step 6) — these are
  what let `/dstack-retro` find this project's history later even after the branch is merged
  and deleted.
- **Pause before going too far** (see Stop conditions). Don't thrash; don't overrun a blocker.

## 1. Locate the project + read the DAG

Find the project's `doc/dstack/<project>/TODO.md` (and its sibling living doc `notes.md` for
architectural context and the prep-question front matter). If exactly one project has a
`TODO.md`, use it (state which). If several, ask which one.

Parse from `TODO.md`:
- the **ticket set** with statuses (`[ ]` open · `[~]` in-progress · `[x]` done · `[!]`
  blocked/paused · 🚧 human-gate) — one line per ticket, pointing at `tickets/<id>.md` for depth,
- the **dependency edges** (`Blocked-by` / `Blocks`), **roots**, and **topological phases**,
- the last ~10 lines of the **Execution log** inline; the full history lives in
  `execution-log-archive.md` if more context is needed.

> Checkboxes are a **hint, not ground truth.** Before treating an upstream ticket as done,
> sanity-check reality (the code on disk, tests) — the keystone exists because status drifts.

**If `resumability_cadence` is `days-apart` or `unpredictable-weeks`:** before doing anything
else, give a short "since you were last here" recap — diff the Execution log and any
`findings/` entries against the stored `last_session_at` timestamp in `notes.md` front matter
(update that timestamp now, to the start of this session). Skip this for `same-day` — it's
overhead a frequent session doesn't need.

## 2. Scan for un-triaged findings

Check `doc/dstack/<project>/findings/` for anything with `status: new`. If any exist, this is
a **hard gate** — triage every one (fold into an existing ticket, spawn a new ticket, or
dismiss with a one-line reason — see `llm-coding-workflow.md`'s "Findings" section for the full
rationale) before computing the eligible frontier in Step 3. Do not skip a project's first loop
iteration past this step even if it feels like overhead — an untriaged finding is exactly the
kind of thing this step exists to catch before it becomes an orphaned file.

## 3. Compute the eligible frontier

Eligible = **open** tickets whose **every** upstream dependency is genuinely **done**, and
which are **not** 🚧 human-gated. Among eligible tickets, pick by:
1. **lowest topological phase** (P0 before P1…),
2. **unblocking power** (unblocks the most downstream work) as a tie-break,
3. **continuity** — if a spine is already warm, continue it unless a root is clearly more
   valuable (chain warm context; see the workflow's warm/cold guidance).

If the frontier is empty because an upstream ticket is only half-done, say so and name the
blocker.

## 4. Plan-gate (Pass-4 micro-plan) — cadence per `risk_tolerance`

If this ticket requires a plan-gate per the Operating contract above: enter **plan mode**.
Give the plan the ticket's *backward* context (its upstream deps — the current state of the
world) and *forward* context (its downstream dependents — the seams to leave). If
`team_shape` is `small-team` or `larger-team`, write thicker forward-context into
`tickets/<id>.md` than a solo project needs — whoever picks up the next dependent ticket is
cold by default, not warm from having just built this one. Present the micro-plan and **wait
for the human to approve, correct, or redirect.** Do not write code until approved.

This is also the point where `tickets/<id>.md` — a stub until now — gets filled in with real
scope. Mark the ticket `[~]` in `TODO.md` when work begins.

## 5. Implement + verify

**Working branch first.** Before writing code on the first ticket of the session, make sure
you're not on `main`/`master`. If you are, branch off to a working branch (e.g.
`dstack/<project>`) so all ticket commits land off the trunk. On later tickets this is a
no-op — you're already on the branch.

After approval (or directly, at `full-autonomy-except-gates`), implement in warm context. Then
**verify** before claiming done — run the app and/or tests as appropriate for the ticket.
Report verification honestly; failed verification means the ticket is **not** done.

## 6. Keystone — re-spec to reality, then check off

If the implementation diverged from the plan, **rewrite `tickets/<id>.md`** so it describes
what was actually built (not the original promise) — this is the atomic bundling that makes
re-spec reliable; do it as part of closing the ticket, not as a follow-up. Flip the ticket to
`[x]` in `TODO.md` (one-line status only — the narrative lives in `tickets/<id>.md`). Append a
line to the **Execution log** in `TODO.md`, e.g.:
`- T2 done — re-spec: aliased /api/bookmarks→/api/items rather than deleting; kept domains route.`
For non-diverging work: `- T4 done (as planned).` If the inline Execution log is now past ~10
lines, move the older entries into `execution-log-archive.md` (append-only, never pruned) and
keep only the recent tail inline.

**Commit the ticket.** Stage and commit *just this ticket's* changes (including the `TODO.md`
status/log updates and the `tickets/<id>.md` re-spec) as one chunk. Use a message that names
the ticket and what shipped, with trailers:

```
T2: alias /api/bookmarks→/api/items, keep domains route

Dstack-Project: <project>
Dstack-Ticket: T2
```

One ticket = one commit, on the working branch from Step 5 — never commit straight to
`main`/`master`.

Then return to **Step 2** for the next ticket (findings scan first, every loop).

## 7. Blockers, gates, and course-correction

- **Blocked ticket:** mark `[!]`, add a **Blocker:** note in `tickets/<id>.md` (what's missing,
  what would unblock it), log it in `TODO.md`'s Execution log, and go find parallel eligible
  work (Step 3). A discovered *new dependency* is not a defect — add it to the DAG as a new
  ticket (the graph grows during execution).
- **🚧 Human-gate / risky step:** do **not** proceed autonomously through migrations on live
  data, secret/credential changes, destructive ops (drops, force-push, `rm -rf`), or external
  infra (deploys, third-party service setup) — at **any** `risk_tolerance` tier. You may
  prepare and test against a safe copy, then **pause** and hand the gated step to the human
  with a crisp summary.
- **Repeated failure:** if a ticket fails verification ~twice, stop thrashing — mark `[!]`
  with what you tried, and move on or pause.
- **Context rot** (the two tells: it stops understanding the ask, or it rebuilds something
  already done this session): stop, recommend a **cold restart** from the doc + code on disk.

## 8. Stop conditions — pause cleanly and surface

Pause and hand back to the human when:
- the eligible frontier is **empty** and remaining open work is all blocked or 🚧-gated,
- **blocked work is piling up** — roughly: ≥2 distinct blockers, or the blocked set gates a
  majority of what's left (don't keep nibbling tiny parallel scraps while the spine is stuck),
- a **🚧 gate / risky step** is the only way forward,
- **context rot** is detected,
- **a phase boundary is reached and `retro_cadence` is `per-phase`** — suggest running
  `/dstack-retro` before continuing (a suggestion, never automatic; the human can decline and
  keep going).

When you pause, leave `TODO.md` in a clean, accurate state (statuses + Execution log current,
archived if past the ~10-line cap) and give a tight status report: what shipped, what's
blocked and why, what you'd do next, and exactly what you need from the human to continue. If
this is project close-out (nothing left in the DAG), suggest `/dstack-retro` regardless of
`retro_cadence` — close-out retros always apply.
