# Roadmap — 0.4.0

Five improvements, drawn from a working list kept while using dstack on real projects, plus
one item deliberately deferred. Each row is built on its own branch and lands as its own PR,
so each can be **accepted or rejected on its own** — none of them depends on another. The
shared touch-points (`CHANGELOG.md`, `README.md`'s FAQ, `SKILL.md`'s front-matter block, this
file) are small enough that rebasing a rejected sibling out is trivial.

**How to use this file:** the PR that ships an item ticks its own row and records the PR
number. A rejected item gets `[-]` and a one-line reason, so the next person to reopen the
question knows why it closed. Nothing here is a spec — each PR's description and the files it
touches are the spec.

## Items

| # | Item | Status | Branch | PR | Shape of the change |
|---|---|---|---|---|---|
| 0 | This roadmap + `VERSION` 0.4.0 + `CHANGELOG` heading | `[x]` | `feat/roadmap-0.4` | #6 | Docs only. |
| 1 | Command arguments — `/dstack-ticket <project \| ticket-id \| LINEAR-ID>`, same for `/dstack-yolo`, `/dstack-retro`, `/dstack` | `[x]` | `feat/command-args` | #7 | An argument picks the project or *proposes* a ticket. The findings gate and the dependency check never move — a proposed ticket still goes through both. |
| 2 | Mermaid — two separate things | `[~]` | `feat/mermaid-diagrams` | #8 | **(A)** a `diagrams:` prep question: a tool for making pass artifacts readable, with a short when-to-draw-what table. **(B)** the DAG is *always* a rigid, conventional Mermaid diagram (fixed `classDef`s, one subgraph per phase, one edge per `blocked-by`), re-rendered from the ticket one-liners in the same commit as every status change. |
| 3 | `/dstack-feedback` — log a note about dstack itself while working | `[~]` | `feat/feedback` | #9 | One file per note in `doc/dstack/feedback/`, `status: new`, same shape as a finding. A gate (same step as the findings scan) clears the list: **file** as a GitHub issue on the dstack repo via `gh`, or **drop** with a reason. Agents are told to log friction the moment they hit it. |
| 4 | Rollout posture (feature flags), Step 1.9 | `[-]` | `feat/rollout-posture` | #10 | **Removed from 0.4.0** (PR closed 2026-10-09). Asked once per project, same shape as design posture: `none` / `flags` / `staged`, with the convention's location recorded (`CLAUDE.md`-first). Per feature, Pass 1 states the rollout decision; flag-gated tickets get a soft marker; a temporary flag's cleanup becomes a DAG node, not a memory. |
| 5 | `vcs_shape` prep question — where dstack's opinion on commits/branches/PRs starts and stops | `[-]` | `feat/vcs-shape` | #11 | **Removed from 0.4.0** (PR closed 2026-10-09). `branch-per-project` / `branch-per-ticket` / `trunk`, recommended by `team_shape`. Invariants for every shape: one ticket = one commit bundling code + re-spec + status, always with trailers. Explicitly *not* dstack's: merge strategy, CI, review rules, release tagging. `/dstack-ticket` gains the close-out step it never had. |

Status legend: `[ ]` not started · `[~]` in progress · `[x]` shipped (PR merged) · `[-]`
rejected (reason inline).

## Deferred

**Plugins / extensions.** Not all features are created equal, and not all projects are —
but some tools and knowledge are reusable without being universal. They're particular to a
developer ("my patterns when I write Rust"), to an architecture or core language, or to a
tool in someone's workflow (a guided flow through a UI design app that checks a design system
exists, creates one if not, and holds features to it). dstack has no place for that today:
everything is either the universal spec or a per-repo fact in `CLAUDE.md`.

Deferred because item 4 (rollout posture) was meant to be the concrete test case for this
shape — a concern that's real for one app and irrelevant to most. Item 4 was removed from
0.4.0, so this stays deferred with no test case yet. Revisit when a concrete instance comes
back.
