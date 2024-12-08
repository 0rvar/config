# Set up a new host

```admonish info
See also [the NixOS installation instructions](https://nixos.org/manual/nixos/stable/index.html#ch-installation).
```

## Install NixOS on physical host

Fire up the live USB and run this on the host:

```sh
lsblk # Ensure config for the host matches the disk in the nix config, eg nvme0n1
passwd # Set a password for the `nixos` user
ip addr # Get ip address for the host
```

On your local machine:

```sh
ssh-keyscan host | ssh-to-age # Add this to the `~/.sops.yaml` file
```

Add a new section with this key to `.sops.yaml`:

```yaml
creation_rules:
  ...
  - path_regex: hosts/<hostname>/secrets(/[^/]+)?\.yaml$
    key_groups:
      - age:
          - *orvar
          - '<key>'
```

Add a `users/orvar` secret with the hashed user password:

```bash
nix run .#secrets <host>
```

```sh
ssh nixos@[ip] # Test that you can SSH into the installer on the host
export nixosanywhere="github:nix-community/nixos-anywhere"
nix run $nixosanywhere -- --flake '.#hostNameInConfig' nixos@[ip]

```

## First boot

Generate an age public key from the host SSH key:

```bash
ssh-to-age -i $HOME/.ssh/id_ed25519.pub'
```

Copy the host SSH keys to `/etc/persist`:

```bash
mkdir /persist/etc/ssh
cp /etc/ssh/ssh_host_rsa_key /persist/etc/ssh/ssh_host_rsa_key
cp /etc/ssh/ssh_host_ed25519_key /persist/etc/ssh/ssh_host_ed25519_key
```

Then:

1. Rebuild the system: `sudo nixos-rebuild boot --flake /persist/etc/nixos`
2. Reboot

## Optional: Generate SSH key

Generate an ed25519 SSH key:

```bash
ssh-keygen -t ed25519
```

**If the host should be able to interact with GitHub:** add the public key to
the GitHub user configuration _as an SSH key_.

**If the host should be able to push commits to GitHub:** add
the public key to the GitHub user configuration _as a signing key_, and also add
it to [the allowed_signers
file](https://github.com/orvar/dotfiles/blob/master/dot_config/git/allowed_signers.tmpl).

**If the host should be able to connect to other machines:** add the public key
to `shared/default.nix`.
