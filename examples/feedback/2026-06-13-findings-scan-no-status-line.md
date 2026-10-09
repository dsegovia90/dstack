---
status: dropped
kind: bug
dstack: 0.3.0 @ b17912d
context: digest-emails · /dstack-yolo · D3
date: 2026-06-13
issue:
reason: Misread — the file had `status:` on line 3, below a stray blank line; the scan was right to flag it. Not a dstack bug.
---
# Findings scan treated a file with no front matter as `status: new`

While closing D3, the Step 2 findings scan surfaced `findings/unused-digest-column.md` as
untriaged even though I'd dismissed it the session before. Expected: a file with
`status: dismissed` is skipped. Got: it was presented again.

Suggested change: if the scan can't find a `status:` line, say "no status line — treating as
new" so the cause is visible instead of looking like a re-triage.

_Illustrative — this note exists to show the shape of a feedback file and one of its two
legal end states. Note the `reason:` line: the gate wrote it when the user chose **drop**, and
a later `/dstack-retro` reads dropped reasons as data. A **filed** note would instead carry
`status: filed` and `issue: dsegovia90/dstack#N`._
