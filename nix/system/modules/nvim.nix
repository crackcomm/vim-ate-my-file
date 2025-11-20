{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (neovim.override { withNodeJs = true; })
    luajitPackages.luarocks
  ];
}
