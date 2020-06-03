let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "ad88bd7ee83a32d0c31e84364533123177b6d596";
    sha256 = "0x1wgfq6b204yqni4akxzm78ls07d2ld80kgsmjbq9xzz33pg22y";
  }