#!/usr/bin/env bash
set -euo pipefail

, nixos-rebuild \
  --flake .#$1 \
  --build-host $VPS_IP \
  --target-host $VPS_IP \
  --use-remote-sudo \
  --fast \
  switch
