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
    "storage001" = import ./make-storage.nix ({
        cfg = import ./storage001-config.nix;
        hardware = ./storage001-hardware.nix;
        stateVersion = "19.09";
    } // cfg);
    "storage002" = import ./make-storage.nix ({
        cfg = import ./storage002-config.nix;
        hardware = ./storage002-hardware.nix;
        stateVersion = "19.09";
    } // cfg);
    "storage003" = import ./make-storage.nix ({
        cfg = import ./storage003-config.nix;
        hardware = ./storage003-hardware.nix;
        stateVersion = "19.09";
    } // cfg);
    "storage004" = import ./make-storage.nix ({
        cfg = import ./storage004-config.nix;
        hardware = ./storage004-hardware.nix;
        stateVersion = "19.09";
    } // cfg);
    "storage005" = import ./make-storage.nix ({
        cfg = import ./storage005-config.nix;
        hardware = ./storage005-hardware.nix;
        stateVersion = "19.03";
    } // cfg);
  };
}
