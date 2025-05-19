#!/bin/bash

# Detect operating system and return appropriate extension
detect_os_extension() {
  # Check for WSL first
  if grep -q Microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "mac"
  elif [[ -f /etc/os-release ]]; then
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
  local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"

  echo "Backing up $target to $backup"
  cp -a "$target" "$backup"
  return $?
}

# Symlink function (works for both files and directories)
symlink_file() {
  local src="$1"
  local target="$2"

  # Create parent directories if they don't exist
  mkdir -p "$(dirname "$target")"

  if [[ -e "$target" ]]; then
    if [[ ! -L "$target" ]]; then
      echo "WARNING: $target exists but is not a symlink."
      echo "Creating backup before replacing..."
      if backup_target "$target"; then
        echo "Backup created successfully. Removing original to create symlink."
        rm -rf "$target"
      else
        echo "ERROR: Failed to create backup. Skipping symlink creation for safety."
        return 1
      fi
    elif [[ "$(readlink "$target")" != "$src" ]]; then
      echo "WARNING: $target is a symlink but points to a different location."
      echo "Creating backup before replacing..."
      if backup_target "$target"; then
        echo "Backup created successfully. Removing original symlink."
        rm -f "$target"
      else
        echo "ERROR: Failed to create backup. Skipping symlink creation for safety."
        return 1
      fi
    else
      echo "INFO: $target symlink already exists and points to the right location."
      return 0
    fi
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
  if [[ -n "$ZSH" ]]; then
    original_zsh="$ZSH"
  fi

  # Use a temporary file to capture output
  local temp_output=$(mktemp)

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

  touch $HOME/.oh-my-zsh
  return 0
}

# Run OS-specific install scripts
run_os_specific_installers() {
  local os_ext="$1"
  local dotfiles_dir="$2"

  # Check for OS-specific install script with format: install.mac.sh
  local os_install_script="$dotfiles_dir/install.$os_ext.sh"
  if [[ -f "$os_install_script" ]]; then
    echo "Running OS-specific installation script: install.$os_ext.sh"
    # Make sure it's executable
    chmod +x "$os_install_script"
    # Run the script
    "$os_install_script"
  fi
}

# Process a directory recursively
process_directory() {
  local src_dir="$1"
  local target_dir="$2"
  local os_ext="$3"

  echo "Processing directory: $src_dir -> $target_dir"

  # Create target directory if it doesn't exist
  mkdir -p "$target_dir"

  # Process each file/subdirectory
  for item in "$src_dir"/*; do
    # Skip if no files in directory
    if [[ ! -e "$item" ]]; then
      continue
    fi

    local item_name=$(basename "$item")

    # Skip README files and hidden files
    if [[ "$filename" == "install.sh" ]] || [[ "$filename" == "secrets.zsh" ]] || [[ "$filename" == "install."*".sh" ]] || [[ "$filename" == "README.md" ]] || [[ "$filename" == .* ]]; then
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
  # Detect OS extension
  OS_EXT=$(detect_os_extension)
  echo "Detected OS: $OS_EXT"

  # Base dotfiles directory
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Run OS-specific install scripts
  run_os_specific_installers "$OS_EXT" "$DOTFILES_DIR"

  # Check for zsh and install Oh My Zsh if needed
  if [[ -f "/bin/zsh" ]]; then
    echo "Found /bin/zsh, checking Oh My Zsh..."
    install_oh_my_zsh
  else
    echo "SKIPPED: /bin/zsh not found. Oh My Zsh installation skipped."
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

    # Skip this script, installation scripts, README, and hidden files
    if [[ "$filename" == "install.sh" ]] || [[ "$filename" == "secrets.zsh" ]] || [[ "$filename" == "install."*".sh" ]] || [[ "$filename" == "README.md" ]] || [[ "$filename" == .* ]]; then
      echo "skip processing file: $filename"
      continue
    fi

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

  echo "copying $HOME/secrets.zsh"
  cp -rf secrets.zsh "$HOME/.secrets.zsh"

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
}

# Run the main function
main
