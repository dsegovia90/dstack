# Digest Emails — Ticket DAG

See `notes.md` for the full design doc (Pass 1 intake, Pass 2 architecture, Pass 3 phasing this
DAG is drawn from). This file is a **skeleton only** — one line per ticket. Full scope, files,
acceptance, and re-spec narratives live in `tickets/<id>.md`. If you're about to write more
than one line per ticket here, it belongs in the ticket file instead.

## Status legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done
- `[!]` blocked / needs attention
- 🚧 human-gate — pause for explicit sign-off before/after this ticket, don't autonomously
  barrel through it
- 🎨 design-touching — check against the project's design ground rules (`notes.md` Step 1.8)
  before closing; not a hard gate, just a visible reminder

## Dependency graph

```
D1 (schema)
  ├──> D2 (preferences UI) 🎨
  └──> D3 (digest content builder) ──┬──> D4 (scheduled send job) 🚧
                                      └──> D5 (unsubscribe link, also needs D2) 🎨
```

**Root:** D1

**Phases:**
1. D1
2. D2 🎨, D3 (parallelizable)
3. D4 🚧, D5 🎨 (parallelizable)

---

## Tickets

- [x] **D1** Schema migration — blocked-by: none (root) · blocks: D2, D3 · phase 1 ·
  [detail](tickets/D1.md)
- [x] **D2** Preferences UI 🎨 — blocked-by: D1 · blocks: D5 · phase 2 · [detail](tickets/D2.md)
- [x] **D3** Digest content builder — blocked-by: D1 · blocks: D4, D5 · phase 2 ·
  [detail](tickets/D3.md)
- [!] **D4** Scheduled send job 🚧 — blocked-by: D3 · blocks: none · phase 3 ·
  [detail](tickets/D4.md)
- [ ] **D5** Unsubscribe/pause link 🎨 — blocked-by: D2, D3 · blocks: none · phase 3 ·
  [detail](tickets/D5.md)

---

## Execution log

_(append-only — one entry per ticket completion, re-spec, or blocker; newest last. Older
entries roll into `execution-log-archive.md` once this list passes ~10 lines — see
`execution-log-archive.md` for this project's early history.)_

- D2 done (as planned).
- D3 done — re-spec: dropped the "highlight top item" idea from Pass-2 prose (never actually
  ticketed, caught during implementation as scope creep) — v1 stays plain chronological, per
  Pass 1's explicit out-of-scope call. Also absorbed finding `email-deliverability-review` —
  see tickets/D3.md.
- Finding `unused-digest-column` triaged — dismissed, see findings/unused-digest-column.md.
- D4 blocked — see tickets/D4.md for the blocker note. 🚧 gate: needs a human decision on which
  scheduler to use before this can proceed even in prep.
