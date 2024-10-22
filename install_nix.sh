#!/usr/bin/env bash

set -eo pipefail

NIX_INSTALLED=$(command -v nix || true)
if [ -z "$NIX_INSTALLED" ]; then
  echo "Nix is not installed. Install?"
  select yn in "Yes" "No"; do
    case $yn in
    Yes)
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
      echo "[√] Nix installed"
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      break
      ;;
    No)
      exit 1
      ;;
    esac
  done
fi

setup_direnv() {
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

  shell_name=$(basename $SHELL)
  if [ "$shell_name" = "fish" ]; then
    # Fish: Try adding the direnv plugin with omf
    echo "IMPORTANT: install the direnv plugin for fish with \`omf install direnv\`"
  elif [ "$shell_name" = "fish" ]; then
    touch ~/.bashrc
    # Check if .bashrc already has the line
    grep -q "eval \"\$(direnv hook bash)\"" ~/.bashrc ||
      (
        echo "Adding direnv hook to ~/.bashrc" &&
          echo "eval \"\$(direnv hook bash)\"" >>~/.bashrc
      )
  elif [ "$shell_name" = "zsh" ]; then
    touch ~/.zshrc
    # Check if .zshrc already has the line
    grep -q "eval \"\$(direnv hook zsh)\"" ~/.zshrc ||
      (
        echo "Adding direnv hook to ~/.zshrc" &&
          echo "eval \"\$(direnv hook zsh)\"" >>~/.zshrc
      )
  else
    echo "IMPORTANT: Add the direnv hook to your shell profile manually:"
    echo "https://direnv.net/docs/hook.html"
  fi

}

install_direnv() {
  echo "Installing direnv..."
  nix profile install nixpkgs#direnv
  nix profile install nixpkgs#nix-direnv

  setup_direnv

  echo "[√] Direnv installed."

  exit 1
}

DIRENV_INSTALLED=$(command -v direnv || true)
if [ -z "$DIRENV_INSTALLED" ]; then
  echo "Direnv is not installed. Install?"
  select yn in "Yes" "No"; do
    case $yn in
    Yes)
      install_direnv
      break
      ;;
    No)
      exit 1
      ;;
    esac
  done
fi

if [[ "$*" == *--force* ]]; then
  # Force direnv config
  setup_direnv
fi
