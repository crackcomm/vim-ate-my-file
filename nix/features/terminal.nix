{ pkgs, ... }: {
  environment.variables = {
    TERMINAL = "kitty -1";
    TERM = "xterm-kitty";
  };

  environment.systemPackages = with pkgs; [
    tmux
    kitty
    xterm # fallback
  ];
}
