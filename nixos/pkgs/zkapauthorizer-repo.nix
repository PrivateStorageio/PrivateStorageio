let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "6cd0c32cc53a9734e2cb7c19a9ad28d479612197";
    sha256 = "0i1r75471yjj4bfi5814ihrcyjk1zdz8rzm06bngij3n70svqhsm";
  }