{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.42.0";
  system = stdenv.hostPlatform.system;
  systemToBinary = {
    "x86_64-linux" = {
      name = "jj-v${version}-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "2d91e81d649e617a81608e7401ad1106029c15ece01ac928c4a351abef42be6a";
    };
    "aarch64-linux" = {
      name = "jj-v${version}-aarch64-unknown-linux-musl.tar.gz";
      sha256 = "bc962ac57ec264541a62ed8492f080898380a277222b115e1ed96163196e6fc8";
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
