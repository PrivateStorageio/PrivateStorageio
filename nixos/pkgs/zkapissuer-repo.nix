let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "6dfc02e395fbbec2c70a109874227ab21bddbb25";
    sha256 = "1zc8cxc37zixsh8zcqasvg07rfsravlx0bhnx6zv9c5srm37iqap";
  }