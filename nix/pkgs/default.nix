{ callPackage }: {
  bazel-lsp = callPackage ./bazel-lsp.nix { };
  bazel_download_proxy = callPackage ../../apps/bazel_download_proxy { };
  jujutsu = callPackage ./jujutsu.nix { };
  tokn = callPackage ./tokn.nix { };
}
