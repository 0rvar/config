{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

with lib;
{
  imports = [
    flakeInputs.nix-index-database.nixosModules.nix-index
  ];

  config = {
    programs.command-not-found.enable = false; # Doesn't work with flakes (we'll use nix-index instead)
    programs.nix-index-database.comma.enable = true;
  };
}
