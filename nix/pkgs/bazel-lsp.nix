{ stdenv, fetchurl, system, autoPatchelfHook, glibc }:
let
  systemToBinary = {
    "x86_64-linux" = {
      name = "bazel-lsp-0.6.4-linux-amd64";
      sha256 = "16m5lbd7fk0k4pp8si8q8bfhy8c3h4br1ymafwp6660017xzzak2";
    };
    "aarch64-linux" = {
      name = "bazel-lsp-0.6.4-linux-arm64";
      sha256 = "1sr64j77wlkl3a5wx39rnf05bw65mixximjyhyb9yp1i0sqf0465";
    };
  };

in stdenv.mkDerivation rec {
  pname = "bazel-lsp";
  version = "0.6.4";

  src = fetchurl {
    url =
      "https://github.com/cameron-martin/bazel-lsp/releases/download/v${version}/${
        systemToBinary.${system}.name
      }";
    sha256 = systemToBinary.${system}.sha256;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/bazel-lsp
    chmod +x $out/bin/bazel-lsp
  '';
}
