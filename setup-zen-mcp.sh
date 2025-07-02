#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test zen-mcp-server with timeout
test_zen_mcp_server() {
    local timeout_seconds=15
    print_status "Testing zen-mcp-server installation (timeout: ${timeout_seconds}s)..."
    
    # Create a temporary script for the test
    local test_script=$(mktemp)
    cat > "$test_script" << 'EOF'
#!/bin/bash
exec $(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --version
EOF
    chmod +x "$test_script"
    
    # Run the test with timeout using background process
    "$test_script" &
    local test_pid=$!
    
    # Wait for completion or timeout
    local elapsed=0
    while kill -0 $test_pid 2>/dev/null && [ $elapsed -lt $timeout_seconds ]; do
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    # Check if process is still running
    if kill -0 $test_pid 2>/dev/null; then
        print_warning "Test timed out after ${timeout_seconds} seconds"
        kill -TERM $test_pid 2>/dev/null
        sleep 2
        kill -KILL $test_pid 2>/dev/null
        rm -f "$test_script"
        return 1
    else
        # Process completed, check exit status
        wait $test_pid
        local exit_code=$?
        rm -f "$test_script"
        
        if [ $exit_code -eq 0 ]; then
            print_success "zen-mcp-server test completed successfully"
            return 0
        else
            print_error "zen-mcp-server test failed with exit code: $exit_code"
            return 1
        fi
    fi
}

main() {
    print_status "Setting up MCP servers (zen-mcp-server + zencode) for Claude Code and Cursor..."
    
    # Check if API keys exist
    if [[ -f "$HOME/.secrets.zsh" ]]; then
        print_success "Found ~/.secrets.zsh"
        
        # Source the secrets to check for API keys
        source "$HOME/.secrets.zsh" 2>/dev/null || true
        
        local api_keys_found=0
        if [[ -n "$ANTHROPIC_API_KEY" ]]; then
            print_success "ANTHROPIC_API_KEY is configured"
            api_keys_found=1
        fi
        if [[ -n "$OPENAI_API_KEY" ]]; then
            print_success "OPENAI_API_KEY is configured"  
            api_keys_found=1
        fi
        if [[ -n "$GEMINI_API_KEY" ]]; then
            print_success "GEMINI_API_KEY is configured"
            api_keys_found=1
        fi
        
        if [[ $api_keys_found -eq 0 ]]; then
            print_warning "No API keys found in ~/.secrets.zsh"
            print_status "Please add your API keys to ~/.secrets.zsh:"
            echo "  export ANTHROPIC_API_KEY='your-key-here'"
            echo "  export OPENAI_API_KEY='your-key-here'"  
            echo "  export GEMINI_API_KEY='your-key-here'"
        fi
    else
        print_warning "~/.secrets.zsh not found"
        print_status "Please create ~/.secrets.zsh with your API keys"
    fi
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command -v uv &> /dev/null && ! command -v uvx &> /dev/null; then
        print_error "uv/uvx not found. Please install uv first:"
        echo "  macOS: brew install uv"
        echo "  Linux: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
    
    print_success "uv/uvx found"
    
    if ! command -v claude &> /dev/null; then
        print_error "Claude Code not found. Please install it first:"
        echo "  npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
    
    print_success "Claude Code found"
    
    # Test zen-mcp-server installation
    if ! test_zen_mcp_server; then
        print_error "zen-mcp-server test failed. Installation may be incomplete."
        print_status "You can try manually testing with:"
        echo "  uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --version"
        # Don't exit here, continue with MCP setup
    fi
    
    # Configure MCP servers at user scope
    print_status "Configuring zen-mcp-server for Claude Code (user scope)..."
    
    # Remove existing servers if they exist
    claude mcp remove zen 2>/dev/null || true
    claude mcp remove zencode 2>/dev/null || true
    
    # Add zen-mcp-server to user scope
    if claude mcp add zen -s user -e "ANTHROPIC_API_KEY=\${ANTHROPIC_API_KEY}" -e "OPENAI_API_KEY=\${OPENAI_API_KEY}" -e "GEMINI_API_KEY=\${GEMINI_API_KEY}" -e "DEFAULT_MODEL=auto" -- sh -c "exec \$(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"; then
        print_success "zen-mcp-server configured successfully in user scope"
    else
        print_error "Failed to configure zen-mcp-server"
        exit 1
    fi
    
    # Add zencode MCP server to user scope
    print_status "Configuring zencode MCP server for Claude Code (user scope)..."
    if claude mcp add zencode -s user -e "ANTHROPIC_API_KEY=\${ANTHROPIC_API_KEY}" -e "OPENAI_API_KEY=\${OPENAI_API_KEY}" -e "GEMINI_API_KEY=\${GEMINI_API_KEY}" -- npx -y @anthropic-ai/mcp-server-zencode; then
        print_success "zencode MCP server configured successfully in user scope"
    else
        print_warning "Failed to configure zencode MCP server (this may be normal if the package doesn't exist yet)"
    fi
    
    # Configure Cursor MCP (global configuration)
    print_status "Configuring MCP servers for Cursor IDE..."
    
    # Create Cursor MCP configuration directory
    mkdir -p "$HOME/.cursor"
    
    # Create global Cursor MCP configuration
    cat > "$HOME/.cursor/mcp.json" << 'EOF'
{
  "mcpServers": {
    "zen": {
      "command": "sh",
      "args": ["-c", "source ~/.secrets.zsh 2>/dev/null; exec $(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"],
      "env": {
        "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
        "OPENAI_API_KEY": "${OPENAI_API_KEY}",
        "GEMINI_API_KEY": "${GEMINI_API_KEY}",
        "DEFAULT_MODEL": "auto"
      }
    }
  }
}
EOF
    
    if [[ -f "$HOME/.cursor/mcp.json" ]]; then
        print_success "Cursor MCP configuration created at ~/.cursor/mcp.json"
    else
        print_warning "Failed to create Cursor MCP configuration"
    fi
    
    # Verify Claude Code configuration
    print_status "Verifying Claude Code MCP configuration..."
    if claude mcp list | grep -q "zen"; then
        print_success "zen-mcp-server is configured and ready for Claude Code"
        
        print_status "MCP configuration complete!"
        echo ""
        echo "Available zen-mcp tools:"
        echo "  • chat, thinkdeep, planner, consensus" 
        echo "  • codereview, precommit, debug, secaudit"
        echo "  • docgen, analyze, refactor, tracer"
        echo "  • testgen, challenge, listmodels, version"
        echo ""
        echo "Usage in nvim:"
        echo "  <leader>aa - CodeCompanion Actions"
        echo "  <leader>ac - Toggle CodeCompanion Chat"
        echo "  <leader>az - Quick Zen MCP Tool selector"
        echo ""
        echo "Usage in Claude Code:"
        echo "  Type '/mcp' to see available tools"
        echo "  Use @ mentions for zen resources"
        echo ""
        echo "Usage in Cursor IDE:"
        echo "  MCP servers configured globally at ~/.cursor/mcp.json"
        echo "  Restart Cursor to load the new MCP configuration"
        echo "  Use @ mentions or MCP commands in Cursor chat"
        echo ""
    else
        print_error "zen-mcp-server configuration verification failed"
        exit 1
    fi
    
    print_success "Setup complete! 🎉"
}

main "$@"