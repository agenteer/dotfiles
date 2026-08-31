#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built machine: the system half, then your account half.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: personalize the configured username"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  # No question here: a person who walks away during the long build must not come back to a stalled script.
  echo "    flake.nix said user \"$FLAKE_USER\"; you are \"$REAL_USER\". Rewriting that one line to \"$REAL_USER\"."
  sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
  echo "    Review it later with: git diff flake.nix"
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

echo "==> Step 4: complete flake.lock as the current user"
# Complete flake.lock if an input is missing. Run as the user, so the root build
# below never writes a root-owned lock into this checkout.
(cd "$DIR" && nix flake lock)

echo "==> Step 5: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still pinned
# by this repo's flake.lock.
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's
# on PATH here. Resolve the absolute path first and invoke that instead.
NIX_BIN="$(command -v nix)"
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Step 6: first home-manager switch (your account: tools, shell, the three coding agents)"
# why the reverse of rebuild.sh's order: on a fresh Mac there is nothing for Homebrew's cleanup to take
# away, and the system step has to run first anyway to put Homebrew itself on the machine.
# The other half of the machine, and it asks for no password: it activates nothing as root.
# Fetched for this one run, the same way step 5 fetches darwin-rebuild, because the home-manager command
# is itself one of the things this step installs.
# "-b backup" renames a colliding hand-written file instead of stopping the whole thing.
"$NIX_BIN" run home-manager/release-26.05 -- switch --flake ~/.dotfiles -b backup

echo "==> Done. Open a new terminal window (existing ones do not pick up the new PATH), then use ./rebuild.sh for future changes - it runs both halves."
