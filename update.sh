#!/usr/bin/env bash
# Deliberately refresh the lock, apply both configurations, then update Homebrew-owned apps.
# Run while present: the system activation can ask for Touch ID or your password.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$DIR"

# Keep an upgrade separate from unreviewed configuration changes. Do not stash or discard them.
if [ -n "$(git status --porcelain)" ]; then
  echo "Review and commit your pending changes before upgrading (git status)." >&2
  exit 1
fi

nix flake update
./rebuild.sh

# Ghostty is the template's only Homebrew app; home.nix disables its native updater.
# Explicit --greedy includes this self-updating cask under Homebrew ownership.
# If you add apps, choose their update owner; do not add native-owned apps to this command.
brew update
brew upgrade --cask --greedy ghostty

echo "==> Updated both configurations and the Homebrew-owned app. Review the lock before committing."
git diff -- flake.lock
