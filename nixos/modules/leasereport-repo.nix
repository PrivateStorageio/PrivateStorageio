let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "LeaseReport";
    rev = "fe093d9ca396a0f2734a58244f694d21112aa678";
    sha256 = "0nw7r1xb908v23882q9mvl7bw9nzhdznhfvhdz94kgdjkll6pafm";
  }