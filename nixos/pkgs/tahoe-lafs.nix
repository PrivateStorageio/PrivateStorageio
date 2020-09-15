{ callPackage }:
let
  tahoe-lafs-repo = import ./tahoe-lafs-repo.nix;
in
  callPackage "${tahoe-lafs-repo}/nix" { }
