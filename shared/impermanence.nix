# Wipe `/` on boot, inspired by ["erase your darlings"][].
#
# This module is responsible for configuring standard NixOS options and
# services, all of my modules have their own `erase-your-darlings.nix` file
# which makes any changes that they need.
#
# ["erase your darlings"]: https://grahamc.com/blog/erase-your-darlings/
# ["set up a new host"]: ./runbooks/set-up-a-new-host.md
{
  config,
  lib,
  flakeInputs,
  ...
}:

with lib;

let
  cfg = config.nixfiles.impermanence;
in
{
  imports = [
    flakeInputs.impermanence.nixosModules.impermanence
  ];

  config = {
    # Persist state in `cfg.persistDir`
    services.openssh.hostKeys = [
      {
        path = "${toString cfg.persistDir}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${toString cfg.persistDir}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    environment.persistence = {
      ${cfg.persistDir} = {
        directories = [
          "/var/lib/systemd"
          "/var/lib/nixos"
          "/etc/nixos"
          # "/var/log" # /var/log is already mounted to a btrfs subvolume
          "/srv"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    };

    system.activationScripts.createPersistDirs = {
      deps = [ ]; # Run early
      text =
        let
          persistDirs = config.environment.persistence.${toString cfg.persistDir}.directories;
          mkPersistDir = dirObj: ''
            if [ ! -d "${cfg.persistDir}${dirObj.directory}" ]; then
              mkdir -p ${cfg.persistDir}${dirObj.directory}
              chown ${dirObj.user}:root ${cfg.persistDir}${dirObj.directory}
              chmod ${dirObj.mode} ${cfg.persistDir}${dirObj.directory}
            fi
          '';
        in
        ''
          # Create all persist directories
          ${concatMapStringsSep "\n" mkPersistDir persistDirs}
        '';
    };
  };

  options.nixfiles.impermanence = {
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
  };
}
