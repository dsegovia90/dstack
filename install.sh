#!/usr/bin/env bash
#
# Install dstack into a target repo: copies the harness-agnostic spec, a
# self-update script (dstack-update), and one harness adapter's skill/command
# files into place, and stamps a .dstack-version file recording what was
# installed.
#
# This is a plain copy, not a merge: re-running overwrites whatever's already
# there. If the target repo has hand-edited its copy, review the diff after
# running this before committing — see README.md's "common mistakes" section.
#
# Usage: ./install.sh --harness <name> <path-to-target-repo>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: $0 --harness <name> <path-to-target-repo>"
  echo
  echo "Available harnesses:"
  for d in "$SCRIPT_DIR"/harnesses/*/; do
    name="$(basename "$d")"
    [[ "$name" == _* ]] && continue
    echo "  - $name"
  done
  exit 1
}

HARNESS=""
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --harness)
      HARNESS="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
        shift
      else
        echo "Unexpected argument: $1" >&2
        usage
      fi
      ;;
  esac
done

if [[ -z "$HARNESS" || -z "$TARGET" ]]; then
  usage
fi

HARNESS_DIR="$SCRIPT_DIR/harnesses/$HARNESS"
if [[ ! -d "$HARNESS_DIR" ]]; then
  echo "Unknown harness: $HARNESS" >&2
  usage
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Target repo does not exist: $TARGET" >&2
  exit 1
fi

echo "Installing dstack ($HARNESS adapter) into $TARGET"

# 1. Harness-agnostic spec -> target repo root.
cp "$SCRIPT_DIR/spec/llm-coding-workflow.md" "$TARGET/llm-coding-workflow.md"
echo "  spec/llm-coding-workflow.md -> llm-coding-workflow.md"

# 2. Self-update script -> target repo root, so a future update doesn't require
#    cloning this repo or remembering where install.sh lives.
cp "$SCRIPT_DIR/dstack-update.sh" "$TARGET/dstack-update"
chmod +x "$TARGET/dstack-update"
echo "  dstack-update.sh -> dstack-update"

# 3. Harness adapter files, whatever shape this harness needs.
case "$HARNESS" in
  claude-code)
    mkdir -p "$TARGET/.claude/skills" "$TARGET/.claude/commands"
    rm -rf "$TARGET/.claude/skills/dstack"
    cp -R "$HARNESS_DIR/skill/dstack" "$TARGET/.claude/skills/dstack"
    echo "  harnesses/claude-code/skill/dstack -> .claude/skills/dstack"
    for f in "$HARNESS_DIR"/commands/dstack-*.md; do
      cp "$f" "$TARGET/.claude/commands/"
      echo "  harnesses/claude-code/commands/$(basename "$f") -> .claude/commands/$(basename "$f")"
    done
    ;;
  *)
    echo "Harness '$HARNESS' has no install logic wired up in install.sh yet." >&2
    exit 1
    ;;
esac

# 4. Version stamp, so a target repo (or a human) can tell what it's running
#    and whether it's stale against this source.
VERSION="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")"
COMMIT="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo "uncommitted")"
# The canonical source repo, so /dstack-feedback knows where to file issues without
# depending on a local checkout. Prefer the actual remote (a fork stays a fork);
# fall back to the canonical URL when this checkout has no origin.
REPO="$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || echo "https://github.com/dsegovia90/dstack.git")"
REPO="${REPO%.git}"
cat > "$TARGET/.dstack-version" <<EOF
version=$VERSION
commit=$COMMIT
harness=$HARNESS
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")
source=$SCRIPT_DIR
repo=$REPO
EOF
echo "  .dstack-version written ($VERSION @ $COMMIT)"

echo
echo "Done. This was a plain copy, not a merge — review 'git diff' in the target repo"
echo "before committing, especially if it already had a dstack copy in place."
echo "Next time, run './dstack-update' from inside $TARGET to pull the latest."
