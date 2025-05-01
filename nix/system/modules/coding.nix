{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Basic Utilities
    git
    curl
    wget
    unzip
    lbzip2
    xz
    patch
    neovim
    jujutsu

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

    # Interpreters
    nodejs_22
    uv

    # Language servers and tools
    lua-language-server
    stylua
    shfmt
    nixfmt
  ];
}
