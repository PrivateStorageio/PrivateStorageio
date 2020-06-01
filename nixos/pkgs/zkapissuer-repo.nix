let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "b8e4f86ad512f2752842f4d3dc2ac219143447eb";
    sha256 = "1fmgqh5n4jbbc5c92bv83k51zd96qb03s5x5pz8qnpfa1mp9wc5q";
  }