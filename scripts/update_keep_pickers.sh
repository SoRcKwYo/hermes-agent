#!/usr/bin/env bash
set -euo pipefail

# One-command workflow:
# - Update Hermes (git pull + deps) via `hermes update`
# - Rebase the custom picker branch on top of the updated official main
#
# Notes:
# - Conflicts are possible when upstream edits the same code. If rebase stops,
#   resolve conflicts, then run: git rebase --continue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BRANCH="${1:-custom/pickers}"

echo "==> Updating Hermes via: hermes update"
hermes update

cd "$REPO_ROOT"

echo "==> Fetching official main"
git fetch origin main --quiet

echo "==> Switching to $BRANCH"
git switch "$BRANCH"

echo "==> Rebasing $BRANCH onto origin/main"
git rebase origin/main

echo "==> Done"
