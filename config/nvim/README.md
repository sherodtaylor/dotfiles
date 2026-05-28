# 💤 LazyVim with zen-mcp-server

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim) enhanced with [zen-mcp-server](https://github.com/BeehiveInnovations/zen-mcp-server) integration.
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## 🚀 zen-mcp-server Integration

This config includes Code Companion with zen-mcp-server integration, providing access to multiple AI models and powerful tools.

### Features

- **Multi-provider AI support**: Anthropic (Claude), OpenAI, Gemini
- **zen-mcp-server tools**: Access to specialized AI workflows
- **Smart API key management**: Environment variables + password manager fallback
- **Enhanced UI**: Progress notifications and improved chat interface

### Quick Start

1. Run the main install script: `./install.sh`
2. When prompted, choose to set up zen-mcp-server
3. Configure your API keys
4. Open nvim and run `:Lazy sync`

### Keybindings

- `<leader>aa` - CodeCompanion Actions
- `<leader>ac` - Toggle CodeCompanion Chat
- `<leader>ad` - Add Selection to Chat (visual mode)
- `<leader>az` - Quick Zen MCP Tool selector
- `<leader>ai` - CodeCompanion Inline
- `<leader>ae` - Explain Code with Zen (visual mode)

### zen-mcp-server Tools

Use these in the Code Companion chat:

- `/zen:chat` - Multi-model conversations
- `/zen:thinkdeep` - Deep analysis and reasoning  
- `/zen:planner` - Project planning and task breakdown
- `/zen:codereview` - Code review and suggestions
- `/zen:debug` - Debugging assistance
- `/zen:analyze` - Code analysis and architecture review

### Configuration

- **MCP config**: `.mcp.json` - Claude Code MCP server configuration
- **API keys**: Stored in `~/.secrets.zsh` - Edit this file to add your API keys
- **Plugin config**: `lua/plugins/ai.lua` - AI and Code Companion settings
- **Service config**: `config/LaunchAgents/` - macOS background service configuration

### API Key Setup

The configuration uses a secure approach for API key management:

1. **Primary**: `~/.secrets.zsh` - Automatically sourced by your shell
2. **Fallback**: `pass` password manager - `pass insert anthropic/api_key`
3. **Environment**: Direct environment variables

To add your API keys:
```bash
# Edit the secrets file
vim ~/.secrets.zsh

# Replace the "**" placeholders with your actual keys:
export ANTHROPIC_API_KEY="your_anthropic_key_here"
export OPENAI_API_KEY="your_openai_key_here"
export GEMINI_API_KEY="your_gemini_key_here"
```

### macOS Background Service (Optional)

On macOS, you can run zen-mcp-server as a background LaunchAgent service for automatic startup and better resource management:

```bash
# Install and start the service
zen-service install

# Check service status and logs
zen-service status

# View logs in real-time
zen-service tail

# Manual log rotation (automatic at 2am daily)
zen-service rotate

# Stop/start/restart the service
zen-service stop
zen-service start
zen-service restart

# Remove the service
zen-service uninstall
```

**Service Features:**
- 🚀 **Auto-start**: Runs automatically when you log in
- 📝 **Persistent logs**: `~/.local/log/zen-mcp-server.log`
- 🔄 **Log rotation**: Automatic daily rotation (max 10MB files)
- 🔧 **Easy management**: Simple commands via `zen-service`
- 💾 **Resource efficient**: Low priority I/O and background processing
