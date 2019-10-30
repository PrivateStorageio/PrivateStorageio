let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "0acf43493a7525b0eba01b1c69fb69b41f411ecc";
    sha256 = "0zaqm6qmylclxn25vghafwqxpm5h13c727x3zjnqgp7vbmi2aglk";
  }