{ ... }: {
  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "nodev" ];
      # VM:
      # efiSupport = false;
      # Installer:
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    loader.efi.canTouchEfiVariables = false;

    kernel.sysctl = { "fs.aio-max-nr" = 1048576; };
  };
}
