{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    zoxide
    zsh-command-time
    zsh-nix-shell
    zsh-vi-mode
    zsh-bd
    zsh-abbr
    zsh-autocomplete
  ];
}
