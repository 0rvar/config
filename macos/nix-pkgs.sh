#!/usr/bin/env bash

set -euo pipefail

WANTED_PACKAGES=($(nix eval --impure --raw --expr "
  let
    pkgs = import <nixpkgs> {};
    packages = import ./shared/packages.nix { inherit pkgs; };
  in
  builtins.concatStringsSep \"\n\" packages.packageNames
"))
WANTED_PACKAGES+=(
  fish
  nix-index

  yt-dlp
  ffmpeg_7-full
  imagemagick

  # Devtools
  flyctl
  gh
  podman
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
