---
status: absorbed
source: ad-hoc review while implementing D3
date: 2026-06-05
---

# Email deliverability review

While building D3's template, checked how a few major providers treat bulk-looking
transactional mail. Found: no `Reply-To` header was being set on the digest template, and
several providers' spam scoring weights that surprisingly heavily for anything that looks like
a one-way broadcast.

**Resolution:** folded directly into D3 (same ticket, since it's a one-line addition to the
template D3 already owns) rather than spawned as a separate ticket — see `tickets/D3.md`'s
re-spec section.
