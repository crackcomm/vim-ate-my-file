{ pkgs, ... }:
{
  console.keyMap = "us";

  environment.systemPackages = with pkgs; [ xkbutils ];

  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };

  # Mouse -> Keyboard remapping
  services.input-remapper.enable = true;
  services.input-remapper.enableUdevRules = true;
}
