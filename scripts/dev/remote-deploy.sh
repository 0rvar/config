#!/usr/bin/env bash
set -euo pipefail

# Check $1
if [ -z "$1" ]; then
  echo "Please provide the environment to deploy to."
  exit 1
fi

nix run .#deploy -- -s .#$1
