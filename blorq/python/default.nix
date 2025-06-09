self: super: {
  python3 = super.python3.override {
    packageOverrides = pself: psuper: {
      modal = (import ./modal.nix) { inherit pself; };
      synchronicity = (import ./synchronicity.nix) { inherit pself; };
      trafilatura = (import ./trafilatura.nix) {
        inherit pself;
        pkgs = self;
      };
      types-certifi = (import ./types-certifi.nix) { inherit pself; };
    };
  };
}
