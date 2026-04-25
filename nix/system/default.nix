{ ... }: {
  imports = [ ./boot.nix ./hardware.nix ./modules ];

  nix.settings.trusted-users = [ "root" "pah" ];

  system.stateVersion = "24.05";

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "unlimited";
    }
  ];
}
