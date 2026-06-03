#!/usr/bin/env bash
set -euo pipefail

# Script to commit and push changes in all submodules, then update the parent repo.
# Usage:
#   ./scripts/git-sync.sh "your commit message"

if [ $# -lt 1 ]; then
  echo "❌ Error: Commit message is required."
  echo "Usage: pnpm git \"your commit message\""
  exit 1
fi

COMMIT_MSG="$1"

echo "============================================="
echo "  Git Submodules & Parent Sync"
echo "  Message: ${COMMIT_MSG}"
echo "============================================="

echo ">>> [1/3] Committing changes in all submodules..."
git submodule foreach "git add . && git commit -m \"${COMMIT_MSG}\" || true"

echo ">>> [2/3] Pushing changes in all submodules..."
git submodule foreach "git push origin develop || true"

echo ">>> [3/3] Updating and pushing parent repository..."
git add .
git commit -m "chore: atualiza ponteiros dos submódulos" || true
git push origin develop

echo "============================================="
echo "  ✅ Done syncing all repositories!"
echo "============================================="
