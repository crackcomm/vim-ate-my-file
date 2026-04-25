{ pkgs, ... }: {
  home.packages = [
    pkgs.nodejs_22 # Node.js for Github Copilot
  ];
}
