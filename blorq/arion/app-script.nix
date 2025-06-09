{ pkgs }:
let
  name = "arion";
  script = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [ pkgs.bash pkgs.arion ];
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      set -x
      cd blorq/arion
      "${pkgs.arion}/bin/arion" "$@"
    '';
  };
in {
  type = "app";
  program = "${script}/bin/${name}";
}
