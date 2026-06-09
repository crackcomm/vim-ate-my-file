{ pkgs, ... }:
{
  home.packages = with pkgs; [ rustToolchain ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
