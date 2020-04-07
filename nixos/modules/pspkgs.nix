# Derive a brand new version of pkgs which has our overlays applied.  This
# includes the ZKAPAuthorizer overlay which defines some Python overrides as
# well as our own which defines the `privatestorage` derivation.
{ pkgs }:
import pkgs.path {
  overlays = [
    # For some reason the order of these overlays matters.  Maybe it has to do
    # with our python27 override, I'm not sure.  In the other order, we end up
    # with two derivations of each of Twisted and treq which conflict with
    # each other.
    (import ./overlays.nix)
    # It might be nice to eventually remove this.  ZKAPAuthorizer now
    # self-applies this overlay without our help.  We only still have it
    # because it also defines tahoe-lafs which we want to use.  We can't see
    # tahoe-lafs from the self-applied overlay because that overlay is applied
    # to ZKAPAuthorizer's nixpkgs, not to the one we're using.
    (import ./zkap-overlay.nix)
  ];
}
