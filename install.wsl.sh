sudo snap install nvim --classic
sudo apt-get update
sudo apt-get install build-essential golang-go python3-pip curl

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Claude Code via npm
echo "Installing Claude Code..."
sudo npm install -g @anthropic-ai/claude-code

# Install uv (required for zen-mcp-server)
curl -LsSf https://astral.sh/uv/install.sh | sh
