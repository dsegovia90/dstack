# Adding a new harness adapter

`spec/llm-coding-workflow.md` is deliberately harness-agnostic — it describes the process in
plain prose with no tool-call syntax, no assumption of a particular skill/command system. Each
subfolder under `harnesses/` is a thin adapter that wires that spec into one coding harness's
actual mechanics. Only `claude-code/` exists today.

A new adapter needs to provide, in whatever native form the target harness uses:

- **A way to invoke a guided, multi-turn planning flow** — the equivalent of `SKILL.md`'s
  Steps 0–4: pick/resume a project, ask the prep questions once per new project, drive Pass
  1/2/3 conversationally, fork the ticketing backend.
- **A way to persist per-project answers and state** — the prep-question front matter, ticket
  statuses, execution log. `claude-code/` does this with plain files under `doc/dstack/<project>/`;
  any harness that can read/write files in the target repo can do the same, since none of that
  state is Claude-Code-specific.
- **A way to run a command against a chosen project** — the equivalents of `dstack-ticket.md`
  (pick next ticket), `dstack-yolo.md` (autonomous loop with plan-gating), and `dstack-retro.md`
  (retrospective). These can be separate commands, one parameterized command, or built into the
  main planning flow — whatever's idiomatic for the harness.
- **A way to enter a plan-mode-equivalent pause** before implementing a ticket — some point
  where the harness proposes a technical approach and waits for explicit human sign-off before
  writing code. If the harness has no such built-in mode, the adapter needs to simulate one
  (state the plan, wait for confirmation) rather than skipping the gate.
- **Whatever the harness needs for `AskUserQuestion`-style forks** — a way to present a
  recommended option plus alternatives and wait for a choice, used throughout Pass 1–3 and the
  ticketing-fork decision.

None of the conventions themselves (`doc/dstack/<project>/notes.md` + `TODO.md` + `tickets/` +
`findings/` + `retros/`, the front-matter shape, the commit-trailer convention, the fixed
Mermaid shape of the DAG diagram) are harness-specific — a new adapter should point at the same files and conventions the
`claude-code/` adapter uses, just invoked through different mechanics.
