{ pkgs ? import <nixpkgs> { } }:
let
  # NixOS 19.03 packaged graphviz has trouble rendering our architecture
  # overview.  Latest from upstream does alright, though.  Use that.
  make-graphviz = (import (pkgs.path + /pkgs/tools/graphics/graphviz/base.nix) {
    rev = "b29d8e369011b832f72e0d250a05a0a15dcb5daa";
    sha256 = "1w61filywn9cif2nryf6vd34mxxbvv25q34fd34am1rx70bk08ps";
    version = "b29d8e369011b832f72e0d250a05a0a15dcb5daa";
  });
  graphviz = (pkgs.callPackage make-graphviz { }).overrideAttrs (old: {
    patches = [];
  });
in
  pkgs.callPackage ./privatestorageio.nix { inherit graphviz; }
