{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    unzip
    lbzip2
    xz
    patch
    jujutsu
  ];
}
