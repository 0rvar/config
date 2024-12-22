# This is the home server to rule home servers.
# NUC with Core Ultra 7 with 22 threads, 64GB DDR5 RAM, 2TB NVMe.
{
  config,
  pkgs,
  lib,
  ...
}:

let
  persistDir = config.nixfiles.impermanence.persistDir;
in
with lib;
{
  config = mkIf config.nixfiles.netdata.enable {
    # For fan speed monitoring
    environment.systemPackages = [ pkgs.lm_sensors ];
    boot.kernelModules = [ "coretemp" ];
    # Netdata port
    networking.firewall.allowedTCPPorts = [ 19999 ];
    # Netdata configuration
    services.netdata = {
      enable = true;
      config = {
        global = {
          "memory mode" = "dbengine"; # Change from "ram" to "dbengine"
          "page cache size" = 32; # Size in MiB
          "dbengine disk space" = 2048; # Size in MiB
          "dbengine multihost disk space" = 256; # Size in MiB
          "history" = 720; # Number of hours of history to maintain (30 days = 720 hours)
          "debug log" = "none";
          "access log" = "none";
          "error log" = "syslog";
        };
      };
    };
    # Use new cloud ui
    services.netdata.package = pkgs.netdata.override {
      withCloudUi = true;
    };
    # Persist netdata database
    environment.persistence.${persistDir} = {
      directories = [
        {
          directory = "/var/lib/netdata";
          user = "netdata";
          mode = "750";
        }
      ];
    };
  };

  options.nixfiles.netdata = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable netdata monitoring.
      '';
    };
  };
}
