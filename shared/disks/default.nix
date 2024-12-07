{ config, ... }:
let
  cfg = config.nixfiles.disks;
  eyd = config.nixfiles.eraseYourDarlings;
  tmpfsMountOptions = [
    "defaults"
    "mode=755"
  ] ++ (lib.optional (cfg.rootTmpfsSize != null) "size=${cfg.rootTmpfsSize}");
in
{
  imports = [ ./options.nix ];

  # Only implemented for eyd right now. I don't know what I would even do 
  # for a persistent system, or why I would ever want that again.
  disko.devices = mkIf eyd.enable {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = tmpfsMountOptions;
    };
    disk.main = {
      type = "disk";
      device = cfg.mainDisk.device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            start = "1MiB";
            end = cfg.mainDisk.espSize;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [ "-n BOOT" ];
              mountpoint = "/boot";
              mountOptions = [
                "dmask=077"
                "fmask=177"
              ];
            };
          };
          root = {
            start = cfg.mainDisk.espSize;
            end = "100%";
            content = {
              type = "btrfs";
              subvolumes =
                let
                  mountOptions = [
                    "compress=${cfg.mainDisk.btrfsCompression}"
                    "noatime" # Reduces disk writes
                    "discard=async" # TRIM support
                  ];
                  dataMountOptions = [
                    # No CoW for these directories
                    # We want to avoid write amplification for things like:
                    # * VM disk images
                    # * Databases
                    # * Persistent containers
                    # 
                    "noatime" # Reduces disk writes
                    "discard=async" # TRIM support
                  ];
                in
                {
                  "@persist" = {
                    mountpoint = eyd.persistDir;
                    inherit mountOptions;
                  };
                  "@data" = {
                    # Storage of persistent data that should not be CoW
                    mountpoint = eyd.dataDir;
                    inherit dataMountOptions;
                  };
                  "@var-log" = {
                    mountpoint = "/var/log";
                    inherit mountOptions;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    inherit mountOptions;
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    inherit mountOptions;
                  };
                  "@swap" = mkIf cfg.mainDisk.swap.enable {
                    mountpoint = "/swap";
                    inherit mountOptions;
                    content = {
                      type = "swap";
                      size = cfg.mainDisk.swap.size;
                    }
                  };
                };
              extraArgs = [
                "--label system"
              ];
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  services.zswap = {
    enable = true;
    algorithm = "zstd";
  };
}
