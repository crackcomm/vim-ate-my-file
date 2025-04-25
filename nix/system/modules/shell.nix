{ pkgs, ... }: {
  users.defaultUserShell = pkgs.zsh;

  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [ "/share/zsh" ];

  environment.variables = {
    EDITOR = "nvim";
    TERMINAL = "kitty -1";
    TERM = "xterm-kitty";
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [ "${XDG_BIN_HOME}" "$HOME/.cargo/bin" ];
  };

  environment.systemPackages = with pkgs; [
    kitty
    xterm # fallback
    zsh
    zsh-syntax-highlighting
    tmux
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
    gnupg
    ncdu # Disk usage analyzer
    jq
  ];

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
}
