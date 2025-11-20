{ pkgs, ... }: {
  home.packages = with pkgs; [ pavucontrol ];

  # TODO: already enabled system-wide, disable?
  xsession.windowManager.awesome.enable = true;

  # home.file.".config/awesome" = {
  #   source = ../../configs/awesome;
  #   recursive = true;
  # };
}
