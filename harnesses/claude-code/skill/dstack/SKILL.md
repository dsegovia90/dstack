---
name: dstack
description: >-
  Interactive planning-first workflow guide for this repo (the "dstack" process).
  Use when the user types /dstack or says "dstack", or otherwise wants to start or
  resume planning a piece of work — primarily a NEW FEATURE, but also a bug, refactor,
  or research effort. Starts from a blank idea, an existing spec, or a drafted plan —
  it assesses what's already answered rather than re-deriving it. It asks guiding
  questions rather than dumping a doc: it advances ONE living design doc through Pass 1
  (intake) → Pass 2 (architecture) → Pass 3
  (execution phasing + ticket DAG), then forks ticketing to either Linear (hand off to
  /dstack-ticket) or a local TODO.md (hand off to /dstack-yolo). Project-specific.
---

# dstack — planning-first workflow guide

You are guiding the user through the planning-first engineering process defined in
**`llm-coding-workflow.md`** (repo root). **Read that file first** and treat it as the
source of truth for the method. Be conversational: **propose, ask, confirm** — do not
monologue, and do not start writing implementation code from this skill.

The method in one breath: **one living design doc**, advanced through three passes, with
**tickets as satellites chained into a dependency DAG**; a fourth, per-ticket plan-mode
micro-plan happens later at execution time (entered directly, in `/dstack-yolo` or on your
own), not here.

Use `AskUserQuestion` for every fork below — one question at a time, with the recommended
option first.

## Step 0 — Pick the project, then detect existing work (resume vs. fresh)

First, list the project folders under `doc/dstack/`.
- **Exactly one project folder:** assume that's the one we're working on (state which).
- **More than one:** do **not** try to reason out which is intended — **immediately ask the
  user which project we're working on** (`AskUserQuestion`) and wait.
- **None:** there's no existing project; proceed to Step 1 to start fresh.

Once the project is settled, look inside it for an existing living doc (`notes.md` or similar)
and/or a `TODO.md`.
- **If found:** name what you found and which pass it reached (scan its headers — does it
  have a Pass 2 / Pass 3 section? a ticket DAG? front matter with prep-question answers, see
  Step 1.5? a `design_posture` answer, see Step 1.8? a `rollout_posture` answer, see Step
  1.9?). Ask whether to **resume** that project (and at which pass) or **start something
  new**. If resuming, load it into context, skip Steps 1.5, 1.8, and 1.9 (their answers are
  already in the doc's front matter), and jump to the
  relevant step below. Before treating the doc as settled, run the **open questions ledger's
  required confirmation pass** (see Step 2) over any row still carrying a "Resolved" or
  "Deferred" status from a prior session — a resumed session is exactly the kind of consuming
  agent that doesn't get to trust an inherited label without checking it.
- **If none:** proceed to Step 1.

> Convention for this repo: each project gets its own folder `doc/dstack/<project>/` containing
> the living doc (`doc/dstack/<project>/notes.md`) and, for the local-ticketing fork,
> `doc/dstack/<project>/TODO.md` plus a `tickets/` and `findings/` subfolder (see Step 3).
> For a fully worked example of the complete shape, see `examples/reference-project/` in the
> dstack toolkit repo this was installed from.

## Step 1 — Establish intent

Ask: **what kind of work is this?**
- **New feature** *(primary path — optimize for this)*
- **Bug fix**
- **Refactor**
- **Research / exploration**

Keep the intent in mind; it sets the altitude (a bug rarely needs all three passes; a new
feature usually does). For non-feature intents, compress the passes sensibly rather than
forcing the full ceremony.

## Step 1.5 — Prep questions (new projects only)

Skip this step entirely when resuming an existing project — these answers persist in the
project's `notes.md` front matter and downstream steps read them from there. For a fresh
project, ask each of the following (see `llm-coding-workflow.md`'s "Prep questions" section for
the full reasoning behind each one) and write the answers into `notes.md`'s front matter before
Pass 1 content begins:

```yaml
---
project: <kebab-case-name>
team_shape: solo | small-team | larger-team
risk_tolerance: gate-every-ticket | gate-first-and-risky | full-autonomy-except-gates
resumability_cadence: same-day | days-apart | unpredictable-weeks
retro_cadence: per-phase | close-out-only
repo_profile_location: claude-md | dstack-file | mixed | none
design_posture: none | utility | existing | new
design_ground_rules_location: claude-md | design-md | dstack-file | n/a
rollout_posture: none | flags | staged
rollout_convention_location: claude-md | dstack-file | n/a
---
```

1. **Team shape** — *Solo (recommended default)* / Small team (2–4) / Larger (5+). This will
   inform the fork recommendation in Step 3 — say so now, briefly, so the question doesn't feel
   arbitrary.
2. **Risk tolerance for autonomous execution** — *Gate every ticket before any code (recommended
   default)* / gate only the first ticket of a session and anything that looks risky / full
   autonomy except hard gates. Note explicitly: whatever is chosen, 🚧 human-gates (migrations
   on live data, secrets/credentials, destructive ops, external infra) are **never** overridable
   at any tier — this setting only ever loosens things below that floor.
3. **Resumability cadence** — same day / days apart / *unpredictable, sometimes weeks apart*.
   If the answer is the latter two, later commands will surface a "since you were last here"
   recap before picking the next ticket; same-day work skips that overhead.
4. **Retro cadence** — *per-phase checkpoints (recommended default)* / close-out only. Sets when
   `/dstack-retro` gets suggested during execution (always human-confirmed, never automatic).

## Step 1.6 — Get grounded (source material)

Ask: **do you already have something to start from** — a rough idea, a feature spec someone
already wrote, a technical plan drafted elsewhere, an existing ticket — or are we starting
blank? *(Recommended: point me at whatever exists, even partial — starting blank is fine too.)*

If material is provided:
- **Assess it against Pass 1 / Pass 2 / Pass 3**, not against a blank template. Check whether it
  already answers Pass 1 (product intent, problem, MVP surface, success criteria), already
  contains Pass 2 decisions (data model, API shape, components), or already has a Pass 3
  execution/DAG breakdown.
- **Write whatever's already answered straight into the matching section(s) of `notes.md`** —
  don't re-derive it, don't re-ask the guiding questions it already settles. A one-line
  provenance note per section (where it came from) is enough.
- **Only run the guiding questions for what's genuinely missing or ambiguous** in the provided
  material. Treat this the same as resuming an existing project (Step 0): extend, don't replace.
- This assessment **sets the recommended entry pass for Step 2** — state it as a recommendation
  with reasoning (e.g. "this reads like a settled Pass 1 with no architecture yet, so Pass 2 is
  the natural entry point"), but still confirm via `AskUserQuestion` rather than deciding
  silently.

If nothing is provided, this step is a no-op — proceed to Step 1.7, then Step 1.8, then Step
1.9, then Step 2's Pass 1 as normal.

## Step 1.7 — Repo profile (existing codebases only)

Skip this step for a brand-new codebase with nothing built yet, and skip it when resuming (the
project's earlier answer persists in front matter as `repo_profile_location`). For work landing
in an existing repo, dstack needs a small set of **durable, slow-changing facts** — stack,
conventions, directory layout, auth pattern, domain model overview, test framework — *once per
project*, not re-derived per feature. These barely change day to day, so treat them as a
one-time-ish artifact rather than a per-feature cost.

1. **Check `CLAUDE.md` first, per-dimension** — not a binary exists/doesn't-exist check. For
   each fact dstack needs, does `CLAUDE.md` already answer it?
   - **Fully covered:** reference `CLAUDE.md` in the profile record, don't copy its content —
     one source of truth per fact, so the two never drift apart.
   - **Partially covered:** tell the user plainly what's there and what's missing (e.g. "your
     `CLAUDE.md` covers stack and conventions, but not the auth pattern or domain model") and
     ask, via `AskUserQuestion`: **add the missing pieces to `CLAUDE.md`** *(recommended — any
     future session benefits, not just dstack)*, or **consolidate everything into dstack's own
     file** (`doc/dstack/<project>/repo-profile.md`)?
   - **No `CLAUDE.md` at all:** same question, framed as *create one* (recommended, same reason)
     vs. a dstack-only file.
2. **Run the research process only for the missing dimensions** — never a full re-sweep of
   dimensions already answered.
3. **Record the destination decision** in the project's front matter
   (`repo_profile_location: claude-md | dstack-file | mixed`) so this is asked once per project,
   never once per feature.
4. **This profile is not what grounds an individual feature.** When Pass 2 runs for any given
   feature (Step 2, below), it should also do a **narrow, scoped look at just the area that
   feature touches** — done fresh every time, because scoping it down is what keeps it cheap, not
   caching it. The durable profile only gets *patched*, never wholesale regenerated, if that
   scoped look turns up something that contradicts it — the same discipline as post-completion
   re-spec, aimed at the profile doc instead of a ticket.

## Step 1.8 — Design ground rules (does this project have a visual surface?)

Skip this step when resuming (the project's earlier answer persists in front matter as
`design_posture`). Otherwise, ask once, via `AskUserQuestion` — see `llm-coding-workflow.md`'s
"Design posture" section for the full reasoning:

1. **No visual surface** — a CLI, an API, a background job. Record `design_posture: none` and
   move on; this is a deliberate answer, not a skipped question.
2. **Follows an existing design system** — a component library, brand guidelines, `DESIGN.md`,
   or Figma file already governs this. Ask where it lives, record it, and point Pass 2 at it
   rather than re-deriving it.
3. **Deliberately utility-only** — an internal tool or admin surface where a custom design
   system would be over-engineering. Record `design_posture: utility` as the explicit decision
   it is, not an unexamined default.
4. **Needs a design system established** — a customer-facing surface with no ground rules yet.
   Recommended: establish one now, before Pass 2 goes far into component decisions — a system
   authored after several features have already shipped inconsistent UI is expensive to
   retrofit. If the `design-consultation` skill (or equivalent) is available in this harness,
   offer to run it to produce a `DESIGN.md`; otherwise ask guiding questions directly covering
   aesthetic direction, typography, color, layout, spacing, and motion, and write the answers
   into `doc/dstack/<project>/design-ground-rules.md` (or `DESIGN.md` at repo root, same
   `CLAUDE.md`-preference logic as Step 1.7 — anything durable benefits every future session).

Record the answer and its location in front matter (`design_posture`,
`design_ground_rules_location`) so this is asked once per project. This step does **not**
replace Pass 2's per-feature visual decisions — once ground rules exist (or the
utility/none decision is recorded), Pass 2's Component architecture still makes this feature's
specific screens/components, grounded against whatever was established here.

## Step 1.9 — Rollout posture (does new behavior ship behind a flag?)

Skip this step when resuming (the project's earlier answer persists in front matter as
`rollout_posture`). Otherwise, ask once, via `AskUserQuestion` — see `llm-coding-workflow.md`'s
"Rollout posture" section for the full reasoning:

1. **No rollout mechanism** *(recommended default when nothing in `CLAUDE.md` or the codebase
   says otherwise)* — changes ship to everyone. Record `rollout_posture: none`; this is a
   deliberate answer, not a skipped question. Nothing below applies to this project.
2. **Feature flags** — a flag system governs new behavior. Ask where its **convention** lives:
   which flag service/library, how flags are named, how one is added/toggled/removed, and
   whether temporary flags are expected to be cleaned up. Same `CLAUDE.md`-first logic as
   Step 1.7: if it's documented there, point at it; if it's partially or not documented, ask
   whether to **add the missing pieces to `CLAUDE.md`** *(recommended)* or write them to
   `doc/dstack/<project>/rollout-convention.md`. Record `rollout_posture: flags`.
3. **Other staged rollout** — a beta cohort, per-tenant enable, canary, or similar. Same
   convention question and recording. Record `rollout_posture: staged`.

Record the answer and its location in front matter (`rollout_posture`,
`rollout_convention_location`). When the posture is `flags` or `staged`, three things follow
downstream — say so now, briefly, so the question doesn't feel arbitrary:

- **Pass 1 states the per-feature decision** (Step 2): a required *Rollout:* line under the
  MVP surface — behind which flag, defaulting to what, visible to whom — or *not flagged,
  because …*. Unknown yet → an open-questions ledger row, not silence.
- **Pass 3 marks flagged tickets 🚩 and adds a cleanup ticket** (Step 3) when the flag is
  temporary — removing a flag is work, and work gets a DAG node.
- **Ticket detail carries a `Rollout:` field** — flag name, default, cleanup ticket id — in
  `tickets/<id>.md` for Fork B and in the Linear issue description for Fork A, so whoever
  picks the ticket up (or reads the issue) sees the flag guidance without opening the doc.

## Step 2 — Establish the project + entry pass

If starting fresh, ask for a short **project name** (kebab-case) → this becomes
`doc/dstack/<project>/`. Then confirm **which pass we're entering** — if Step 1.6 assessed
provided material, put its recommendation to the user as the default option rather than asking
blind; otherwise ask directly:
- **Pass 1 — Intake:** the *what*. Product intent, the problem, the MVP surface, success
  criteria. If `rollout_posture` is `flags` or `staged` (Step 1.9), the MVP surface ends with
  a required **Rollout:** line — *behind flag `<name>`, default off, visible to <who>* or *not
  flagged, because <reason>* — decided here, not invented mid-ticket; if it genuinely can't
  be decided yet, it's a ledger row. Output: `doc/dstack/<project>/notes.md` with the Pass-1
  sections (plus the Step 1.5 front matter). Anything that can't be settled yet goes into an
  **open questions ledger**
  section — a table with columns id / question / raised-in-pass / status — not a loose bullet
  list. See `llm-coding-workflow.md`'s "Open questions" section for the exact row format.
- **Pass 2 — Architecture:** rewrite the *same* doc through a structural lens (data model,
  API, components, the *how*); ticket grooming falls out of this as a side effect. Ground it in
  the durable repo profile (Step 1.7), the design ground rules (Step 1.8) if the project has a
  visual surface, plus a narrow, scoped look at the specific area this feature touches — not a
  full-repo sweep.
- **Pass 3 — Execution phasing + DAG:** add an execution-by-phases section; turn the groomed
  seams into tickets chained by dependency (`blocked-by` / `blocks`), with roots and
  topological phases called out. **Keep this ticket set to one-liners in the doc itself** —
  full scope/files/acceptance per ticket is generated in Step 3, not written here.

Drive each pass by **asking guiding questions**, then writing the result into the *same*
living doc (never spawn parallel files for passes — it is one enriched artifact). Reference
the shape and section names used in `llm-coding-workflow.md` and, if you want a concrete
worked example rather than just the prose spec, `examples/reference-project/` in the dstack
toolkit repo.

**Before starting Pass 2 or Pass 3, run the ledger's required confirmation pass.** Walk every
row the ledger inherits from an earlier pass: for each "Resolved" row, open the section its
citation points to and state in one line what it actually says and why that answers the
question — don't just trust the label. For each "Deferred" row, check whether its named target
(this pass, or a specific ticket) has now arrived; if so, resolve it for real (with a citation)
or explicitly re-defer with a new target — it doesn't get to silently roll forward unchanged. A
row that fails this check reverts to open and gets re-raised in the current pass. Surface the
outcome briefly to the user (a one-line status per row is enough) rather than doing this check
silently — this is the forcing function, not a formality.

When a pass surfaces a genuine design fork (data model, embedding strategy, sync vs async,
etc.), put it to the user as an `AskUserQuestion` with a recommended option — don't decide
silently.

## Step 3 — Fork the ticketing backend

Once Pass 3 produces a groomed ticket set, ask **how tickets are tracked**. If `team_shape`
was answered in Step 1.5, state the correlation as reasoning, not a silent default: *the
PR/review cycle on a team is what makes post-completion re-spec reliable without extra
discipline; solo work has to earn that same reliability a different way (the ticket-closing
step doing the bundling itself, per Fork B below) — which works, but isn't automatic the way a
team's review process makes it.* Recommend Fork A for team-shaped projects and Fork B for solo
ones on that basis, but let the user pick either regardless.

**Regardless of which fork gets picked**, create an empty **`doc/dstack/<project>/findings/`**
folder now — findings live **in-repo for both forks**, deliberately never in the ticketing
backend itself. A structured backend like Linear stays unopinionated about a dstack-internal
process concern that isn't its own: it only ever sees the *outcome* of a triage decision (a new
linked ticket, or a re-spec comment on an existing one), the same thing that would land there
anyway. See `llm-coding-workflow.md`'s "Findings" section and `dstack-ticket.md` Step 3 for the
scan/triage mechanics.

### Fork A — Linear (structured / team / large, complex projects)
- The DAG lives in Linear (ticket↔ticket links); the doc holds the skeleton **only** — link +
  one-line title per ticket, nothing more. Linear is the sole source of ticket detail; don't
  duplicate scope/acceptance into the doc once Linear has it, that's redundancy with no sync
  guarantee.
- **Re-spec discipline:** a Linear description can be silently overwritten with no diff trail.
  Before updating a ticket's description to match what shipped, add a **Linear comment**
  narrating original-spec → actual-shipped → why. That comment thread is what a later
  `/dstack-retro` walks — treat it as append-only history, not scratch space.
- **Findings** stay in-repo (see the shared `findings/` note above), not in Linear — Linear
  only ever sees the *outcome* of a triage decision, never dstack's own pre-ticket bookkeeping.
- Hand off: tell the user to run **`/dstack-ticket`** to pick the next eligible ticket
  (it confirms each choice, and scans for un-triaged findings first — see below), then enter
  plan mode directly for that ticket's Pass-4 micro-plan.
- Record the Linear team/project used for *this* project in its living doc — `dstack-ticket.md`
  reads that per-project record rather than assuming a fixed team, since different dstack
  projects (or different repos) may use different Linear teams.

### Fork B — Local TODO.md (lighter weight / solo / autonomous) *(default for this repo today)*
- Generate **`doc/dstack/<project>/TODO.md`** as a pure **skeleton**: a status legend
  (`[ ] [~] [x] [!]`, plus 🚧 human-gate, 🎨 design-touching, and 🚩 flag-gated when the
  project's posture calls for it), the DAG diagram, roots +
  topological phases, and **one line per ticket** — `- [ ] **T3** Recipient mgmt — blocked-by:
  T1,T3 · blocks: T6,T7 · phase 3 · [detail](tickets/T3.md)` — plus only the last ~10 lines of
  the Execution log (older entries roll into `execution-log-archive.md`). Match the shape used
  in `examples/reference-project/TODO.md`. **If you're about to write more than that one line
  per ticket into `TODO.md`, stop — that content belongs in `tickets/<id>.md`.**
- Create **`doc/dstack/<project>/tickets/<id>.md`** as an empty stub for every ticket in the
  DAG right now, so the skeleton's links never point at nothing — scope/files/acceptance get
  filled in only when a ticket is actually picked (`/dstack-ticket` or `/dstack-yolo`).
- `findings/` already exists (see the shared note above) — this is where anything discovered
  outside the normal pick→plan→implement→re-spec loop (an ad hoc review, an audit) gets
  written, so it has a forced path back into the DAG instead of sitting as an orphaned file.
- Mark any risky or externally-dependent ticket (migrations on live data, secrets, infra) with 🚧.
- Mark any ticket that touches user-visible UI with 🎨 when `design_posture` is `existing` or
  `new` (Step 1.8) — unlike 🚧 this is **not** a hard gate, just a visible signal that the
  ticket's Pass-4 micro-plan and close-out should check its work against the design ground
  rules before the ticket is called done, so visual polish doesn't silently get skipped.
- Mark any ticket that puts behavior behind the flag with 🚩 when `rollout_posture` is
  `flags` or `staged` (Step 1.9) — same soft-signal semantics as 🎨: the micro-plan and
  close-out should confirm the flag is wired and defaults per the convention. Each 🚩
  ticket's `tickets/<id>.md` (or Linear description, Fork A) gets a one-line **Rollout:**
  field — flag name, default, cleanup ticket. **If the flag is temporary, add a cleanup
  ticket to the DAG now** — remove the flag + the dead path, `blocked-by` the last 🚩 ticket,
  in its own phase after launch — so removal is a node the next-ticket pick will find, not a
  reminder that rots. If the flag is permanent, say so in the Rollout line instead.
- Hand off: tell the user to run **`/dstack-yolo`** to autonomously work the whole DAG
  (findings scan → plan-gate per `risk_tolerance` → implement → verify → re-spec → loop), or
  **`/dstack-ticket`** if they just want the next ticket picked and confirmed without
  committing to the autonomous loop yet — both commands auto-detect this fork from the
  presence of `TODO.md`, no need to specify.

## Step 4 — Close out

Summarize: the project, the pass reached, the artifacts written (`doc/dstack/<project>/notes.md`,
and `TODO.md` + `tickets/` + `findings/` if Fork B). Tell the user the exact next command
(`/dstack-ticket` or `/dstack-yolo`). Remind them:

- if `rollout_posture` is `flags` or `staged`, every 🚩 ticket's close-out checks the flag
  against the convention, and the cleanup ticket is in the DAG — it'll surface on the
  frontier after launch, not need remembering;
- the **post-completion re-spec keystone** keeps tickets truthful, and it works best when it's
  bundled into the same commit/close-out step as the code — not left as a thing to remember;
- **freestanding findings** (audits, reviews) get written to `findings/` and get scanned before
  every ticket pick — nothing should sit there un-triaged;
- every row in the **open questions ledger** shows Resolved-with-citation, Deferred-with-target,
  or Dropped-with-reason before close-out — if anything's still bare, run the required
  confirmation pass now rather than leaving it for whoever picks the project back up;
- the project doc is a durable substrate — bugs and fast-follows file into the same DAG after
  launch;
- **`/dstack-retro`** is available any time (and will be suggested automatically at phase
  boundaries or close-out per the `retro_cadence` answer) to read back the project's real
  history and surface what, if anything, should change about how future projects run.
