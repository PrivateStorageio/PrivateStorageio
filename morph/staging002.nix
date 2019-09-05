let
  cfg = import ./staging002-config.nix;
in
{ publicStoragePort, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./staging002-hardware.nix
      # Configure it as a system operated by 100TB.
      ../nixos/modules/100tb.nix
      # Bring in our module for configuring the Tahoe-LAFS service and other
      # Private Storage-specific things.
      ../nixos/modules/private-storage.nix
   ];

  # Pass the configuration specific to this host to the 100TB module to be
  # expanded into a complete system configuration.  See the 100tb module for
  # handling of this value.
  #
  # The module name is quoted because `1` makes `100tb` look an awful lot like
  # it should be a number.
  "100tb".config = cfg;

  # Turn on the Private Storage (Tahoe-LAFS) service.
  services.private-storage =
  { enable = true;
    # Get the public IPv4 address from the node configuration.
    inherit (cfg) publicIPv4;
    # And the port to operate on is specified via parameter.
    inherit publicStoragePort;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
