# dstack

**What this is, in three sentences:** dstack is a planning-first workflow for coding with an
LLM agent — one living design doc advances through three passes (intake → architecture →
execution phasing), tickets hang off it chained into a dependency DAG, and a fourth per-ticket
"plan mode" pass happens right before any code gets written. The keystone habit is
**post-completion re-spec**: when implementation diverges from the plan, the ticket gets
rewritten to match reality instead of left as a stale promise, so the history stays a truthful
changelog. The thesis behind all of it: output quality is set by the planning that precedes the
model, not by the model itself — so the system's whole job is to make that upstream planning
structured, reviewable, and hard to skip.

This repo is the canonical, installable source — not tied to any one project. Read
`spec/llm-coding-workflow.md` for the full method in prose; this README is the practical,
dummy-proof "how do I actually use this" guide.

---

## Walkthrough — following one project start to finish

Everything below refers to a real, fully worked example checked into this repo:
`examples/reference-project/`. Open its files alongside this walkthrough — every step here
produced one of them.

1. **Start:** in a repo with dstack installed (see Install, below), invoke the planning skill
   and say what you're building. It asks what kind of work this is (new feature, bug, refactor,
   research), then — for a brand-new project — asks the four **prep questions** once:
   team shape, risk tolerance, resumability cadence, retro cadence. Answers get written into
   the new project's `notes.md` front matter. In the reference project:
   ```yaml
   team_shape: solo
   risk_tolerance: gate-every-ticket
   resumability_cadence: days-apart
   retro_cadence: per-phase
   ```
2. **Pass 1 — Intake:** guided questions produce the "what" — product intent, problem, MVP
   surface, success criteria. See `examples/reference-project/notes.md`'s "Pass 1" section.
   Written into `doc/dstack/<project>/notes.md`, the *same* file every later pass reuses.
3. **Pass 2 — Architecture:** the same doc gets rewritten through a structural lens — data
   model, components, the "how." Ticket grooming falls out of this pass as a side effect (see
   that doc's "Rough ticket-shaped seams" list) — it's not a separate step.
4. **Pass 3 — Execution phasing + DAG:** the groomed seams become real tickets (`D1`–`D5` in
   the reference project), chained by `blocked-by`/`blocks` into a dependency graph, with roots
   and topological phases called out. See that doc's "Pass 3" section for the diagram.
5. **Fork the ticketing backend:** Linear (structured/team) or a local `TODO.md` (lighter,
   solo-friendly) — see the Decision guide below for which. The reference project uses the
   local fork: `TODO.md` is generated as a **skeleton only** (one line per ticket, the DAG
   diagram, phases, a status legend) — full detail moves to `tickets/<id>.md`, created as empty
   stubs for every ticket right away so nothing links to nowhere.
6. **Pick and work a ticket:** the next-ticket command scans for untriaged `findings/` first
   (a hard gate — see below), computes the eligible frontier (open tickets with every
   dependency done), and presents its pick with reasoning and alternatives. Once confirmed, a
   plan-mode micro-plan happens before any code — cadence depends on the `risk_tolerance`
   answer. Compare `tickets/D1.md`'s "Scope (as planned)" section to its "Re-spec — what
   actually shipped" section: the plan changed once real implementation surfaced a wrinkle
   (needing per-user timezone, not just day-of-week), and the ticket was rewritten to match,
   in the same commit as the code.
7. **Findings show up mid-project too.** `findings/email-deliverability-review.md` is a
   discovery made *while* working D3, unrelated to D3's original scope — it got folded
   straight into that ticket rather than left to rot as a loose file. Compare
   `findings/rate-limit-audit.md`, still `status: new` in this example on purpose: that's what
   the next ticket-pick's findings scan is designed to catch before it gets ignored.
8. **Blockers get named, not hidden.** `tickets/D4.md` is `[!]` blocked — not because anything
   broke, but because an architecture-time open question (which scheduler to use) never
   actually got resolved before the ticket became eligible. The 🚧 marker means: don't push
   through this autonomously at any risk-tolerance setting, surface it to a human instead.
9. **Retro, on the cadence you asked for.** `retros/2026-06-14-retro.md` was triggered at a
   phase boundary (`retro_cadence: per-phase`) — it reads the *real* history (git log, ticket
   files, findings) rather than the plan, and ends with process-observations worth watching for
   recurrence across other projects. Anything that does recur belongs in this repo's own
   `meta/process-notes.md`, pasted in by a human, not merged automatically.

## Install

```
./install.sh --harness claude-code /path/to/your-repo
```

This copies `spec/llm-coding-workflow.md` to your repo's root, the `claude-code` adapter's
skill + commands into `.claude/skills/dstack` and `.claude/commands/`, and writes a
`.dstack-version` file recording what was installed and from where.

**What it deliberately does not do:** merge. It's a plain copy — re-running it overwrites
whatever's currently in the target repo's `.claude/skills/dstack` and
`.claude/commands/dstack-*.md`. If you've hand-edited an installed copy, `git diff` after
re-running before committing. This is a known, accepted limitation, not an oversight — see
"Common mistakes" below for the real drift story that motivated calling it out this plainly.

Only the `claude-code` harness adapter exists today. `harnesses/_template/README.md` describes
what a new adapter needs to provide if you want to wire dstack into a different coding agent.

## Decision guide

**Which ticketing fork do I want?**
- **Solo, no real PR/review cycle → local `TODO.md`.** Make the ticket-closing step itself do
  the re-spec+commit bundling (it's built into the autonomous-loop command already) — this
  gets you reliable re-spec without needing a review process to force it.
- **Team, real PR/review cycle already happening → Linear (or equivalent).** The review cycle
  is what actually makes re-spec reliable in practice — it forces the doc-update and the
  code-change into the same reviewed unit. Without a review cycle, a structured backend's
  reliability is no better than the local fork's, while adding real overhead for no payoff.
- This is a *nudge*, not a rule — the planning skill states this reasoning and lets you pick
  either fork regardless of team shape.

**What do I answer for the four prep questions?**
- **Team shape:** answer honestly about *this project*, not your general team size — a solo
  side-project inside a larger org is still "solo" for this purpose.
- **Risk tolerance:** default to "gate every ticket" unless you have a specific reason not to.
  Loosening this trades review safety for speed; 🚧 human-gates (migrations on live data,
  secrets, destructive ops, external infra) are never affected by this setting either way.
- **Resumability cadence:** answer based on how you actually work, not how you'd like to. If
  you're honestly unsure, pick "unpredictable/weeks" — the recap it adds is cheap on a day you
  didn't need it, but its absence is expensive on a day you did.
- **Retro cadence:** "per-phase" if the project has more than a couple of phases; "close-out
  only" for something small enough that a mid-project checkpoint would just be close-out early.

## Common mistakes

Drawn from real evidence, not hypotheticals — these are documented failure modes a prior,
pre-standalone version of dstack actually hit in production use:

- **Don't let the skeleton (`TODO.md` / the doc's ticket list) grow past one line per ticket.**
  A real production project's dstack doc grew to 900 lines by mixing stable architecture prose
  with ever-growing per-ticket detail in the same file. Full detail belongs in `tickets/<id>.md`
  (or the ticketing system's own detail view) — always.
- **Don't leave a review/audit artifact sitting outside `findings/`.** The same project had
  three real analysis reports (a code review, a component audit, a wireframe-comparison) sit
  uncommitted and never folded back into the living doc — real work discovered, never
  scheduled. `findings/` plus the mandatory pre-pick scan exists specifically to prevent this.
- **Don't skip the findings scan "just this once" before picking the next ticket.** It's a hard
  gate for a reason — the one time it gets skipped is the time something sits orphaned for
  weeks.
- **Don't treat a 🚧 marker as advisory.** It means a genuinely irreversible action is on the
  other side (migrations on live data, secrets, destructive ops, external infra) — no
  `risk_tolerance` setting is meant to bypass it, at any tier.
- **Don't hand-edit an installed copy and then blindly re-run `install.sh`.** It's a plain
  copy, not a merge (see Install, above) — it will clobber local changes silently.

## FAQ

**What if I want to change my answer to a prep question mid-project?** Edit the front matter
in `notes.md` directly — nothing enforces it as read-only, it's just read once at project
start and otherwise trusted. Downstream commands will pick up the new value on their next read.

**What happens if I never run `/dstack-retro`?** Nothing breaks — ticket-level re-spec and
findings-absorption both work independently of it. You just lose the cross-project learning
loop: process-level patterns (like a recurring blocker shape) stay invisible if nobody ever
reads the accumulated history as a set.

**Can I use this without Claude Code?** Not yet, out of the box — only the `claude-code`
harness adapter is built. The spec itself (`spec/llm-coding-workflow.md`) is deliberately
harness-agnostic prose with no tool-specific syntax, so a new adapter is meant to be a thin
translation layer, not a rewrite. See `harnesses/_template/README.md` if you want to build one.

**Does this work for a bug fix or refactor, not just a new feature?** Yes — the planning skill
asks what kind of work it is up front and compresses the three passes sensibly for anything
that isn't a full new feature. A one-line bug rarely needs a Pass 2 architecture rewrite; use
judgment rather than forcing the full ceremony every time.
