---
description: Log a note about dstack itself (a bug, friction, an idea) while working — or, with no argument, run the gate that files each pending note as a GitHub issue or drops it
argument-hint: "[note]"
---

# dstack-feedback: the fast lane for toolkit friction

This command is about **dstack**, not about the project you're building with it. It exists
so that a thought like "the findings scan fired on a file with no status line" or "Pass 2
should ask about X" gets written down *the moment it happens*, in a place the process treats
as unfinished business — the same shape as `findings/`, aimed at the toolkit instead of the
codebase. See `llm-coding-workflow.md`'s "Feedback — the fast lane" section for why this is
a gate and not a suggestion box.

Two modes, decided by whether `$ARGUMENTS` is empty.

## Mode 1 — `/dstack-feedback <note>`: log it and stop

Logging has to be cheap or it won't happen, so this mode asks **nothing** and touches **no
network**.

1. Read `.dstack-version` at the repo root for `version=`, `commit=`, and `repo=` (the
   canonical dstack source; if the line is missing — an older install — fall back to
   `https://github.com/dsegovia90/dstack`). Note which project, command, and ticket are in
   flight in this conversation, if any — leave blank rather than guess.
2. Write **one file per note** to `doc/dstack/feedback/<YYYY-MM-DD>-<short-slug>.md` (the
   folder is repo-level, not per project — feedback is about the toolkit; create it if
   missing):

   ```
   ---
   status: new
   kind: bug | friction | idea
   dstack: 0.4.0 @ 1a2b3c4
   context: digest-emails · /dstack-yolo · D4
   date: 2026-09-11
   issue:
   reason:
   ---
   # <one-line heading — the note's title, as an issue title would read>

   <the note, one to five lines. What happened, what you expected. A "Suggested change:"
   line if there's an obvious one.>
   ```

   `kind` is your best read of the note — `bug` (the instructions are wrong or contradict
   each other), `friction` (they work but cost more than they should), `idea` (something
   dstack doesn't do yet). `issue:` and `reason:` stay empty until the gate fills one of them.
3. Confirm the path in one line and **stop**. Do not ask whether to file it; that's the
   gate's job (Mode 2), and it runs on its own schedule.

## Mode 2 — `/dstack-feedback` (no argument): run the gate now

Scan `doc/dstack/feedback/` for every file with `status: new`. This gate also runs
automatically before every ticket pick — `dstack-ticket.md` Step 3 and `dstack-yolo.md`
Step 2 — right after the findings scan; running it by hand just does the same thing earlier.

For each `new` note, present it (heading + body + context line) and ask, via
`AskUserQuestion`, for one of exactly **two** legal outcomes — mirroring findings triage,
minus "fold into a ticket," which doesn't apply to toolkit notes:

1. **File as a GitHub issue** *(recommended when `gh auth status` succeeds)* —
   `gh issue create --repo <repo> --title "<heading>" --body "<body, then a footer with the
   dstack version/commit and the context line>"`. On success, set `status: filed` and
   `issue: <owner/repo>#<N>` from the URL `gh` prints. If several notes are clearly the same
   observation, offer to file them as one issue and mark each with the same number.
2. **Drop** — set `status: dropped` and write a one-line `reason:` (already fixed upstream,
   was a misread, not actually dstack's concern). The reason stays in the file; a later retro
   reads dropped notes and their reasons as data.

"Sitting there" is not an outcome. The only time a note survives the gate as `new` is when
filing is impossible right now — `gh` missing, not authenticated, or offline — and the user
chooses not to drop it. Say so plainly and move on; it's caught by the next gate.

Never run `gh issue create` without the user picking outcome 1 for that specific note —
filing is outward-facing, and a half-formed note filed by reflex is worse than one that
waits a day.

## For the agent, not just the human

If **you** hit friction with dstack's own instructions while running any dstack command — an
ambiguous step, a case the instructions don't cover, a gate that fired when it shouldn't have
(or didn't when it should) — write a `feedback/` note right then, in Mode 1 form, with the
context line filled in. Don't wait for the retro, don't mention it and move on, and don't
file the issue yourself: the gate asks the human. The commands that run the gate say this
too; this is the canonical wording.
