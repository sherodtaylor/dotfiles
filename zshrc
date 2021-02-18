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

# keep TONS of history
export HISTSIZE=4096
export HISTFILE=~/.zsh_history
export PROMPT_COMMAND="history -a; history -n"
setopt inc_append_history
set hist_ignore_dups



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
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.bin:$PATH"

# recommended by brew doctor
export PATH='/usr/local/bin:/Users/sherodtaylor/.bin:/Users/sherodtaylor/.bin:/Users/sherodtaylor/.bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin'

export PATH="$HOME/.bin:$PATH"
eval $(go env)
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/10/bin

export ALL_PROXY=http://127.0.0.1:8888
export http_proxy=http://127.0.0.1:8888
export https_proxy=http://127.0.0.1:8888
export GOPRIVATE="*.dev.bloomberg.com"
export GOPROXY="https://artprod.dev.bloomberg.com/artifactory/api/go/bbgolang,https://proxy.golang.org,direct"
alias dev_proxy='http_proxy=http://bproxy.tdmz1.bloomberg.com:80 https_proxy=http://bproxy.tdmz1.bloomberg.com:80'
alias ext_proxy='http_proxy=http://proxy.bloomberg.com:81 https_proxy=http://proxy.bloomberg.com:81'
export http_proxy=http://proxy.bloomberg.com:81
export https_proxy=http://proxy.bloomberg.com:81
export SASS_BINARY_PATH=~/Downloads/darwin-x64-72_binding.node


[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh



export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

alias fsmount="mkdir ~/dev && sshfs devsftp.bloomberg.com: ~/dev -p 2222 -o IdentityFile=~/.toolkit/toolkit_ssh_key_staylor279"
alias fsunmount="hdiutil eject -force ~/dev && rm -rf ~/dev"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/usr/local/opt/python@3.8/bin:$PATH"
