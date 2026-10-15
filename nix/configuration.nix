{ config, lib, pkgs, ... }:

with lib;

{
  # Leave the determinate to handle the Nix, so here we disable it from nix-darwin
  nix.enable = false;

  nixpkgs.config.allowUnfree = true; # allow us to install apps that are not completely free
  nixpkgs.hostPlatform = "x86_64-darwin"; # use x86_64-darwin for Intel CPU
  # Silence "Nixpkgs 26.05 will be the last release to support x86_64-darwin"
  # on every eval. Acknowledged: 26.05 gets binaries until end of 2026; 26.11
  # drops x86_64-darwin entirely, so stay on 26.05 (see README change log).
  nixpkgs.config.allowDeprecatedx86_64Darwin = true;
  # The bundled `darwin-uninstaller` evaluates a second, stock nix-darwin
  # system whose nixpkgs config can't see the flag above, so it would still
  # warn. If ever needed: `nix run nix-darwin#darwin-uninstaller`.
  system.tools.darwin-uninstaller.enable = false;

  # Define the main user, get from `id` command
  system.primaryUser = "yimingpeng";
  users.users.yimingpeng = {
    home = "/Users/yimingpeng";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Required so that /etc/zshrc & /etc/zprofile source
  # /etc/profiles/per-user/$USER/etc/profile.d/*.sh (incl. home-manager's
  # hm-session-vars.sh, which carries NPM_CONFIG_PREFIX etc.)
  programs.zsh.enable = true;

  # my own settings
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      # KeyRepeat = 2;            # fast key repeat
      # InitialKeyRepeat = 25;    # short delay before repeat, but not so short it double-fires on mechanical keyboard dwell time
      _HIHideMenuBar = true; # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv"; # list view by default
    finder.CreateDesktop = false; # clean desktop
    trackpad.Clicking = true; # tap to click
  };

  # add the homebrew configurations
  nix-homebrew = {
    enable = true;
    user = "yimingpeng";
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # remove anything not listed here
    onActivation.autoUpdate = true; # refresh brew's package index (does not upgrade installed packages)
    # onActivation.upgrade is left at its default (false): upgrading is the
    # `brew upgrade` at the end of rebuild_nix.sh, after the switch, so a
    # failed upgrade can never abort `darwin-rebuild switch`.
    #
    # Casks only, no `brews`. This Intel Mac (x86_64-darwin) is Homebrew
    # Tier 3: new formula versions ship no x86_64 bottle, so every formula
    # upgrade turned into a source build that failed (gh, herdr, rtk,
    # pi-coding-agent, tailscale, then pre-commit -> python@3.14 ->
    # openssl@4, and cmake for rsync's lz4/xxhash/zstd). Casks are
    # prebuilt app bundles and unaffected. CLI tools come from nixpkgs
    # instead (home.packages in nix/home.nix, services.tailscale below),
    # herdr from herdr-nix's package.nix, and rtk/pi-coding-agent from GitHub
    # release binaries (activation hooks in nix/home.nix).
    # `cleanup = "zap"` uninstalls the old Homebrew formulae.
    casks = [
      "wezterm"
      "claude-code@latest" # tracks Homebrew's "latest" release channel (vs "stable" for plain claude-code)
      "docker-desktop"
      "alfred"
      "arc"
      "betterdisplay"
      "rectangle"
      "sublime-text"
      "superwhisper"
      "visual-studio-code"
      "orbstack"
      "android-studio"
      "copilot-cli"
    ];
  };

  # Tailscale via nix-darwin's native module (pkgs.tailscale from nixpkgs)
  # instead of the Homebrew formula - see the homebrew comment above for why.
  # This installs the CLI and manages the `com.tailscale.tailscaled` launchd
  # daemon itself, replacing brew's `tailscale` service of the same name.
  services.tailscale.enable = true;

  # Remote Login (Apple's sshd), reachable only from the home LAN and the
  # tailnet. sshd listens on every interface and en0 has global IPv6
  # addresses, so AllowUsers is what keeps the open internet out. Keys work
  # from both; passwords only from the LAN. The `Match` ends at the end of this
  # included file, so it can't swallow later sshd_config.d drop-ins.
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      AllowUsers ${config.system.primaryUser}@192.168.31.0/24 ${config.system.primaryUser}@fe80::/10 ${config.system.primaryUser}@100.64.0.0/10 ${config.system.primaryUser}@fd7a:115c:a1e0::/48
      Match Address 192.168.31.0/24,fe80::/10
        PasswordAuthentication yes
    '';
  };
}
