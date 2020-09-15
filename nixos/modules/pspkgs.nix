# Derive a brand new version of pkgs which has our overlays applied.  This
# includes our definition of the `privatestorage` derivation, a Python
# environment with Tahoe-LAFS and ZKAPAuthorizer installed.
{ pkgs }:
import pkgs.path {
  overlays = [
    (import ./overlays.nix)
  ];
}
