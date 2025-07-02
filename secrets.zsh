# AI API Keys - Keep this file secure!
# Replace "**" with your actual API keys

export ANTHROPIC_API_KEY="**"
export OPENAI_API_KEY="**"
export GEMINI_API_KEY="**"

# Go configuration using go env evaluation
if command -v go >/dev/null 2>&1; then
    # Set GOROOT to Homebrew location first
    export GOROOT="/opt/homebrew/opt/go/libexec"
    
    # Use go env to get the correct paths
    eval "$(GOROOT=/opt/homebrew/opt/go/libexec go env | grep -E '^(GOPATH|GOROOT)=' | sed 's/^/export /')"
    
    # Add GOPATH/bin to PATH
    export PATH="$GOPATH/bin:$PATH"
    
    # Ensure GOPATH directory exists
    [ ! -d "$GOPATH" ] && mkdir -p "$GOPATH"
fi

# Optional: Other AI providers
# export GROQ_API_KEY="**"
# export XAI_API_KEY="**"
