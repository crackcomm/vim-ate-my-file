{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  environment.shells = [ pkgs.zsh ];
  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    zsh
    zsh-command-time
    zsh-nix-shell
    zsh-vi-mode
    zsh-bd
    zsh-abbr
    zsh-autocomplete
  ];

  programs.zsh.enable = true;
}
