#!/usr/bin/env bash
# Install dev environment dependencies on macOS.
# Usage: ./install/mac.sh

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$HERE/common.sh"

if ! command_exists brew; then
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log_ok "Homebrew already installed"
fi

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

log_info "Running brew bundle..."
brew bundle --file="$HERE/Brewfile"
log_ok "brew bundle complete"

# nvm config + node LTS
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
if [[ -s "$(brew --prefix nvm)/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  source "$(brew --prefix nvm)/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
  log_ok "node LTS via brew nvm installed"
fi

install_uv
install_rustup
install_claude_cli
setup_fzf_integration

# Go tools
if command_exists go; then
  log_info "Installing gopls..."
  GOPATH="${GOPATH:-$HOME/go}"
  mkdir -p "$GOPATH"
  GOPATH="$GOPATH" go install golang.org/x/tools/gopls@latest
  log_ok "gopls installed"
fi

log_ok "mac install complete."
echo
echo "Next steps:"
echo "  ./install.sh"
