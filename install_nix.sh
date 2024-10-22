#!/usr/bin/env bash

set -eo pipefail

NIX_INSTALLED=$(command -v nix || true)
if [ -z "$NIX_INSTALLED" ]; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  echo "[√] Nix installed"
  echo
  echo
  echo "=================== IMPORTANT ====================="
  echo "NOW RESTART YOUR TERMINAL AND RUN THIS SCRIPT AGAIN"
  echo "==================================================="
  echo
  echo
  exit 1
fi

installed_before=$(command -v direnv || true)

nix profile install nixpkgs#direnv
nix profile install nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
touch ~/.config/direnv/direnv.toml
grep -q "hide_env_diff = true" ~/.config/direnv/direnv.toml || (
  echo "Creating ~/.config/direnv/direnv.toml" &&
    echo "[global]" >>~/.config/direnv/direnv.toml &&
    echo "hide_env_diff = true" >>~/.config/direnv/direnv.toml
)

touch ~/.config/direnv/direnvrc
grep -q "source \$HOME/.nix-profile/share/nix-direnv/direnvrc" ~/.config/direnv/direnvrc || (
  echo "Adding nix-direnv to ~/.config/direnv/direnvrc" &&
    echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >>~/.config/direnv/direnvrc
)

if [ -z "$installed_before" ]; then
  echo
  echo
  echo "=========== IMPORTANT ============="
  echo "Restart your terminal to use direnv"
  echo "==================================="
  echo
  echo
fi
