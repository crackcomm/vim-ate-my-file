{ optionalModule, ... }:
{
  imports = [
    (optionalModule "bazel" ./bazel.nix)
    (optionalModule "common-libs" ./common-libs.nix)
    (optionalModule "common-tools" ./common-tools.nix)
    (optionalModule "cpp" ./cpp.nix)
    (optionalModule "lua" ./lua.nix)
    (optionalModule "nodejs" ./nodejs.nix)
    (optionalModule "python" ./python.nix)
    (optionalModule "rust" ./rust.nix)
  ];
}
