#!/usr/bin/env bash
# Every change after the first build: one command. It applies both halves of the machine, in order.
# Two separate steps, not one: if the second fails, the first has still happened.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# why your account goes FIRST: the system step below has Homebrew remove every app not on its list, so when
# a tool moves from a Homebrew line to a Nix line, the Nix one is in place before Homebrew takes the old one away.
# why no password here: this half activates nothing as root.
# why "-b backup": if a file this folder manages already exists by hand, rename it and carry on.
echo "==> Your account"
if command -v home-manager >/dev/null 2>&1; then
  home-manager switch --flake ~/.dotfiles -b backup
else
  # why: the very first time, the home-manager command is what we are about to install, so it cannot be
  # the thing that installs it. This line fetches it for one run; every later run takes the branch above.
  nix run home-manager/release-26.05 -- switch --flake ~/.dotfiles -b backup
fi

# why the password here: this half activates as root, which is why it is the one you sit and watch.
# Full path on purpose: darwin-rebuild lives in /run/current-system/sw/bin, which an older
# terminal window (or sudo) may not have on its path.
echo "==> System (Touch ID, or your password)"
sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.dotfiles#mac
