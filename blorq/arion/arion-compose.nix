{ pkgs, ... }:

let
  searxngConfig = ''
    use_default_settings: true
    server:
      secret_key: "123"
    search:
      formats:
        - html
        - json
  '';

  searxngConfigFile = pkgs.writeTextFile {
    name = "searxng-config.yml";
    text = searxngConfig;
  };

  trafilaturaImage = let
    python3 = pkgs.python3.withPackages (ps: [ ps.trafilatura ps.gunicorn ]);
  in pkgs.dockerTools.buildImage {
    name = "trafilatura-api";
    tag = "v0.0.4";
    copyToRoot = pkgs.buildEnv {
      name = "trafilatura-env";
      paths = [ python3 ];
    };
    config = {
      Cmd = [
        "gunicorn"
        "--workers"
        "4"
        "--bind"
        "0.0.0.0:5000"
        "trafilatura.api_server:app"
      ];
      ExposedPorts = { "5000/tcp" = { }; };
    };
  };

  # TODO(crackcomm): the /nix/store contains the secrets.json file, fix this
  tensorzeroConfigFile = pkgs.runCommand "tensorzero-config.toml" {
    nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.toml ])) ];
    src = ../tensorzero/generate-config.py;
    secretsFile = ../tensorzero/secrets.json;
  } ''
    cp $secretsFile secrets.json
    python3 $src
    mv tensorzero-config.toml $out
  '';

  tensorzeroSecretsEnv = import ../tensorzero/secrets.nix { lib = pkgs.lib; };

  dataDir = "/home/pah/.blorq";

in {
  project.name = "dev-services";

  services = {
    meilisearch = {
      service.image = "getmeili/meilisearch:v1.14.0";
      service.container_name = "dev-meilisearch";
      service.ports = [ "7700:7700" ];
      service.environment = {
        MEILI_MASTER_KEY = "YOUR_DEVELOPMENT_MASTER_KEY";
      };
      service.volumes = [ "${dataDir}/meilisearch:/meili_data" ];
      service.healthcheck = {
        test = [
          "CMD"
          "wget"
          "--no-verbose"
          "--spider"
          "http://localhost:7700/health"
        ];
        interval = "5s";
        timeout = "2s";
        retries = 10;
      };
      service.restart = "unless-stopped";
    };

    searxng = {
      service.image = "searxng/searxng:latest";
      service.container_name = "dev-searxng";
      service.ports = [ "7701:8080" ];
      service.volumes = [ "${searxngConfigFile}:/etc/searxng/settings.yml:ro" ];
    };

    trafilatura = {
      build.image = pkgs.lib.mkForce trafilaturaImage;
      service.container_name = "dev-trafilatura";
      service.ports = [ "7702:5000" ];
      service.restart = "unless-stopped";
    };

    tensorzero-clickhouse = {
      service.image = "clickhouse/clickhouse-server:24.12-alpine";
      service.container_name = "dev-tensorzero-clickhouse";
      service.ports = [ "8123:8123" ];
      service.environment = {
        CLICKHOUSE_USER = "tzuser";
        CLICKHOUSE_PASSWORD = "tzpassword";
        CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT = "1";
      };
      service.volumes = [ "${dataDir}/tz-clickhouse:/var/lib/clickhouse" ];
      service.restart = "unless-stopped";
      service.healthcheck = {
        test = [
          "CMD"
          "wget"
          "--no-verbose"
          "--spider"
          "http://tensorzero-clickhouse:8123/ping"
        ];
        interval = "5s";
        timeout = "2s";
        retries = 10;
      };
    };

    tensorzero-ui = {
      service.image = "tensorzero/ui:latest";
      service.container_name = "dev-tensorzero-ui";
      service.ports = [ "7705:4000" ];
      service.environment = {
        TENSORZERO_GATEWAY_URL = "http://tensorzero:3000";
        TENSORZERO_CLICKHOUSE_URL =
          "http://tzuser:tzpassword@tensorzero-clickhouse:8123/tensorzero";
      } // tensorzeroSecretsEnv;
      service.volumes =
        [ "${tensorzeroConfigFile}:/app/config/tensorzero.toml:ro" ];
      service.depends_on = {
        tensorzero-clickhouse = { condition = "service_healthy"; };
        tensorzero = { condition = "service_healthy"; };
      };
      service.restart = "unless-stopped";
      service.healthcheck = {
        test = [
          "CMD"
          "wget"
          "--no-verbose"
          "--spider"
          "http://tensorzero-ui:4000/health"
        ];
        interval = "5s";
        timeout = "2s";
        retries = 10;
      };
    };

    tensorzero = {
      service.image = "tensorzero/gateway:latest";
      service.container_name = "dev-tensorzero";
      service.ports = [ "7703:3000" ];
      service.command = [ "--config-file" "/app/config/tensorzero.toml" ];
      service.environment = {
        TENSORZERO_CLICKHOUSE_URL =
          "http://tzuser:tzpassword@tensorzero-clickhouse:8123/tensorzero";
      } // tensorzeroSecretsEnv;
      service.volumes =
        [ "${tensorzeroConfigFile}:/app/config/tensorzero.toml:ro" ];
      service.depends_on = {
        tensorzero-clickhouse = { condition = "service_healthy"; };
      };
      service.restart = "unless-stopped";
      service.healthcheck = {
        test = [
          "CMD"
          "wget"
          "--no-verbose"
          "--spider"
          "http://tensorzero:3000/health"
        ];
        interval = "5s";
        timeout = "2s";
        retries = 10;
      };
    };
  };
}
