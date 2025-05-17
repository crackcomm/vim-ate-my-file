{ outputs, inputs, ... }: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.rust-overlay.overlays.default
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
  };

  imports = [
    ./bluetooth.nix
    ./coding.nix
    ./desktop.nix
    ./devenv.nix
    ./fonts.nix
    ./keyboard.nix
    ./linux.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    # ./python.nix
    ./nvidia.nix
    ./shell.nix
    ./sound.nix
    ./time.nix
    ./users.nix
  ];
}
