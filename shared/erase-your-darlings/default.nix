# Wipe `/` on boot, inspired by ["erase your darlings"][].
#
# This module is responsible for configuring standard NixOS options and
# services, all of my modules have their own `erase-your-darlings.nix` file
# which makes any changes that they need.
#
# ["erase your darlings"]: https://grahamc.com/blog/erase-your-darlings/
# ["set up a new host"]: ./runbooks/set-up-a-new-host.md
{ config, lib, ... }:

with lib;

let
  cfg = config.nixfiles.eraseYourDarlings;
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf cfg.enable {
    # Set /etc/machine-id, so that journalctl can access logs from
    # previous boots.
    environment.etc.machine-id = {
      text = "${cfg.machineId}\n";
      mode = "0444";
    };

    # Switch back to immutable users
    users.mutableUsers = mkForce false;
    users.extraUsers.orvar.initialPassword = mkForce null;
    users.extraUsers.orvar.hashedPasswordFile = cfg.orvarPasswordFile;

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

    systemd.tmpfiles.rules = [
      "L+ /etc/nixos - - - - ${toString cfg.persistDir}/etc/nixos"
    ];
  };
}
