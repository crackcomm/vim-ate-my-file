{ pkgs, ... }:
let
  brave = pkgs.brave.overrideAttrs (oldAttrs: {
    commandLineArgs =
      [ "--ozone-platform-hint=auto" "--silent-debugger-extension-api" ];
  });
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
