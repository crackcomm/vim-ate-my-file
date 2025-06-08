{
  description = "configs for my development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs.lib) nixosSystem;
      specialArgs = { inherit inputs outputs; };
    in {
      overlays = import ./nix/overlays { inherit inputs; };

      nixosConfigurations = {
        nixos-vm = nixosSystem {
          specialArgs = specialArgs;

          modules = [
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
