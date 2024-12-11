{
  lib,
  config,
  flakeInputs,
  ...
}:
let
  persistDir = config.nixfiles.impermanence.persistDir;
in
{
  imports = [
    flakeInputs.home-manager.nixosModules.home-manager
  ];

  config = {
    users.extraUsers.orvar = {
      uid = 1000;
      description = "Orvar Segerström <orvarsegerstrom@gmail.com>";
      isNormalUser = true;
      extraGroups = [
        config.nixfiles.oci-containers.backend
        "wheel"
      ];
      group = "users";
      initialPassword = "nixlixzix";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUsW3xavYlqUnTbLXcuDXZk4T5Y4aYEwknP6bbGWAB2 orvarsegerstrom@gmail.com"
      ];
    };

    environment.persistence.${persistDir} = {
      directories = [
        {
          directory = "/home/orvar/develop";
          user = "orvar";
          mode = "0700";
        }
        {
          directory = "/home/orvar/.ssh";
          user = "orvar";
          mode = "0700";
        }
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.orvar =
        { config, ... }:
        {
          home.stateVersion = "24.05";

          # Git config directly in nix
          programs.git = {
            enable = true;
            userName = "Orvar Segerström";
            userEmail = "orvarsegerstrom@gmail.com";
          };

          # Symlinks to your existing config files
          home.file = {
            ".config/fish/conf.d/config.fish".source = config.lib.file.mkOutOfStoreSymlink "/home/orvar/develop/config/shell/config.fish";
            ".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/orvar/develop/config/shell/starship.toml";
            ".config/atuin/config.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/orvar/develop/config/shell/atuin.toml";
          };

          # Enable the programs so they're installed
          programs = {
            fish.enable = true;
            starship.enable = true;
            atuin.enable = true;
          };
        };
    };
  };
}
