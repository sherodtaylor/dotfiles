# CLAUDE.md

Context for AI coding agents working in this dotfiles repo.

## What this is

Personal dotfiles for Sherod Taylor. One-command bootstrap for a dev environment
on macOS, Debian/Ubuntu, and WSL.

## How install works

One command: `./install.sh`. Internally it:

1. **Detects OS** (`detect_os_extension()` → `mac`/`ubuntu`/`debian`/`wsl`/etc.)
2. **Installs packages** by dispatching to the matching `install/<os>.sh`:
   - `install/mac.sh` (Homebrew + `install/Brewfile`)
   - `install/apt.sh` (apt + `install/packages.apt` + release tarballs for newer tools)
   - `install/wsl.sh` (delegates to `apt.sh` + win32yank)
3. **Symlinks** every top-level file/dir to `~/.<name>` (with backup if already present)

Flags:
- `--skip-packages` — skip step 2 (re-run only the symlink pass)
- `--dry-run` — print intended symlinks without creating them

`install.sh` gates files/dirs by suffix: `name.mac`, `name.ubuntu`, `name.wsl`, etc.
A file or dir with no OS suffix is treated as universal. The detected OS is used
to decide which suffixed files apply.

The per-OS scripts in `install/` are also directly invocable for debugging
(`./install/apt.sh` runs only the package install, skipping symlinks).

Existing OS-gated entries: `hammerspoon.mac/`, `gvimrc.mac`, `install.mac.sh` (now `install/mac.sh`).

## Shell config loads OS-aware

Base `zshrc` is slim. It sources:
- `zsh/os/common.zsh` — universal
- `zsh/os/{mac,linux,wsl}.zsh` — picked by OS detection in `zshrc`
- `~/.aliases` (the symlinked `aliases` file)
- `~/.secrets.zsh` (gitignored personal secrets file)
- `~/.zshrc.local` (gitignored personal additions per machine)

Anything machine-specific belongs in `~/.zshrc.local` or `~/.gitconfig.local`, never
committed to the base `zshrc` or `gitconfig`.

## Git workflow

- Default branch: `master` (historical; rename to `main` is a separate change)
- Feature branches: `feat/<short-slug>` or `fix/<short-slug>`
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- One PR per concern. Don't bundle unrelated changes.

## Tests / CI

- `tests/lint.sh` — shellcheck over every shell script in the repo
- `tests/verify-install.sh` — checks symlinks + binary presence after install
- `.github/workflows/ci.yml` — runs apt install + install.sh + verify in `ubuntu:24.04`
- CI must be green before merging.

## What lives where

| Path | Purpose |
|---|---|
| `install/` | Installation entry scripts + declarative package lists |
| `zsh/os/` | Per-OS shell fragments |
| `zsh/completion/`, `zsh/functions/` | Custom zsh completion + functions |
| `config/nvim/` | LazyVim configuration (do not edit casually) |
| `config/wezterm/` | WezTerm terminal config |
| `bin/` | Personal scripts on `$PATH` after install |
| `tests/` | Lint + verification scripts |
| `docs/specs/`, `docs/plans/` | Design docs and implementation plans |

## Gotchas

- Don't add hardcoded `$HOME/...` paths to committed config — use `~` or `$HOME` consistently and gate by OS.
- `*.example` templates at the repo root (e.g., `secrets.zsh.example`, `gitconfig.local.example`) are copied — not symlinked — to `~/.<name>` on first install only. `install.sh` skips copying if the target already exists. Don't put real secrets or personal config in the `.example` files.
- LazyVim regenerates `config/nvim/lazy-lock.json` — commit it on plugin updates so installs are reproducible.
- On Debian, `fd` is `fdfind` and `bat` is `batcat` — `zsh/os/linux.zsh` aliases them.
