# dstack config — levels, loading, and limits

Shared reference for every dstack command (`/dstack`, `/dstack-ticket`, `/dstack-yolo`,
`/dstack-retro`, and `/dstack-config`, which edits what the others load). See
`llm-coding-workflow.md`'s "Config" section for the reasoning; this file is the mechanics.

Config is **standing instructions about how dstack itself should behave** — plain-prose
bullets, written once, applied to every later dstack command in their scope.

## The five levels

Who a setting applies to (just me / everyone) × where (everywhere / this repo / one project):

| Level | Applies to | File | Shared? |
|---|---|---|---|
| `user` | me, in every repo | `~/.dstack/config.md` | no |
| `repo` | everyone using dstack in this repo | `doc/dstack/config.md` | committed |
| `user-repo` | me, in this repo | `~/.dstack/repos/<repo-id>/config.md` | no |
| `project` | everyone working this dstack project | `doc/dstack/<project>/config.md` | committed |
| `user-project` | me, on this dstack project | `~/.dstack/repos/<repo-id>/projects/<project>.md` | no |

The table is in **precedence order, lowest first**: when two levels genuinely conflict, the
later row wins — narrower scope beats wider, and personal beats shared at the same scope.

Never derive these paths by hand — `dstack-config` (repo root, installed alongside
`dstack-update`, shared by every harness adapter) is the single implementation of both lookups:

- `./dstack-config paths [project]` prints one line per level (`level`,
  `shared|personal`, `exists|missing`, absolute path) in precedence order.
- `./dstack-config load` prints every level that's set, in precedence
  order, preceded by the rules for applying it.

`<repo-id>` comes from the `origin` remote, so every clone and worktree of the repo resolves to
the same personal files; a repo with no `origin` falls back to its main checkout's path.

## Loading

Commands don't load config themselves. In this adapter each one carries a single line —
`` !`./dstack-config load` `` — which the harness runs and replaces with
the script's output *before* the model sees the prompt. What gets loaded, in what order, and
the rules for applying it all come from the script, so changing any of that is a one-file
change and no command has a procedure to follow or skip. The project isn't known at that
point, so the output includes the project-level config of every project in the repo, labeled
by project; the rules tell the command to apply only the one it ends up working on.

The prompt-time injection is the only Claude-Code-specific part. The script, the file
locations, and the rules it prints are the same for every harness.

## Limits — what config can't do

- **It never relaxes a 🚧 human-gate or skips the findings scan.** Those are hard gates at every
  level, the same way no `risk_tolerance` tier relaxes them. A setting that tries to is ignored,
  and the user is told so.
- **It doesn't override a project's recorded prep answers.** `team_shape`, `risk_tolerance`,
  `resumability_cadence`, `retro_cadence`, and `design_posture` live in `notes.md` front matter
  once a project exists, and front matter wins. Config only supplies the *default* for those
  when a new project is created (see `SKILL.md` Step 1.5). To change a recorded answer, edit
  the front matter.
- **It isn't for facts about the repo.** Stack, conventions, ports, verify commands belong in
  `CLAUDE.md` (see `SKILL.md` Step 1.7), where every session reads them — config is read only
  by dstack commands.
- **It's scoped to dstack's own behavior.** A setting asking for something unrelated to how
  dstack plans, picks, executes, or retros isn't a dstack setting; flag it rather than act on it.

## File format

Plain markdown, one setting per bullet, written as an instruction. A `##` heading per topic is
fine once a file grows; nothing parses these files, so keep them readable rather than
structured.

```markdown
# dstack config — repo

- Never recommend the Linear fork here; this repo tracks everything in local `TODO.md`.
- Default `retro_cadence` to `close-out-only` for new projects.
- Branch names for `/dstack-yolo` are `feat/<project>`, not `dstack/<project>`.
```
