{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # -- Common --
    keep-sorted
    # -- Shell --
    shfmt
    # -- Nix --
    nixd
    nixfmt
  ];
}
