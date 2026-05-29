# ~/.zshrc -> dotfiles/zshrc
# Slim base — sources OS-specific fragments and personal overrides.

# Resolve the dotfiles directory from the symlink target of this rc file.
# `${(%):-%x}` evaluates to the path of the script currently being sourced
# (~/.zshrc), and `:A` follows the symlink to the real file, `:h` strips
# the filename. Top-level only — `%x` inside a function would name the
# function instead of the script.
export DOTFILES="${DOTFILES:-${${(%):-%x}:A:h}}"

[[ -f "$DOTFILES/zsh/os/common.zsh" ]] && source "$DOTFILES/zsh/os/common.zsh"

case "$(uname -s)" in
  Darwin)
    [[ -f "$DOTFILES/zsh/os/mac.zsh" ]] && source "$DOTFILES/zsh/os/mac.zsh"
    ;;
  Linux)
    [[ -f "$DOTFILES/zsh/os/linux.zsh" ]] && source "$DOTFILES/zsh/os/linux.zsh"
    if grep -qi microsoft /proc/version 2>/dev/null; then
      [[ -f "$DOTFILES/zsh/os/wsl.zsh" ]] && source "$DOTFILES/zsh/os/wsl.zsh"
    fi
    ;;
esac

[[ -f ~/.aliases ]]     && source ~/.aliases
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
