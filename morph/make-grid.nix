# Define a function for making a morph configuration for a storage grid.  It
# takes two arguments.  A string like "Production" giving the name of the grid
# and a function that takes the grid configuration as an argument and returns
# a set of nodes specifying the addresses and NixOS configurations for each
# server in the morph network.
{ name, nodes }:
let
  # Pin the deployment package-set to a specific version of nixpkgs.  This is
  # NixOS 19.03 as of Aug 28 2019.  There's nothing special about it.  It's
  # just recent at the time of development.  It can be upgraded when there is
  # value in doing so.  Meanwhile, our platform doesn't shift around beneath
  # us in surprising ways as time passes.
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/3c83ad6ac13b67101cc3e2e07781963a010c1624.tar.gz";
    sha256 = "0cdq342wrkvkyccygpp1gvwp7hhqg68hljjwld4vjixm901ayy14";
  }) {};
  # Load our JSON configuration for later use.
  cfg = pkgs.lib.trivial.importJSON ./grid.config.json;
in
{
  network =  {
    # Make all of the hosts in this network use the nixpkgs we pinned above.
    inherit pkgs;
    # This is just for human consumption as far as I can tell.
    description = "PrivateStorage.io ${name} Grid";
  };
} // (nodes cfg)
