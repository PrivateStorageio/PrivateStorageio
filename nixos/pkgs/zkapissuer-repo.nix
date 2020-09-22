let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "18f3d56e2ac795da5eb5f8ecf01a93f005ce478b";
    sha256 = "1bw3yz971j3rr16pb9cj3jyka3akc8kdx8fv5zlfyvhnm67gdlqx";
  }