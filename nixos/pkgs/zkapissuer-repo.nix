let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "dc3d1f08e9fa4ce0aef2f7a46db3ede6174e456a";
    sha256 = "05zwldrxg71lsjnsw3rvvn5qmsfspz9lk66zgz03qahxbcsh5243";
  }