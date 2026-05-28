#!/usr/bin/env bash
# Lint the shell scripts this repo actively maintains.
#
# Scope: install.sh + install/*.sh + tests/*.sh.
# Out of scope: bin/* (legacy personal utilities) and setup-zen-mcp.sh — these
# predate this refresh and ride along as-is. If you edit one, lint it
# separately: `shellcheck bin/<name>`.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not installed — install via 'apt install shellcheck' or 'brew install shellcheck'" >&2
  exit 1
fi

scripts=("$REPO/install.sh")
while IFS= read -r -d '' f; do
  scripts+=("$f")
done < <(find "$REPO/install" "$REPO/tests" -maxdepth 1 -type f -name '*.sh' -print0 2>/dev/null)

echo "Linting ${#scripts[@]} scripts..."
fail=0
for s in "${scripts[@]}"; do
  [[ -f "$s" ]] || continue
  if ! shellcheck -x --source-path="$(dirname "$s")" "$s"; then
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "All shell scripts pass shellcheck."
else
  echo "Lint failures above." >&2
  exit 1
fi
