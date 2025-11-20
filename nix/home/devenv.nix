{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Build Tools
    m4
    gnumake
    cmake

    # Development Libraries
    openssl
    zlib
    libffi

    # Compilers
    gcc13
    # # gfortran13
    # go_1_24
    # llvmPackages_19.clang
    # llvmPackages_19.lld
    # llvmPackages_19.clang-tools
    # # llvmPackages_19.llvm
    rustToolchain

    # Node.js for Github Copilot
    nodejs_22

    # --- Language servers and tools ---
    # -- Common --
    keep-sorted
    # -- Shell --
    shfmt
    # -- Lua --
    stylua
    lua-language-server
    # -- Python --
    uv
    ruff
    pyright
    # -- Nix --
    nixd
    nixfmt-classic
    # -- Bazel --
    bazel-lsp
  ];
}
