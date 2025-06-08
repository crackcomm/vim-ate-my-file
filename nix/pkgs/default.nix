pkgs: {
  lsproxy = (import ./lsproxy.nix { inherit pkgs; });
  bazel-lsp = pkgs.callPackage ./bazel-lsp.nix { };
}
