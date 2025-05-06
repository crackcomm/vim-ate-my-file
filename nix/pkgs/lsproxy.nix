{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "lsproxy";
  version = "0.4.1";

  src = pkgs.fetchFromGitHub {
    owner = "agentic-labs";
    repo = "lsproxy";
    rev = "cb757d39b17fc182e5c199b7ec43c28b5cf55b40";
    sha256 = "sha256-OgyyCqddcuMUGWkvkK1H9A8TqElQPvKptJIuo8w7wGM=";
  };

  cargoHash = pkgs.lib.fakeHash;
  cargoLock = { lockFile = "${src}/lsproxy/Cargo.lock"; };

  buildAndTestSubdir = "lsproxy";

  buildInputs = [ pkgs.openssl.dev ];
  nativeBuildInputs = [ pkgs.pkg-config pkgs.openssl ];

  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  postPatch = ''
    ln -s lsproxy/Cargo.lock Cargo.lock
  '';

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Multi-language code navigation API in a container";
    homepage = "https://github.com/agentic-labs/lsproxy";
    license = licenses.mit;
  };
}
