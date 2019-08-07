# https://nixos.org/nixos/manual/index.html#sec-nixos-tests
import <nixpkgs/nixos/tests/make-test.nix> {

  # Configure a single machine as a PrivateStorage storage node.
  machine =
    { config, pkgs, ... }:
    { imports =
      [ ../private-storage.nix
      ];
      services.private-storage.enable = true;
    };

  # Test the machine with a Perl program (sobbing).
  testScript =
    ''
      # Boot the VM.
      $machine->start;

      # The systemd unit should reach the running state.
      $machine->waitForUnit("tahoe.storage.service");

      # Some while after that the Tahoe-LAFS node should listen on the web API
      # port. The port number here has to agree with the port number set in
      # the private-storage.nix module.
      $machine->waitForOpenPort(3456);

      # Once the web API is listening it should be possible to scrape some
      # status from the node if it is really working.
      $machine->succeed("tahoe -d /var/db/tahoe-lafs/storage status");
    '';
}
