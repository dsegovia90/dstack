# Coding with LLMs: The Planning-First Workflow

> **Thesis:** Productivity with LLMs is decided *upstream* of the model. The quality of the output is almost entirely a function of the planning that precedes it. The model is a strong **executor** of well-shaped work and a poor **inventor** of structure — so my job is to do the structuring, and let it execute.

---

## The shape of it

There is **one living artifact — the design doc** — and it goes through **three passes**, each applying a different lens to the *same* document. Tickets are satellites that hang off the doc, linked both to it and to *each other*. Then, inside every ticket, there's a **fourth, nested pass**: a micro-plan done in "plan mode" right before implementation.

```
Pass 1  Intake        product intent (design doc + rough tickets), handed down
Pass 2  Architecture  rewrite the SAME doc through an architectural lens
                      (ticket grooming falls out of this as a side effect)
Pass 3  Execution     add an "execution by phases" section to the SAME doc;
                      link tickets to the doc AND chain them to each other (a DAG)
   └─ Pass 4  Micro-plan   per-ticket "plan mode" before any code is written
```

It is **not** three (or four) separate files. Passes 1–3 converge on one enriched design doc plus a groomed, linked ticket set; Pass 4 is a per-ticket step at execution time.

---

## The four passes

### Pass 1 — Intake (the "what")
Work can arrive three ways: a **rough idea** with nothing written down yet, an **existing spec** someone already drafted, or a **technical plan** drafted elsewhere. This is the product/requirements layer — it says *what* we're building, not *how*. The job at this pass is to **assess what's already been answered and only elicit the rest**: a settled spec shouldn't get re-derived from scratch just because it wasn't authored inside this process; a blank idea gets the full set of guiding questions. Either way, the output is the same — `notes.md`'s Pass-1 sections, filled in wherever the input already answers them and elicited wherever it doesn't. Whatever this pass can't settle yet goes into the **open questions ledger** (see below), not a loose paragraph.

### Pass 2 — Architectural rewrite (the structural "how")
I **rewrite the design doc through an architectural lens.** This is the step I fully own — translating product intent into the *shape* of a solution. It's grounded in two durable layers established up front — the repo profile and, when the project has a visual surface, the design posture (see Grounding and Design posture, below) — plus a narrow, scoped look at just the area this feature touches.

Before adding anything new, this pass runs the **required confirmation pass** over every row the ledger inherited from Pass 1: each claimed "Resolved" gets its citation checked, not trusted on label alone (see Open questions, below).

Ticket grooming happens **as a side effect of this pass**, not as a separate chore, because re-architecting is exactly what reveals the real boundaries. During this pass I add descriptions to rough tickets, create new tickets the architecture implies, and rename/re-scope tickets so they map to genuine seams. Output: the same doc, now architectural, with a ticket set that reflects the true structure of the work.

### Pass 3 — Execution phasing + dependency chaining (the operational "how")
On that **same doc**, I add an **execution-by-phases** section and link the tickets in. Linking is two-directional:

- **ticket → doc** (each ticket points back to its place in the plan), and
- **ticket → ticket** (dependencies: what must exist before this, and what depends on this).

The ticket-to-ticket edges form a **dependency graph (DAG)**, and that single structure does double duty:

- **Roots** (tickets with no unmet dependencies) = where we can **start**.
- **Independent branches** (no shared edges) = what we can **parallelize**.

The phased order is essentially a topological read of that graph.

### Pass 4 — Micro-plan per ticket ("plan mode")
Inside each ticket node, before any code: a literal **plan mode** session with the model to settle the technical decisions. I sign off before it implements. This micro-plan carries **three jobs at once**:

1. **Implementation spec** — the technical decisions I approve before code is written.
2. **Reference for post-completion re-spec** — the ticket-level *intent* I later reconcile against the *reality* on disk (see Keystone).
3. **Bottom-up correction signal** — it surfaces micro-issues the macro architectural pass (Pass 2) overlooked, so detail discovered at the ground floor can flow *back up*.

---

## What makes the work LLM-shaped

### Chunk sizing — ~1–3 human-days
I size each ticket to roughly **1–3 days of *human* work** (no LLM help beyond autocomplete). The unit is deliberate: I size to **intrinsic task coherence, not tool speed.** Human-days are a stable measure of how much *meaning* sits in a chunk; "how long the LLM takes" is noise. The model then compresses the wall-clock time, but the *grain* of the work stays constant.

1–3 days is the sweet spot, bounded on both ends:

- **Ceiling = reviewability.** A 1–3 day chunk yields a diff I can actually review and verify — which is what makes the post-completion re-spec possible. Week-sized chunks make review the bottleneck and let divergence slip through uncaught.
- **Floor = coherence + overhead.** Smaller than ~a day and you lose the payoff of positional context, and grooming/ticketing overhead starts to dominate the real work.

In short: a chunk is **the largest unit I can still meaningfully review in one sitting.** On a team (see Prep questions below), tighten the ceiling toward 1–2 days — a reviewer who wasn't in the room writing the code needs a smaller diff to actually catch divergence.

### Positional context — the relationship *between* chunks
A ticket is never a self-contained island; it knows its **coordinates in the dependency graph**. Working a ticket, the model can:

- **Look backward** at its **upstream dependencies** to know *the current state of the world* — what's built, what it can assume exists and call into.
- **Look forward** at its **downstream dependents** to know *what seams to leave* — so it builds in a way that *sets up* the next work instead of painting it into a corner.

That forward glance is the subtle, high-value part: the difference between a chunk that merely *works* and one that *prepares* the next.

### Progressive disclosure of the dependency graph
The same graph exists at **two resolutions**:

- **The doc (Pass 3)** holds the cheap, high-level map — relationships written out, the skeleton.
- **The ticketing system** holds the navigable graph — real links between tickets, full detail behind each node.

So the model gets the skeleton for free and then **lazily traverses**: it decides whether to inspect an adjacent ticket at all, and how deep to go (direct neighbor most of the time; further up the cone only when needed). This is **context economy by construction** — you hand a map and let the model pull detail on demand, instead of pre-loading the whole transitive closure into the window.

### Two-resolution ticket detail — keeping the skeleton lean, permanently

The progressive-disclosure principle above only holds if the skeleton actually *stays* a skeleton. Left unchecked, a living doc tends to accrete full per-ticket detail directly into itself as work lands — scope prose, file lists, acceptance criteria, re-spec narratives all pile into the same document that started as a clean map. The failure mode is a single file that mixes stable, rarely-re-read intent/architecture prose with dense, constantly-growing per-ticket detail — expensive to load, and stale the moment anyone stops keeping the whole thing current.

The fix is structural, not a discipline to remember: **three tiers, not two.**

1. **The doc** (Pass 1–3 narrative) — intent, architecture, execution phasing. Stable. Full ticket bodies never live here past Pass 3; Pass 2's rough ticket-shaped seams are grooming output and stay light, but the moment Pass 3 forks to a ticketing backend, per-ticket detail moves out, not just grows in place.
2. **The skeleton** (the DAG artifact itself — a ticketing-system board, or a lightweight local file) — status, the dependency diagram, phases, and **one line per ticket**: id, title, blocked-by/blocks, phase, a pointer to tier 3. If you're about to write more than that one line into the skeleton, stop — it belongs in tier 3.
3. **Per-ticket detail** — scope, files, acceptance, the Pass-4 micro-plan, and the re-spec narrative once it exists. Created as a stub the moment a ticket enters the DAG (so pointers never dangle), filled in only when the ticket is actually picked — depth exists exactly where work has reached, not everywhere at once.

Where a ticketing system with its own navigable detail view already exists, it *is* tier 2+3 combined — don't also duplicate ticket scope/acceptance into the doc. That's pure redundancy with no sync guarantee: two copies of the same fact, one of which will eventually go stale. The doc references a ticket by id/link and a one-line title, full stop; the ticketing system is the sole source of ticket detail.

---

## Grounding: a durable repo profile vs. scoped per-feature research

A codebase's **slow-changing facts** — stack, conventions, directory layout, auth pattern, domain model overview, test framework — cost nothing to get wrong once and expensive to keep re-deriving. Left unhandled, this becomes a choice between two bad defaults: skip grounding entirely (Pass 2 architects blind, disconnected from what's actually on disk) or re-research the whole codebase before every feature (expensive, and mostly re-answering questions whose answers haven't moved).

The fix is the same shape as the two-resolution principle above: **split by how fast the fact changes, not by which pass needs it.**

- **Durable facts** (stack, conventions, auth pattern, layout, domain model, test framework) go in a **repo profile**, generated close to once per project, not once per feature. Prefer surfacing this in `CLAUDE.md` (or an equivalent project doc) if one exists or can exist — anything durable that lives there benefits every future session, not just this process's. Only fall back to a process-owned file for facts that genuinely don't belong in a general-purpose project doc.
- **Feature-specific facts** (the actual models/policies/routes/services a given feature touches) stay **scoped and fresh every time** — narrow enough that re-deriving them per feature is cheap, which is what makes freshness free instead of costly.
- The durable profile is **patched, not regenerated**, when scoped research contradicts it — the same post-completion-re-spec discipline applied to the profile doc instead of a ticket.

Getting this split wrong in either direction reproduces a known failure mode: too coarse (one big repeated sweep) pays the cost of staleness-avoidance on facts that weren't stale; too fine (no durable layer at all) pays the opposite cost, re-deriving stable facts on every single feature.

---

## Design posture: the same grounding discipline, applied to visual/UX decisions

Left unhandled, design decisions fall into the same trap as ungrounded architecture, just less visibly: nobody explicitly decided *how much* design rigor this project needs, so Pass 2 either invents visual decisions with nothing to check them against (drift, inconsistency across features, a different agent making different aesthetic calls each time) or drags a full design-system exercise into a project that never needed one. Neither is a deliberate choice — both are what happens when the question never gets asked.

The fix is to ask it explicitly, once, and split by the same volatility logic as the repo profile:

- **No visual surface at all** (a CLI, an API, a background job) is a legitimate answer — record it as a decision, not a silent skip, so a later reader knows design was considered and correctly ruled out rather than forgotten.
- **Durable ground rules** — an established design system, brand guidelines, component library, or a project's `DESIGN.md` (typography, color, spacing, motion, voice) — are established **once per project**, the same cadence as the repo profile. If they already exist, Pass 2 points to them; it doesn't re-derive them.
- **If a customer-facing surface has no ground rules yet**, establishing them deliberately, before Pass 2 goes far into component decisions, is worth the up-front cost — a design system authored after several features have already shipped inconsistent UI is expensive to retrofit, for the same reason an unrecorded repo profile is expensive to reverse-engineer later.
- **A project can also deliberately choose not to invest here** — an internal tool or admin surface where custom visual design would be over-engineering. That's a legitimate posture too, as long as it's the *stated* posture and not just an unexamined default.
- **Feature-specific visual decisions** (this feature's actual screens/components) stay scoped to Pass 2's Component architecture, grounded against whatever ground rules were established — same shape as the narrow, per-feature repo-profile look.

The output of this isn't prose buried in Pass 1 — it's a **recorded posture** (does this project have a visual surface, and if so what governs it) that Pass 2 can point back to instead of re-deciding per feature, and that later tickets touching UI can check their work against before calling themselves done.

---

## The context each ticket gets at execution time

- **Backward (state of the world):** the model reads **both** the **ticket** (intent, kept truthful — see Keystone) and the **actual code** on disk (reality), and reconciles them.
- **Forward (preparing the next step):** the model reads the **next ticket** *and* can climb to the **Pass-2 architecture** when the ticket is thin. Architecture is the stable source of intent and the tiebreaker; the ticket is the operational slice.

---

## The keystone: post-completion re-specification

The single most important habit — it's what stops the system from rotting.

> After completing a ticket, if the implementation **diverged** from the plan, I have the LLM **re-specify the ticket to match what was actually built.**

A ticket begins as *intent*; once the work lands, I reconcile it back to *reality*. So when a later step looks backward at this ticket, it reads an **accurate account of what's on disk**, not a stale promise. The ticket history becomes a **truthful changelog**, not a wishlist.

| Layer | Role | How it stays trustworthy |
|---|---|---|
| Architecture (Pass 2) | stable source of *intent* / tiebreaker | authored deliberately, by hand |
| Micro-plan (Pass 4) | ticket-level *intent* / spec | signed off before code |
| Tickets (Pass 3) | operational slices | kept truthful via post-completion re-spec |
| Code | ground-truth *reality* | it is the reality |

**What makes this actually reliable in practice — evidence, not aspiration.** Re-spec that depends on someone *remembering* to do it degrades quickly. What works is making it **structural**: bundling the re-spec edit into the same commit (or same PR/branch, even if later squashed) as the code that caused the divergence. When that bundling exists, re-spec happens close to universally, often within minutes of the code landing. When it doesn't — a ticket closes without a forced "does the ticket still match what you built" step — divergence survives uncorrected far longer, sometimes for weeks, and only gets caught if someone circles back deliberately. Design the ticket-closing step so re-spec is *part of* closing, not a follow-up task that can be skipped.

---

## Findings — absorbing freestanding discoveries

The re-spec keystone above only covers divergence discovered *while working a ticket*. A second, distinct source of divergence exists: things found **outside** the pick → plan → implement → re-spec loop entirely — an ad hoc code review, a security audit, a wireframe-vs-built-UI comparison, a "hey check this while you're in there" side observation. These produce real findings, but because they aren't attached to any ticket, nothing forces them back into the graph. Left alone, they become orphaned files: real work discovered, never scheduled, invisible to anyone reading the DAG.

The fix mirrors the re-spec keystone's own logic — give freestanding discoveries the same *forced* absorption path tickets already get:

1. **Every such artifact gets written down as a finding**, tagged with where it came from and when, in a place the process treats as *unfinished business until proven otherwise* (not a place items quietly accumulate).
2. **Before picking the next unit of work, scan for un-triaged findings.** This is a hard pre-step, not a reminder — the process doesn't get to move on to "what's next in the DAG" while something sits untriaged.
3. **Triage has exactly three legal outcomes**, and every finding must land on one: fold it into an existing ticket's scope (re-spec that ticket now, citing the finding, even before it's picked), spawn it as a new DAG node (it earns its own ticket — this is the *structural* half of Recovery's "add a ticket," below), or dismiss it with a one-line reason recorded in the finding itself. "Sitting unaddressed" is never a valid end state.

This is the same forcing function that already makes ticket-scoped re-spec reliable, aimed one level up — at the things that never became tickets in the first place.

Concretely, this artifact lives in the project itself (a file with `status:` frontmatter) regardless of which ticketing backend Pass 3 chose. This is deliberate, not an oversight: even a structured backend like Linear stays unopinionated about a dstack-internal process concern that isn't its own — it only ever sees the *outcome* of a triage decision (a new linked ticket, or a comment on an existing one), the same thing that would land there anyway.

---

## Open questions: a ledger, not a paragraph

Pass 1 (and, less often, Pass 2) surfaces things that can't be answered yet — a genuine fork the next pass needs more context to resolve. Left as loose prose ("open questions carried to Pass 2"), these degenerate fast: a later pass claims a question "resolved" in a clause, with nothing pointing at where the actual decision was made, and there's no way to tell a real resolution from an assumed one without re-deriving the whole judgment call by hand. This is exactly the same failure shape as an untracked finding — a genuine discovery with no forced path back into the graph — just aimed at *questions* instead of *discoveries*.

The fix mirrors the findings mechanism: **every open question is a row in a ledger, not a sentence in a paragraph**, and every row must carry one of exactly three statuses before the pass that owns it is considered done.

1. **Raise it as a ledger row**, not a bare bullet: an id (`Q1`, `Q2`, …), the question, and the pass it was raised in.
2. **Every row resolves to exactly one status before its owning pass finishes:**
   - **Resolved** — requires a **citation**: the specific section/heading in the *same* doc where the actual decision lives (e.g. `→ Pass 2 § Component architecture, digest/send-job.ts`). A row marked resolved with no citation, or a citation that doesn't actually address the question, is not resolved — it's an assumption wearing a resolved label.
   - **Deferred** — requires a **named target**: the specific pass or ticket it's deferred to (`→ Pass 3`, `→ ticket D4`), not "later" or "TBD." An un-named deferral is functionally identical to a dropped question nobody admitted dropping.
   - **Dropped** — requires a one-line **reason** (scope cut, superseded, no longer relevant).
3. **A pass isn't done while any inherited row is unaccounted for.** Carrying a question forward unchanged, or silently omitting it from the next pass's ledger, is not a legal outcome — same discipline as an untriaged finding.

**The required confirmation pass.** Whichever agent picks up the doc next — the same session moving to the next pass, or a fresh session resuming a project — does not get to trust an inherited "Resolved" label at face value. Before treating the ledger as settled, it must **walk every Resolved row, open the cited section, and state in one line what that section actually says and why it answers the question** — not just that the citation exists. A citation that turns out to point at the wrong section, or at prose that doesn't actually settle the question, gets its status reverted to open and re-raised in the current pass; the label alone was never evidence. This confirmation is what makes a ticket like `D4` in the reference project — blocked because Pass 2 left a scheduler decision open and it surfaced as a surprise at execution time — the exception rather than the norm: a genuinely-deferred row still shows up as a live blocker when its named target arrives, but it arrives *expected*, not discovered.

This is the same discipline as post-completion re-spec, aimed at claims instead of code: a resolution earns trust by being checked against the actual text, not by being asserted.

---

## Working a session

### Warm vs. cold context
After shipping ticket 1 (micro-plan → implement → submit for review), I'll often **start ticket 2's micro-plan in the same session**, because the **warm context** — the code and decisions already loaded — makes the next plan sharper and cheaper. This is the positional-context payoff cashed in: I just built the thing ticket 2 depends on, so the model is maximally primed.

**Tendency (not a law):** dependent tickets tend to chain inside one *warm* session; independent branches are natural candidates for separate, *cold*/parallel sessions. It's only a tendency because session boundaries are also set by plain **human rhythm** — I quit sessions at the end of a normal workday regardless of the graph. On a team, default to writing thicker forward-context into a ticket's detail (tier 3, above) than a solo project needs — the next person to pick it up is cold by default, not warm from having just built its dependency.

### When to stop — the tells of context rot
Chaining backfires on long sessions, and knowing when to cut it off is **an art, not a science.** The reliable tells:

1. **It stops understanding what you want built** — comprehension degradation.
2. **It rebuilds, or tries to rebuild, something already done this session** — it's lost track of in-session state.

Tell #2 is diagnostically perfect: trying to rebuild existing work means the model has **lost its grip on the "what's already built" backward-context** — the exact thing the positional-context system exists to guarantee. Context rot's signature is the in-session reappearance of the failure the structure is designed to prevent.

---

## When it goes wrong: recovery

Recovery operates at two scales, plus a floor:

- **Local — steer in place (default).** The issue is contained within the current ticket's scope; correct it conversationally and let it patch forward in the same session. Most failures end here, and **plan mode prevents many of them** by catching bad technical decisions before any code is written.
- **Structural — add a ticket to the chain.** Sometimes the micro-scale discovery is bigger than this ticket: it's not a defect, it's *newly revealed work*. It earns its own node in the dependency graph. This is the bottom-up correction signal becoming structural — the DAG **grows during execution** when reality reveals what the macro passes missed. (This is also the second of the three legal findings-triage outcomes, above, when the discovery came from outside a ticket rather than from inside one.)
- **Floor — cold restart.** When the problem is context *rot* rather than scope, abandon the session: fresh context, rebuild from the doc + the code on disk. The structured approach is the reliable floor that warm context only rises above temporarily.

**Distinguishing trigger:** is the issue *contained in the current ticket's scope* (steer) or does it represent *new work / a new dependency* (add a ticket)? Is it *logic/scope* (steer or add) or *context degradation* (cold restart)?

---

## The system flows both ways

The structure isn't purely top-down. It has a matching bottom-up current that keeps it honest:

- **Top-down:** product intent → architecture → phasing/DAG → micro-plan → code.
- **Bottom-up:** code → post-completion re-spec → truthful ticket; and micro-scale discovery → new ticket in the chain → (sometimes) architecture correction.

Two reconciliation mechanisms mirror each other: **re-spec reconciles a ticket's *text* to reality; adding a ticket reconciles the *graph* to reality.**

---

## The project outlives the launch

The project is **not** torn down at launch — it's a **durable context substrate** for the life of the system. After we ship to staging/production, we keep filing into the *same* project:

- **Bugs** — unforeseen defects and holes (the *corrective* evolution).
- **Fast-follows** — scope we deliberately punted past launch (the *intended* evolution).

Both join the **same dependency graph**, which means the model iterating post-launch drops into the same navigable history it had during the build — skeleton in the doc, drill-down via the ticket links — and can pull exactly the context it needs to fix a hole correctly. This is where the **re-spec keystone pays off long-term**: because the tickets were kept *truthful*, a bug filed months later (or a fast-follow touching old work) reads an accurate account of *what was built and why*, not a stale promise.

So "the graph is living" runs the **full lifecycle**: micro-discoveries grow it during the build (see Recovery), and bugs + fast-follows grow it after launch. Maintenance isn't a separate regime — it's the same machinery, still running.

---

## Retrospective — closing the loop on the loop

Everything above describes how a *project* stays honest while it runs. A separate, complementary question: how does the *process itself* get better across projects? Individual re-specs and findings are locally truthful, but nobody reads all of them as a set unless something makes that reading happen deliberately.

A retrospective pass does that reading. Periodically (at natural phase boundaries, and always at project close-out — see Prep questions below for setting the cadence), walk the project's actual history — not the aspirational plan, the *history*: completions against the original phased plan, every re-spec and what it reveals about where planning underestimated reality, blockers hit and how they resolved, findings absorbed vs. dismissed and why, and DAG-growth events (tickets added mid-execution are the bottom-up correction signal made visible as data, worth reading as a set, not just individually).

That reading produces two things:

1. **A project-scoped retrospective artifact** — the honest account of how this particular project unfolded, valuable on its own for anyone (including a future session with no memory of this one) trying to understand what actually happened here.
2. **Process-level observations** — did this project's actual chunk sizes, warm/cold pattern, blocker frequency, or re-spec timeliness match what this document predicts? Divergence that shows up once is noise; divergence that shows up across multiple projects is signal. Curate — by hand, deliberately, not by automatic aggregation — the process-observations that recur into wherever this document itself is maintained. This document should change when the evidence says so; a retrospective pass is what supplies that evidence instead of leaving it to guesswork or memory.

A retrospective is always a **human-confirmed suggestion**, never something that runs and rewrites process unattended — the whole point is that a person is deciding, from real evidence, whether the process needs to change.

---

## Prep questions

Before Pass 1 begins on a new project, a small number of questions shape how the rest of this process should run. They're asked once, the answers persist with the project, and downstream steps read them rather than re-deriving the same judgment call every time.

- **Team shape — solo, or a team (and roughly what size)?** This one measurably changes what makes the system reliable, not just what's convenient. The clearest evidence available: projects with a real PR/review cycle are where post-completion re-spec has actually proven reliable, because the review cycle is what forces the doc-update and the code-change into the same reviewed unit. A solo project with no review cycle has to earn that same reliability a different way — by making the ticket-closing step itself do the bundling (see Keystone) — which is achievable, but isn't automatic the way a team's PR process makes it. Team shape should therefore inform: which ticketing approach is likely to sustain reliable re-spec with the least extra discipline required, how tight the chunk-sizing ceiling should be (a reviewer who wasn't in the room needs a smaller diff), how "alternatives" in a ticket-pick get framed (pickable by someone else right now, vs. just a redirect for the same person), and how much forward-context a ticket needs to carry (a cold teammate vs. a warm original author).
- **Risk tolerance for autonomous execution — how much should the agent do without pausing for sign-off?** Ranges from gating every ticket before any code is written (the safe default) to full autonomy bounded only by hard gates on genuinely irreversible actions (migrations against live data, secrets/credential changes, destructive operations, external infra). Hard gates are never something a risk-tolerance setting relaxes — they exist because some actions are categorically different from "got the ticket wrong," not because the default is overcautious.
- **Resumability cadence — same day, days apart, or unpredictable/weeks between sessions?** A return after weeks needs real "since you were last here" scaffolding — a recap of what changed since the last touch — that a same-day return doesn't, and shouldn't pay the overhead of. Sized wrong in either direction, this either buries a frequent user in recap noise or leaves an infrequent one to reconstruct context from scratch every time.
- **Retro cadence — checkpoints at natural phase boundaries, or only at project close-out?** Sets when the retrospective pass above actually fires as a suggestion.
- **Version-control shape — one branch per project, one branch (and PR) per ticket, or straight onto trunk?** Sets how the ticket-closing step packages its work (see Tooling, below, for what each shape means and for the line between what this process owns about version control and what it leaves to the host repo). Team shape is the leading signal: a team's PR-per-ticket review cycle is the thing that makes re-spec reliable without extra discipline, so branch-per-ticket is the natural fit there; a solo project gets that reliability from the closing step's own bundling and can keep one branch per project with a PR at phase boundaries. Trunk is legitimate for solo work with no review surface at all — it just gives up the PR as a place to read the diff.

---

## Tooling

- **Model / interface:** an LLM coding agent, using **plan mode** (or the harness's equivalent) for the per-ticket micro-plan.
- **Ticketing — two forks, chosen per project, not prescribed globally:**
  - **Structured backend** (e.g. Linear) — the DAG lives in the ticketing system's own ticket↔ticket links; the doc holds the skeleton only. Natural fit when a real review/PR cycle already exists, since that cycle is what makes re-spec reliable (see Prep questions). The tradeoff: the ticketing system needs its own durable, timestamped account of divergence, since an issue description can be silently overwritten with no diff trail the way a version-controlled file has one — a comment narrating original-spec → actual-shipped → why, left before updating the description, is what gives a later retrospective something real to read.
  - **Local file-based** (a lightweight in-repo ticket file) — lighter-weight, solo/autonomous-friendly, and able to make the re-spec bundling *fully structural*: the ticket-closing step itself does status update + re-spec + commit as one atomic unit, with no review cycle required to force it. This is genuinely competitive with a structured backend for reliability, specifically because that bundling is a designed property of the closing step, not an emergent property of someone else's review process.

  Team shape (Prep questions) is the leading signal for which fork suits a given project, stated as reasoning, not a silent default — either fork can work; the question is which one costs the least extra discipline to keep reliable given how the project is actually staffed.
- **Source of truth for reality:** the **code on disk**, read alongside tickets at execution time.
- **Version control — what this process owns, and what it doesn't.** It owns exactly three things, and holds them for every project regardless of shape:
  1. **The unit.** One ticket = one commit that bundles the code, the ticket's re-spec, and its status change (the Keystone's structural bundling). A ticket's work is never split across commits that could land separately, and a closing commit is never rewritten once it's been pushed or a PR opened on it.
  2. **The trailers.** Every ticket commit carries `Dstack-Project: <project>` and `Dstack-Ticket: <id>` — what makes a project's history findable after branches are merged and deleted.
  3. **The shape**, chosen once per project (Prep questions):

     | shape | branch | commit | PR |
     |---|---|---|---|
     | branch-per-project | one working branch per project, cut from trunk at the first ticket | one per ticket | at a phase boundary or close-out, suggested alongside the retro |
     | branch-per-ticket | one branch per ticket, cut from trunk — or, when a dependency's PR is still open, stacked on that branch | one per ticket | one per ticket; the ticket's re-spec section is the PR body |
     | trunk | none — commits land on trunk directly | one per ticket | none |

     Branch names: for a local ticketing fork, `dstack/<project>` or `dstack/<project>/<id>-<slug>`; for a structured backend that issues its own branch name per ticket (Linear does), use that name verbatim — the backend's auto-linking depends on it, and its format is the backend's setting, not this process's.

  It does **not** own — and deliberately reads from the host repo's own conventions (`CLAUDE.md` or equivalent) rather than setting — merge strategy (squash vs. rebase vs. merge), CI requirements, review rules and who approves, branch protection, PR templates, release tagging. Those are properties of the repo, not of how work is planned; a process that dictated them would be wrong for most repos it was installed into. Hard gates (🚧) are unchanged by any of this: no shape makes a destructive git operation — force-push, history rewrite — acceptable.

---

## Principles, distilled

1. **Plan upstream; the model executes.** Output quality is set before the model ever writes a line.
2. **One living doc, three passes; a fourth nested per ticket.** Co-locate intent, architecture, and phasing.
3. **Chain tickets into a DAG.** It yields *where to start* (roots) and *what to parallelize* (forks) for free.
4. **Size chunks to ~1–3 human-days** — to reviewable, coherent units, not to tool speed.
5. **Give each chunk positional context.** Backward = state to build on; forward = seams to leave.
6. **Disclose the graph progressively, at three tiers.** Doc = stable map; skeleton = one line per ticket; detail = created only where work has actually reached.
7. **Re-specify after completion — and make it structural.** Bundle the re-spec into the same commit/close-out step as the code, not a remembered follow-up; that's what actually makes it reliable.
8. **Give freestanding discoveries the same forcing function as tickets.** A finding isn't done being handled until it's folded in, spawned as a ticket, or explicitly dismissed — never left sitting.
9. **Chain warm, restart cold.** Exploit warm context across dependents; reset when it rots.
10. **Watch the two tells** — loss of comprehension, and rebuilding existing work.
11. **Recover at the right scale** — steer, grow the graph, or cold-restart.
12. **Keep the project alive past launch.** Bugs and fast-follows join the same graph, so the accumulated, truthful context stays queryable by the model for the life of the system.
13. **Retrospect on purpose.** Reading the accumulated history as a set — not just each entry individually — is what turns local honesty into process improvement over time.
14. **Ask what shapes the project before starting.** Team shape, risk tolerance, resumability cadence, retro cadence, and version-control shape aren't bureaucracy — each one changes a concrete downstream default that would otherwise be guessed at, differently, every time.
15. **Split grounding by volatility.** Durable repo facts prefer `CLAUDE.md` and get patched, not regenerated; feature-specific facts stay scoped and fresh every single time.
16. **Design posture is a decision, not a default.** "No visual surface," "deliberately utility-only," "follow the existing system," and "establish one now" are all legitimate answers — the failure mode is never picking one and letting Pass 2 invent it silently.
17. **Open questions are a ledger with required evidence, not a paragraph of good intentions.** Resolved needs a citation, deferred needs a named target, dropped needs a reason — and the next agent to touch the doc re-checks the citation before trusting the label.
18. **Own the unit, the trailers, and the shape of version control — nothing else.** One ticket is one commit bundling code + re-spec + status, always with trailers, packaged per the project's chosen branch/PR shape; merge strategy, CI, review rules, and release mechanics belong to the host repo.
