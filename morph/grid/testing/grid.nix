# Load the helper function and call it with arguments tailored for the testing
# grid.  It will make the morph configuration for us.  We share this function
# with the production grid and have one fewer possible point of divergence.
import ../../lib/make-grid.nix {
  name = "Testing";
  config = ./config.json;
  nodes = cfg:
  let
    sshUsers = import ../../../../PrivateStorageSecrets/staging-users.nix;
  in {
    "payments.privatestorage-staging.com" = import ../../lib/issuer.nix ({
      inherit sshUsers;
      hardware = ../../lib/issuer-aws.nix;
      stateVersion = "19.03";
    } // cfg);

    "3.120.26.190" = import ../../lib/make-testing.nix (cfg // {
      publicIPv4 = "3.120.26.190";
      inherit sshUsers;
      hardware = ./testing001-hardware.nix;
      stateVersion = "19.03";
    });
  };
}
