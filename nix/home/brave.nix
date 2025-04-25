{ pkgs, ... }:
let
  brave = pkgs.brave.overrideAttrs
    (oldAttrs: { commandLineArgs = [ "--ozone-platform-hint=auto" ]; });
in {
  programs.brave = {
    enable = true;
    package = brave;
    extensions = [
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
    ];

  };
}
