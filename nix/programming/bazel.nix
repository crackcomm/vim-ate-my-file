{ pkgs, ... }: { home.packages = with pkgs; [ bazel-lsp buildifier ]; }
