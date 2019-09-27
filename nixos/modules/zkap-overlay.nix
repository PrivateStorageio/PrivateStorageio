let
  zkapauthorizer = import ../pkgs/zkapauthorizer-repo.nix;
in
  import "${zkapauthorizer}/overlays.nix"
