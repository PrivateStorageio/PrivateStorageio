# Derive a brand new version of pkgs which has our overlays applied.  This is
# where the `privatestorage` derivation is added to nixpkgs.
{ pkgs }:
pkgs.extend (import ./overlays.nix)
