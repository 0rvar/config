{ pkgs }:
rec {
  packageNames =
    with builtins;
    attrNames (
      with pkgs;
      {
        inherit
          # Basic nix tooling
          nixfmt-rfc-style # recommended nix formatter in $current_year
          direnv # use_flake
          nix-direnv # faster use_flake with caching
          comma # Runs commands without installing them
          nix-index # Has nix-locate (find which nix packages has a file or executable). Also builds the db that comma needs.

          # Rust-based CLI tools
          starship # Shell prompt gifted by the heavens unto the mortals
          bat # cat with wings
          dust # what if `du` was useful
          duf # also a `du` alternative, but whole-disk analysis
          eza # nice `ls`
          fd # like `find` but not horrifyingly bad
          hyperfine # benchmarking tool
          rargs # xargs except doesnt suck
          ripgrep # rg
          hexyl # hex representation viewer
          binocle # binary file visualizer
          rqbit # CLI torrent client
          tokei # Code statistics
          bottom # htop but in rust
          zoxide # automatic cd bookmarks. just `z my` or `z stuff` to cd to a commonly used folder named `my folder and stuff`. Needs shell config.
          sd # Search and replace. Weird how there is nothing like this in coreutils
          yazi # CLI file explorer and manager (blazing fast, if you were wondering)
          vivid # ls/fd/dust/etc colors beyond your wildest dreams - `set -xg LS_COLORS (vivid generate molokai)`
          atuin # an attempt at making shell history less boring and also optionally pipe it straight into the cloud

          # CLI tools written in lesser languages.
          # However, do not hold it against them, they are
          # nonetheless impressive and/or useful.
          jq # JSON swiss army knife
          btop # what if htop was good
          htop # somebody once told me htop is better for "inspecting processes"

          # Shell
          fish # if you are not using fish, what are you even doing
          fzf # fuzzy finder, very nice integration with fish (cmd+r and more)

          # Git stuff
          git
          git-interactive-rebase-tool # easier cli interface for interactive rebases
          delta # really nice git diff viewer with syntax highlighting

          # Download & media
          curl
          wget
          ;
      }
    );

  mkPackages = pkgs: map (name: pkgs.${name}) packageNames;
}
