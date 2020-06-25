let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "LeaseReport";
    rev = "959d73fa9c0290d46d7eb9439c02df780909b03e";
    sha256 = "0ksir726gsh67zlswmapw3iw0l7m052277vwbn689mg2galj8dfb";
  }