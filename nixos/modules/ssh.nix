# A NixOS module which configures SSH access to a system.
{
  lib,
  config,
  ...
}: {
  options = {
    services.private-storage.sshUsers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      example = lib.literalExample { root = "ssh-ed25519 AAA..."; };
      description = ''
        Users to configure on the issuer server and the storage servers and
        the SSH public keys to use to authenticate them.
      '';
    };
  };
  config =
  let
     cfg = config.services."private-storage";
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

        # Only allow authentication as one of the configured users, not random
        # other (often system-managed) users.
        AllowUsers ${builtins.concatStringsSep " " (builtins.attrNames cfg.sshUsers)}
      '';
    };

    users.users =
      let makeUserConfig = username: sshPublicKey: {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ sshPublicKey ];
      };
      in builtins.mapAttrs makeUserConfig cfg.sshUsers;
  };
}
