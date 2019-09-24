# Derive a brand new version of pkgs which has our overlay applied.  The
# overlay defines a new version of Tahoe-LAFS and some of its dependencies
# and maybe other useful Private Storage customizations.
{ pkgs }:
import pkgs.path {
  overlays = [
    # needs fetchFromGitHub to check out zkapauthorizer
    (pkgs.callPackage ./zkap-overlay.nix { })
    (import ./overlays.nix)
  ];
}
