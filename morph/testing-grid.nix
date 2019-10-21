# Load the helper function and call it with arguments tailored for the testing
# grid.  It will make the morph configuration for us.  We share this function
# with the production grid and have one fewer possible point of divergence.
import ./make-grid.nix {
  name = "Testing";
  nodes = cfg: {
    "testing000" = import ./testing000.nix (cfg // {
      publicIPv4 = "35.157.216.200";
    });
  };
}
