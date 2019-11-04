# Load the helper function and call it with arguments tailored for the testing
# grid.  It will make the morph configuration for us.  We share this function
# with the production grid and have one fewer possible point of divergence.
import ./make-grid.nix {
  name = "Testing";
  config = ./testing-grid.config.json;
  nodes = cfg: {
    "payments.privatestorage-staging.com" = import ./issuer.nix ({
      hardware = ./issuer-aws.nix;
      stateVersion = "19.03";
    } // cfg);

    "35.157.216.200" = import ./testing000.nix (cfg // {
      publicIPv4 = "35.157.216.200";
    });
  };
}
