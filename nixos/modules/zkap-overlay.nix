let
  src = import ../pkgs/zkapauthorizer-repo.nix;
in
  import "${src}/overlays.nix"
