let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "139323f403fa0847606f8e58d950b68f0dc59105";
    sha256 = "0jx5h469hvc8i7k61cj2240z6gwza0l5zlm55wj1kd0dqgigi0lj";
  }