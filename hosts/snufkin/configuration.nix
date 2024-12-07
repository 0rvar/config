# This is the home server to rule home servers.
# NUC with Core Ultra 7 with 22 threads, 64GB DDR5 RAM, 2TB NVMe.
{
  config,
  pkgs,
  lib,
  ...
}:

# Bring names from 'lib' into scope.
with lib;
{
  # More to shared/disks ?
  boot.supportedFilesystems = {
    btrfs = true;
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;

  # Enable memtest
  boot.loader.systemd-boot.memtest86.enable = true;

  nixfiles.eraseYourDarlings.enable = true;
  nixfiles.eraseYourDarlings.machineId = "2961e7896d4d53f7bd5d0ba438074371";
  nixfiles.eraseYourDarlings.orvarPasswordFile = config.sops.secrets."users/orvar".path;
  sops.secrets."users/orvar".neededForUsers = true;

  virtualisation.libvirtd.enable = true;

  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:8428";
    retentionPeriod = 1200;
  };
}
