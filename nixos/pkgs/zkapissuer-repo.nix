let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "c5240ad31225fdb482713f8799016bde87ffcc2f";
    sha256 = "08ngyabcnadn1767xjpbcx90i7ygh6x1fkklpv6h5bd2001s9glh";
  }