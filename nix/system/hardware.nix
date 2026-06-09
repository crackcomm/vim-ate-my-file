{ lib, ... }:
{
  imports = [ ../../hardware-configuration.nix ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
