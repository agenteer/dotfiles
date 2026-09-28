#!/usr/bin/env bash
# Apply the existing lock to both halves. Build failures stop before either activation.
# Activation is sequential, not atomic: a system activation failure can follow a successful account activation.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$DIR"

# These are flake output names, not the computer's display name.
DARWIN_HOST="${DARWIN_HOST:-mac}"
HM_PROFILE="${HM_PROFILE:-$(id -un)}"

if ! command -v home-manager >/dev/null 2>&1; then
  echo "home-manager is missing. Finish ./bootstrap.sh first, then open a new terminal." >&2
  exit 1
fi

# ln -sfn would put a link inside an existing directory, not replace it.
# Preserve legacy data and require an intentional migration of this location.
if [[ -e "$HOME/.dotfiles" && ! -L "$HOME/.dotfiles" ]]; then
  echo "Refusing to replace existing ~/.dotfiles data; preserve and migrate it before rebuilding." >&2
  exit 1
fi

echo "==> Build both configurations from flake.lock"
nix build --no-link --no-update-lock-file \
  ".#darwinConfigurations.\"${DARWIN_HOST}\".system" \
  ".#homeConfigurations.\"${HM_PROFILE}\".activationPackage"

# home.nix's links use this stable location. Change it only after both builds succeed.
ln -sfn "$DIR" "$HOME/.dotfiles"

# No root activation here. Preserve a colliding hand-written file with the existing backup policy.
echo "==> Your account"
home-manager switch --no-update-lock-file --flake ".#${HM_PROFILE}" -b backup

# Full path: an older shell or sudo may not have darwin-rebuild on PATH.
echo "==> System (Touch ID, or your password)"
sudo /run/current-system/sw/bin/darwin-rebuild switch --no-update-lock-file --flake ".#${DARWIN_HOST}"
