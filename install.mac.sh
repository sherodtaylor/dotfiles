brew install nvim fzf python go nvm uv

# Setup fzf integration
echo "Setting up fzf integration..."
fzf --zsh > ~/.fzf.zsh
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o ~/.fzf-git.zsh
brew install --cask hammerspoon
brew install --cask font-firacode-mono-nerd-font

# Setup Node.js and npm via nvm
echo "Setting up Node.js and npm via nvm..."
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/share/nvm/nvm.sh" ] && \. "/opt/homebrew/share/nvm/nvm.sh"  # This loads nvm

# Install and use the latest LTS version of Node.js
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

# Install Claude Code via npm
echo "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# Install Go tools
echo "Installing Go tools..."
if command -v go >/dev/null 2>&1; then
    export GOROOT="/opt/homebrew/opt/go/libexec"
    eval "$(GOROOT=/opt/homebrew/opt/go/libexec go env | grep -E '^(GOPATH|GOROOT)=' | sed 's/^/export /')"
    [ ! -d "$GOPATH" ] && mkdir -p "$GOPATH"
    go install golang.org/x/tools/gopls@latest
    echo "✓ gopls installed"
else
    echo "⚠️  Go not found, skipping gopls installation"
fi

echo ""
echo "🚀 macOS-specific setup complete!"
echo ""
echo "Available after dotfiles installation:"
echo "  zen-service install  - Set up zen-mcp-server as a background service"
echo "  zen-service status   - Check service status and logs"
