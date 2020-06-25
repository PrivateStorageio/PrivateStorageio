let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "LeaseReport";
    rev = "59d98d2e0d14ac05e4c57b285463910e04b8a9b0";
    sha256 = "0w5msd6q7lpfabzs3d5czcb3jbi9vdh5xzp13phjc4gimfdzfd94";
  }