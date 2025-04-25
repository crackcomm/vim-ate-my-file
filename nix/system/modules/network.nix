{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ networkmanager ];

  networking = {
    hostName = "nixx";
    firewall.enable = false;
    networkmanager.enable = true;
  };
}
