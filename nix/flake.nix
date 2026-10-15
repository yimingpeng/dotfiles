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
    # prebuilt release binary as a Nix derivation. Only its source is used
    # (`flake = false`): `home.nix` calls its package.nix with our own pkgs
    # (see the `herdr` let-binding there), so its nixos-unstable nixpkgs,
    # flake-utils and Cachix substituter aren't needed. Upstream's
    # `update-herdr` bot bumps stable releases; pick them up with
    # `nix flake update herdr-nix`.
    herdr-nix = {
      url = "github:herdrdev/herdr-nix";
      flake = false;
    };
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
