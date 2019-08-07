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
      $machine->start;
      $machine->waitForUnit("tahoe.storage.service");
      $machine->succeed("tahoe -d /var/db/tahoe-lafs/storage status");
    '';
}
