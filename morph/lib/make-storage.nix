# Define the function that defines the node.
{ cfg                        # Get the configuration that's specific to this node.
, hardware                   # The path to the hardware configuration for this node.
, publicStoragePort          # The storage port number on which to accept connections.
, ristrettoSigningKeyPath    # The *local* path to the Ristretto signing key file.
, passValue                  # Bytes component of size×time value of passes.
, sshUsers                   # Users for which to configure SSH access to this node.
, stateVersion               # The value for system.stateVersion on this node.
                             # This value determines the NixOS release with
                             # which your system is to be compatible, in order
                             # to avoid breaking some software such as
                             # database servers. You should change this only
                             # after NixOS release notes say you should.
, ...
}: rec {
  deployment = {
    secrets = {
      "ristretto-signing-key" = {
        source = ristrettoSigningKeyPath;
        destination = "/var/secrets/ristretto.signing-key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
        # Service name here matches the name defined by our tahoe-lafs nixos
        # module.  It would be nice to not have to hard-code it here.  Can we
        # extract it from the tahoe-lafs nixos module somehow?
        action = ["sudo" "systemctl" "restart" "tahoe.storage.service"];
      };
    };
  };

  # Any extra NixOS modules to load on this server.
  imports = [
    # Include the results of the hardware scan.
    hardware
    # Configure it as a system operated by 100TB.
    ../../nixos/modules/100tb.nix
    # Bring in our module for configuring the Tahoe-LAFS service and other
    # Private Storage-specific things.
    ../../nixos/modules/private-storage.nix
  ];

  # Pass the configuration specific to this host to the 100TB module to be
  # expanded into a complete system configuration.  See the 100tb module for
  # handling of this value.
  #
  # The module name is quoted because `1` makes `100tb` look an awful lot like
  # it should be a number.
  "100tb".config = cfg;

  # Turn on the Private Storage (Tahoe-LAFS) service.
  services.private-storage = {
    # Yep.  Turn it on.
    enable = true;
    # Get the public IPv4 address from the node configuration.
    inherit (cfg) publicIPv4;
    # And the port to operate on is specified via parameter.
    inherit publicStoragePort;
    # Give it the Ristretto signing key, too, to support authorization.
    ristrettoSigningKeyPath = deployment.secrets.ristretto-signing-key.destination;
    # Assign the configured pass value.
    inherit passValue;
    # It gets the users, too.
    inherit sshUsers;
  };

  system.stateVersion = stateVersion;
}
