#!/usr/bin/env bash
# Shows what is on this machine that the folder does not know about: the residue a "try it for five
# minutes" habit leaves behind. Nothing here is removed; you decide, line by line, whether it becomes
# one line in the folder or goes away.
set -uo pipefail
export PATH="/opt/homebrew/bin:/run/current-system/sw/bin:$PATH"

echo "== Homebrew: installed but not on the list (the next rebuild removes these)"
BREWFILE=$(grep -o '/nix/store/[a-z0-9]*-Brewfile' /run/current-system/activate 2>/dev/null | head -1)
if [ -n "$BREWFILE" ]; then
  # brew's own output ends with a hint to run "brew bundle cleanup --force", which would look for a
  # Brewfile in this folder and fail; the folder's answer is a rebuild, so that line is replaced.
  OUT=$(brew bundle cleanup --file="$BREWFILE" 2>/dev/null | grep -v 'brew bundle cleanup')
  if [ -n "$OUT" ]; then
    printf '%s\n' "$OUT" | sed 's/^/   /'
    echo "   The next ./rebuild.sh removes these. To keep one, add it to configuration.nix first."
  else
    echo "   (nothing)"
  fi
else
  echo "   (could not find the Brewfile the folder generated)"
fi

echo "== ~/.zshrc: lines an installer or you added by hand (the folder's own shell config lives in ~/.config/zsh)"
if [ -s "$HOME/.zshrc" ]; then grep -v '^\s*$' "$HOME/.zshrc" | sed 's/^/   /'; else echo "   (empty)"; fi

echo "== ~/.local/bin and ~/bin: programs installed by scripts, not by the folder"
ls -1 "$HOME/.local/bin" "$HOME/bin" 2>/dev/null | grep -v ':$' | sed 's/^/   /' || true

echo "== Nix: tools you tried with 'nix shell' leave nothing on the path; nothing to list."
