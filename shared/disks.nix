{ config, lib, ... }:
let
  cfg = config.nixfiles.disks;
  impermanenceCfg = config.nixfiles.impermanence;
  tmpfsMountOptions = [
    "defaults"
    "mode=755"
  ] ++ (lib.optional (cfg.rootTmpfsSize != null) "size=${cfg.rootTmpfsSize}");
in
with lib;
{
  config = {
    boot.supportedFilesystems = {
      btrfs = true;
    };

    disko.devices = {
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
                      "compress=zstd"
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
                      mountpoint = impermanenceCfg.persistDir;
                      inherit mountOptions;
                    };
                    "@data" = {
                      # Storage of persistent data that should not be CoW
                      mountpoint = impermanenceCfg.dataDir;
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
  };

  options.nixfiles.disks = {
    rootTmpfsSize = mkOption {
      type = types.nullOr types.str;
      default = "8G";
      description = ''
        Size of root tmpfs. Can be:
        - absolute size (like '16G')
        - percentage of RAM (like '25%')
        - null for unbounded size
      '';
    };

    mainDisk = {
      device = mkOption {
        type = types.str;
        example = "/dev/sda";
        description = "Main disk device path";
      };

      swap = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to use swap";
        };

        size = mkOption {
          type = types.str;
          default = "16G";
          description = "Size of swapfile when enabled";
        };
      };
    };
  };
}
