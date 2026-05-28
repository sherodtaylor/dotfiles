#!/usr/bin/env bash
# bootstrap.sh — curl|bash entry point for dotfiles
#
# Usage (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/sherodtaylor/dotfiles/master/bootstrap.sh | bash
#
# Skip OS package installation (e.g. in containers):
#   curl -fsSL .../bootstrap.sh | bash -s -- --skip-packages
#
# Clones the repo to ~/dotfiles (or $DOTFILES_DEST), then runs install.sh.
# If the repo is already present, pulls the latest instead of re-cloning.
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/sherodtaylor/dotfiles.git}"
DOTFILES_DEST="${DOTFILES_DEST:-$HOME/dotfiles}"

if [[ ! -d "$DOTFILES_DEST/.git" ]]; then
  echo "[bootstrap] cloning dotfiles to $DOTFILES_DEST"
  git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DEST"
else
  echo "[bootstrap] updating existing dotfiles at $DOTFILES_DEST"
  git -C "$DOTFILES_DEST" pull --ff-only
fi

echo "[bootstrap] running install.sh $*"
exec bash "$DOTFILES_DEST/install.sh" "$@"
