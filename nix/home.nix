{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = "yimingpeng";
  home.homeDirectory = "/Users/yimingpeng";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    nil        # Nix language server, used by nvim's nil_ls (Mason can't build it: no cargo)
    nixfmt     # Nix formatter, invoked by nil_ls
    statix     # Nix linter, invoked by nil_ls for diagnostics
    # the font everything renders in
    nerd-fonts.hack
    nodejs_22
    codex       # OpenAI Codex CLI (the `codex` command; the Codex app is separate)
    uv          # python package manager; `uv tool install` puts tools in ~/.local/bin
    rclone      # CLI sync/upload to cloud storage (used for pCloud instead of the memory-hungry pCloud app)
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  # ~/.local/bin holds user-installed binaries from activation hooks below
  # (rtk, pi-coding-agent); prepending it to sessionPath keeps them ahead of
  # any old copies that might still be on PATH from a previous install.
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  # freebuff has no nixpkgs/Homebrew package, only `npm install -g freebuff`.
  # Installed via activation hook (not a pinned buildNpmPackage derivation)
  # since it ships new releases frequently; this keeps it auto-updated on
  # every darwin-rebuild switch instead of hand-maintaining an npmDepsHash.
  home.activation.installFreebuff = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.nodejs_22}/bin/npm install -g --prefix "$HOME/.npm-global" freebuff \
      || echo "freebuff install failed, continuing"
  '';

  # rtk (Rust Token Killer) and pi-coding-agent have no Homebrew x86_64
  # bottles for new versions, and source builds aren't viable on this Intel
  # Mac (rtk pulls llvm@22 + rust, multi-hour). Both publish pre-built
  # x86_64 darwin binaries on GitHub Releases, so download those directly
  # into ~/.local/. Versions below are bumped when the user wants to
  # upgrade - matching the release tag on GitHub.
  #
  # The hooks are non-fatal on failure so a network blip or GitHub rate
  # limit doesn't break the rest of the system activation.
  #
  # ponytail: relying on GitHub Releases as the source of truth for the
  # version is fragile (release gets yanked, rate-limited, mirror dies).
  # Acceptable ceiling because both projects ship signed releases; upgrade
  # is opt-in by editing the version string here.
  home.activation.installRtk = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL \
      "https://github.com/rtk-ai/rtk/releases/download/v0.47.0/rtk-x86_64-apple-darwin.tar.gz" \
      | ${pkgs.gnutar}/bin/tar -xz -C "$HOME/.local/bin" rtk \
      && ${pkgs.coreutils}/bin/chmod +x "$HOME/.local/bin/rtk" \
      || echo "rtk install failed, continuing"
  '';

  home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PI_DIR="$HOME/.local/share/pi-coding-agent/0.84.4"
    $DRY_RUN_CMD mkdir -p "$PI_DIR" \
      && ${pkgs.curl}/bin/curl -fsSL \
        "https://github.com/earendil-works/pi/releases/download/v0.84.4/pi-darwin-x64.tar.gz" \
        | ${pkgs.gnutar}/bin/tar -xz -C "$PI_DIR" \
      && ${pkgs.coreutils}/bin/ln -sfn "$PI_DIR/pi/pi" "$HOME/.local/bin/pi" \
      && ${pkgs.coreutils}/bin/chmod +x "$PI_DIR/pi/pi" \
      || echo "pi-coding-agent install failed, continuing"
  '';
  
  # config the zsh
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = lib.mkMerge [
      ''
        bindkey '^f' autosuggest-accept
      ''
      # zoxide's enableZshIntegration doesn't control where its init line
      # lands in .zshrc - home-manager splices it in at a fixed position
      # regardless of declaration order below. It must run after starship
      # (or anything else hooking precmd/chpwd) or it warns on every `cd`,
      # so the eval is placed here under mkAfter instead.
      (lib.mkAfter ''
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"
      '')
    ];
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };
  
  # config the starship
  programs.starship = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Yiming Peng";
      email = "yimingpengjojo@gmail.com";
    };
  };

  programs.zoxide = {
    enable = true;
    # Replaces the default 'cd' command completely with zoxide
    options = [ "--cmd cd" ];

    # integration to different shells
    enableBashIntegration = true;
    # zsh integration is wired manually in programs.zsh.initContent above
    # (via mkAfter) so it inits after starship instead of wherever
    # home-manager would otherwise splice it in.
    enableZshIntegration = false;
    enableFishIntegration = true;
  };

  # configs for various tools
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wezterm";

  home.file.".config/starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/starship.toml";

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";

  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/herdr";

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.claude/settings.json";

  # AGENTS.md wiring to all agents 
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/AGENTS.md";

  # RTK (Rust Token Killer) reference, shared across agents. Tracked file
  # in this repo; written by `rtk init -g --no-patch` after Homebrew installs
  # the formula. Claude Code auto-loads it via the @RTK.md reference that
  # `rtk init` adds; pi/Codex/opencode can read it on demand from the same
  # AGENTS.md directory.
  home.file.".claude/RTK.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/RTK.md";
  home.file.".codex/RTK.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/RTK.md";
  home.file.".config/opencode/RTK.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/RTK.md";

  # Agent skills, shared across agents.
  # agents/skills holds symlinks to the skills that are switched ON; the full
  # upstream sets live in agents/vendor/ as git subtrees. Enable another skill
  # by adding a symlink in agents/skills - no rebuild needed for that.
  #
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/skills";

  # Codex gets a nested subdirectory, NOT ~/.codex/skills itself: that directory
  # is owned and written by Codex (its .system built-ins plus installed skills),
  # so replacing it with a symlink would destroy them.
  home.file.".codex/skills/dotfiles".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/skills";

  # pi agent
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/AGENTS.md";
  home.file.".pi/agent/RTK.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/RTK.md";
  home.file.".pi/agent/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/skills";
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/agents/.pi/agent/settings.json";

  # create-project: scaffolds a matching project folder pair (Finder +
  # Obsidian/Google Drive) with a linked README.
  home.file.".local/bin/create-project".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/scripts/create_project.py";

}
