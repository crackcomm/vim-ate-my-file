{
  additions = final: _prev: {
    bazel_download_proxy =
      final.callPackage ../../apps/bazel_download_proxy { };
    lsproxy = (import ./lsproxy.nix { pkgs = final.pkgs; });
    bazel-lsp = final.callPackage ./bazel-lsp.nix { };
    jujutsu = final.callPackage ./jujutsu.nix { };
  };
  modifications = final: prev: { };
}
