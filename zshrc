# load our own completion functions
fpath=(~/.zsh/completion $fpath)

# completion
autoload -U compinit
compinit
for function in ~/.zsh/functions/*; do
  source $function
done

# automatically enter directories without cd
setopt auto_cd

# use vim as the visual editor
export VISUAL=vim
export EDITOR=$VISUAL

#Node Environmet
export NODE_ENV=development

# vi mode
bindkey -v
bindkey "^F" vi-cmd-mode
bindkey jj vi-cmd-mode

# use incremental search
bindkey "^R" history-incremental-search-backward

# add some readline keys back
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

# handy keybindings
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word
bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='[${SSH_CONNECTION+"%n@%m:"}%~] '

# avoid duplicates..
export HISTCONTROL=ignoredups:erasedups

# append history entries..
setopt inc_append_history


# keep TONS of history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
export HISTFILE=~/.zsh_history
export PROMPT_COMMAND="history -a; history -n"
setopt inc_append_history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS



# look for ey config in project dirs
export EYRC=./.eyrc

# automatically pushd
setopt auto_pushd
export dirstacksize=5

# awesome cd movements from zshkit
setopt AUTOCD
setopt AUTOPUSHD PUSHDMINUS PUSHDSILENT PUSHDTOHOME
setopt cdablevars

# Try to correct command line spelling
#setopt CORRECT CORRECT_ALL

# Enable extended globbing
#setopt EXTENDED_GLOB

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
export PATH="$HOME/.bin:$PATH"

export ZSH_THEME="eastwood"
# recommended by brew doctor
export PATH='/usr/local/bin:/Users/sherodtaylor/.bin:/Users/sherodtaylor/.bin:/Users/sherodtaylor/.bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin'
export GOROOT=/usr/local/go
export GOPATH=/Users/staylor279/go
export GOBIN=$GOROOT/bin
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/10/bin
eval $(go env)

#export ALL_PROXY=http://127.0.0.1:8888
#export http_proxy=http://proxy.bloomberg.com:81
#export https_proxy=http://proxy.bloomberg.com:81
#export ALL_PROXY=http://proxy.bloomberg.com:81
#export GOPRIVATE="*.dev.bloomberg.com"
#export GOPROXY="https://goproxy.dev.bloomberg.com,direct"

#alias dev_proxy='http_proxy=http://bproxy.tdmz1.bloomberg.com:80 https_proxy=http://bproxy.tdmz1.bloomberg.com:80'
#alias ext_proxy='http_proxy=http://proxy.bloomberg.com:81 https_proxy=http://proxy.bloomberg.com:81'
#export http_proxy=http://proxy.bloomberg.com:81
#export https_proxy=http://proxy.bloomberg.com:81
#export SASS_BINARY_PATH=~/Downloads/darwin-x64-72_binding.node
#alias dev_proxy='http_proxy=http://bproxy.tdmz1.bloomberg.com:80 https_proxy=http://bproxy.tdmz1.bloomberg.com:80 GOPROXY=https://artprod.dev.bloomberg.com/artifactory/api/go/bbgolang,https://proxy.golang.org,direct'
alias ext_proxy='http_proxy=http://proxy.bloomberg.com:81 https_proxy=http://proxy.bloomberg.com:81 GOPROXY=https://artprod.dev.bloomberg.com/artifactory/api/go/bbgolang,https://proxy.golang.org,direct GOPRIVATE="*.dev.bloomberg.com"'
alias go_proxy='GOPROXY=https://goproxy.dev.bloomberg.com,direct  GOPRIVATE=*.dev.bloomberg.com'


[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh



export PATH="/usr/local/opt/openssl@1.1/bin:$PATH:$HOME/.rover/bin"

alias fsmount="mkdir ~/dev && sshfs devsftp.bloomberg.com: ~/dev -p 2222 -o IdentityFile=~/.toolkit/toolkit_ssh_key_staylor279"
alias fsunmount="hdiutil eject -force ~/dev && rm -rf ~/dev"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export PATH="/usr/local/opt/python@3.7/bin:$PATH:/Users/staylor279/Library/Python/3.7/bin:$HOME/.cargo/bin"
export PATH="/usr/local/opt/python@3.9/bin:$PATH:/Users/staylor279/Library/Python/3.9/bin:$HOME/.cargo/bin"
export GO111MODULE=on

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

export PNPM_HOME="/Users/staylor279/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# KREW
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
source $HOME/.fzf-git.zsh

alias rapi3tool='docker run --rm -v "`pwd -P`:/workarea" -v "/tmp:/mnttmp:ro" -e USER=${USER} -e KRB5CCNAME="/mnttmp/krb5cc_`id -u $USER`" -it artprod.dev.bloomberg.com/training/rapi3tool:latest rapi3tool'

# Wasmer
export WASMER_DIR="/Users/staylor279/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/staylor279/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/staylor279/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/staylor279/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/staylor279/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


# pnpm
export PNPM_HOME="/Users/staylor279/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pnpm endexport PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
#

# Created by `pipx` on 2024-04-17 21:16:08
export PATH="$PATH:/Users/staylor279/.local/bin:/Applications/Postgres.app/Contents/Versions/16/bin"

#source /opt/homebrew/opt/spaceship/spaceship.zsh

# wezterm to path
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH="$PATH:/snap/bin"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/"
export PATH="$PATH:/mnt/c/Users/shero/AppData/Local/Microsoft/WinGet/Packages/equalsraf.win32yank_Microsoft.Winget.Source_8wekyb3d8bbwe/"
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

source ~/.secrets.zsh
