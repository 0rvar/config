#!/usr/bin/env bash

set -eo pipefail

packages=(
  # Terminal tools
  bat
  dust
  eza
  fd
  htop
  hyperfine
  jq
  rargs
  ripgrep

  # Shell
  fish
  fzf
  thefuck

  # Git stuff
  git
  git-interactive-rebase-tool
  delta

  # Download & media
  curl
  wget
  yt-dlp
  ffmpeg_7-full
  rqbit # Torrent client

  # Devtools
  flyctl
  gh
  supabase-cli
)
for package in "${packages[@]}"; do
  nix profile install "nixpkgs#$package"
done

# supabase/tap/supabase
