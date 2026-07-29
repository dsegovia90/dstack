---
project: digest-emails
team_shape: solo
risk_tolerance: gate-every-ticket
resumability_cadence: days-apart
retro_cadence: per-phase
repo_profile_location: mixed
last_session_at: 2026-06-14T09:00:00-06:00
---

# Digest Emails — Design Doc

_Illustrative reference project for the dstack v2 conventions. Fictional app: a saved-articles
tool. This doc shows the full shape end to end — a real project's Pass 1/2 prose will be
longer and more specific than this, but the structure and section names are the point._

---

## Grounding (Steps 1.6 – 1.7)

- **Step 1.6 — source material:** started from a two-sentence idea note ("people save articles
  and never come back — send a weekly digest"), not a full spec or plan. That note answered
  Product intent; everything else in Pass 1 below (Problem, MVP surface, Out of scope, Success
  criteria) was elicited fresh via guided questions, same as if nothing had been provided.
- **Step 1.7 — repo profile:** the host app's `CLAUDE.md` already covered stack, conventions,
  and testing; auth pattern and domain model overview weren't documented there yet, so those
  two dimensions live in [`repo-profile.md`](repo-profile.md) in this folder instead
  (`repo_profile_location: mixed`, front matter above). Pass 2's Data model and Component
  architecture below were grounded against both sources.

---

## Pass 1 — Intake

### Product intent

Users save articles into the app over the course of a week but rarely come back on their own.
A weekly digest email — "here's what you saved this week" — should pull lapsed users back in
without being spammy: one email per week, easy to pause, no dark patterns.

### Problem

Saved items with no re-engagement loop just accumulate and get forgotten, which makes the
"save for later" feature feel pointless in hindsight. A single well-timed weekly nudge is
enough; more than that risks feeling like spam and driving unsubscribes.

### MVP surface

- A per-user digest preference (on/off, day-of-week, timezone).
- A weekly job that builds and sends the digest to everyone with it enabled.
- The digest itself: a simple list of the week's saved items, no ranking/personalization logic
  in v1.
- A one-click pause link in every digest email (no login required).

### Out of scope for MVP

- Personalized ranking / "top pick" highlighting.
- Any cadence other than weekly.
- A/B testing subject lines or send times.

### Success criteria

Users who receive at least one digest have a measurably higher week-over-week return-visit
rate than users with digests disabled or no saved items. (Real measurement is a fast-follow;
MVP just needs the pipe built correctly.)

### Open questions carried to Pass 2

- Where does per-user send time/timezone come from — account settings, or inferred?
- What actually sends the email — existing transactional-email provider, or something new?
- What triggers the weekly job — app-level cron, or the hosting platform's scheduler?

---

## Pass 2 — Architecture

### Data model

```
digestPreferences
  userId        TEXT PK/FK -> users.id
  enabled       BOOLEAN default true
  dayOfWeek     INTEGER  -- 0-6, default 1 (Monday)
  timezone      TEXT     -- IANA tz name; added during D1 re-spec, see tickets/D1.md
  updatedAt     TEXT

digestSends
  id            TEXT PK
  userId        TEXT FK -> users.id
  sentAt        TEXT
  itemCount     INTEGER   -- how many saved items were included
  status        TEXT      -- 'sent' | 'skipped_empty' | 'failed'
```

`digestSends` exists so the weekly job is idempotent (don't double-send if the job re-runs)
and so support can answer "did user X get their digest" without grepping logs.

### Component architecture

- **`digest/preferences.ts`** — CRUD for `digestPreferences`, backing the settings UI.
- **`digest/content.ts`** — `buildDigestContent(userId, since)`: queries saved items since the
  last send, returns the render-ready list. No ranking logic in v1 — chronological, capped at
  a reasonable max count.
- **`digest/send-job.ts`** — the weekly job: for every user with `enabled=true` whose
  `dayOfWeek`/`timezone` say "now," build content via `digest/content.ts`, render, send via the
  existing transactional-email provider, write a `digestSends` row.
- **`digest/unsubscribe.ts`** — a signed, no-login-required link (`/digest/pause?token=...`)
  that flips `enabled=false`.

### Rough ticket-shaped seams (grooming falls out of this pass — DAG comes in Pass 3)

1. Schema migration: `digestPreferences`, `digestSends`.
2. Preferences UI (settings page addition).
3. Digest content builder + email template.
4. Scheduled send job wiring.
5. Unsubscribe/pause link.

---

## Pass 3 — Execution phasing + DAG

Ticket IDs: `D1`–`D5`.

### Dependency graph

```
D1 (schema)
  ├──> D2 (preferences UI)
  └──> D3 (digest content builder) ──┬──> D4 (scheduled send job) 🚧
                                      └──> D5 (unsubscribe link, also needs D2)
```

**Root:** `D1`.

**Phases:**
- Phase 1: `D1`
- Phase 2: `D2`, `D3` (parallelizable)
- Phase 3: `D4` 🚧, `D5` (parallelizable — `D4` needs `D3`; `D5` needs `D2`+`D3`)

Full ticket detail lives in `tickets/*.md`, one file per id — `TODO.md` carries only the
one-line skeleton per the two-resolution convention. See `TODO.md` in this same folder.
