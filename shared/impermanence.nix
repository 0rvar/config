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
    users.mutableUsers = mkForce false;
    users.extraUsers.orvar.initialPassword = mkForce null;
    users.extraUsers.orvar.hashedPasswordFile = config.sops.secrets."users/orvar".path;
    sops.secrets."users/orvar".neededForUsers = true;
    sops.age.keyFile = cfg.sopsKeyFile;

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
      "/persist" = {
        directories = [
          "/var/lib/systemd"
          "/var/lib/nixos"
          # "/var/log" # /var/log is already mounted to a btrfs subvolume
          "/srv"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    };

    system.activationScripts.persistent-dirs.text =
      let
        mkHomePersist =
          user:
          lib.optionalString user.createHome ''
            mkdir -p /persist/${user.home}
            chown ${user.name}:${user.group} /persist/${user.home}
            chmod ${user.homeMode} /persist/${user.home}
          '';
        users = lib.attrValues config.users.users;
      in
      lib.concatLines (map mkHomePersist users);
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

    sopsKeyFile = mkOption {
      type = types.path;
      default = "/persist/key.txt";
      description = mdDoc ''
        Path to the sops key file used to decrypt the `orvarPasswordFile`.
      '';
    };
  };
}
