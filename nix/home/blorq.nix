{ pkgs, ... }: {
  home.packages = [ pkgs.aistudio-server ];

  systemd.user.services.aistudio-server = {
    Unit = {
      Description = "Aistudio WebSocket server";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${pkgs.aistudio-server}/bin/aistudio-server";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "default.target" ]; };
  };
}
