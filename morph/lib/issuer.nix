{ hardware
, ristrettoSigningKeyPath
, stripeSecretKeyPath
, issuerDomain
, letsEncryptAdminEmail
, allowedChargeOrigins
, sshUsers
, stateVersion
, ...
}: {
  deployment = {
    secrets = {
      "ristretto-signing-key" = {
        source = ristrettoSigningKeyPath;
        destination = "/var/secrets/ristretto.signing-key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
        action = ["sudo" "systemctl" "restart" "zkapissuer.service"];
      };
      "stripe-secret-key" = {
        source = stripeSecretKeyPath;
        destination = "/var/secrets/stripe.secret-key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
        action = ["sudo" "systemctl" "restart" "zkapissuer.service"];
      };
    };
  };

  imports = [
    hardware
    ../../nixos/modules/issuer.nix
  ];

  services.private-storage.sshUsers = sshUsers;
  services.private-storage-issuer = {
    enable = true;
    tls = true;
    ristrettoSigningKeyPath = "/var/secrets/ristretto.signing-key";
    stripeSecretKeyPath = "/var/secrets/stripe.secret-key";
    database = "SQLite3";
    databasePath = "/var/db/vouchers.sqlite3";
    inherit letsEncryptAdminEmail;
    domain = issuerDomain;
    inherit allowedChargeOrigins;
  };

  system.stateVersion = stateVersion;
}
