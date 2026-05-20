{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.nodejs
  ];

  programs.npm = {
    enable = true;
    settings = {
      prefix = "${config.home.homeDirectory}/.npm-global";
      registry = "https://registry.npmjs.org/";
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];
}
