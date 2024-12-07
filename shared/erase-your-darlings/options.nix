{ lib, ... }:

with lib;

{
  options.nixfiles.eraseYourDarlings = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Enable storing `/` on tmpfs and storing persistent data in
        `''${persistDir}`.
      '';
    };

    orvarPasswordFile = mkOption {
      type = types.str;
      description = mdDoc ''
        File containing the hashed password for `orvar`.

        If using [sops-nix](https://github.com/Mic92/sops-nix) set the
        `neededForUsers` option on the secret.
      '';
    };

    persistDir = mkOption {
      type = types.path;
      default = "/persist";
      description = mdDoc ''
        Persistent directory which will not be erased.  This must be on a
        different ZFS dataset that will not be wiped when rolling back to the
        `rootSnapshot`.

        This module moves various files from `/` to here.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/data";
      description = mdDoc ''
        Directory for persistent data that should not be CoW.
        For things like VM disk images, databases, and persistent containers.
      '';
    };

    machineId = mkOption {
      type = types.str;
      example = "8d0944eaa7111a4e83832389a8a384e4";
      description = mdDoc ''
        An arbitrary 32-character hexadecimal string, used to identify the host.
        This is needed for journalctl logs from previous boots to be accessible.

        `openssl rand -hex 16` can be used to generate a new one.

        See [the systemd documentation](https://www.freedesktop.org/software/systemd/man/machine-id.html).
      '';
    };
  };
}
