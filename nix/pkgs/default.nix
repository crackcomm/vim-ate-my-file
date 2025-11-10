pkgs: {
  bazel_download_proxy = pkgs.callPackage ../../apps/bazel_download_proxy { };
  lsproxy = (import ./lsproxy.nix { inherit pkgs; });
  bazel-lsp = pkgs.callPackage ./bazel-lsp.nix { };
}
