{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    curl
    wget
    inetutils
    networkmanager
  ];

  networking = {
    hostName = "nixx";
    firewall.enable = false;
    networkmanager.enable = true;
  };
}
