{ fetchFromGitHub }:
let
  zkapauthorizer = import ../pkgs/zkapauthorizer-repo.nix { inherit fetchFromGitHub; };
in
  import "${zkapauthorizer}/overlays.nix"
