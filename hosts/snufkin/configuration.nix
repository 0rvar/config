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
  nixfiles.sops.enable = true;
  nixfiles.disks.mainDisk.device = "/dev/nvme0n1";
  nixfiles.disks.mainDisk.swap.size = "16G";

  virtualisation.libvirtd.enable = true;
  nixfiles.netdata.enable = true;

  # services.victoriametrics = {
  #   enable = true;
  #   listenAddress = "127.0.0.1:8428";
  #   retentionPeriod = 1200;
  # };
}
