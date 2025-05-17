{ ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.opengl.enable = true;
}
