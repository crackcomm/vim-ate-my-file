{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    delta
    direnv
    eza
    fd
    tree
    fzf
    ripgrep
    grip-grab
    file
    htop
    ncdu # Disk usage analyzer
    jq
    zoxide # smarter cd command
  ];
}
