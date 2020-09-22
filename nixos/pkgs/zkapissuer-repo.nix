let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "529278d6ee63a70d78f763c46e448c6ed1d9de61";
    sha256 = "0jx5h469hvc8i7k61cj2240z6gwza0l5zlm55wj1kd0dqgigi0lj";
  }