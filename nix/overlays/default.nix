{
  additions = final: prev: (import ../pkgs { inherit (final) callPackage; });
  modifications = final: prev: {
    rustToolchain = prev.rust-bin.nightly."2026-04-24".default.override {
      targets = [ "x86_64-unknown-linux-gnu" ];
    };
  };
}
