{ ... }:

{
  # Leave the determinate to handle the Nix, so here we disable it from nix-darwin 
  nix.enable = false;

  nixpkgs.config.allowUnfree = true; # allow us to install apps that are not completely free
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86-64-darwin for Intel CPU
  
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
        KeyRepeat = 2;            # fast key repeat 
        InitialKeyRepeat = 15;    # short delay before repeat 
        _HIHideMenuBar = true;    # auto-hide the menu bar
        AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv"; # list view by default 
    finder.CreateDesktop = false;         # clean desktop 
    trackpad.Clicking = true;             # tap to click
  };

  # add the homebrew configurations 
  nix-homebrew = {
    enable = true;
    user = "yimingpeng";
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";   # remove anything not listed here 
    onActivation.autoUpdate = true; # auto-update
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "zoxide"
      "herdr"
    ];
    casks = [
      "wezterm"
      "claude-code"
    ];
  };
}
