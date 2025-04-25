{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    lsof
    bind
    gparted
    dmidecode
    pciutils
    usbutils
    unixtools.xxd
    iprange
    ps_mem
    bc # calculator
  ];

  services.openssh = {
    enable = true;
    # WARNING:
    # TODO: change it soon
    settings = { PasswordAuthentication = true; };
  };
}
