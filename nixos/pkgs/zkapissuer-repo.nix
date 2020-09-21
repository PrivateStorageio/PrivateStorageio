let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "025e51718c6267916195d06eb3df434edcfcd169";
    sha256 = "1gqgmhv1dvpvapp9v54qqmx7vkl8ln7f191p7mpf32ndqqnzjnjy";
  }