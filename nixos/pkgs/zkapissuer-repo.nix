let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "028d26152eba4f034aba405caa17627a764c2bbe";
    sha256 = "06hdln97r2ign7phf661wlzh3z06bk9906lvc0gm3lh1pa23d3gb";
  }