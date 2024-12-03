#!/usr/bin/env bash

set -euo pipefail

WANTED_PACKAGES=(
  # Basic nix tooling
  nixfmt-rfc-style # recommended nix formatter in $current_year
  direnv           # use_flake
  nix-direnv       # faster use_flake with caching

  # Rust-based CLI tools
  starship  # Shell prompt gifted by the heavens unto the mortals
  bat       # cat with wings
  dust      # what if `du` was useful
  duf       # also a `du` alternative, but whole-disk analysis
  eza       # nice `ls`
  fd        # like `find` but not horrifyingly bad
  hyperfine # benchmarking tool
  rargs     # xargs except doesnt suck
  ripgrep   # rg
  hexyl     # hex representation viewer
  binocle   # binary file visualizer
  rqbit     # CLI torrent client
  tokei     # Code statistics
  bottom    # htop but in rust
  zoxide    # automatic cd bookmarks. just `z my` or `z stuff` to cd to a commonly used folder named `my folder and stuff`
  sd        # Search and replace. Weird how there is nothing like this in coreutils
  yazi      # CLI file explorer and manager (blazing fast, if you were wondering)
  vivid     # ls/fd/dust/etc colors beyond your wildest dreams - `set -xg LS_COLORS (vivid generate molokai)`
  atuin     # an attempt at making shell history less boring and also optionally pipe it straight into the cloud

  # CLI tools written in lesser languages.
  # However, do not hold it against them, they are
  # nonetheless impressive and/or useful.
  jq   # JSON swiss army knife
  btop # what if htop was good
  htop # somebody once told me htop is better for "inspecting processes"

  # Shell
  fish # if you are not using fish, what are you even doing
  fzf  # fuzzy finder, very nice integration with fish (cmd+r and more)

  # Git stuff
  git
  git-interactive-rebase-tool # easier cli interface for interactive rebases
  delta                       # really nice git diff viewer with syntax highlighting

  # Download & media
  curl
  wget
  yt-dlp # I admit to no crime
  ffmpeg_7-full
  imagemagick

  # Devtools
  flyctl
  gh # github cli. use "gh pr create -w", "gh repo view -w" and "gh repo fork" a lot
)

NIX_PROFILE_LIST=$(nix profile list)
INSTALLED_PACKAGES=0
for package in "${WANTED_PACKAGES[@]}"; do
  if ! echo "$NIX_PROFILE_LIST" | sed -r "s/\x1b\[[0-9;]*m//g" | grep -qE "^Name:\W+$package\$"; then
    echo "Installing $package"
    nix profile install "nixpkgs#$package"
    INSTALLED_PACKAGES=$((INSTALLED_PACKAGES + 1))
  fi
done
if [ $INSTALLED_PACKAGES -eq 0 ]; then
  NUM_WANTED_PACKAGES=${#WANTED_PACKAGES[@]}
  echo "$NUM_WANTED_PACKAGES packages are already installed"
else
  echo "Installed $INSTALLED_PACKAGES packages"
fi

# Find packages in profile that are not in $packages
ALL=$(echo "$NIX_PROFILE_LIST" | sed -r "s/\x1b\[[0-9;]*m//g" | grep -E "^Name:\W+" | awk '{print $2}')
for package in $ALL; do
  if [[ ! " ${WANTED_PACKAGES[@]} " =~ " $package " ]]; then
    echo "Found extra package $package"
  fi
done
