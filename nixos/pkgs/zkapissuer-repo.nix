let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "e1e0817b80ce1031d21587357bfb8dc4e7837b01";
    sha256 = "0i95cpqbz9fj4b1cii1xh01ss77v2jgd5qwzqvk812f0slz3fw6q";
  }