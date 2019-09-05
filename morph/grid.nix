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
    description = "PrivateStorage.io Staging Grid";
  };

  # Here are the hosts that are in this morph network.  This is sort of like a
  # server manifest.  We try to keep as many of the specific details as
  # possible out of *this* file so that this file only grows as server count
  # grows.  If it grows too much, we can load servers by listing contents of a
  # directory or reading from another JSON file or some such.  For now, I'm
  # just manually maintaining these entries.
  #
  # The name on the left of the `=` is mostly irrelevant but it does provide a
  # default hostname for the server if the configuration on the right side
  # doesn't specify one.
  #
  # The names must be unique!

  "testing000" = import ./testing000.nix {
    publicIPv4 = "3.123.26.90";
    # Pass along some of the Tahoe-LAFS configuration.  If we have much more
    # configuration than this we may want to keep it bundled up in one value
    # instead of pulling individual values out to pass along.
    inherit (cfg) publicStoragePort;
  };

  "staging001" = import ./staging001.nix {
    publicIPv4 = "209.95.51.251";
    inherit (cfg) publicStoragePort;
  };

  # Pass the whole grid configuration to the module and let it take what it
  # wants.
  "staging002" = import ./staging002.nix cfg;
}
