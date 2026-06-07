{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.python3.withPackages (ps: [ ]))
    pkgs.tokn
  ];
}
