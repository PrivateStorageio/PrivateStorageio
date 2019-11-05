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
      type = lib.types.enum [ "Trivial" "Ristretto" ];
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
    services.private-storage-issuer.letsEncryptAdminEmail = lib.mkOption {
      type = lib.types.str;
      description = ''
        An email address to give to Let's Encrypt as an operational contact
        for the service's TLS certificate.
      '';
    };
  };

  config =
    let
      certroot = "/var/lib/letsencrypt/live";
    in lib.mkIf cfg.enable {
    # Add a systemd service to run PaymentServer.
    systemd.services.zkapissuer = {
      enable = true;
      description = "ZKAP Issuer";
      wantedBy = [ "multi-user.target" ];

      # Make sure we have a certificate the first time, if we are running over
      # TLS and require a certificate.
      requires = lib.optional cfg.tls "cert-${cfg.domain}";

      after = [
        # Make sure there is a network so we can bind to all of the
        # interfaces.
        "network.target"
      ] ++
        # Make sure we run after the certificate is issued, if we are running
        # over TLS and require a certificate.
        lib.optional cfg.tls "cert-${cfg.domain}";

      # It really shouldn't ever exit on its own!  If it does, it's a bug
      # we'll have to fix.  Restart it and hope it doesn't happen too much
      # before we can fix whatever the issue is.
      serviceConfig.Restart = "always";
      serviceConfig.Type = "simple";

      script =
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
              "--https-certificate-path ${certroot}/${cfg.domain}/cert.pem " +
              "--https-certificate-chain-path ${certroot}/${cfg.domain}/chain.pem " +
              "--https-key-path ${certroot}/${cfg.domain}/privkey.pem"
            else
              # Only for automated testing.
              "--http-port 80";
        in
          "${cfg.package}/bin/PaymentServer-exe ${issuerArgs} ${databaseArgs} ${httpsArgs}";
    };

    # Certificate renewal.  We must declare that we *require* it in our
    # service above.
    systemd.services."cert-${cfg.domain}" = {
      enable = true;
      description = "Issue/Renew certificate for ${cfg.domain}";
      serviceConfig = {
        ExecStart =
        let
          configArgs = "--config-dir /var/lib/letsencrypt --work-dir /var/run/letsencrypt --logs-dir /var/run/log/letsencrypt";
        in
          pkgs.writeScript "cert-${cfg.domain}-start.sh" ''
          #!${pkgs.runtimeShell} -e
          # Register if necessary.
          ${pkgs.certbot}/bin/certbot register ${configArgs} --non-interactive --agree-tos -m ${cfg.letsEncryptAdminEmail} || true
          # Obtain the certificate.
          ${pkgs.certbot}/bin/certbot certonly ${configArgs} --non-interactive --standalone --domains ${cfg.domain}
          '';
      };
    };
    # Open 80 and 443 for the certbot HTTP server and the PaymentServer HTTPS server.
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
