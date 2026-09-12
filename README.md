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
2. **Get grounded, then check the repo profile and design posture:** before Pass 1 content
   begins, the skill asks whether you already have something to start from — a rough idea, an
   existing spec, a drafted plan — and assesses it against Pass 1/2/3 rather than re-deriving
   anything it already answers. It also checks whether the host repo's durable facts (stack,
   conventions, auth pattern, domain model, test framework) are already covered in `CLAUDE.md`,
   per dimension, before running any research. See `examples/reference-project/notes.md`'s
   "Grounding" section and `examples/reference-project/repo-profile.md` — in this example,
   `CLAUDE.md` covered three of five dimensions, so only the missing two were researched and
   written down, not the whole set. It then asks the same question about **design ground
   rules** (Step 1.8): does this project have a visual surface at all, and if so, does an
   existing design system/component library govern it, is it deliberately utility-only, or
   does one need to be established now before Pass 2 goes far? In the reference project,
   `design_posture: existing` — the host app's `CLAUDE.md` already documents its component
   library, so no new design work was needed, just a pointer to it.
3. **Pass 1 — Intake:** guided questions fill in whatever Step 1.6 didn't already answer — the
   "what": product intent, problem, MVP surface, success criteria. Anything that can't be
   settled yet becomes a row in the **open questions ledger** — an id, a status (resolved with
   a citation / deferred to a named pass or ticket / dropped with a reason), never a bare
   bullet. See `examples/reference-project/notes.md`'s "Pass 1" section and its "Open questions
   ledger" table. Written into `doc/dstack/<project>/notes.md`, the *same* file every later pass
   reuses — the ledger is mutated in place as later passes confirm or resolve its rows, not
   re-created.
4. **Pass 2 — Architecture:** the same doc gets rewritten through a structural lens — data
   model, components, the "how" — grounded against the repo profile from step 2 plus a narrow,
   scoped look at just the area this feature touches, not a full-repo sweep. Ticket grooming
   falls out of this pass as a side effect (see that doc's "Rough ticket-shaped seams" list) —
   it's not a separate step.
5. **Pass 3 — Execution phasing + DAG:** the groomed seams become real tickets (`D1`–`D5` in
   the reference project), chained by `blocked-by`/`blocks` into a dependency graph, with roots
   and topological phases called out. See that doc's "Pass 3" section for the diagram.
6. **Fork the ticketing backend:** Linear (structured/team) or a local `TODO.md` (lighter,
   solo-friendly) — see the Decision guide below for which. The reference project uses the
   local fork: `TODO.md` is generated as a **skeleton only** (one line per ticket, the DAG
   diagram, phases, a status legend) — full detail moves to `tickets/<id>.md`, created as empty
   stubs for every ticket right away so nothing links to nowhere.
7. **Pick and work a ticket:** the next-ticket command scans for untriaged `findings/` first
   (a hard gate — see below), computes the eligible frontier (open tickets with every
   dependency done), and presents its pick with reasoning and alternatives. Once confirmed, a
   plan-mode micro-plan happens before any code — cadence depends on the `risk_tolerance`
   answer. Compare `tickets/D1.md`'s "Scope (as planned)" section to its "Re-spec — what
   actually shipped" section: the plan changed once real implementation surfaced a wrinkle
   (needing per-user timezone, not just day-of-week), and the ticket was rewritten to match,
   in the same commit as the code.
8. **Findings show up mid-project too.** `findings/email-deliverability-review.md` is a
   discovery made *while* working D3, unrelated to D3's original scope — it got folded
   straight into that ticket rather than left to rot as a loose file. Compare
   `findings/rate-limit-audit.md`, still `status: new` in this example on purpose: that's what
   the next ticket-pick's findings scan is designed to catch before it gets ignored.
9. **Blockers get named, not hidden.** `tickets/D4.md` is `[!]` blocked — not because anything
   broke, but because the ledger's `Q3` (which scheduler to use) was deferred to this exact
   ticket back at Pass 1, reconfirmed still-open at every later ledger-confirmation pass, and
   simply arrived at its named target still unresolved — a tracked outcome, not a surprise. The
   🚧 marker means: don't push through this autonomously at any risk-tolerance setting, surface
   it to a human instead. Compare `tickets/D2.md` and `tickets/D5.md`'s 🎨 marker — a much
   lighter, non-blocking signal that a ticket touches UI and should be checked against the
   design ground rules (Step 1.8) before it's closed.
10. **Retro, on the cadence you asked for.** `retros/2026-06-14-retro.md` was triggered at a
   phase boundary (`retro_cadence: per-phase`) — it reads the *real* history (git log, ticket
   files, findings) rather than the plan, and ends with process-observations worth watching for
   recurrence across other projects. Anything that does recur belongs in this repo's own
   `meta/process-notes.md`, pasted in by a human, not merged automatically.
11. **Friction with dstack itself gets logged, not remembered.** `/dstack-feedback <note>`
   writes one file to `doc/dstack/feedback/` — repo-level, not per project, because it's about
   the toolkit — with `status: new`, the installed version, and where you were. Costs nothing
   at logging time; the agent is told to do the same when it hits an ambiguous or missing
   instruction. Every ticket pick then gates those notes right after the findings scan: each
   one is **filed** as a GitHub issue on the dstack repo (via `gh`, on your say-so) or
   **dropped** with a reason. See `examples/feedback/` for the shape of one that was dropped.

## Install

```
./install.sh --harness claude-code /path/to/your-repo
```

This copies `spec/llm-coding-workflow.md` to your repo's root, the `claude-code` adapter's
skill + commands into `.claude/skills/dstack` and `.claude/commands/`, a `dstack-update` script
into the repo root (see Updating, below), and writes a `.dstack-version` file recording what was
installed and from where.

**What it deliberately does not do:** merge. It's a plain copy — re-running it overwrites
whatever's currently in the target repo's `.claude/skills/dstack`, `.claude/commands/dstack-*.md`,
and `dstack-update` itself. **Don't hand-edit any of those and expect it to survive an update —
put repo-specific facts in `CLAUDE.md` instead** (see Step 1.7 in the walkthrough above), where
install/update can't reach them and every session reads them anyway. That single move is what
actually prevents the drift described in "Common mistakes" below — not a merge-aware installer.

Only the `claude-code` harness adapter exists today. `harnesses/_template/README.md` describes
what a new adapter needs to provide if you want to wire dstack into a different coding agent.

## Updating

Once installed, pull the latest dstack from inside the target repo itself — no need to clone
this repo or remember where `install.sh` lives:

```
./dstack-update
```

This fetches current `master` fresh (a shallow temp clone, cleaned up after) and re-runs
`install.sh` against your repo using the harness recorded in `.dstack-version`. Same plain-copy
semantics as a manual install — `doc/dstack/<project>/` (all your generated project content) is
never touched, and repo-specific facts living in `CLAUDE.md` are safe by construction. Review
`git diff` before committing, same as any install.

## Migrating a repo that already had dstack

If a repo already has a hand-copied, pre-standalone dstack (this described `wake`, `vanedoc`,
`cairn`, and `kairos` before this repo existed as the single source of truth) — or you've been
hand-editing an installed copy — do this **in order**, not ad hoc, because later steps assume
earlier ones already happened:

1. **Extract repo-specific facts first, before installing anything.** Read every hand-edited
   `dstack-*.md` / `SKILL.md` for facts that belong to *this repo*, not to dstack generally
   (ports, verify commands, directory conventions — anything a plain install would silently
   delete) and move them into `CLAUDE.md`. Do this **before** running install — once install
   overwrites the file, whatever wasn't extracted is gone with no diff to recover it from.
2. **Install.** `./install.sh --harness claude-code .` (there's no `dstack-update` yet on a
   first install). Only after this can front matter honestly say
   `repo_profile_location: claude-md` — that field means the extraction in step 1 actually
   happened, not "I intend to get to this."
3. **Backfill `notes.md` front matter** on any project whose doc predates the four prep
   questions. Until it's filled in, every command falls back to that question's recommended
   default rather than leaving it silently unset — see "What if a prep answer is missing?" in
   the FAQ below.
4. **Split a fat `TODO.md`** into the skeleton + `tickets/<id>.md` shape if the project predates
   that convention (a `TODO.md` with full ticket bodies inline, rather than one line per
   ticket). Do this last, after the doc structure around it is already current.

**Verify the split didn't drop anything.** This is the step where content actually goes
missing — a token-frequency comparison against the pre-split commit catches drops that reading
the diff alone doesn't (a locally-rewritten caption that quietly loses information while
*looking* like an improvement, for instance):

```bash
diff <(git show $SHA:doc/dstack/<project>/TODO.md | tr -cs '[:alnum:]' '\n' | sort | uniq -c) \
     <(cat TODO.md tickets/*.md execution-log-archive.md | tr -cs '[:alnum:]' '\n' | sort | uniq -c)
```

Any line only on one side of that diff is a word whose count changed — worth checking by hand.

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

**What design posture should I pick (Step 1.8)?**
- **Has a visual surface, and a system already governs it (brand guidelines, component
  library, `DESIGN.md`) → "existing."** Point Pass 2 at it; don't re-derive it.
- **Has a visual surface, but genuinely doesn't need custom design (internal tool, admin
  surface) → "utility."** This is a legitimate, deliberate answer — say so explicitly rather
  than let it default silently.
- **Has (or will have) a customer-facing surface with no ground rules yet → "new."**
  Recommended: establish them now, before Pass 2 goes far into component decisions — retrofitting
  a design system after several features have shipped inconsistent UI costs more than settling
  it up front.
- **No visual surface at all (CLI, API, background job) → "none."** Also a deliberate, recorded
  answer, not a skipped question.

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
- **Don't let a `feedback/` note sit `new`.** Same reason as the findings gate: the one time
  the gate gets skipped is the time a real observation about the process quietly evaporates.
  File it or drop it with a reason — and never file on the agent's own initiative; that's an
  outward-facing action the human picks per note.
- **Don't mark an open question "resolved" without a citation.** A resolution needs to point at
  the specific section where the decision actually lives, and the next agent to touch the doc
  is expected to open that section and check it, not trust the label — a "resolved" with no
  citation (or one that turns out not to actually answer the question) is functionally an
  unexamined assumption wearing a settled-looking label.
- **Don't treat a 🚧 marker as advisory.** It means a genuinely irreversible action is on the
  other side (migrations on live data, secrets, destructive ops, external infra) — no
  `risk_tolerance` setting is meant to bypass it, at any tier.
- **Don't hand-edit an installed copy (or `dstack-update`) and then blindly re-run
  `install.sh`/`dstack-update`.** It's a plain copy, not a merge (see Install, above) — it will
  clobber local changes silently. Repo-specific facts belong in `CLAUDE.md`, not the vendored
  files — see Install and "Migrating a repo that already had dstack" above.

## FAQ

**What if I want to change my answer to a prep question mid-project?** Edit the front matter
in `notes.md` directly — nothing enforces it as read-only, it's just read once at project
start and otherwise trusted. Downstream commands will pick up the new value on their next read.

**What if a prep answer is missing from `notes.md`'s front matter** (e.g. a project that
predates the four prep questions, or one where only some got backfilled)? Every command falls
back to that question's stated recommended default from Step 1.5 rather than treating it as an
error: `team_shape` → `solo`, `risk_tolerance` → `gate-every-ticket`, `resumability_cadence` →
`same-day` (skip the recap), `retro_cadence` → `per-phase`. This is a deliberate default, not a
bug — see "Migrating a repo that already had dstack" above for backfilling it properly instead
of relying on the fallback indefinitely.

**How do I report a problem with dstack itself?** `/dstack-feedback "<what happened>"` the
moment you notice it — it writes a `doc/dstack/feedback/` note and stops. The next ticket
pick (or `/dstack-feedback` with no argument) walks every pending note and asks you to file it
as a GitHub issue on the dstack repo or drop it with a reason. The issue goes to the `repo=`
recorded in `.dstack-version` at install time (a fork stays a fork); an older install without
that line falls back to the canonical repo.

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
