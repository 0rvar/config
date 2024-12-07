{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  promcfg = config.services.prometheus;
  nodeExporter = promcfg.enable && config.services.prometheus.exporters.node.enable;
in
{
  #############################################################################
  ## Dashboards & Alerting
  #############################################################################

  services.grafana = {
    enable = promcfg.enable;
    settings.server.http_port = 47652;
    settings."auth.anonymous".enabled = true;
    provision.enable = true;
    provision.datasources.settings.datasources = mkIf promcfg.enable [
      {
        name = "prometheus";
        url = "http://localhost:${toString promcfg.port}";
        type = "prometheus";
      }
    ];
    provision.dashboards.settings.providers =
      let
        nodeExporterDashboard = {
          name = "Node Stats (Detailed)";
          folder = "Common";
          options.path = ./dashboards/node-stats-detailed.json;
        };
      in
      (if nodeExporter then [ nodeExporterDashboard ] else [ ]);
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    globalConfig.scrape_interval = "15s";
    scrapeConfigs =
      let
        nodeExporterScraper = {
          job_name = "${config.networking.hostName}-node";
          static_configs = [ { targets = [ "localhost:${toString promcfg.exporters.node.port}" ]; } ];
        };
      in
      (if nodeExporter then [ nodeExporterScraper ] else [ ]);
    alertmanagers = mkIf promcfg.alertmanager.enable [
      {
        static_configs = [ { targets = [ "localhost:${toString promcfg.alertmanager.port}" ]; } ];
      }
    ];
  };

  services.prometheus.alertmanager = {
    enable = promcfg.enable;
    port = 9093;
    configuration = {
      route = {
        group_by = [ "alertname" ];
        repeat_interval = "6h";
        receiver = "aws-sns";
      };
      receivers = [
        {
          name = "aws-sns";
          sns_configs = [
            {
              sigv4 = {
                region = "eu-west-1";
              };
              topic_arn = "arn:aws:sns:eu-west-1:197544591260:host-notifications";
              subject = "Alert: ${config.networking.hostName}";
            }
          ];
        }
      ];
    };
  };

  services.prometheus.rules = [
    ''
      groups:
      - name: disk
        rules:
        - alert: DiskSpaceLow
          expr: node_filesystem_avail_bytes{fstype!~"(ramfs|tmpfs)"} / node_filesystem_size_bytes < 0.1
      - name: zfs
        rules:
        - alert: ZPoolStatusDegraded
          expr: node_zfs_zpool_state{state!="online"} > 0
    ''
  ];

  # Host metrics
  services.prometheus.exporters.node = {
    enable = promcfg.enable;
    enabledCollectors = [
      "processes"
      "systemd"
    ];
  };

  # if a disk is mounted at /home, then the default value of
  # `"true"` reports incorrect filesystem metrics
  systemd.services.prometheus-node-exporter.serviceConfig.ProtectHome = mkForce "read-only";
}
