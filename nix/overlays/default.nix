{ ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    rustToolchain = prev.rust-bin.nightly."2024-11-28".default.override {
      targets = [ "x86_64-unknown-linux-gnu" ];
    };

    bazelisk = prev.bazelisk.overrideAttrs
      (oldAttrs: { postFixup = "ln -s $out/bin/bazelisk $out/bin/bazel"; });
  };
}
