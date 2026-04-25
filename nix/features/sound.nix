{ pkgs, ... }: {
  security.rtkit.enable = true; # realtime scheduling for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # enable pulseaudio compatibility layer
    wireplumber.enable = true;
  };

  hardware.alsa.enablePersistence = true;
  environment.systemPackages = with pkgs; [ wireplumber pulseaudio ];
}
