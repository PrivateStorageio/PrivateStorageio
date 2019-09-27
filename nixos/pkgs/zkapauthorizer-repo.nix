let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "00387ea1d02a5800ff4480a3a177ecc87b34532f";
    sha256 = "053bzpq68fz1y0qzyryxjmbpvpzshhxhkp404pviqdi18xyqgzyc";
  }