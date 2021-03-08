# Load the helper function and call it with arguments tailored for the testing
# grid.  It will make the morph configuration for us.  We share this function
# with the production grid and have one fewer possible point of divergence.
import ../../lib/make-grid.nix {
  name = "LocalDev";
  config = ./config.json;
  nodes = cfg:
  let
    sshUsers = import ../../../../PrivateStorageSecrets/localdev-users.nix;
  in {
    "payments-1" = import ../../lib/issuer.nix ({
      publicIPv4 = "10.233.4.2";
      inherit sshUsers;
      hardware = ../../lib/issuer-aws.nix;
      stateVersion = "19.03";
    } // cfg);

    "storage-1" = import ../../lib/make-testing.nix (cfg // {
      publicIPv4 = "10.233.5.2";
      inherit sshUsers;
      hardware = ./localdev001-hardware.nix;
      stateVersion = "19.03";
    });
  };
}
