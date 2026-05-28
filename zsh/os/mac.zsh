# Mac-only shell config — loaded only on Darwin.

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Cache brew --prefix to avoid repeated subprocess forks
_BREW_PREFIX="$(brew --prefix 2>/dev/null)"

# nvm via homebrew
export NVM_DIR="$HOME/.nvm"
if [[ -s "$_BREW_PREFIX/opt/nvm/nvm.sh" ]]; then
  source "$_BREW_PREFIX/opt/nvm/nvm.sh"
  [[ -s "$_BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]] && source "$_BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

# Postgres.app (optional — only if present)
for v in 16 15 14 13; do
  if [[ -d "/Applications/Postgres.app/Contents/Versions/$v/bin" ]]; then
    case ":$PATH:" in
      *":/Applications/Postgres.app/Contents/Versions/$v/bin:"*) ;;
      *) export PATH="/Applications/Postgres.app/Contents/Versions/$v/bin:$PATH" ;;
    esac
    break
  fi
done

# WezTerm CLI
if [[ -d "/Applications/WezTerm.app/Contents/MacOS" ]]; then
  case ":$PATH:" in
    *":/Applications/WezTerm.app/Contents/MacOS:"*) ;;
    *) export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH" ;;
  esac
fi

# Docker Desktop
if [[ -d "/Applications/Docker.app/Contents/Resources/bin" ]]; then
  case ":$PATH:" in
    *":/Applications/Docker.app/Contents/Resources/bin:"*) ;;
    *) export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH" ;;
  esac
fi

# GNU make (brew)
if [[ -d "$_BREW_PREFIX/opt/make/libexec/gnubin" ]]; then
  case ":$PATH:" in
    *":$_BREW_PREFIX/opt/make/libexec/gnubin:"*) ;;
    *) export PATH="$_BREW_PREFIX/opt/make/libexec/gnubin:$PATH" ;;
  esac
fi

# Ruby (brew)
if [[ -d "$_BREW_PREFIX/opt/ruby/bin" ]]; then
  case ":$PATH:" in
    *":$_BREW_PREFIX/opt/ruby/bin:"*) ;;
    *) export PATH="$_BREW_PREFIX/opt/ruby/bin:$PATH" ;;
  esac
fi
