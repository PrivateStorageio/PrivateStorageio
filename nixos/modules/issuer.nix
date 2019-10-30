# A NixOS module which can run a Ristretto-based issuer for PrivacyStorage
# ZKAPs.
{ lib, pkgs, config, ... }: let
  pspkgs = pkgs.callPackage ./pspkgs.nix { };
  zkapissuer = pspkgs.callPackage ../pkgs/zkapissuer.nix { };
  cfg = config.services.private-storage-issuer;
in {
  options = {
    services.private-storage-issuer.enable = lib.mkEnableOption "PrivateStorage ZKAP Issuer Service";
    services.private-storage-issuer.package = lib.mkOption {
      default = zkapissuer.components.exes."PaymentServer-exe";
      type = lib.types.package;
      example = lib.literalExample "pkgs.zkapissuer.components.exes.\"PaymentServer-exe\"";
      description = ''
        The package to use for the ZKAP issuer.
      '';
    };
    services.private-storage-issuer.domain = lib.mkOption {
      default = "payments.privatestorage.io";
      type = lib.types.str;
      example = lib.literalExample "payments.example.com";
      description = ''
        The domain name at which the issuer is reachable.
      '';
    };
    services.private-storage-issuer.tls = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether or not to listen on TLS.  For real-world use you should always
        listen on TLS.  This is provided as an aid to automated testing where
        it might be difficult to obtain a real certificate.
      '';
    };
    services.private-storage-issuer.issuer = lib.mkOption {
      default = "Ristretto";
      type = lib.types.enum [ " Trivial" "Ristretto" ];
      example = lib.literalExample "Trivial";
      description = ''
        The issuer algorithm to use.  Either Trivial for a fake no-crypto
        algorithm or Ristretto for Ristretto-flavored PrivacyPass.
      '';
    };
    services.private-storage-issuer.ristrettoSigningKey = lib.mkOption {
      default = null;
      type = lib.types.str;
      description = ''
        The Ristretto signing key to use.  Required if the issuer is
        ``Ristretto``.
      '';
    };
    services.private-storage-issuer.database = lib.mkOption {
      default = "Memory";
      type = lib.types.enum [ "Memory" "SQLite3" ];
      description = ''
        The kind of voucher database to use.
      '';
    };
    services.private-storage-issuer.databasePath = lib.mkOption {
      default = null;
      type = lib.types.str;
      description = ''
        The path to a database file in the filesystem, if the SQLite3 database
        type is being used.
      '';
    };
  };

  config =
    let
      acme = "/var/lib/acme";
    in lib.mkIf cfg.enable {
    # Add a systemd service to run PaymentServer.
    systemd.services.zkapissuer = {
      enable = true;
      description = "ZKAP Issuer";
      wantedBy = [ "multi-user.target" ];
      after = [
        # Make sure there is a network so we can bind to all of the
        # interfaces.
        "network.target"
      ];
      # Make sure we at least have a self-signed certificate.
      requires = lib.optional cfg.tls "acme-selfsigned-${cfg.domain}.service";

      serviceConfig = {
        ExecStart =
          let
            # Compute the right command line arguments to pass to it.  The
            # signing key is only supplied when using the Ristretto issuer.
            issuerArgs =
              if cfg.issuer == "Trivial"
                then "--issuer Trivial"
                else "--issuer Ristretto --signing-key ${cfg.ristrettoSigningKey}";
            databaseArgs =
              if cfg.database == "Memory"
                then "--database Memory"
                else "--database SQLite3 --database-path ${cfg.databasePath}";
            httpsArgs =
              if cfg.tls
              then
                "--https-port 443 " +
                # acme has plugins to write the files in different ways but the
                # self-signed certificate generator doesn't.  The files it
                # writes are weirdly named and shaped but they work.
                "--https-certificate-path ${acme}/${cfg.domain}/full.pem " +
                "--https-certificate-chain-path ${acme}/${cfg.domain}/fullchain.pem " +
                "--https-key-path ${acme}/${cfg.domain}/key.pem"
              else
                # Only for automated testing.
                "--http-port 80";
          in
            "${cfg.package}/bin/PaymentServer-exe ${issuerArgs} ${databaseArgs} ${httpsArgs}";
        Type = "simple";
        # It really shouldn't ever exit on its own!  If it does, it's a bug
        # we'll have to fix.  Restart it and hope it doesn't happen too much
        # before we can fix whatever the issue is.
        Restart = "always";
      };
    };

    # Certificate renewal.  Note that preliminarySelfsigned only creates the
    # service.  We must declare that we *require* it in our service above.
    security.acme = if cfg.tls
      then {
        production = false;
        preliminarySelfsigned = true;
        certs."${cfg.domain}" = {
          email = "jean-paul@privatestorage.io";
          postRun = "systemctl restart zkapissuer.service";
          webroot = "${acme}/acme-challenges";
          plugins = [ "full.pem" "fullchain.pem" "key.pem" ];
        };
      }
      else {};

    systemd.timers = if cfg.tls
      then {
        "acme-${cfg.domain}-initial" = config.systemd.timers."acme-${cfg.domain}" // {
          timerConfig = {
            OnUnitActiveSec = "0";
            Unit = "acme-${cfg.domain}.service";
            Persistent = "yes";
            AccuracySec = "1us";
            RandomizedDelaySec = "0s";
          };
        };
      }
      else {};

    services.nginx.virtualHosts = if cfg.tls
      then {
        "${cfg.domain}" = {
          locations."/" = "${acme}/acme-challenges";
        };
      }
      else {};
  };
}
