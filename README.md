# dotfiles

Personal dotfiles. One command to bootstrap a dev environment on macOS, Debian/Ubuntu, or WSL.

## Install

```sh
git clone https://github.com/sherodtaylor/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
chsh -s $(command -v zsh)
```

Open a new shell. Done.

`install.sh` detects your OS, dispatches package installation to the matching `install/<os>.sh`, then symlinks every top-level file/dir into `$HOME` (backing up anything it would overwrite).

Flags:
- `./install.sh --skip-packages` — skip package install, only symlink (fast re-run after config edits)
- `./install.sh --dry-run` — print intended symlinks without creating them

## What you get

| Layer | Tools |
|---|---|
| Shell | zsh + Oh My Zsh + `eastwood` theme |
| Editor | Neovim (LazyVim config in `config/nvim/`), vim fallback |
| Terminal | tmux, WezTerm (mac), FiraCode Nerd Font |
| Core CLI | rg, fd, bat, jq, yq, gh, fzf, zoxide, eza, ag |
| Languages | go, node (via nvm), python (via uv), rust (via rustup) |
| AI | `claude-code` |

## Personal overrides

Put machine-specific config in:

- `~/.zshrc.local` — shell additions
- `~/.gitconfig.local` — git user/work overrides (seeded from `gitconfig.local.example` on first install)
- `~/.aliases.local` — extra aliases
- `~/.secrets.zsh` — API tokens, etc. (chmod 600, seeded from `secrets.zsh.example` on first install)

None of these are committed. `install.sh` only seeds them if missing — your existing files are never overwritten.

## OS-specific files

Append `.mac`, `.ubuntu`, `.debian`, `.wsl`, `.fedora`, or `.win` to a filename or directory name to gate it to that OS — `install.sh` only symlinks matching entries. See `hammerspoon.mac/` and `gvimrc.mac` for examples.

## Repo layout

```
install/      OS install scripts + package lists (Brewfile, packages.apt)
zsh/os/       Per-OS shell fragments sourced by zshrc
zsh/          completion/, functions/
config/       nvim, wezterm, cursor, LaunchAgents
bin/          personal scripts on $PATH
tests/        lint + verify-install
docs/         design docs and implementation plans
```

## Development

```sh
./tests/lint.sh             # shellcheck all scripts
./tests/verify-install.sh   # sanity check after install
```

CI runs the install end-to-end in `ubuntu:24.04` on every push.

## License

[MIT](LICENSE). Originally forked from [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles).
