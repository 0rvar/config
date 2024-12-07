{ pkgs }:
rec {
  packageNames =
    with builtins;
    attrNames (
      with pkgs;
      {
        inherit
          # Basic nix tooling
          nixfmt-rfc-style
          direnv
          nix-direnv
          comma
          nix-index

          # Rust-based CLI tools
          starship
          bat
          dust
          duf
          eza
          fd
          hyperfine
          rargs
          ripgrep
          hexyl
          binocle
          rqbit
          tokei
          bottom
          zoxide
          sd
          yazi
          vivid
          atuin

          # CLI tools in lesser languages
          jq
          btop
          htop

          # Shell
          fzf

          # Git stuff
          git
          git-interactive-rebase-tool
          delta

          # Download & media
          curl
          wget
          ;
      }
    );

  mkPackages = pkgs: map (name: pkgs.${name}) packageNames;
}
