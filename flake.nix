{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      deploy-rs,
      ...
    }@flakeInputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations =
        let
          mkNixosConfiguration =
            name: extraModules:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit flakeInputs;
              };
              modules = [
                {
                  networking.hostName = name;
                  sops.defaultSopsFile = ./hosts + "/${name}" + /secrets.yaml;
                }
                ./shared
                (./hosts + "/${name}" + /configuration.nix)
                (./hosts + "/${name}" + /hardware.nix)
              ] ++ extraModules;
            };
        in
        {
          snufkin = mkNixosConfiguration "snufkin" [ ];
        };

      deploy.nodes.snufkin = {
        hostname = "snufkin.home";
        sshUser = "orvar";
        remoteBuild = true;
        fastConnection = true;
        interactiveSudo = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.snufkin;
        };
      };

      # Add deployment checks
      # CAN'T do this on mac host
      # checks =
      #   if system == "x86_64-linux" then
      #     builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib
      #   else
      #     null;

      apps = import ./apps.nix {
        inherit (flakeInputs) deploy-rs flake-utils nixpkgs;
      };
    };
}
