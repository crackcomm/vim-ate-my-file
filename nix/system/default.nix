{ ... }: {
  imports = [
    ./modules/boot.nix
    ./modules/common.nix
    ./hardware.nix
    ../../hardware-configuration.nix
  ];

  nix.settings.trusted-users = [ "root" "pah" ];

  system.stateVersion = "24.05";

  services.xserver.xrandrHeads = [
    {
      output = "DP-0";
      monitorConfig = ''
        Option "PreferredMode" "1920x1200" # Corresponds to --mode
        Option "Position" "0 0"           # Corresponds to --pos 0x0
        Option "Rotate" "normal"          # Corresponds to --rotate normal
      '';
    }
    {
      output = "DP-4";
      primary = true; # Corresponds to --primary
      monitorConfig = ''
        Option "PreferredMode" "1920x1200"
        Option "Position" "1920 0"        # Corresponds to --pos 1920x0
        Option "Rotate" "normal"
      '';
    }
    {
      output = "DP-2";
      monitorConfig = ''
        Option "PreferredMode" "1920x1200"
        Option "Position" "3840 -530"     # Corresponds to --pos 3840x-530
        Option "Rotate" "left"            # Corresponds to --rotate left
      '';
    }
    {
      output = "HDMI-0";
      monitorConfig = ''
        Option "PreferredMode" "1920x1080"
        Option "Position" "3840 -1610"    # Corresponds to --pos 3840x-1730
        Option "Rotate" "normal"
      '';
    }
  ];
}
