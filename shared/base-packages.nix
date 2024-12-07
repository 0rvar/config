{
  pkgs,
  ...
}:
{
  # Base system packages
  environment.systemPackages = with pkgs; [
    bind
    file
    git
    iotop
    lsof
    psmisc
    rsync
    smartmontools
    vim
    wget
    which
    whois
  ];
}
