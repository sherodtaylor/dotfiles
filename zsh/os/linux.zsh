# Linux-only shell config — loaded on any Linux (including WSL).

# nvm
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# uv shim (added to PATH by uv installer)
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# snap
[[ -d /snap/bin ]] && export PATH="/snap/bin:$PATH"

# fdfind shim — Debian ships fd as `fdfind` to avoid a name clash
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd=fdfind
fi
# bat shim — Debian ships bat as `batcat`
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat=batcat
fi
