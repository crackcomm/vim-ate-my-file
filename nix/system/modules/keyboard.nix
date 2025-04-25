{ pkgs, ... }: {
  console.keyMap = "us";

  environment.systemPackages = with pkgs; [ xorg.xkbutils ];

  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };
}
