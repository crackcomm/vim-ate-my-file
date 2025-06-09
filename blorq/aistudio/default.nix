{ pkgs }:
pkgs.buildGoModule {
  pname = "aistudio-server";
  version = "0.1.0";
  src = ./server;
  vendorHash = "sha256-0Qxw+MUYVgzgWB8vi3HBYtVXSq/btfh4ZfV/m1chNrA=";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 $GOPATH/bin/server $out/bin/aistudio-server

    runHook postInstall
  '';
}
