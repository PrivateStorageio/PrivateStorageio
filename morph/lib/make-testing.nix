{ publicIPv4, hardware, publicStoragePort, ristrettoSigningKeyPath, passValue, sshUsers, stateVersion, ... }: rec {

  deployment = {
    secrets = {
      "ristretto-signing-key" = {
        source = ristrettoSigningKeyPath;
        destination = "/var/secrets/ristretto.signing-key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
        # Service name here matches the name defined by our tahoe-lafs nixos
        # module.  It would be nice to not have to hard-code it here.  Can we
        # extract it from the tahoe-lafs nixos module somehow?
        action = ["sudo" "systemctl" "restart" "tahoe.storage.service"];
      };
    };
  };

  imports = [
    hardware
    ../../nixos/modules/private-storage.nix
  ];

  services.private-storage =
  { enable = true;
    inherit publicIPv4;
    inherit publicStoragePort;
    ristrettoSigningKeyPath = deployment.secrets.ristretto-signing-key.destination;
    inherit passValue;
    inherit sshUsers;
  };

  system.stateVersion = stateVersion;
}
