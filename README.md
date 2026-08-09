# dotfiles
The repo contains all my dotfiles

# What it contains
- `wezterm`: This folder contains the configs for my `wezterm`
- `iterm2`: This folder contains my default `iterm2` profile
- `nvim`: This folder contains all the configs for my `nvim`
- `karabiner`: This folder contains all the configs for my `karabiner`, this is suitable for my filco 68 keyboard
- `starship.toml`: This is for configuring the look-and-feel for the prompt
- `vscode`: This folder includes all the configs for my `vscode`
- `herdr`: Config for `herdr`, a terminal session manager with tmux-style pane keybindings and an agents panel for managing multiple AI coding agent sessions
- `.claude`: My Claude Code settings (`settings.json`), symlinked into `~/.claude`
- `archives`: Deprecated/legacy configs kept for reference (e.g. the old `.zshrc`, now that zsh is configured declaratively via `nix/home.nix`)

# System setup (nix-darwin + home-manager)
- `nix/`: Declarative macOS system config — `flake.nix` (inputs: nixpkgs, nix-darwin, nix-homebrew, home-manager), `configuration.nix` (system defaults, homebrew brews/casks), and `home.nix` (packages, zsh/starship/git/zoxide setup, and symlinks for `wezterm`, `starship.toml`, `nvim`, `herdr`, and `.claude/settings.json` into place)
- `rebuild_nix.sh`: Symlinks this repo to `~/.dotfiles` and runs `darwin-rebuild switch` to apply the config
- Homebrew itself is now managed through nix-darwin (see `nix/configuration.nix`): brews `zoxide`, `herdr`; casks `wezterm`, `claude-code`

# Change Logs
- By 31/08/2025, I decided to switch back to `iterm2`, enjoying its out-of-box experience.
- By 09/08/2026, migrated system setup to `nix-darwin` + `home-manager` (see `nix/`), replacing manual dotfile symlinking and one-off `brew install` steps. Added `herdr` for agent session management, started tracking Claude Code settings, archived the old `.zshrc`, and brought `wezterm` back into active use alongside `iterm2`.
