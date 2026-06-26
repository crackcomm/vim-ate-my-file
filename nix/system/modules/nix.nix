{ ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
    settings.auto-optimise-store = true;
    settings.download-attempts = 1;
    settings.connect-timeout = 5;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
  };
}
