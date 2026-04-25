{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ git jujutsu patch gnupg ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
}
