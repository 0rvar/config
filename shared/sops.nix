{
  config,
  lib,
  flakeInputs,
  ...
}:

with lib;

let
  cfg = config.nixfiles.sops;
in
{
  config = mkIf cfg.enable {
    users.mutableUsers = mkForce false;
    users.extraUsers.orvar.initialPassword = mkForce null;
    users.extraUsers.orvar.hashedPasswordFile = config.sops.secrets."users/orvar".path;
    sops.secrets."users/orvar".neededForUsers = true;
    sops.age.keyFile = "/persist/key.txt";
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
