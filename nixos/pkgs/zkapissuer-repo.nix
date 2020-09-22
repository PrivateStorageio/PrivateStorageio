let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "04a0b325958be64750c3c75272edf9dfc89d4139";
    sha256 = "1bw3yz971j3rr16pb9cj3jyka3akc8kdx8fv5zlfyvhnm67gdlqx";
  }