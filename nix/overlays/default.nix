let myPkgs = import ../pkgs;
in {
  additions = myPkgs.additions;
  modifications = final: prev:
    {
      rustToolchain = prev.rust-bin.nightly."2025-08-29".default.override {
        targets = [ "x86_64-unknown-linux-gnu" ];
      };
    } // myPkgs.modifications final prev;
}
