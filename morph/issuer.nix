{ hardware
, ristrettoSigningKeyPath
, stripeSecretKeyPath
, issuerDomain
, letsEncryptAdminEmail
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
    };
  };

  imports = [
    hardware
    ../nixos/modules/issuer.nix
  ];

  services.private-storage-issuer = {
    enable = true;
    ristrettoSigningKeyPath = ./.. + ristrettoSigningKeyPath;
    stripeSecretKeyPath = ./.. + stripeSecretKeyPath;
    database = "SQLite3";
    databasePath = "/var/db/vouchers.sqlite3";
    inherit letsEncryptAdminEmail;
    domain = issuerDomain;
  };

  system.stateVersion = stateVersion;
}
