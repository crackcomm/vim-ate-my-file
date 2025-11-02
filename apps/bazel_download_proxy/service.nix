{ pkgs, ... }: {
  home.packages = [ pkgs.bazel_download_proxy ];

  systemd.user.services.bazel_download_proxy = {
    Unit = {
      Description = "Bazel Download Proxy Server";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${pkgs.bazel_download_proxy}/bin/bazel_download_proxy";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "default.target" ]; };
  };
}
