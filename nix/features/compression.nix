{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unzip
    lbzip2
    xz
  ];
}
