# Derive a brand new version of pkgs which has our overlays applied.  This
# includes the ZKAPAuthorizer overlay which defines some Python overrides as
# well as our own which defines the `privatestorage` derivation.
{ pkgs }:
import pkgs.path {
  overlays = [
    (import ./zkap-overlay.nix)
    (import ./overlays.nix)
  ];
}
