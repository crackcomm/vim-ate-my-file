{ pkgs, ... }: {
  console.keyMap = "us";

  environment.systemPackages = with pkgs; [ xkbutils ];

  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };
}
