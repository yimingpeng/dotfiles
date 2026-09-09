{
  description = "Yiming's darwin system";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Add the home brew url 
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Add the home manager to manage the home directory 
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # herdr has no nixpkgs/x86_64-darwin Homebrew bottle (Tier 3 dropped
    # it in 0.9.0). herdr-nix is the official packaging of herdr's
    # prebuilt release binary as a Nix derivation, with a Cachix cache
    # behind it. Used by `home.nix` (see the `herdr` let-binding there);
    # can be dropped once the upstream `update-herdr` bot bumps past 0.9.0
    # and our local override becomes unnecessary.
    herdr-nix.url = "github:herdrdev/herdr-nix";
  };

  # herdr-nix ships Cachix-cached builds. The substituter and public key
  # are declared here so `darwin-rebuild switch` (which runs from inside
  # this flake) picks them up automatically - herdr's binary then comes
  # from the cache instead of being re-fetched and re-hashed locally.
  nixConfig = {
    extra-substituters = [ "https://herdr.cachix.org" ];
    extra-trusted-public-keys = [
      "herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="
    ];
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, herdr-nix }: {
    darwinConfigurations."Yiming-iMac" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./configuration.nix
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # `inputs` is forwarded so `home.nix` can pull herdr-nix
            # (and any future flake input) without each module having to
            # reach through `self`/global state.
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.yimingpeng = import ./home.nix;
        }
      ];
    };
  };
}
