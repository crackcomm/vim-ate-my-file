{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Development Libraries
    openssl
    zlib
    libffi
  ];
}
