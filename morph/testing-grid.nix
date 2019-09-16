# Load the helper function and call it with arguments tailored for the testing
# grid.  It will make the morph configuration for us.  We share this function
# with the production grid and have one fewer possible point of divergence.
import ./make-grid.nix {
  name = "Testing";
  nodes = cfg: {
    "testing000" = import ./testing000.nix {
      publicIPv4 = "3.123.26.90";
      # Pass along some of the Tahoe-LAFS configuration.  If we have much more
      # configuration than this we may want to keep it bundled up in one value
      # instead of pulling individual values out to pass along.
      inherit (cfg) publicStoragePort;
    };
  };
}
