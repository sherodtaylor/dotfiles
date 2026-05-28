#!/usr/bin/env bash
# Install dev environment dependencies on Debian/Ubuntu.
# Usage: ./install/apt.sh

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$HERE/common.sh"

# When running as root (e.g. in a container), sudo is a no-op wrapper.
# When running as a normal user, sudo is required for system-level installs.
if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

# Detect architecture once — used by nvim, eza, and yq download logic.
_ARCH="$(uname -m)"
case "$_ARCH" in
  x86_64)  _NVIM_ARCH="x86_64" ; _EZA_ARCH="x86_64-unknown-linux-gnu" ; _YQ_ARCH="amd64" ;;
  aarch64|arm64) _NVIM_ARCH="arm64" ; _EZA_ARCH="aarch64-unknown-linux-gnu" ; _YQ_ARCH="arm64" ;;
  *)
    log_error "Unsupported architecture: $_ARCH"
    exit 1
    ;;
esac

log_info "Updating apt package index..."
${SUDO} apt-get update -qq

log_info "Installing packages from install/packages.apt..."
mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$HERE/packages.apt")
${SUDO} apt-get install -y "${pkgs[@]}"

# fzf via git for newer version + key bindings installer
if [[ ! -d "$HOME/.fzf" ]]; then
  log_info "Installing fzf from git..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
else
  log_ok "fzf already installed at ~/.fzf"
fi

# Neovim — install from official release tarball (apt + snap versions are stale/broken in LXC)
NVIM_VERSION="${NVIM_VERSION:-v0.10.4}"
NVIM_PREFIX="$HOME/.local"
if ! command_exists nvim || [[ "$(nvim --version | head -1 | awk '{print $2}')" != "$NVIM_VERSION" ]]; then
  log_info "Installing Neovim $NVIM_VERSION ($_ARCH)..."
  _NVIM_TARBALL="nvim-linux-${_NVIM_ARCH}.tar.gz"
  _NVIM_DIR="nvim-linux-${_NVIM_ARCH}"
  TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${_NVIM_TARBALL}" -o "$TMP/nvim.tar.gz"
  tar -xzf "$TMP/nvim.tar.gz" -C "$TMP"
  mkdir -p "$NVIM_PREFIX"
  cp -r "$TMP/${_NVIM_DIR}/." "$NVIM_PREFIX/"
  rm -rf "$TMP"
  log_ok "Neovim $NVIM_VERSION installed to $NVIM_PREFIX/bin/nvim"
else
  log_ok "Neovim $NVIM_VERSION already installed"
fi

# gh (GitHub CLI) via official apt repo
if ! command_exists gh; then
  log_info "Installing gh..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | ${SUDO} dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  ${SUDO} chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | ${SUDO} tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  ${SUDO} apt-get update -qq
  ${SUDO} apt-get install -y gh
  log_ok "gh installed"
else
  log_ok "gh already installed"
fi

# yq via release binary
YQ_VERSION="${YQ_VERSION:-v4.44.6}"
if ! command_exists yq; then
  log_info "Installing yq $YQ_VERSION ($_YQ_ARCH)..."
  ${SUDO} curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${_YQ_ARCH}" -o /usr/local/bin/yq
  ${SUDO} chmod +x /usr/local/bin/yq
  log_ok "yq $YQ_VERSION installed"
else
  log_ok "yq already installed"
fi

# zoxide via official installer
if ! command_exists zoxide; then
  log_info "Installing zoxide..."
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  log_ok "zoxide installed"
else
  log_ok "zoxide already installed"
fi

# eza via release binary
EZA_VERSION="${EZA_VERSION:-v0.20.5}"
if ! command_exists eza; then
  log_info "Installing eza $EZA_VERSION ($_EZA_ARCH)..."
  TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${_EZA_ARCH}.tar.gz" -o "$TMP/eza.tgz"
  tar -xzf "$TMP/eza.tgz" -C "$TMP"
  ${SUDO} mv "$TMP/eza" /usr/local/bin/eza
  rm -rf "$TMP"
  log_ok "eza installed"
else
  log_ok "eza already installed"
fi

# Language toolchains
install_nvm
install_uv
install_rustup
install_claude_cli

# fzf integration
setup_fzf_integration

# Nerd Font (FiraCode)
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! ls "$FONT_DIR"/FiraCodeNerdFont*.ttf >/dev/null 2>&1; then
  log_info "Installing FiraCode Nerd Font..."
  TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" -o "$TMP/FiraCode.zip"
  unzip -qo "$TMP/FiraCode.zip" -d "$TMP/FiraCode"
  cp "$TMP/FiraCode"/*.ttf "$FONT_DIR/"
  if command_exists fc-cache; then fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true; fi
  rm -rf "$TMP"
  log_ok "FiraCode Nerd Font installed"
else
  log_ok "FiraCode Nerd Font already installed"
fi

log_ok "apt install complete."
echo
echo "Next steps:"
echo "  ./install.sh          # symlink dotfiles into \$HOME"
echo "  chsh -s \$(command -v zsh)   # set zsh as login shell"
