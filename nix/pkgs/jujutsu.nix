{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.43.0";
  system = stdenv.hostPlatform.system;
  systemToBinary = {
    "x86_64-linux" = {
      name = "jj-v${version}-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "59e5588583ac82b623239929368c65b90735931c0f26b5a16c1f04d5bb97643d";
    };
    "aarch64-linux" = {
      name = "jj-v${version}-aarch64-unknown-linux-musl.tar.gz";
      sha256 = "289197b6bec60b4e57d47260624b617716f737eb02cdfd9155791b2576aa5862";
    };
  };

in
stdenv.mkDerivation rec {
  pname = "jj";
  inherit version;

  src = fetchurl {
    url = "https://github.com/jj-vcs/jj/releases/download/v${version}/${systemToBinary.${system}.name}";
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
