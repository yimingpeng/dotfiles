{ ... }:

{
  # Leave the determinate to handle the Nix, so here we disable it from nix-darwin 
  nix.enable = false;

  nixpkgs.config.allowUnfree = true; # allow us to install apps that are not completely free
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86-64-darwin for Intel CPU
  
  # Define the main user, get from `id` command
  system.primaryUser = "yimingpeng";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
