{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "bazel_download_proxy";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.go ];

  buildPhase = ''
    export GOCACHE=$TMPDIR/go-cache
    mkdir -p $GOCACHE
    go build -o $out/bin/bazel_download_proxy main.go
  '';
}
