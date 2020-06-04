{ pkgs ? import <nixpkgs> { } }:
let
  nixpkgs-rev = builtins.readFile ./nixpkgs.rev;
  morph-src = pkgs.fetchFromGitHub {
    owner = "DBCDK";
    repo = "morph";
    rev = "v1.4.0";
    hash = "sha256:1y6clzi8sfnrv4an26b44r24nnxds1kj9aw3lmjbgxl9yrxxsj1k";
  };
  morph = pkgs.callPackage (morph-src + "/nix-packaging") { };
in
pkgs.mkShell {
  NIX_PATH = "nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/${nixpkgs-rev}.tar.gz";

  buildInputs = [
    morph
  ];
}
