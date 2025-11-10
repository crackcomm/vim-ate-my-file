{ stdenv, fetchurl, system, autoPatchelfHook }:

let
  systemToBinary = {
    "x86_64-linux" = {
      name = "jj-v0.35.0-x86_64-unknown-linux-musl.tar.gz";
      sha256 =
        "9967a240e3294a0bce4444c55d40a35b70af44c69b558689aced95e4e497cef2";
    };
    "aarch64-linux" = {
      name = "jj-v0.35.0-aarch64-unknown-linux-musl.tar.gz";
      sha256 =
        "b42a8a102f60bf5e39d827a9a9faa92c763ca7c1a9cd7fd8782395bdedbecb76";
    };
  };

in stdenv.mkDerivation rec {
  pname = "jj";
  version = "0.35.0";

  src = fetchurl {
    url = "https://github.com/jj-vcs/jj/releases/download/v${version}/${
        systemToBinary.${system}.name
      }";
    sha256 = systemToBinary.${system}.sha256;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ":"; # skip automatic unpacking

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf ${src} -C $out/bin
    chmod +x $out/bin/jj
  '';
}
