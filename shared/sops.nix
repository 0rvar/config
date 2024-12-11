{
  config,
  lib,
  flakeInputs,
  ...
}:

with lib;

let
  cfg = config.nixfiles.sops;
  persistDir = config.nixfiles.impermanence.persistDir;
in
{
  config =
    {
      sops.age = {
        keyFile = "${toString persistDir}/etc/ssh/age.txt";
        generateKey = true;
        sshKeyPaths = [
          "${toString persistDir}/etc/ssh/ssh_host_ed25519_key"
        ];
      };
      sops.gnupg.sshKeyPaths = [ ];
    }
    // mkIf cfg.enable {
      users.mutableUsers = mkForce false;
      users.extraUsers.orvar.initialPassword = mkForce null;
      users.extraUsers.orvar.hashedPasswordFile = config.sops.secrets."users/orvar".path;
      sops.secrets."users/orvar".neededForUsers = true;
    };

  options.nixfiles.sops = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Enable SOPS for managing secrets.
      '';
    };
  };
}
