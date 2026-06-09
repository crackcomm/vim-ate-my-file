{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.fuse
    pkgs.fuse.dev
  ];

  programs.fuse.userAllowOther = true;
}
