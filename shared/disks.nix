{
  config,
  lib,
  flakeInputs,
  ...
}:
let
  cfg = config.nixfiles.disks;
  impermanenceCfg = config.nixfiles.impermanence;
  persistDir = impermanenceCfg.persistDir;
  dataDir = impermanenceCfg.dataDir;
  tmpfsMountOptions = [
    "defaults"
    "mode=755"
  ] ++ (lib.optional (cfg.rootTmpfsSize != null) "size=${cfg.rootTmpfsSize}");
in
with lib;
{
  imports = [
    flakeInputs.disko.nixosModules.disko
  ];
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
          partitions =
            (
              if cfg.mainDisk.boot.mode == "legacy" then
                {
                  boot = {
                    name = "boot";
                    label = "BOOT";
                    type = "EF02"; # for grub MBR
                    size = "1M";
                  };
                }
              else
                {
                }
            )
            // {
              ESP = {
                name = "ESP";
                size = "512M";
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
                        mountpoint = persistDir;
                        inherit mountOptions;
                      };
                      "@data" = {
                        # Storage of persistent data that should not be CoW
                        mountpoint = dataDir;
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

    fileSystems."${persistDir}".neededForBoot = true;
    fileSystems."${dataDir}".neededForBoot = true;
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;

    zramSwap.enable = true;

    boot.loader = {
      grub = {
        enable = cfg.mainDisk.boot.mode == "legacy";
        efiSupport = false;
      };
      systemd-boot.enable = cfg.mainDisk.boot.mode == "uefi";
      systemd-boot.memtest86.enable = cfg.mainDisk.boot.mode == "uefi";
    };
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

      boot = {
        mode = mkOption {
          type = types.enum [
            "uefi"
            "legacy"
          ];
          default = "uefi";
          description = "Boot mode to use (UEFI or legacy BIOS). Set to 'legacy' for VPS providers that don't support UEFI boot.";
        };
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
