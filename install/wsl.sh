#!/usr/bin/env bash
# Install dev environment dependencies on WSL.
# Delegates to apt.sh + adds Windows interop (win32yank for clipboard).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$HERE/common.sh"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  log_error "This script is for WSL. Use install/apt.sh on native Linux."
  exit 1
fi

log_info "Running apt installer..."
"$HERE/apt.sh"

# win32yank for nvim clipboard interop with Windows
if [[ ! -x "$HOME/.local/bin/win32yank.exe" ]]; then
  log_info "Installing win32yank..."
  mkdir -p "$HOME/.local/bin"
  TMP="$(mktemp -d)"
  curl -fsSL https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip -o "$TMP/w.zip"
  unzip -qo "$TMP/w.zip" -d "$TMP"
  install -m 0755 "$TMP/win32yank.exe" "$HOME/.local/bin/win32yank.exe"
  rm -rf "$TMP"
  log_ok "win32yank installed to ~/.local/bin/win32yank.exe"
else
  log_ok "win32yank already installed"
fi

log_ok "WSL install complete."
