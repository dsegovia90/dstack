---
status: new
source: ad-hoc audit of the email provider's docs
date: 2026-06-13
---

# Email provider rate limits not accounted for

Skimmed the transactional-email provider's docs while unrelated to any ticket and noticed a
per-minute send-rate cap that `digest/send-job.ts` (D4, still blocked/not built) doesn't
account for in its current plan — if the user base grows past a few hundred same-timezone
Monday-morning sends, a naive loop could get throttled or rejected mid-run.

**Resolution:** not yet triaged. This is exactly the kind of item `/dstack-ticket` and
`/dstack-yolo`'s findings-scan pre-step exists to catch before the next ticket gets picked —
in this reference project it's left `status: new` on purpose, to show what that scan surfaces
when it runs. A real session would triage this now: most likely folded into D4's scope (it's
not built yet, so this can just become part of D4's plan) rather than spawned as a separate
ticket.
