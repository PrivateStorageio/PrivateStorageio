let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "17d66c052bfd08f8d00301cc431a83c70f05db0f";
    sha256 = "10ss41lk2mlb3ys7b8dc9dkcdiabkvi8clklkm75llk0g5bkvvss";
  }