#!/usr/bin/env bash
set -euo pipefail

ROOT=$(
  cd "$(dirname "${BASH_SOURCE[0]}")/../.."
  pwd
)
cd $ROOT

scripts/validate.sh snufkin

, nixos-rebuild \
  --flake .#snufkin \
  --build-host snufkin.home \
  --target-host snufkin.home \
  --use-remote-sudo \
  --fast \
  switch
