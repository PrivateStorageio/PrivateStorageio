{ fetchFromGitHub, python27Packages }:
let
  zkapauthorizer = import ./zkapauthorizer-repo.nix { inherit fetchFromGitHub; };
in
  python27Packages.callPackage "${zkapauthorizer}/tahoe-lafs.nix" { }
