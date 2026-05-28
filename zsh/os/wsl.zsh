# WSL-only shell config — loaded only when /proc/version contains "microsoft".
# Sources are additive to zsh/os/linux.zsh, which has already been sourced.

# Windows PATH for interop (PowerShell, winget shims)
[[ -d "/mnt/c/Windows/System32/WindowsPowerShell/v1.0" ]] && \
  export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

# win32yank for Windows clipboard integration with nvim
if [[ -d "$HOME/.local/bin" ]] && [[ -f "$HOME/.local/bin/win32yank.exe" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
