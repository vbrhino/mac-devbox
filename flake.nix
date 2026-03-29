{
  description = "Shared dev environment — macOS Apple Silicon + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "terraform"   # BSL 1.1 — required for IaC workflows
        ];
      };
    in
    {
      homeConfigurations = {

        # ── Default profile — used by install.sh ────────────────────────
        # Each colleague can add their own block or just use "default".
        "default" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = { };
        };

      };
    };
}
