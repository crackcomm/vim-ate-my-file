pkgs: {
  aistudio-server = pkgs.callPackage ../../blorq/aistudio { };
  lsproxy = (import ./lsproxy.nix { inherit pkgs; });
  bazel-lsp = pkgs.callPackage ./bazel-lsp.nix { };
}
