{
  pkgs,
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
    programs.fish.enable = true;
    documentation.man.generateCaches = false; # Ugh

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
      shell = pkgs.fish;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUsW3xavYlqUnTbLXcuDXZk4T5Y4aYEwknP6bbGWAB2 orvarsegerstrom@gmail.com"
      ];
    };
    security.sudo.extraRules = [
      {
        users = [ "orvar" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.orvar =
        { config, ... }:
        {
          imports = [
            flakeInputs.impermanence.homeManagerModules.impermanence
          ];
          home.stateVersion = "24.11";

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

          home.persistence."${persistDir}/home/orvar" = {
            directories = [
              "develop"
              ".ssh"
              ".local/share/atuin"
            ];
            files = [ ];
            allowOther = false;
          };

          programs = {
            starship.enable = true;
            atuin.enable = true;
          };
        };
    };
  };
}
