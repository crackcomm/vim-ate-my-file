{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      bluez # Provides bluetoothctl command-line utility
    ];

  hardware.bluetooth = {
    enable = true; # Required to enable the Bluetooth stack
    powerOnBoot = true; # Optional: Power on Bluetooth adapter on boot
    # Some systems might need firmware, usually handled by nixos-hardware or linux-firmware
    # If you have issues, check dmesg for firmware errors after enabling bluetooth.
    # enableA2dp = true; # This is often default/handled by PipeWire/PulseAudio now
  };
}
