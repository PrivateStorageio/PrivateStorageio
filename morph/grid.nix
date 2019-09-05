# Load the helper function and call it with arguments tailored for the testing
# grid.  It will make the morph configuration for us.  We share this function
# with the testing grid and have one fewer possible point of divergence.
import ./make-grid.nix {
  name = "Production";
  nodes = cfg: {
    # Here are the hosts that are in this morph network.  This is sort of like
    # a server manifest.  We try to keep as many of the specific details as
    # possible out of *this* file so that this file only grows as server count
    # grows.  If it grows too much, we can load servers by listing contents of
    # a directory or reading from another JSON file or some such.  For now,
    # I'm just manually maintaining these entries.
    #
    # The name on the left of the `=` is mostly irrelevant but it does provide
    # a default hostname for the server if the configuration on the right side
    # doesn't specify one.
    #
    # The names must be unique!

    # Pass the whole grid configuration to the module and let it take what it
    # wants.
    "storage000" = import ./storage000.nix cfg;
  };
}
