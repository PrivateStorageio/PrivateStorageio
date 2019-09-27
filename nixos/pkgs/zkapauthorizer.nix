{ python27Packages }:
let
  zkapauthorizer = import ./zkapauthorizer-repo.nix;
in
  python27Packages.callPackage "${zkapauthorizer}/zkapauthorizer.nix" { }
