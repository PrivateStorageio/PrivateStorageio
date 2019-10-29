{ hardware
, ristrettoSigningKeyPath
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
    # XXX This should be passed as a path.
    ristrettoSigningKey = builtins.readFile (./.. + ristrettoSigningKeyPath);
    database = "SQLite3";
    databasePath = "/var/db/vouchers.sqlite3";
  };

  system.stateVersion = stateVersion;
}
