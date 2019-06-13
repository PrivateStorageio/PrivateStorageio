{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage ./privatestorageio.nix { }
