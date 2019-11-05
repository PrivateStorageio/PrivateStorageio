# Define a function for making a morph configuration for a storage grid.  It
# takes two arguments.  A string like "Production" giving the name of the grid
# and a function that takes the grid configuration as an argument and returns
# a set of nodes specifying the addresses and NixOS configurations for each
# server in the morph network.
{ name, config, nodes }:
let
  pkgs = import <nixpkgs> { };
  # Load our JSON configuration for later use.
  cfg = pkgs.lib.trivial.importJSON config;
in
{
  network =  {
    # Make all of the hosts in this network use the nixpkgs we pinned above.
    inherit pkgs;
    # This is just for human consumption as far as I can tell.
    description = "PrivateStorage.io ${name} Grid";
  };
} // (nodes cfg)
