#!/usr/bin/env bash
#
# Pull the latest dstack into this repo. Installed by install.sh as
# `dstack-update` at the target repo's root — run it from there, no need to
# clone the dstack source repo yourself or remember where install.sh lives.
#
# Fetches a fresh shallow clone of the canonical source each run (so this
# works for any user on any machine, with no dependency on a pre-existing
# local checkout), then re-runs that clone's own install.sh against this
# repo, using the harness recorded in .dstack-version.
#
# Same plain-copy semantics as a manual install: this is not a merge.
# doc/dstack/<project>/ is never touched. See README.md's "Install" and
# "Migrating a repo that already had dstack" sections.

set -euo pipefail

# install.sh (below) re-copies this exact file back into place at
# $TARGET_DIR/dstack-update. A running script must not be overwritten out
# from under itself mid-execution -- bash reads a script incrementally from
# disk, and once the file changes underneath it, further parsing breaks in
# confusing ways. Re-exec from a throwaway temp copy first, so the on-disk
# file this process is reading from is never the one install.sh rewrites.
if [[ "${DSTACK_UPDATE_REEXEC:-}" != "1" ]]; then
  TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  SELF_TMP="$(mktemp)"
  cp "${BASH_SOURCE[0]}" "$SELF_TMP"
  chmod +x "$SELF_TMP"
  DSTACK_UPDATE_REEXEC=1 exec "$SELF_TMP" "$TARGET_DIR"
fi

TARGET_DIR="${1:?internal error: missing target dir}"
REPO_URL="https://github.com/dsegovia90/dstack.git"

if [[ ! -f "$TARGET_DIR/.dstack-version" ]]; then
  echo "error: .dstack-version not found in $TARGET_DIR — is dstack installed here?" >&2
  exit 1
fi

HARNESS="$(grep '^harness=' "$TARGET_DIR/.dstack-version" | cut -d= -f2)"
if [[ -z "$HARNESS" ]]; then
  echo "error: couldn't determine harness from .dstack-version" >&2
  exit 1
fi

CLONE_DIR="$(mktemp -d)"
trap 'rm -rf "$CLONE_DIR" "$0"' EXIT

echo "-> fetching latest dstack (master) from $REPO_URL..."
git clone --quiet --depth 1 "$REPO_URL" "$CLONE_DIR"

echo "-> reinstalling (harness: $HARNESS)..."
"$CLONE_DIR/install.sh" --harness "$HARNESS" "$TARGET_DIR"

echo "-> done. doc/dstack/ (your project content) was never touched."
echo "-> this was a plain copy, not a merge: run 'git diff' before committing."
