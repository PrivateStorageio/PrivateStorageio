# The overall system test suite for PrivateStorageio NixOS configuration.
let
  pkgs = import <nixpkgs> { };
in {
  private-storage = pkgs.nixosTest ./modules/tests/private-storage.nix;
  tahoe = pkgs.nixosTest ./modules/tests/tahoe.nix;
}
