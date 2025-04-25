{ pkgs, ... }: {
  security.rtkit.enable = true; # Realtime scheduling for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # If you need 32-bit ALSA compatibility
    pulse.enable = true; # Enable PulseAudio compatibility layer
    # jack.enable = true;    # Enable JACK compatibility layer if needed
  };
}
