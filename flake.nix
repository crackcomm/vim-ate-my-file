{
  description = "configs for my development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url =
        "github:crackcomm/rust-overlay?rev=2ced420b3bdf54601c08037ca05fbd54a9c6ff0c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, rust-overlay, ... }@inputs:
    let
      inherit (self) outputs;

      system = "x86_64-linux";
      overlays = import ./nix/overlays;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          rust-overlay.overlays.default
          overlays.additions
          overlays.modifications
        ];
      };

      specialArgs = { inherit inputs outputs; };
    in {
      nixosConfigurations = {
        nixos-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs;

          modules = [
            { nixpkgs.pkgs = pkgs; }

            home-manager.nixosModules.home-manager

            {
              home-manager.users.pah = ./nix/home;
              home-manager.extraSpecialArgs = specialArgs;
            }

            ./nix/system
          ];
        };
      };
    };
}
