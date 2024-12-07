{ lib, ... }:
with lib;
{
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

      espSize = mkOption {
        type = types.str;
        default = "1024MiB";
        description = "Size of EFI System Partition";
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

      btrfsCompression = mkOption {
        type = types.str;
        default = "zstd";
        description = "Compression algorithm for BTRFS";
      };
    };
  };
}
