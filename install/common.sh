#!/usr/bin/env bash
# Shared bash helpers for install scripts. Source, don't execute.

set -euo pipefail

COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

log_info()  { printf "${COLOR_BLUE}[INFO]${COLOR_RESET}  %s\n" "$*"; }
log_ok()    { printf "${COLOR_GREEN}[ OK ]${COLOR_RESET}  %s\n" "$*"; }
log_warn()  { printf "${COLOR_YELLOW}[WARN]${COLOR_RESET}  %s\n" "$*"; }
log_error() { printf "${COLOR_RED}[FAIL]${COLOR_RESET}  %s\n" "$*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

install_nvm() {
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    log_ok "nvm already installed at ~/.nvm"
    return 0
  fi
  log_info "Installing nvm..."
  PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
  log_ok "nvm + node LTS installed"
}

install_rustup() {
  if command_exists rustup; then
    log_ok "rustup already installed"
    return 0
  fi
  log_info "Installing rustup..."
  curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
  log_ok "rustup installed"
}

install_uv() {
  if command_exists uv; then
    log_ok "uv already installed"
    return 0
  fi
  log_info "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
  log_ok "uv installed"
}

install_claude_cli() {
  if command_exists claude; then
    log_ok "claude-code already installed"
    return 0
  fi
  if ! command_exists npm; then
    log_warn "npm not found; skipping claude-code install (run after node)"
    return 0
  fi
  log_info "Installing @anthropic-ai/claude-code globally..."
  npm install -g @anthropic-ai/claude-code
  log_ok "claude-code installed"
}

setup_fzf_integration() {
  log_info "Setting up fzf integration..."
  if command_exists fzf; then
    fzf --zsh > "$HOME/.fzf.zsh" 2>/dev/null || true
  fi
  if [[ ! -f "$HOME/.fzf-git.zsh" ]]; then
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o "$HOME/.fzf-git.zsh"
  fi
  log_ok "fzf integration ready"
}
