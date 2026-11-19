# Tickets and branches — the ticket table, branch names, and the branch-first step

Shared reference for every dstack command that writes or reads a ticket set (`/dstack` Pass 3,
`/dstack-ticket`, `/dstack-yolo`, `/dstack-retro`) and for any script that parses one. See
`llm-coding-workflow.md`'s "One ticket, one branch, one PR" section for the reasoning; this file
is the mechanics.

The rule: **every ticket that changes code has exactly one branch and one PR, and the ticket
table names that branch.** Tools read the name from the table. Nothing invents one at checkout.

## The ticket table

Pass 3 writes the ticket set as a Markdown table, for both forks:

- **Fork A (Linear):** in the living doc (`notes.md`, or `README.md` where that is the project's
  living doc), in its ticket-set section.
- **Fork B (local):** in `TODO.md`, under `## Tickets`.

The first four columns are required, with exactly these names, in this order:

```markdown
| Ticket | Branch | Scope | Blocked by |
```

Optional columns may follow, in any order (`Phase`, `Days`, …). Scripts find a ticket table by
this header row, not by the heading above it, so a doc may split its tickets across several
tables (one per milestone, say) as long as each one starts with this header.

Fork B:

```markdown
| Ticket | Branch | Scope | Blocked by | Phase |
|---|---|---|---|---|
| [x] [D1](tickets/D1.md) | `feature/d1-schema-migration` | Schema migration | — | 1 |
| [ ] [D5](tickets/D5.md) 🎨 | `feature/d5-unsubscribe-pause-link` | Unsubscribe/pause link | D2, D3 | 3 |
```

Fork A:

```markdown
| Ticket | Branch | Scope | Blocked by | Phase |
|---|---|---|---|---|
| A1 [ENG-101](https://linear.app/acme/issue/ENG-101) | `feature/eng-101-a1-check-access-before-serving-files` | Check access before serving files | — | 1 |
| A2 🚧 [ENG-102](https://linear.app/acme/issue/ENG-102) | — | Upload spike on the review bucket | — | 1 |
| A3 ✂ [ENG-103](https://linear.app/acme/issue/ENG-103) | `feature/eng-103-a3-scan-pipeline` | Scan pipeline: webhook, verdict job, reconcile job | A1, A2 | 2 |
```

### Cell rules — what a script can rely on

- **Ticket** — these parts, in this order, separated by spaces:
  1. **Status box — Fork B only**, and required there: `[ ]` open · `[~]` in progress · `[x]`
     done · `[!]` blocked. A Fork A row has **no** status box: Linear is the only source of
     Fork A status (see Status, below).
  2. **Local id** — letters then digits, no dash (`D3`, `MA12`). Plain, or as a link to its
     detail file (`[D3](tickets/D3.md)`). Fork A tickets have a local id too.
  3. **Markers**, if any — 🚧 human gate · 🎨 touches visible UI · ✂ may split into more than
     one PR at its plan gate. They may be written together (`✂🎨`).
  4. **Fork A only:** the issue link, `[ENG-101](url)` — a team key, a dash, a number.
- **Branch** — one of:
  - `—`: the ticket changes no code (a spike, infra, a rollout, a flag flip). No branch, no PR.
  - One or more branch names, each in backticks, separated by `, `. The first is the ticket's
    branch. More names appear only when the ticket split into more PRs (branch-first step,
    rule 6).
  - Empty: the name was never filled in. The branch-first step fills it before it does anything
    else (rule 1).
- **Scope** — one line. A literal `|` is written `\|`.
- **Blocked by** — local ids separated by `, `, or `—` for none. A note in parentheses after the
  ids is allowed (`A3, A4 (built after A9)`); scripts ignore it. Readers treat `none` like `—`.

There is no `Blocks` column: it is the reverse of `Blocked by`, and a second copy would drift.
Derive it when you need it.

### Legacy: bullet ticket sets

Projects from before the table list tickets as bullets (`- [ ] **D3** Title — blocked-by: D1 ·
…` in Fork B, `- [ ] [ENG-101](url) Title` in Fork A). Every command still reads them. Pass 3
no longer writes them. Boxes in a Fork A doc — bullets or an older table — are ignored: never
read for status, never ticked. A bullet has no Branch, so the branch-first step treats it like an empty
Branch cell: offer to convert the whole ticket set to the table, filling every Branch (§ Branch
names), rather than writing one name into one bullet. The user confirms before it's converted.

## Status

- **Fork B:** the status box in `TODO.md`'s ticket table. `[x]` means built, verified, and
  committed on the ticket's branch; its PR may still be open, and a dependent ticket stacks on
  it (branch-first step, rule 4). The box is flipped on the ticket's own branch, in the same
  commit as its code.
- **Fork A:** Linear only. The table has no status box, and nothing else in the repo records
  Fork A status. Read it fresh when it's needed — one `list_issues` call for the project's
  issues per pick, which gives every ticket's state for the eligible frontier. Set it in Linear
  on each transition: the team's started status (status type `started`) when work on the ticket
  begins, its completed status (type `completed`) when the work is done — Linear's GitHub
  integration may do the second when the PR merges, if the team turned that on. Never write
  Fork A status into the doc.

## Branch names

Pass 3 fills the Branch cell when it creates each ticket. So does anything that adds a ticket
later: a finding spawned as a new ticket, a new dependency found mid-execution.

- **Fork A:** create the Linear issue first, then read its `gitBranchName` and copy it
  verbatim. Linear's team settings decide the format. The issue id inside the name is what lets
  Linear link the branch and PR to the issue, and move the issue's status if the team turned
  that on. Keep the copy even if the issue's title changes later: Linear recomputes its
  suggestion, ours stays fixed.
- **Fork B:** fill `branch.pattern` from `./dstack-config branching <project>` (default
  `feature/<id>-<slug>`):
  - `<project>` — the project's folder name under `doc/dstack/`.
  - `<id>` — the local id, lowercase (`D3` → `d3`).
  - `<slug>` — from the Scope: first drop anything shaped like an issue id (`ABC-123`), so the
    branch can't link to an unrelated Linear issue by accident; lowercase it; turn every run of
    characters other than `a-z0-9` into one `-`; trim `-` from both ends; if it's longer than
    40 characters, cut it at the last `-` within 40 (or at 40, if there is none).

  Fork B ids restart at `D1` in every project, so before writing a name, check it isn't already
  taken — by a branch (local or on `origin`) or by a row in another project's ticket table. If
  it is, put the project in front of the id (`feature/<project>-<id>-<slug>`).
- **No code:** `—`.

## The branch-first step

Used by `/dstack-ticket` (Step 7, right after the pick is confirmed) and `/dstack-yolo` (the
start of Step 4, for every ticket). It runs **before any file edit for the ticket** — its detail
file, its Fork B status box, its code — so all of that lands on the ticket's branch.

Read the settings first: `./dstack-config branching <project>` gives `tool`, `trunk`, and
`submit`. With `tool: graphite`, run every `gt` command with `--no-interactive` (an agent can't
answer its prompts); if `gt` isn't installed, or the repo isn't set up for it, stop and say so —
never fall back to raw git in a repo that asked for Graphite.

1. **Read the ticket's Branch cell.**
   - `—` → skip the rest of this step; the ticket has no branch and no PR. Stay where you are,
     and leave its doc edits (status, re-spec) uncommitted: they ride on the next ticket's
     branch (rule 2). If no ticket follows in this session, say so and leave them for the user.
   - Empty, or a legacy bullet → fill it first (§ Branch names), write it into the table, then
     go on. Never use a name that isn't in the table.
2. **Check the working tree** (`git status --porcelain`).
   - Clean → go on.
   - Only dstack doc edits under `doc/dstack/<project>/` from this session (findings triage, a
     no-code ticket's close-out) → they move to the ticket's branch. Set them aside now with
     `git stash push --include-untracked -- doc/dstack/<project>`, restore them with
     `git stash pop` after rule 5, and include them in the ticket's first commit.
   - Anything else → stop and ask. Never carry unrelated changes onto a ticket branch.
3. **Sync.** Graphite: `gt sync --no-interactive`. Git: `git fetch --prune origin`.
4. **Pick the parent.** Look at the ticket's `Blocked by`. A blocker is a candidate when it has a
   branch and that branch is still **open** — it exists (locally or on `origin`) and is not
   merged. Merged means `gh pr view <branch> --json state --jq .state` prints `MERGED`, or the
   branch's tip is already in the trunk (`git merge-base --is-ancestor <branch>
   origin/<trunk>`).
   - No candidate → the parent is the trunk.
   - One → that blocker's branch (if it split, its last part).
   - Several → the one this ticket's code builds on. If the plan and the code don't make that
     clear, ask.

   Say which parent you chose. It is also the PR's base.
5. **Check out or create the branch.**
   - Already exists locally → check it out (`gt checkout <branch> --no-interactive` or
     `git switch <branch>`). Only on `origin` → `gt get <branch> --no-interactive` or
     `git switch <branch>`. Never create a second branch for the same ticket.
   - New → Graphite: `gt checkout <parent> --no-interactive`, then
     `gt create <branch> --no-interactive` (with nothing staged, it makes the branch without a
     commit). Git: `git switch --no-track -c <branch> <parent-ref>`, where `<parent-ref>` is
     `origin/<trunk>` for the trunk, or the blocker's branch (`origin/<branch>` if it isn't
     local). `--no-track` keeps the new branch from tracking its parent; the first push sets its
     upstream.
6. **A ticket that splits at its plan gate** (often one marked ✂) into more than one PR: the first
   PR keeps the table's name. Each extra part is named `<branch>-2`, `<branch>-3`, …, created by
   rule 5 with the previous part as its parent, and added to the same Branch cell
   (`` `x`, `x-2` ``). In Fork A the extra names still hold the issue id, so Linear links every
   part to the same issue.
7. **Report it** in one line: `On <branch> — new, from <parent>` or `On <branch> — existing`.

## One ticket, one PR

- Every commit on a ticket's branch carries the `Dstack-Project:` and `Dstack-Ticket:` trailers,
  in the commit's last paragraph. That's how `/dstack-retro` finds the ticket's history on any
  branch.
- **The first commit's subject is the PR title.** Fork A: start it with the issue id in
  brackets — `[ENG-101] Check access before serving files`. Fork B: start it with the local id —
  `D3: build the digest content`.
- When the ticket is verified and committed, its PR is ready. `branch.submit` decides who opens
  it:
  - `manual` (default) → don't push. Print the exact command for the user:
    - Graphite: `gt submit --no-interactive -d` (on the ticket's branch)
    - Git: `git push -u origin <branch> && gh pr create --draft --fill-first --base <parent>`
  - `draft` → run that command yourself. The PR opens as a draft; marking it ready, review, and
    merge stay human.

  `--fill-first` takes the title and description from the first commit, so the trailers are in
  the PR description too — they survive a squash merge that uses the PR description as the
  commit message.
- Ticket status after this follows § Status: Fork B's box was flipped in the ticket's own
  commits; Fork A's is set in Linear.

## Known limit — Fork B status on per-ticket branches

Fork B's boxes and Execution log live in `TODO.md`, and each ticket flips its own box on its own
branch, in the same commit as its code — that bundling is what keeps re-spec reliable. Two
consequences follow, and neither is solved here:

- **Sibling PRs conflict.** Two ticket branches cut from the trunk edit neighboring rows and the
  log's last lines; merging the second one conflicts there. Keep both sides' edits when
  resolving. Stacked branches don't hit this.
- **The trunk lags.** Until a ticket's PR merges, the trunk — and every branch cut from it —
  still shows that ticket's box as it was before the work (usually `[ ]`). What guards against
  redoing the work today: commands treat boxes as a hint and check the code, and the
  branch-first step finds the ticket's existing branch and checks it out instead of making a
  second one. A command reading `TODO.md` on a sibling branch can still list a built-but-unmerged
  ticket as open until it looks at that branch.
