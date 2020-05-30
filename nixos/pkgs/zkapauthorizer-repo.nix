let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "27a2f31e5483fa732785cf550e3beef09d67c398";
    sha256 = "10x28f1iplhskbaqxqcd68kz0llssvn261b87x1aaay3959s8ama";
  }