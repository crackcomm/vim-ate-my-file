{
  pkgs,
  config,
  lib,
  ...
}:
{
  environment.systemPackages = [
    pkgs.docker
    pkgs.gvisor
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
      runtimes = {
        runsc = {
          path = "${pkgs.gvisor}/bin/runsc";
        };
      };
    };
  };

  virtualisation.containerd = {
    enable = true;
  };

  environment.sessionVariables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };

  systemd.services."user@".serviceConfig = {
    Delegate = "cpu cpuset io memory pids";
  };

  systemd.user.extraConfig = "DefaultLimitNPROC=infinity";
  systemd.services.docker.serviceConfig.LimitNPROC = "infinity";

  systemd.user.services.docker.serviceConfig.ExecStart = lib.mkForce [
    "" # Clear the default ExecStart
    "${config.virtualisation.docker.package}/bin/dockerd-rootless --config-file=${
      pkgs.writeText "docker-daemon.json" (
        builtins.toJSON {
          runtimes = {
            runsc = {
              path = "${pkgs.gvisor}/bin/runsc";
              runtimeArgs = [
                "--network=host"
                "--ignore-cgroups" # Essential: Stops gVisor from trying to touch systemd/cgroups
              ];
            };
          };
        }
      )
    }"
  ];
}
