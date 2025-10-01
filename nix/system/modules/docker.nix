{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.docker pkgs.gvisor ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.containerd = { enable = true; };

  environment.sessionVariables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };

  systemd.services."user@".serviceConfig = {
    Delegate = "cpu cpuset io memory pids";
  };

  systemd.user.extraConfig = "DefaultLimitNPROC=infinity";
  systemd.services.docker.serviceConfig.LimitNPROC = "infinity";
}
