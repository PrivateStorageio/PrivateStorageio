let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "d7ba9ffd970d7b4caa99ba93433f613d4773b17c";
    sha256 = "0h086173m6ih24wmdy7jshwv7ihl17wh7qir2x4slwydhyrfrwjk";
  }