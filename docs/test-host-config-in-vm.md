# Test config in vm

Before maybe run `scripts/validate.sh <host>` to check for errors.

- run script
- set root pw
- check disk name with lsblk (prop /dev/vda)
- update host config to use disk name
- `nix run github:nix-community/nixos-anywhere -- --flake '.#<host>' --build-on-remote -p 2222 root@localhost`
