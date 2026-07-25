---
status: dismissed
source: ad-hoc review while implementing D3
date: 2026-06-05
---

# Leftover column from early prototyping

Noticed `digestSends.itemCount` is currently unused by any read path — it's written on every
send but nothing displays or queries it yet.

**Resolution:** dismissed, not spawned as a ticket. It's cheap to keep (one column, already
written correctly) and plausibly useful later for a "how many items did this digest include"
support/debug view — removing it now would just mean re-adding it later if that need shows up.
Not worth a ticket either way at this scale; revisit only if it's still unused after the
project's next retro.
