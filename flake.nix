{
  description = "configs for my development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay?rev=403c09094a877e6c4816462d00b1a56ff8198e06";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      rust-overlay,
      ...
    }@inputs:
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

      moduleLib = import ./nix/lib/optional-module.nix { inherit (pkgs) lib; };

      specialArgs = {
        inherit inputs outputs;
        optionalModule = moduleLib.optionalModule;
        defaultModule = moduleLib.defaultModule;
      };
    in
    {
      packages.${system} = {
        bazel_download_proxy = pkgs.bazel_download_proxy;
        default = pkgs.bazel_download_proxy;
      };

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
              home-manager.sharedModules = [ ./local-home.nix ];
            }

            ./nix/system
            ./nix/features
            ./nix/setups/main
            ./local.nix
          ];
        };
      };
    };
}
