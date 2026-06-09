{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Desktop packages
    awesome
    vlc
  ];

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.awesome.enable = true;
  };
}
