{ pkgs, ... }: {
  home.packages = with pkgs; [
    blueman # Provides blueman-applet and blueman-manager (GUI)
    networkmanagerapplet # Tray icon for NetworkManager
    pavucontrol # volume control
  ];

  # TODO: already enabled system-wide, disable?
  xsession.windowManager.awesome.enable = true;

  # home.file.".config/awesome" = {
  #   source = ../../configs/awesome;
  #   recursive = true;
  # };
}
