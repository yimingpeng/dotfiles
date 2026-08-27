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
- `agents`: Everything shared across AI coding agents.
  - `agents/AGENTS.md`: Global agent rules, symlinked into `~/.claude/CLAUDE.md`,
    `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`, and
    `~/.pi/agent/AGENTS.md`. Includes the vendored Ponytail ruleset in a marked
    block
  - `agents/skills`: The skills that are switched **on**. First-party skills
    (e.g. `writing-mentor`, `talk-workflow`) live directly here as folders;
    every other entry is a symlink into `agents/vendor/`. Symlinked into
    `~/.claude/skills`, `~/.pi/agent/skills`, and `~/.codex/skills/dotfiles`
  - `agents/vendor`: Full upstream skill sets, tracked as `git subtree` (see
    [Updating vendored skills](#updating-vendored-skills))
  - `agents/.pi`: pi settings, models, themes, and extensions
- `archives`: Deprecated/legacy configs kept for reference (e.g. the old
  `.zshrc`, now that zsh is configured declaratively via `nix/home.nix`)
- `scripts`: Standalone personal scripts, symlinked onto `PATH` via
  `nix/home.nix`. Currently just `create_project.py` (the `create-project`
  command)

## Agent skills

Skills follow the [Agent Skills standard](https://agentskills.io): a folder with
a `SKILL.md`. Claude Code, pi, and Codex all read that format, so one directory
serves all three.

Two layers, deliberately:

- **`agents/vendor/`** holds the complete upstream sets, so everything is on
  disk to browse and update.
- **`agents/skills/`** holds only the skills that are enabled. First-party
  skills (like `writing-mentor` and `talk-workflow`) live here as folders;
  vendored skills are enabled as symlinks into `agents/vendor/`. This is what
  the agents actually see.

Enable a skill:

```sh
ln -sfn ../vendor/mattpocock-skills/skills/engineering/wizard \
        ~/.dotfiles/agents/skills/wizard
```

Disable one: delete the symlink. Neither needs a rebuild - only adding a brand
new *path* to `home.nix` does.

Claude Code only looks **one level deep** for `SKILL.md`, which is why
`agents/skills/` is flat and the categorised upstream tree stays in
`agents/vendor/`.

`~/.codex/skills` is **not** symlinked wholesale, because Codex owns and writes
that directory (its `.system` built-ins plus installed skills). Codex gets
`~/.codex/skills/dotfiles` instead.

### Updating vendored skills

```sh
# Matt Pocock's skills
git subtree pull --prefix=agents/vendor/mattpocock-skills \
  https://github.com/mattpocock/skills.git main --squash

# Ponytail
git subtree pull --prefix=agents/vendor/ponytail \
  https://github.com/DietrichGebert/ponytail.git main --squash
```

Existing symlinks keep working, since they point at paths inside the subtree.
Two things to check after a pull: newly added skills are **not** enabled
automatically (add a symlink if wanted), and if `agents/vendor/ponytail/AGENTS.md`
changed, re-copy it into the marked `VENDORED: ponytail` block in
`agents/AGENTS.md`.

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
| `codex` | OpenAI Codex CLI (the `codex` command; the Codex app is separate) |
| `uv` | Python package manager (`uv tool install` -> `~/.local/bin`) |
| `nil` | Nix language server (used by nvim's `nil_ls`) |
| `nixfmt` | Nix formatter (invoked by `nil_ls`) |
| `statix` | Nix linter (invoked by `nil_ls` for diagnostics) |
| `nerd-fonts.hack` | Hack Nerd Font, the font everything renders in |

### npm-global tools (via activation hook)

| Tool | Purpose |
| --- | --- |
| `freebuff` | AI coding agent CLI; no nixpkgs/Homebrew package exists, so a `home.activation` hook runs `npm install -g` on every rebuild instead |
| `@suibiji/dida-cli` | DIDA CLI (TickTick/Dida365's own documented task-management CLI, binary `dida`); same no-nixpkgs-package, activation-hook rationale as `freebuff` |

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
- By 18/08/2026, fixed a missing `;` in `nix/configuration.nix`'s `homebrew`
  block that was breaking `nil_ls`'s nixfmt formatting, and added `nixfmt`
  and `statix` to `home.packages` so `nil_ls`'s formatting and lint
  diagnostics actually have binaries to call.
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
- By 18/08/2026, removed `NSGlobalDomain._HIHideMenuBar` from
  `nix/configuration.nix`, which had been auto-hiding the top menu bar
  alongside the Dock. `dock.autohide` alone now controls Dock-only hiding.
- By 18/08/2026, fixed zoxide's "initialize me at the end of your shell
  config" warning firing on every `cd`. `programs.zoxide.enableZshIntegration`
  doesn't control where home-manager splices the init line into `.zshrc`, so
  it always landed before `starship`. Turned that integration off and eval
  `zoxide init zsh` manually in `programs.zsh.initContent` under `lib.mkAfter`
  instead, forcing it to the very end of `.zshrc`.
- By 18/08/2026, added `rclone` to `home.packages` to replace the pCloud
  desktop app for bulk uploads, which was consuming excessive memory. The
  `rclone` remote config (`~/.config/rclone/rclone.conf`) holds OAuth tokens
  and is intentionally not tracked in this repo; set it up locally with
  `rclone config`.
- By 19/08/2026, added `create-project` to PATH via a
  `home.file.".local/bin/create-project"` symlink in `nix/home.nix`, pointing
  at `create_project.sh` in the (separate, pCloud-synced) `automation/workflow`
  repo. `~/.local/bin` is already on PATH via nix. Also fixed that wrapper
  script to `cd` to its own resolved location instead of a hardcoded
  `~/Documents/workflow`, since it's now invoked through a symlink and its
  actual location is the pCloud-synced repo.
- By 20/08/2026, moved off pCloud: this repo now lives at
  `~/Documents/My_Code/dotfiles` (the old pCloud copy had sync-conflict
  damage to its `.git`). `~/.dotfiles` is repointed there; `rebuild_nix.sh`
  handles this automatically on any machine it's run from.
- By 20/08/2026, folded the separate `automation/workflow` repo's
  `create-project` script into this repo as `scripts/create_project.py`.
  Dropped `click` in favor of plain `sys.argv` (single positional arg didn't
  need a CLI framework), and dropped the `.venv`/`uv.lock`/`pyproject.toml`
  scaffolding and the `create_project.sh` wrapper along with it - the script
  is pure stdlib, so it's just an executable file symlinked directly onto
  `PATH` like everything else in `nix/home.nix`. `config.toml` in the old repo
  was unused dead weight (the script hardcoded its paths regardless) and
  wasn't carried over.
- By 24/08/2026, added `freebuff` (an AI coding agent CLI). It has no
  nixpkgs package or Homebrew formula, only `npm install -g freebuff`, and
  ships releases frequently enough that hand-pinning an `npmDepsHash` for a
  `buildNpmPackage` derivation wasn't worth the upkeep. Instead added a
  `home.activation` hook in `nix/home.nix` that runs `npm install -g`
  against `~/.npm-global` (already on `PATH` via the existing
  `NPM_CONFIG_PREFIX`/`sessionPath` setup) on every `darwin-rebuild switch`,
  so it self-updates like the Homebrew brews/casks do. The hook is
  non-fatal on failure so a network blip doesn't break the rest of the
  system activation.
- By 24/08/2026, enabled the `teach` skill (from `mattpocock-skills`,
  `productivity/teach`) by symlinking it into `agents/skills/teach`. No
  rebuild needed - it's live in `~/.claude/skills` immediately. It's
  invoked as `/teach`, not `/learn` (`disable-model-invocation: true` means
  it only runs on explicit invocation).
- By 24/08/2026, added the DIDA CLI (`@suibiji/dida-cli`, binary `dida`) -
  this is the CLI actually documented on TickTick/Dida365's own help site
  (help.dida365.com), not `@ticktick/ticktick-cli` as first assumed. Like
  `freebuff`, it has no nixpkgs/Homebrew package and ships frequent point
  releases, so it's installed via a second `home.activation` hook in
  `nix/home.nix` instead of a pinned `buildNpmPackage` derivation. After
  rebuilding, run `dida auth login` once to authenticate (browser OAuth) -
  that step is interactive and intentionally not scripted here.
  Also confirmed the vendored `ponytail` and `mattpocock-skills` skill sets
  (`agents/vendor/`) are frozen `git subtree` snapshots, not auto-updating -
  see "Updating vendored skills" above for the manual refresh commands.
- By 28/08/2026, added the `talk-workflow` skill, a first-party talk coach
  distilled from the `agent-talk-workflow` repo into a single `SKILL.md` plus
  one lazily-loaded `references/sources.md` (provenance honesty, the
  load-bearing rulings, and the citation table). It lives directly in
  `agents/skills/talk-workflow/` like `writing-mentor` - no vendor subtree, no
  template pipeline, no checker script. Also corrected the README's
  `agents/skills` description, which said every entry is a symlink into
  `agents/vendor/`.
