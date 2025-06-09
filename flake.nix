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

  outputs = { self, nixpkgs, home-manager, rust-overlay, ... }@inputs:
    let
      inherit (self) outputs;

      system = "x86_64-linux";
      overlays = import ./nix/overlays { inherit inputs; };
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
      arionAppScript = import ./blorq/arion/app-script.nix { inherit pkgs; };
    in {
      apps.${system}.arion = arionAppScript;
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
