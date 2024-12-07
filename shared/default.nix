{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

with lib;
{
  imports = [
    ./base-packages.nix
    ./erase-your-darlings
    ./oci-containers
  ];

  config = {
    #############################################################################
    ## General
    #############################################################################

    # The NixOS release to be compatible with for stateful data such as databases.
    system.stateVersion = "24.11";

    # Only keep the last 500MiB of systemd journal.
    services.journald.extraConfig = "SystemMaxUse=500M";

    # Collect nix store garbage and optimise daily.
    nix.gc.automatic = true;
    nix.gc.options = "--delete-older-than 30d";
    nix.optimise.automatic = true;

    # Enable flakes
    nix.extraOptions = "experimental-features = nix-command flakes";

    # Clear out /tmp after a fortnight and give all normal users a ~/tmp
    # cleaned out weekly.
    systemd.tmpfiles.rules =
      [ "d /tmp 1777 root root 14d" ]
      ++ (
        let
          mkTmpDir = n: u: "d ${u.home}/tmp 0700 ${n} ${u.group} 7d";
        in
        mapAttrsToList mkTmpDir (filterAttrs (_: u: u.isNormalUser) config.users.extraUsers)
      );

    # Enable passwd and co.
    users.mutableUsers = true;

    # Upgrade packages and reboot if needed
    # system.autoUpgrade.enable = true;
    # system.autoUpgrade.allowReboot = true;
    # system.autoUpgrade.flags = [ "--recreate-lock-file" ];
    # system.autoUpgrade.flake = "/etc/nixos";
    # system.autoUpgrade.dates = "06:45";

    # Reboot on panic and oops
    # https://utcc.utoronto.ca/~cks/space/blog/linux/RebootOnPanicSettings
    boot.kernel.sysctl = {
      "kernel.panic" = 10;
      "kernel.panic_on_oops" = 1;
    };

    #############################################################################
    ## Locale
    #############################################################################

    # Locale
    i18n.defaultLocale = "en_US.UTF-8";

    # Timezone
    services.timesyncd.enable = mkForce true;
    time.timeZone = "Europe/Stockholm";

    # Keyboard
    console.keyMap = "se-latin1";
    services.xserver.xkb.layout = "se";

    #############################################################################
    ## Firewall
    #############################################################################

    networking.firewall.enable = true;
    networking.firewall.allowPing = true;
    networking.firewall.trustedInterfaces = if config.nixfiles.oci-containers.backend == "docker" then [ "docker0" ] else [ "podman" ];
    services.fail2ban.enable = true;

    #############################################################################
    ## Services
    #############################################################################

    # Every machine gets an sshd
    services.openssh = {
      enable = true;

      # Only pubkey auth
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      authorizedKeysInHomedir = true;
    };

    # Start ssh-agent as a systemd user service
    programs.ssh.startAgent = true;

    # Mosh
    programs.mosh = {
      enable = true;
      # make `who` work
      withUtempter = true;
    };

    # Use podman for all the OCI container based services
    nixfiles.oci-containers.backend = "podman";

    # If running a docker registry, also enable deletion and garbage collection.
    services.dockerRegistry.port = 46453;
    services.dockerRegistry.enableDelete = config.services.dockerRegistry.enable;
    services.dockerRegistry.enableGarbageCollect = config.services.dockerRegistry.enable;

    #############################################################################
    ## User accounts
    #############################################################################

    programs.fish.enable = true;

    users.extraUsers.orvar = {
      uid = 1000;
      description = "Orvar Segerström <orvarsegerstrom@gmail.com>";
      isNormalUser = true;
      extraGroups = [
        config.nixfiles.oci-containers.backend
        "wheel"
      ];
      group = "users";
      initialPassword = "breadbread";
      shell = pkgs.fish;

      packages = with pkgs; [
        # Prefer system packages tbh fr fr no cap
      ];

      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDecA77QT8/Ol9mSyg8hVajumh0YzKMRz+CnRdpHQ4568yQrF4wQLHzQc5obSbAvi/iYX4vdjnce7L4eN3W6su0geDw/jCDD/lI732hAfA/LI6bxWKSjv+RxkbR26PjkVSCR2yunJhQHSEBT2qB9JLHDOF+wjoDfvGxqj/1854wMhPNeXLNqLAPGWdvJS+4/NSy7Eh0WjWYO5dPXpZzXwbYltJFr/VPDxGCgQH6D0ERYfr0ldXBHbvFprpn4uwPSUiu9tFoF/7WlzP/zrQgqhFtLrVyA5pFpTTPsrQawFGFDNYcPVdq0GvKF+EuUzR2ZXaEwmX4KtUMXDPV+Nl1wHiT orvar@Orvars-MacBook-Pro.local"
      ];
    };

    # Allow packages with non-free licenses.
    nixpkgs.config.allowUnfree = true;

    # System-wide packages
    environment.systemPackages = (import ./packages.nix).mkPackages pkgs;
  }
}
