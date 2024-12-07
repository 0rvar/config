#!/usr/bin/env bash
set -eo pipefail

if [ -z "$1" ]; then
  echo "Usage: nix run .#validate <hostname>"
  echo "Available hosts:"
  echo "  $(ls -1 hosts | tr '\n' ' ')"
  exit 1
fi

echo "Validating configuration for $1..."
nix eval ".#nixosConfigurations.$1.config.system.build.toplevel" --show-trace
