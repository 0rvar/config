{ flake-utils, nixpkgs }:
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
  )
