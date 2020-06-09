# A NixOS module which configures SSH access to a system.
{
  lib,
  config,
  ...
}: {
  options = {
  };
  config =
  let
    cfg = config."private-storage".config;
  in {
    # An attempt at a properly secure SSH configuration.  This is informed by
    # personal experience as well as various web resources:
    #
    # https://www.cyberciti.biz/tips/linux-unix-bsd-openssh-server-best-practices.html
    services.openssh = {
      enable = true;

      # We don't use SFTP for anything.  No reason to expose it.
      allowSFTP = false;

      # We only allow key-based authentication.
      challengeResponseAuthentication = false;
      passwordAuthentication = false;

      extraConfig = ''
        # Possibly this is superfluous considering we don't allow
        # password-based authentication at all.
        PermitEmptyPasswords no

        # Don't allow authentication as random system users.
        AllowUsers root
      '';
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4GenAY/YLGuf1WoMXyyVa3S9i4JLQ0AG+pt7nvcLlQ exarkun@baryon"
    ];
  };
}
