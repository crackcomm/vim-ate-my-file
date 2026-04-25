{ config, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.graphics.enable = true;
  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.legacy_580;
}
