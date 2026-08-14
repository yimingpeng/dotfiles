# dotfiles

The repo contains all my dotfiles

## What it contains

- `wezterm`: This folder contains the configs for my `wezterm`
- `iterm2`: This folder contains my default `iterm2` profile
- `nvim`: My `nvim` config, LazyVim-based - catppuccin colorscheme, `obsidian.nvim`
  wired to my personal notes vault, telescope tweaks (horizontal layout,
  `<leader>fp` for plugin files), `cmp-emoji` completion, and LSPs for
  nix/python/typescript/markdown (`nil_ls` comes from home-manager, not
  Mason)
- `karabiner`: This folder contains all the configs for my `karabiner`, this is
  suitable for my filco 68 keyboard
- `starship.toml`: This is for configuring the look-and-feel for the prompt
- `vscode`: This folder includes all the configs for my `vscode`
- `herdr`: Config for `herdr`, a terminal session manager with tmux-style pane
  keybindings and an agents panel for managing multiple AI coding agent sessions
- `AGENTS.md`: Project-level agent rules for this repo (e.g. always update
  the README at the end of any change); global rules live in
  `agents/AGENTS.md`
- `.claude`: My Claude Code settings (`settings.json`), symlinked into
  `~/.claude`, plus `CLAUDE.md` (symlink to the project `AGENTS.md`) so
  Claude Code picks up the project rules. The directory is gitignored
  (see `.gitignore`) - `settings.json` is local-only and no longer tracked
- `archives`: Deprecated/legacy configs kept for reference (e.g. the old
  `.zshrc`, now that zsh is configured declaratively via `nix/home.nix`)

## System setup (nix-darwin + home-manager)

- `nix/`: Declarative macOS system config — `flake.nix` (inputs: nixpkgs,
  nix-darwin, nix-homebrew, home-manager), `configuration.nix` (system defaults,
  homebrew brews/casks), and `home.nix` (packages, zsh/starship/git/zoxide
  setup, and symlinks for `wezterm`, `starship.toml`, `nvim`, `herdr`, and
  `.claude/settings.json` into place)
- `rebuild_nix.sh`: Symlinks this repo to `~/.dotfiles` and runs
  `darwin-rebuild switch` to apply the config
- Homebrew itself is now managed through nix-darwin (see
  `nix/configuration.nix`). See [Installed applications](#installed-applications)
  for the full list of what gets installed

## Installed applications

Everything below is installed declaratively - nixpkgs packages come from
`nix/home.nix`, homebrew packages from `nix/configuration.nix`, and enabled
programs from home-manager's `programs.*` modules in `nix/home.nix`.

### Homebrew casks (GUI apps)

| App | Purpose | Config |
| --- | --- | --- |
| `wezterm` | Terminal emulator | `wezterm/` |
| `claude-code` | Claude Code CLI | `agents/`, `home.nix` aliases |

### Homebrew brews (CLI)

| Tool | Purpose |
| --- | --- |
| `zoxide` | Smarter `cd` |
| `herdr` | Terminal session manager with agents panel |
| `gh` | GitHub CLI |
| `pi-coding-agent` | AI coding agent (pi) |
| `openssl@3` | TLS/SSL library |
| `ca-certificates` | Root CA certificates |

### home-manager packages (nixpkgs)

| Tool | Purpose |
| --- | --- |
| `neovim` | Editor (LazyVim-based, see `nvim/`) |
| `lazygit` | Terminal git UI |
| `ripgrep` | Fast search |
| `fd` | Fast find |
| `fzf` | Fuzzy finder |
| `jq` | JSON on the command line |
| `nodejs_22` | Node.js 22 runtime |
| `uv` | Python package manager (`uv tool install` -> `~/.local/bin`) |
| `nil` | Nix language server (used by nvim's `nil_ls`) |
| `nerd-fonts.hack` | Hack Nerd Font, the font everything renders in |

### Enabled via home-manager `programs.*` modules

- `zsh` with autosuggestions, syntax highlighting, and aliases
- `starship` prompt (config in `starship.toml`)
- `git` (identity set in `home.nix`)
- `zoxide` (replaces `cd` entirely)

## References

- The nix-darwin + home-manager setup was inspired by
  [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles) and
  [his YouTube walkthrough](https://www.youtube.com/watch?v=5N-okeDdIuI)

## Change Logs

- By 31/08/2025, I decided to switch back to `iterm2`, enjoying its out-of-box
  experience.
- By 09/08/2026, migrated system setup to `nix-darwin` + `home-manager` (see
  `nix/`), replacing manual dotfile symlinking and one-off `brew install` steps.
  Added `herdr` for agent session management, started tracking Claude Code
  settings, archived the old `.zshrc`, and brought `wezterm` back into active
  use alongside `iterm2`.
- By 11/08/2026, added a References section crediting Kun Chen's dotfiles and
  YouTube walkthrough as the inspiration for the nix-darwin + home-manager
  setup.
- By 14/08/2026, documented the `nvim` setup (LazyVim config, plugins, LSP
  details) in this README, and added a project-level `AGENTS.md` at the repo
  root (with `.claude/CLAUDE.md` symlinked to it) requiring that the README
  be updated after every change to this repo.
- By 14/08/2026, added an Installed applications section listing everything
  installed via `nix/home.nix` (packages + enabled programs) and
  `nix/configuration.nix` (homebrew brews/casks).
- By 14/08/2026, stopped tracking `.claude/settings.json` (it was already in
  `.gitignore`, but was still tracked from before the ignore rule was added).
  It is now untracked and gitignored like the rest of `.claude`.
