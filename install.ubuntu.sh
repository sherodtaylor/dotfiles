#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install essential packages
echo "Installing essential packages..."
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    zsh

# Install modern tools
echo "Installing modern tools..."

# Install fzf
if ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
else
    echo "✓ fzf already installed"
fi

# Install Neovim
if ! command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim..."
    sudo snap install nvim --classic
else
    echo "✓ Neovim already installed"
fi

# Install Go
if ! command -v go >/dev/null 2>&1; then
    echo "Installing Go..."
    sudo apt-get install -y golang-go
    
    # Install Go tools
    echo "Installing Go tools..."
    export GOPATH="$HOME/go"
    [ ! -d "$GOPATH" ] && mkdir -p "$GOPATH"
    go install golang.org/x/tools/gopls@latest
    echo "✓ gopls installed"
else
    echo "✓ Go already installed"
fi

# Install Node.js and npm
if ! command -v node >/dev/null 2>&1; then
    echo "Installing Node.js and npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✓ Node.js already installed"
fi

# Install Claude Code via npm
if ! command -v claude-code >/dev/null 2>&1; then
    echo "Installing Claude Code..."
    sudo npm install -g @anthropic-ai/claude-code
else
    echo "✓ Claude Code already installed"
fi

# Install uv (required for zen-mcp-server)
if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Verify installation
    if command -v uv >/dev/null 2>&1; then
        echo "✓ uv installed successfully"
    else
        echo "⚠️  uv installed but not in PATH. You may need to:"
        echo "   - Restart your terminal, or"
        echo "   - Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
else
    echo "✓ uv already installed"
fi

# Setup fzf integration
echo "Setting up fzf integration..."
if [ -f ~/.fzf/shell/key-bindings.zsh ]; then
    echo "export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'" >> ~/.fzf.zsh
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o ~/.fzf-git.zsh
    echo "✓ fzf integration configured"
fi

# Install Nerd Font
echo "Installing Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" ]; then
    echo "Downloading FiraCode Nerd Font..."
    cd /tmp
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
    unzip -o FiraCode.zip -d FiraCode
    cp FiraCode/*.ttf "$FONT_DIR/"
    fc-cache -fv
    echo "✓ FiraCode Nerd Font installed"
else
    echo "✓ FiraCode Nerd Font already installed"
fi

echo ""
echo "🚀 Ubuntu-specific setup complete!"
echo ""
echo "Available after dotfiles installation:"
echo "  zen-service install  - Set up zen-mcp-server as a background service"
echo "  zen-service status   - Check service status and logs"
echo ""
echo "Don't forget to:"
echo "  1. Set zsh as your default shell: chsh -s $(which zsh)"
echo "  2. Log out and back in for font changes to take effect"
echo "  3. Restart your terminal to use the new shell"