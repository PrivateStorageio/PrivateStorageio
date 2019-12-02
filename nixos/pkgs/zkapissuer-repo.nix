let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "1130b17e85392efd9f6be733308542b50bded1e3";
    sha256 = "1ivcy3xcakxs0yfvbnvizq9pchp15g2wdprh5r5rq4fkqk8k6nbf";
  }