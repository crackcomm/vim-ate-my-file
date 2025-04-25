{ outputs, inputs, ... }: {
  nixpkgs.config.allowUnfree = true;

  nixpkgs = {
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
    ./fonts.nix
    ./keyboard.nix
    ./linux.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    # ./python.nix
    ./shell.nix
    ./sound.nix
    ./time.nix
    ./users.nix
  ];
}
