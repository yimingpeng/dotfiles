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
  home.sessionPath = [ "${config.home.homeDirectory}/.npm-global/bin" ];
  
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

}
