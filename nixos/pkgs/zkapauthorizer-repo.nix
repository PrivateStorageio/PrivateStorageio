let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "6bde7dfd7b47bed2b994440f3139698fbca23e00";
    sha256 = "1018kq7q6302j4631kh612f9ykgk3417dbabp9g93nr4bfg58sv5";
  }
