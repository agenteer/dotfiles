#!/usr/bin/env bash
# Shows what is on this machine that the folder does not know about: the residue a "try it for five
# minutes" habit leaves behind. Nothing here is removed; you decide, line by line, whether it becomes
# one line in the folder or goes away.
set -uo pipefail
export PATH="/opt/homebrew/bin:/run/current-system/sw/bin:$PATH"

echo "== Homebrew: installed outside the declared inventory (ordinary rebuilds preserve these)"
BREWFILE=$(grep -o '/nix/store/[a-z0-9]*-Brewfile' /run/current-system/activate 2>/dev/null | head -1)
if [ -n "$BREWFILE" ]; then
  # No --force; closed stdin and captured stdout prevent an interactive cleanup confirmation.
  # Exit 1 is also Homebrew's normal result when it finds undeclared software.
  STATUS=0
  OUT=$(HOMEBREW_NO_AUTO_UPDATE=1 brew bundle cleanup --file="$BREWFILE" </dev/null) || STATUS=$?
  if [ "$STATUS" -eq 0 ] || { [ "$STATUS" -eq 1 ] && printf '%s\n' "$OUT" | grep -Eq '^Would (uninstall|untap)'; }; then
    REPORT=$(printf '%s\n' "$OUT" | grep -v 'brew bundle cleanup' || true)
    if [ -n "$REPORT" ]; then
      printf '%s\n' "$REPORT" | sed 's/^/   /'
      echo "   Report only. Declare software you want to manage; remove anything else deliberately."
    else
      echo "   (nothing reported)"
    fi
  else
    echo "   Homebrew inventory check failed (exit $STATUS); inventory is unverified." >&2
  fi
else
  echo "   (could not find the generated Brewfile; inventory is unverified)"
fi

echo "== ~/.zshrc: local shell configuration (contents withheld because they may contain secrets)"
if [ -s "$HOME/.zshrc" ]; then
  COUNT=$(awk 'NF { count++ } END { print count+0 }' "$HOME/.zshrc")
  echo "   $COUNT nonblank lines; inspect ~/.zshrc locally. Managed shell configuration lives in ~/.config/zsh."
else
  echo "   (empty or absent)"
fi

echo "== ~/.local/bin and ~/bin: programs installed by scripts, not by the folder"
ls -1 "$HOME/.local/bin" "$HOME/bin" 2>/dev/null | grep -v ':$' | sed 's/^/   /' || true

echo "== Nix: tools you tried with 'nix shell' leave nothing on the path; nothing to list."
