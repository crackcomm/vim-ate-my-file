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
}
