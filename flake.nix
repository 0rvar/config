{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      flake-utils,
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
                flakeInputs.disko.nixosModules.disko
                ./shared
                (./hosts + "/${name}" + /configuration.nix)
                (./hosts + "/${name}" + /hardware.nix)
                sops-nix.nixosModules.sops
              ] ++ extraModules;
            };
        in
        {
          snufkin = mkNixosConfiguration "snufkin" [
            "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
          ];
        };

      apps =
        flake-utils.lib.eachSystemPassThrough
          [
            "x86_64-linux"
            "aarch64-darwin"
          ]
          (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            {
              ${system} =
                let
                  mkApp = name: script: {
                    type = "app";
                    program = toString (pkgs.writeShellScript "${name}.sh" script);
                  };
                in
                {
                  fmt = mkApp "fmt" ''
                    PATH=${
                      with pkgs;
                      lib.makeBinPath [
                        nix
                        git
                        nixfmt-rfc-style
                      ]
                    }

                    nixfmt /shared /hosts flake.nix
                  '';

                  secrets = mkApp "secrets" ''
                    PATH=${
                      with pkgs;
                      lib.makeBinPath [
                        sops
                        nettools
                        vim
                      ]
                    }
                    export EDITOR=vim

                    ${pkgs.lib.fileContents ./scripts/secrets.sh}
                  '';
                };
            }
          );
    };
}
