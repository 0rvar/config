{ config, lib, ... }:
let
  cfg = config.nixfiles.disks;
  eyd = config.nixfiles.eraseYourDarlings;
  tmpfsMountOptions = [
    "defaults"
    "mode=755"
  ] ++ (lib.optional (cfg.rootTmpfsSize != null) "size=${cfg.rootTmpfsSize}");
in
with lib;
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
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "128M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "dmask=077"
                "fmask=177"
              ];
            };
          };
          root = {
            size = "100%";
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
                    mountOptions = dataMountOptions;
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
                    mountpoint = "/.swapvol";
                    inherit mountOptions;
                    swap = {
                      swapfile.size = cfg.mainDisk.swap.size;
                    };
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

  zramSwap.enable = true;
}
