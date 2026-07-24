{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.python314.withPackages (ps: [ ]))
    pkgs.tokn
  ];
}
