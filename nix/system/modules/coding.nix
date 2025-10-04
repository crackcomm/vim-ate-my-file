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
    luajitPackages.luarocks
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

    # Node.js for Github Copilot
    nodejs_22

    # Development Tools
    devenv

    # Language servers and tools
    ruff
    lua-language-server
    stylua
    shfmt
    nixfmt-classic
    keep-sorted
    pyright
  ];
}
