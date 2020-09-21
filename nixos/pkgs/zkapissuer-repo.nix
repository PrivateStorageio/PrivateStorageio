let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "00265d835ff11ef9b2f10408dff431e6f04e281a";
    sha256 = "0ikqqnjbka06d92p60imzh2hkk1gp54g4gpyy5va4s659j1ws1y7";
  }