# Universal zsh config — loaded on every OS by ~/.zshrc.
# Anything that depends on a specific OS belongs in zsh/os/{mac,linux,wsl}.zsh.

# completion — extend fpath; OMZ calls compinit itself
fpath=(~/.zsh/completion $fpath)

# auto-cd into directories by typing their name
setopt auto_cd

# vi mode + sane keybindings
bindkey -v
bindkey "^F" vi-cmd-mode
bindkey jj  vi-cmd-mode
bindkey "^R" history-incremental-search-backward
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word

# editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
setopt INC_APPEND_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS

# directory stack
setopt auto_pushd
export dirstacksize=5
setopt AUTOCD AUTOPUSHD PUSHDMINUS PUSHDSILENT PUSHDTOHOME cdablevars

# prompt — kept light; OMZ theme handles styling
setopt prompt_subst

# user-local bin — guard against duplicate entries on re-source
case ":$PATH:" in
  *":$HOME/.bin:"*) ;;
  *) [[ -d "$HOME/.bin" ]] && export PATH="$HOME/.bin:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) [[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) ;;
  *) [[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# tool integrations (no-op if not installed)
[[ -f "$HOME/.fzf.zsh" ]]     && source "$HOME/.fzf.zsh"
[[ -f "$HOME/.fzf-git.zsh" ]] && source "$HOME/.fzf-git.zsh"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="eastwood"
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# user functions — sourced after OMZ so compdef/compinit are available
for fn in ~/.zsh/functions/*(N); do
  source "$fn"
done
