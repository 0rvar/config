{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  dataDir = config.nixfiles.impermanence.dataDir;
  configure_prom = builtins.toFile "prometheus.yml" ''
    scrape_configs:
    - job_name: 'local_node'
      stream_parse: true
      static_configs:
      - targets:
        - 127.0.0.1:9100
  '';
in
{
  environment.systemPackages = with pkgs; [
    lm_sensors
    dmidecode
    acpi
  ];
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "cpu"
      "filesystem"
      "loadavg"
      "meminfo"
      "netdev"
      "diskstats"
      "hwmon" # For temperature sensors
      "thermal_zone" # Additional temperature data
    ];
    port = 9100;
  };
  # systemd.services.export-to-vm = {
  #   path = with pkgs; [ victoriametrics ];
  #   enable = true;
  #   after = [ "network-online.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   script = "vmagent -promscrape.config=${configure_prom} -remoteWrite.url=http://127.0.0.1:8428/api/v1/write";
  # };

  # VictoriaMetrics to store our metrics
  services.victoriametrics = {
    enable = true;
    retentionPeriod = "1y";
    extraOptions = [
      "-search.maxUniqueTimeseries=3000000"
      "-search.maxQueryDuration=1m"
    ];
    prometheusConfig = {
      scrape_configs = [
        {
          job_name = "node-exporter";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:9100" ];
              labels.type = "node";
            }
          ];
        }
      ];
    };
  };

  services.grafana = {
    enable = true;
    dataDir = "${dataDir}/grafana";
    settings = {
      server = {
        http_port = 3000;
        http_addr = "0.0.0.0";
      };
      security = {
        # You'll want to change this
        admin_password = "xxx";
      };
    };
    provision = {
      # Auto-configure the VictoriaMetrics datasource
      datasources.settings.datasources = [
        {
          name = "VictoriaMetrics";
          type = "prometheus"; # VM is Prometheus-compatible
          url = "http://localhost:8428";
          access = "proxy";
          isDefault = true;
        }
      ];
      dashboards.settings = {
        providers = [
          {
            name = "Default";
            options.path = ./dashboards;
            allowUiUpdates = true; # Allow saving dashboard changes from UI
          }
        ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 3000 ];

  # Make sure our data persists
  environment.persistence.${dataDir}.directories = [
    {
      directory = "/var/lib/private/victoriametrics";
    }
  ];
}
