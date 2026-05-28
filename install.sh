#!/bin/bash

# Detect operating system and return appropriate extension
detect_os_extension() {
  # Check for WSL first
  if grep -q Microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "mac"
  elif [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    echo "${ID,,}" # lowercase distro ID (ubuntu, debian, fedora, etc.)
  elif [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
    echo "win"
  else
    echo "unknown"
  fi
}

# Backup file or directory function
backup_target() {
  local target="$1"
  local backup
  backup="${target}.backup.$(date +%Y%m%d%H%M%S)"

  echo "Backing up $target to $backup"
  cp -a "$target" "$backup"
  return $?
}

# Symlink function (works for both files and directories)
symlink_file() {
  local src="$1"
  local target="$2"

  # Create parent directories if they don't exist
  if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
    mkdir -p "$(dirname "$target")"
  fi

  if [[ -e "$target" ]]; then
    if [[ ! -L "$target" ]]; then
      echo "WARNING: $target exists but is not a symlink."
      echo "Creating backup before replacing..."
      if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
        if backup_target "$target"; then
          echo "Backup created successfully. Removing original to create symlink."
          rm -rf "$target"
        else
          echo "ERROR: Failed to create backup. Skipping symlink creation for safety."
          return 1
        fi
      fi
    elif [[ "$(readlink "$target")" != "$src" ]]; then
      echo "WARNING: $target is a symlink but points to a different location."
      echo "Creating backup before replacing..."
      if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
        if backup_target "$target"; then
          echo "Backup created successfully. Removing original symlink."
          rm -f "$target"
        else
          echo "ERROR: Failed to create backup. Skipping symlink creation for safety."
          return 1
        fi
      fi
    else
      echo "INFO: $target symlink already exists and points to the right location."
      return 0
    fi
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo "DRY-RUN: would create symlink $src -> $target"
    return 0
  fi

  echo "Creating symlink for $src to $target"
  ln -s "$src" "$target"
}

# Check if a filename contains the OS extension
contains_os_extension() {
  local filename="$1"
  local os_ext="$2"

  if [[ "$filename" == *".$os_ext."* ]] || [[ "$filename" == *".$os_ext" ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

# Check and install Oh My Zsh
install_oh_my_zsh() {
  # First check if zsh exists
  if ! command -v zsh &>/dev/null; then
    echo "WARNING: zsh not found. Skipping Oh My Zsh installation."
    echo "Please install zsh first using your package manager, then run this script again."
    return 1
  fi

  # Check if Oh My Zsh is already installed
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "INFO: Oh My Zsh is already installed at ~/.oh-my-zsh"
    return 0
  fi

  # Install Oh My Zsh
  echo "Installing Oh My Zsh..."

  # Save original ZSH value if it exists
  local original_zsh=""
  if [[ -n "${ZSH:-}" ]]; then
    original_zsh="$ZSH"
  fi

  # Use a temporary file to capture output
  local temp_output
  temp_output=$(mktemp)

  # Run the Oh My Zsh installer
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended >"$temp_output" 2>&1; then
    echo "Oh My Zsh installed successfully."

    # Display installation output summary
    grep -v "^$" "$temp_output" | head -n 10
    echo "..."
    grep -v "^$" "$temp_output" | tail -n 5
  else
    echo "ERROR: Oh My Zsh installation failed."
    echo "Installation output:"
    cat "$temp_output"
  fi

  # Clean up
  rm -f "$temp_output"

  # Restore original ZSH value if it existed
  if [[ -n "$original_zsh" ]]; then
    export ZSH="$original_zsh"
  fi

  touch "$HOME/.oh-my-zsh"
  return 0
}

# Clean up broken symlinks
cleanup_broken_symlinks() {
  local dotfiles_dir="$1"
  local cleanup_log
  cleanup_log="$dotfiles_dir/.cleanup-$(date +%Y%m%d%H%M%S).log"
  echo "Cleaning up broken symlinks..."
  echo "Cleanup log: $cleanup_log"

  # Function to clean symlinks in a directory
  cleanup_symlinks_in_dir() {
    local target_dir="$1"
    local src_prefix="$2"

    if [[ ! -d "$target_dir" ]]; then
      return
    fi

    # Find all symlinks in the target directory.
    # -maxdepth 2 keeps the scan to the dotfiles we actually install
    # (~/.<name> at depth 1, ~/.config/<name> at depth 2). Without this,
    # `find $HOME -type l` recursively walks every dir in $HOME — on a
    # developer Mac with years of files that hangs for tens of minutes.
    find "$target_dir" -maxdepth 2 -type l 2>/dev/null | while read -r symlink; do
      local link_target
      link_target=$(readlink "$symlink")

      # Check if this symlink points to our dotfiles directory
      if [[ "$link_target" == "$src_prefix"* ]]; then
        # Check if the source file still exists
        if [[ ! -e "$link_target" ]]; then
          echo "Found broken symlink: $symlink -> $link_target"

          # Create backup entry in dotfiles repo
          local relative_path="${link_target#"$dotfiles_dir"/}"
          local backup_file
          backup_file="$dotfiles_dir/${relative_path}.removed-$(date +%Y%m%d%H%M%S)"

          # Create backup marker file
          {
            echo "# This file was removed during cleanup on $(date)"
            echo "# Original symlink: $symlink"
            echo "# Target path: $link_target"
            echo "# Removed because source file no longer exists in dotfiles repo"
          } > "$backup_file"

          # Log the cleanup action
          echo "$(date): REMOVED $symlink -> $link_target (backup: $backup_file)" >> "$cleanup_log"

          echo "  Created backup marker: $backup_file"
          echo "  Removing broken symlink: $symlink"
          rm -f "$symlink"

          # Remove empty parent directories if they exist
          local parent_dir
          parent_dir=$(dirname "$symlink")
          if [[ -d "$parent_dir" ]] && [[ -z "$(ls -A "$parent_dir" 2>/dev/null)" ]]; then
            echo "  Removing empty directory: $parent_dir"
            rmdir "$parent_dir" 2>/dev/null || true
          fi
        fi
      fi
    done
  }

  # Clean up home directory symlinks (top-level dotfiles)
  cleanup_symlinks_in_dir "$HOME" "$dotfiles_dir/"

  # Clean up config directory symlinks
  cleanup_symlinks_in_dir "$HOME/.config" "$dotfiles_dir/config/"

  # Create cleanup summary
  if [[ -f "$cleanup_log" ]]; then
    echo ""
    echo "Cleanup completed. Summary:"
    cat "$cleanup_log"
    echo ""
    echo "Backup markers created in dotfiles repo for removed files."
    echo "You can remove the .cleanup-*.log and *.removed-* files once you confirm everything is working."
  else
    echo "No broken symlinks found."
  fi
}

# Process a directory recursively
process_directory() {
  local src_dir="$1"
  local target_dir="$2"
  local os_ext="$3"

  echo "Processing directory: $src_dir -> $target_dir"

  # Create target directory if it doesn't exist
  if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
    mkdir -p "$target_dir"
  fi

  # Process each file/subdirectory (including hidden files in config)
  for item in "$src_dir"/* "$src_dir"/.*; do
    # Skip if no files in directory
    if [[ ! -e "$item" ]]; then
      continue
    fi

    local item_name
    item_name=$(basename "$item")

    # Skip special directories and install files
    if [[ "$item_name" == "." ]] || [[ "$item_name" == ".." ]] || [[ "$item_name" == "install.sh" ]] || [[ "$item_name" == "install."*".sh" ]] || [[ "$item_name" == "README.md" ]]; then
      continue
    fi

    # Skip hidden files in root directory (but allow them in config)
    if [[ "$src_dir" != *"/config"* ]] && [[ "$item_name" == .* ]]; then
      continue
    fi

    if [[ -d "$item" ]]; then
      # Recursively process subdirectory
      process_directory "$item" "$target_dir/$item_name" "$os_ext"
    else
      # Check if file has current OS extension
      if contains_os_extension "$item_name" "$os_ext"; then
        # This file is for the current OS - symlink it with the exact name
        symlink_file "$item" "$target_dir/$item_name"
      elif contains_os_extension "$item_name" "mac" ||
        contains_os_extension "$item_name" "ubuntu" ||
        contains_os_extension "$item_name" "debian" ||
        contains_os_extension "$item_name" "fedora" ||
        contains_os_extension "$item_name" "win" ||
        contains_os_extension "$item_name" "wsl"; then
        # This file is for a different OS - skip it
        echo "Skipping OS-specific file for different OS: $item_name"
      else
        # This is a common file with no OS extension - symlink it
        symlink_file "$item" "$target_dir/$item_name"
      fi
    fi
  done
}

# Main script
main() {
  # Parse flags
  SKIP_PACKAGES=0
  DRY_RUN=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-packages) SKIP_PACKAGES=1; shift ;;
      --dry-run)       DRY_RUN=1; shift ;;
      --help|-h)
        cat <<HELP
Usage: ./install.sh [--skip-packages] [--dry-run]

  --skip-packages  Skip OS package installation; only refresh symlinks.
  --dry-run        Print intended symlinks without creating them.

Default: install OS packages via install/<os>.sh, then symlink dotfiles.
HELP
        exit 0
        ;;
      *)
        echo "Unknown flag: $1" >&2
        exit 2
        ;;
    esac
  done

  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Detect OS extension
  OS_EXT=$(detect_os_extension)
  echo "Detected OS: $OS_EXT"

  # Dispatch to per-OS package installer unless --skip-packages
  if [[ "$SKIP_PACKAGES" -eq 0 ]]; then
    local script=""
    case "$OS_EXT" in
      mac)
        script="$DOTFILES_DIR/install/mac.sh" ;;
      ubuntu|debian)
        script="$DOTFILES_DIR/install/apt.sh" ;;
      wsl)
        script="$DOTFILES_DIR/install/wsl.sh" ;;
      *)
        echo "WARNING: No package installer for OS '$OS_EXT' — skipping package install."
        script="" ;;
    esac

    if [[ -n "$script" ]]; then
      if [[ ! -x "$script" ]]; then
        echo "ERROR: $script is missing or not executable." >&2
        exit 1
      fi
      echo "==> Running $(basename "$script")..."
      "$script"
      echo "==> Package install complete. Continuing to symlink pass..."
    fi
  fi

  # Clean up broken symlinks first
  cleanup_broken_symlinks "$DOTFILES_DIR"

  # Check for zsh and install Oh My Zsh if needed (skip in dry-run)
  if [[ "$DRY_RUN" -eq 0 ]] && { [[ -f "/bin/zsh" ]] || [[ -f "/usr/bin/zsh" ]] || command -v zsh &>/dev/null; }; then
    echo "Found zsh, checking Oh My Zsh..."
    install_oh_my_zsh
  elif [[ "$DRY_RUN" -eq 0 ]]; then
    echo "SKIPPED: zsh not found. Oh My Zsh installation skipped."
    echo "If you want to use Oh My Zsh, please install zsh using your package manager:"
    echo "  - On Ubuntu/Debian: sudo apt install zsh"
    echo "  - On Fedora: sudo dnf install zsh"
    echo "  - On macOS: brew install zsh"
    echo "Then run this script again."
  fi

  # Process top-level files and directories
  for file in "$DOTFILES_DIR"/*; do
    # Get the base filename
    filename=$(basename "$file")

    # Skip this script, installation scripts, README, hidden files, and new top-level dirs
    case "$filename" in
      install.sh|install|tests|docs|CLAUDE.md|README.md|LICENSE|package-lock.json)
        echo "skip processing file: $filename"
        continue
        ;;
      install.*.sh)
        echo "skip processing file: $filename"
        continue
        ;;
      *.example)
        # Templates are copied below, not symlinked
        continue
        ;;
      .*)
        echo "skip processing file: $filename"
        continue
        ;;
    esac

    # Special handling for config directory
    if [[ "$filename" == "config" ]]; then
      echo "Processing .config directory structure..."
      process_directory "$file" "$HOME/.config" "$OS_EXT"
      continue
    fi

    # Handle top-level files and directories
    if [[ -d "$file" ]]; then
      # Directory

      # Check if directory has an OS extension
      if contains_os_extension "$filename" "$OS_EXT"; then
        # This directory is for current OS
        # Get target directory name without replacing OS extension
        target_dir="$HOME/.$filename"
        echo "Processing OS-specific directory: $filename -> $target_dir"
        symlink_file "$file" "$target_dir"
      elif contains_os_extension "$filename" "mac" ||
        contains_os_extension "$filename" "ubuntu" ||
        contains_os_extension "$filename" "debian" ||
        contains_os_extension "$filename" "fedora" ||
        contains_os_extension "$filename" "win" ||
        contains_os_extension "$filename" "wsl"; then
        # Directory for a different OS - skip it
        echo "Skipping directory for different OS: $filename"
      else
        # Common directory with no OS extension
        target_dir="$HOME/.$filename"
        echo "Processing common directory: $filename -> $target_dir"
        symlink_file "$file" "$target_dir"
      fi
    else
      # File

      # Check if file has current OS extension
      if contains_os_extension "$filename" "$OS_EXT"; then
        # This file is for current OS - symlink it with the exact name
        target="$HOME/.$filename"
        echo "Processing OS-specific file: $filename -> $target"
        symlink_file "$file" "$target"
      elif contains_os_extension "$filename" "mac" ||
        contains_os_extension "$filename" "ubuntu" ||
        contains_os_extension "$filename" "debian" ||
        contains_os_extension "$filename" "fedora" ||
        contains_os_extension "$filename" "win" ||
        contains_os_extension "$filename" "wsl"; then
        # File for a different OS - skip it
        echo "Skipping file for different OS: $filename"
      else
        # Common file with no OS extension
        target="$HOME/.$filename"
        echo "Processing common file: $filename -> $target"
        symlink_file "$file" "$target"
      fi
    fi
  done

  # Copy *.example templates to $HOME on first install (no overwrite)
  for example in "$DOTFILES_DIR"/*.example; do
    [[ -e "$example" ]] || continue
    base="$(basename "$example" .example)"     # e.g. secrets.zsh, gitconfig.local
    target="$HOME/.$base"
    if [[ -f "$target" ]]; then
      echo "INFO: $target already exists; leaving it alone."
      continue
    fi
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "DRY-RUN: would copy $example -> $target"
      continue
    fi
    cp -f "$example" "$target"
    # Tighten perms on anything secret-shaped
    case "$base" in
      secrets.*|*.local) chmod 600 "$target" ;;
    esac
    echo "Created $target from $(basename "$example")"
  done

  # Print summary of backup files if any were created
  backup_files=$(find "$HOME" -name "*.backup.*" 2>/dev/null)
  if [[ -n "$backup_files" ]]; then
    echo
    echo "The following backup files were created:"
    echo "$backup_files"
    echo
    echo "You can remove them manually once you confirm everything is working correctly."
  fi

  echo "Dotfiles installation complete!"

  # Optional MCP server setup — skip in dry-run or non-interactive shells
  if [[ -f "$DOTFILES_DIR/setup-zen-mcp.sh" ]] && [[ -t 0 ]] && [[ "$DRY_RUN" -eq 0 ]]; then
    echo
    read -r -p "Would you like to set up MCP servers (zen + zencode) for Claude Code and Cursor? (user scope) (y/n): " -n 1 REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Running MCP server setup (user scope)..."
      "$DOTFILES_DIR/setup-zen-mcp.sh"
    else
      echo "Skipping MCP server setup. You can run it later with: ./setup-zen-mcp.sh"
      echo "Note: MCP servers will be configured for Claude Code (~/.config/claude/mcp.json) and Cursor (~/.cursor/mcp.json)"
    fi
  fi
}

# Run the main function
main "$@"
