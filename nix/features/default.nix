{ optionalModule, defaultModule, ... }: {
  imports = [
    (defaultModule "bluetooth" ./bluetooth.nix)
    (defaultModule "compression" ./compression.nix)
    (defaultModule "desktop" ./desktop.nix)
    (defaultModule "devenv" ./devenv.nix)
    (defaultModule "fonts" ./fonts.nix)
    (defaultModule "linux-tools" ./linux-tools.nix)
    (defaultModule "nvim" ./nvim.nix)
    (defaultModule "sound" ./sound.nix)
    (defaultModule "sshd" ./sshd.nix)
    (defaultModule "terminal" ./terminal.nix)
    (defaultModule "tools" ./tools.nix)
    (defaultModule "vcs" ./vcs.nix)
    (defaultModule "zsh" ./zsh.nix)
    (optionalModule "docker" ./docker.nix)
    (optionalModule "fuse" ./fuse.nix)
    (optionalModule "media-player" ./media-player.nix)
    (optionalModule "nvidia" ./nvidia.nix)
    (optionalModule "steam" ./steam.nix)
  ];
}
