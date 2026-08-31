#!/usr/bin/env bash
# Run this when you want the machine current; nothing in this folder does it for you.
# It moves every pinned version to today's, rebuilds your account (the tools and the three coding agents),
# brings the Homebrew apps current, then prints what changed. No password: none of this runs as root.
#
# why the system half is not rebuilt here: it only changes when you edit configuration.nix, and that is the
# one rebuild that asks for your password. Run ./rebuild.sh after such an edit; it applies both halves.
set -euo pipefail
cd ~/.dotfiles
nix flake update
home-manager switch --flake ~/.dotfiles -b backup
brew update --quiet >/dev/null   # refresh Homebrew's catalog without its news feed
brew upgrade   # the Mac apps from Homebrew; they move here and nowhere else, and brew prints what it upgraded

# why: the two newest builds of your account, compared: one line per program that moved, old version to new.
# This is the update in words you can read; git diff flake.lock is the same fact as revisions.
echo "==> What changed in your account"
PROFILES="$HOME/.local/state/nix/profiles"
[ -d "$PROFILES" ] || PROFILES="$HOME/.local/state/home-manager/profiles"
NEW="$(ls -dt "$PROFILES"/home-manager-*-link 2>/dev/null | sed -n '1p')"
OLD="$(ls -dt "$PROFILES"/home-manager-*-link 2>/dev/null | sed -n '2p')"
if [ -n "$OLD" ] && [ -n "$NEW" ]; then
  nix store diff-closures "$(readlink -f "$OLD")" "$(readlink -f "$NEW")"
else
  echo "    (could not find two builds to compare under $PROFILES)"
fi
