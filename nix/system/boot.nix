{ ... }: {
  boot = {
    loader = {
      timeout = 5;
      grub = {
        extraConfig = ''
          terminal_input console
          terminal_output console
        '';
        enable = true;
        devices = [ "nodev" ];
        # VM:
        # efiSupport = false;
        # Installer:
        efiSupport = true;
        efiInstallAsRemovable = true;
      };

      efi.canTouchEfiVariables = false;
    };

    kernel.sysctl = { "fs.aio-max-nr" = 1048576; };
  };
}
