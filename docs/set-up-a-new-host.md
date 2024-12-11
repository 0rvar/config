# Set up a new host

## Install NixOS on physical host

First, ensure that sops is turned off for the initial installation:

```nix
{
  nixfiles.sops.enable = false;
}
```

Fire up the live USB and run this on the host:

```sh
lsblk # Ensure we have the right disk name in the host config, eg nvme0n1 (or vda on VMs)
passwd # Set a password for the `nixos` user
ip addr # Get ip address for the host, if applicable
```

On your local machine:

```sh
ssh nixos@[ip] # Test that you can SSH into the installer on the host
nix run github:nix-community/nixos-anywhere -- --flake '.#[host]' nixos@[ip] --build-on-remote --generate-hardware-config nixos-generate-config ./hosts/[host]/hardware.nix
```

## First boot

Verify things are working after reboot, then

```sh
ssh-keyscan host | ssh-to-age # Add this to the `~/.sops.yaml` file
```

Add a new section with this key to `.sops.yaml`:

```yaml
creation_rules:
  ...
  - path_regex: hosts/[host]/secrets(/[^/]+)?\.yaml$
    key_groups:
      - age:
          - *orvar
          - '<key>'
```

Add a `users/orvar` secret with the hashed user password:

```bash
, mkpasswd -s
nix run .#secrets <host>
```

Now we can enable SOPS and rebuild:

```nix
{
  nixfiles.sops.enable = true;
}
```

Then, let's rebuild remotely:

```bash
, nixos-rebuild \
  --flake .#[host] \
  --build-host [ip] \
  --target-host [ip] \
  --use-remote-sudo \
  --fast \
  switch

```

## First boot

Then:

1. Rebuild the system: `sudo nixos-rebuild boot --flake /persist/etc/nixos`
2. Reboot

## Optional: Generate SSH key

Generate an ed25519 SSH key to use with SOPS:

```bash
ssh-keygen -t ed25519
, ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/Library/Application\ Support/sops/age/keys.txt
```

**If the host should be able to interact with GitHub:** add the public key to
the GitHub user configuration _as an SSH key_.

**If the host should be able to push commits to GitHub:** add
the public key to the GitHub user configuration _as a signing key_, and also add
it to [the allowed_signers
file](https://github.com/orvar/dotfiles/blob/master/dot_config/git/allowed_signers.tmpl).

**If the host should be able to connect to other machines:** add the public key
to `shared/default.nix`.
