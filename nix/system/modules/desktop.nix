{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      # Desktop packages
      awesome
      vlc
      # brave
      xdg-utils
    ];

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.awesome.enable = true;
  };
}
