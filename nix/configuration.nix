{ config, lib, pkgs, ... }:

with lib;

{
  # Leave the determinate to handle the Nix, so here we disable it from nix-darwin
  nix.enable = false;

  nixpkgs.config.allowUnfree = true; # allow us to install apps that are not completely free
  nixpkgs.hostPlatform = "x86_64-darwin"; # use x86_64-darwin for Intel CPU

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
    onActivation.upgrade = true; # actually upgrade outdated brews/casks on every activation
    onActivation.extraFlags = [ "--force" ];
    # Intel Mac (x86_64-darwin) — Homebrew dropped x86_64 macOS bottles for
    # newer versions of gh, openssl@3, pi-coding-agent, and rtk. Source builds
    # aren't viable here either (rtk pulls in llvm@22 + rust, multi-hour).
    # So:
    #   - gh: stays here (currently installed 2.98.0 has a working bottle).
    #     Pinned below to keep brew bundle from trying to upgrade to 2.99.0,
    #     which has no x86_64 bottle. Unpin manually to upgrade once bottles
    #     reappear.
    #   - pi-coding-agent: downloaded from GitHub releases into ~/.local/
    #     by a home.activation hook in nix/home.nix
    #   - rtk: same — GitHub release binary into ~/.local/bin/
    #   - openssl@3: stays here because pre-commit/rsync/pi-coding-agent
    #     etc. link against the Homebrew copy. Pinned below for the same
    #     reason as gh.
    brews = [
      "zoxide"
      "herdr"
      "ca-certificates"
      "openssl@3"
      "gh"
      "tailscale"
      "pre-commit"
      "kubeconform"
      "rsync"
    ];
    casks = [
      "wezterm"
      "claude-code"
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

  # Pin openssl@3 and gh so brew bundle doesn't try to upgrade either to
  # a version with no x86_64 macOS bottle. Idempotent: `brew pin` is a no-op
  # if already pinned. Runs as root via sudo -u, matching the user that owns
  # the Homebrew install (brew pin writes to /usr/local/var/homebrew/pinned).
  # postActivation runs AFTER the homebrew bundle slot in the master
  # activation script, so the pin is in place before the next rebuild's
  # brew bundle checks for outdated formulae.
  system.activationScripts.postActivation = {
    text = ''
      /usr/bin/sudo --user=${escapeShellArg config.system.primaryUser} --set-home \
        ${config.homebrew.prefix}/bin/brew pin openssl@3 \
          || echo "brew pin openssl@3 failed (non-fatal), continuing"
      /usr/bin/sudo --user=${escapeShellArg config.system.primaryUser} --set-home \
        ${config.homebrew.prefix}/bin/brew pin gh \
          || echo "brew pin gh failed (non-fatal), continuing"
    '';
  };
}
