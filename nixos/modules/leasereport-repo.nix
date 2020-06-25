let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "LeaseReport";
    rev = "92f6567160c1459b5992f1cb8535aee0c23bc093";
    sha256 = "04k1q170n4dwvakgi9gsc8mbbhqzcnygiw51rqyrf9blrsdh5fma";
  }