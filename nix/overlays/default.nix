{ ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    rustToolchain = prev.rust-bin.nightly."2025-04-03".default.override {
      targets = [ "x86_64-unknown-linux-gnu" ];
    };
  };
}
