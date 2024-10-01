#!/bin/sh

#!/bin/sh

function symlink_file {
  local src="$1"
  local target="$2"
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      echo "WARNING: $target exists but is not a symlink."
    fi
  else
    echo "Creating symlink for $src to $target"
    ln -s "$src" "$target"
  fi
}

for name in *; do
  # Skip hidden files (starting with .) and install.sh, README.md
  if [[ $name == .+ ]] || [[ $name == "install.sh" ]] || [[ $name == "README.md" ]]; then
    continue
  fi

  # Construct source and target paths
  src="$PWD/$name"
  target="$HOME/.$name"

  # Check if it's a directory and call recursively
  if [ -d "$src" ]; then
    # Create target directory if it doesn't exist
    mkdir -p "$target"
    # Call the symlink_file function recursively for each file inside
    for f in "$src/"*; do
      symlink_file "$f" "$target/$(basename "$f")"
    done
  else
    # Symlink the file
    symlink_file "$src" "$target"
  fi
done
