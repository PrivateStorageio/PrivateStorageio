let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "c5651f58ff564f00cfcdb4c73584817b9197f7a6";
    sha256 = "1gmx4c82h95lkmqdklak3kpj6gkpp57hwc309h4798sclgvp287b";
  }