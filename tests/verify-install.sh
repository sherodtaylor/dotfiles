#!/usr/bin/env bash
# Verify that install.sh + install/<os>.sh produced a working dev environment.
# Run after the install scripts have been executed in a clean test container.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"

fail=0

check_symlink() {
  local target="$1"
  local must_resolve_into_repo="${2:-yes}"
  if [[ ! -L "$target" ]]; then
    echo "[FAIL] $target is not a symlink"
    fail=1
    return
  fi
  local dest
  dest="$(readlink -f "$target")"
  if [[ "$must_resolve_into_repo" == "yes" ]] && [[ "$dest" != "$REPO"/* ]]; then
    echo "[FAIL] $target -> $dest (does not resolve into $REPO)"
    fail=1
    return
  fi
  echo "[ OK ] $target"
}

check_binary() {
  local bin="$1"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "[ OK ] $bin on PATH"
  else
    echo "[FAIL] $bin not on PATH"
    fail=1
  fi
}

check_no_legacy_strings() {
  # Patterns are split so the file itself doesn't contain the literal
  # strings — keeps this script from tripping the history rewrite that
  # scrubs them.
  local p1 p2 p3 p4 pattern
  p1="$(printf '%s%s' 'staylor' '279')"
  p2="$(printf '%s%s' 'bloom' 'berg.net')"
  p3="$(printf '%s%s' 'bloom' 'berg.com')"
  p4='\*\*\*REMOV''ED\*\*\*'
  pattern="${p1}|${p2}|${p3}|${p4}"

  if grep -rIqEi "$pattern" --exclude-dir=.git --exclude-dir=docs "$REPO"; then
    echo "[FAIL] legacy work strings still in repo:"
    grep -rIniEi "$pattern" --exclude-dir=.git --exclude-dir=docs "$REPO" | head -20
    fail=1
  else
    echo "[ OK ] no legacy work strings in repo"
  fi
}

echo "=== Symlinks ==="
check_symlink "$HOME/.zshrc"
check_symlink "$HOME/.aliases"
check_symlink "$HOME/.gitconfig"
check_symlink "$HOME/.tmux.conf"
check_symlink "$HOME/.gitignore"
check_symlink "$HOME/.zsh"
check_symlink "$HOME/.bin"
check_symlink "$HOME/.config/nvim"

echo "=== Template copies (not symlinks) ==="
if [[ -f "$HOME/.secrets.zsh" ]]; then
  echo "[ OK ] ~/.secrets.zsh exists"
else
  echo "[FAIL] ~/.secrets.zsh missing"; fail=1
fi
if [[ -f "$HOME/.gitconfig.local" ]]; then
  echo "[ OK ] ~/.gitconfig.local exists"
else
  echo "[FAIL] ~/.gitconfig.local missing"; fail=1
fi
if [[ "$(stat -c '%a' "$HOME/.secrets.zsh" 2>/dev/null)" == "600" ]]; then
  echo "[ OK ] ~/.secrets.zsh perms 600"
else
  echo "[FAIL] ~/.secrets.zsh not 600"; fail=1
fi

echo "=== Binaries ==="
for b in zsh nvim rg fd bat jq gh node go uv; do
  check_binary "$b"
done

echo "=== Sourceability ==="
if ! zsh -c 'source ~/.zshrc' 2>/tmp/zsh-source.log; then
  echo "[FAIL] sourcing ~/.zshrc exited with errors:"
  cat /tmp/zsh-source.log
  fail=1
else
  echo "[ OK ] ~/.zshrc sources without error"
fi

echo "=== Hygiene ==="
check_no_legacy_strings

if [[ "$fail" -eq 0 ]]; then
  echo
  echo "ALL CHECKS PASSED"
  exit 0
else
  echo
  echo "VERIFICATION FAILED" >&2
  exit 1
fi
