# ~/.zshrc -> dotfiles/zshrc
# Slim base — sources OS-specific fragments and personal overrides.

# Resolve the dotfiles directory from the symlink
__dotfiles_resolve() {
  local self="${(%):-%N}"
  # If $self is a symlink, follow it
  if [[ -L "$self" ]]; then
    self="$(readlink "$self")"
  fi
  print -r -- "${self:A:h}"
}
export DOTFILES="${DOTFILES:-$(__dotfiles_resolve)}"
unfunction __dotfiles_resolve

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
