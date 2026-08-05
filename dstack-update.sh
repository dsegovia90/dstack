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

REPO_URL="https://github.com/dsegovia90/dstack.git"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$TARGET_DIR/.dstack-version" ]]; then
  echo "error: .dstack-version not found in $TARGET_DIR — is dstack installed here?" >&2
  exit 1
fi

HARNESS="$(grep '^harness=' "$TARGET_DIR/.dstack-version" | cut -d= -f2)"
if [[ -z "$HARNESS" ]]; then
  echo "error: couldn't determine harness from .dstack-version" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "-> fetching latest dstack (master) from $REPO_URL..."
git clone --quiet --depth 1 "$REPO_URL" "$TMP_DIR"

echo "-> reinstalling (harness: $HARNESS)..."
"$TMP_DIR/install.sh" --harness "$HARNESS" "$TARGET_DIR"

echo "-> done. doc/dstack/ (your project content) was never touched."
echo "-> this was a plain copy, not a merge: run 'git diff' before committing."
