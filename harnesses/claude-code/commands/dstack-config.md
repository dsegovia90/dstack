---
description: View and edit dstack config — standing instructions, at user, repo, or project level, that every later dstack command loads
allowed-tools: Bash(./dstack-config:*)
---

# dstack-config: standing instructions for future dstack commands

You are helping the user view and change **dstack config**: plain-prose settings that
`/dstack`, `/dstack-ticket`, `/dstack-yolo`, and `/dstack-retro` load at startup and follow.
Do this conversationally — show what exists, take the change in the user's own words, check it
against the other levels, and **confirm before writing anything**.

Read **`.claude/skills/dstack/config.md`** first — it defines the five levels, their files and
precedence, the limits on what config can do, and the file format. This command is the only
place those files get written.

## 1. Load every level

List the project folders under `doc/dstack/` (each subdirectory is a project; `config.md`
directly under `doc/dstack/` is the repo-level config, not a project).

Everything currently set, at every level and for every project, is below — you need all of it
in hand, not just the level being edited, for the conflict check in Step 5. Its closing rule
about config only changing through the config command is this command: here, you do write it.

!`./dstack-config load`

To find the file for a level that isn't set yet, run
`./dstack-config paths <project>` (omit the project for the three
non-project levels) — never derive the paths by hand.

## 2. Ask where the setting applies

`AskUserQuestion`:

- **Everywhere I use dstack** — all my repos.
- **This repo** *(recommended default)*.
- **One project in this repo** — only offer this if `doc/dstack/` has at least one project. If
  it has several, follow up asking which one; do not guess.

## 3. Ask who it applies to

Skip this step if the answer to Step 2 was "everywhere" — that level is always personal.
Otherwise, `AskUserQuestion`:

- **Just me** — stored under `~/.dstack/`, never committed, invisible to teammates.
- **Everyone** — stored under `doc/dstack/` and committed; anyone running dstack in this repo
  (or on this project) gets it.

Steps 2 and 3 together pick exactly one of the five levels. State which level and which file
that is before continuing.

## 4. Show the current config, then take the change

Present that level's current settings as a numbered list (or say plainly that it's empty).
Underneath, briefly list any settings from the *other* levels that are also in effect here, so
the user can see what they'd be adding to.

Then ask, in plain text rather than `AskUserQuestion` — this is an open input: **describe what
you want to add, remove, or change.** If the user already described a change when invoking the
command, use that instead of asking again.

## 5. Check the change before writing it

Turn the user's description into concrete setting bullets (see the file format in
`config.md`), then check each one:

- **Conflicts and duplicates across levels.** Compare against every other level loaded in
  Step 1. If the same setting already exists at another level, say so — it may not need adding.
  If it contradicts one, say which level wins under the precedence order and what that means in
  practice (e.g. "the repo config says X for everyone; this personal setting will override it
  for you only", or "the project config overrides this, so it won't take effect on
  `<project>`"). Let the user decide whether to keep, change, or drop it.
- **Hard gates.** If it would relax a 🚧 human-gate or skip the findings scan, don't write it —
  explain that no config level can do that.
- **Prep answers.** If it sets `team_shape`, `risk_tolerance`, `resumability_cadence`,
  `retro_cadence`, or `design_posture`: at the `user`, `repo`, or `user-repo` level, write it as
  a *default for new projects* and say that existing projects keep their recorded answer. At a
  project level, don't write it — point at that project's `notes.md` front matter, which is
  where the answer lives, and offer to edit that instead.
- **Repo facts.** If it's a fact about the codebase rather than an instruction about dstack
  (stack, ports, verify commands, conventions), recommend `CLAUDE.md` instead and let the user
  choose.

## 6. Confirm, then write

Show the exact resulting file content (or the before/after for the lines that change) and get
an explicit confirmation. Then write it — creating the file and any parent directories under
`~/.dstack/` if this is the level's first setting. Removing the last setting deletes the file
rather than leaving an empty one behind.

For a shared level, remind the user that the file is part of the repo and takes effect for
teammates once committed. **Do not commit it yourself.**

## 7. Close out

State what changed, at which level, and in which file, and that it applies from the next
dstack command onward. Ask whether there's another setting to change; if so, return to Step 2.
