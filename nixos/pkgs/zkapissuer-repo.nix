let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "15d0c6aab44dda9974442c59b5103ad4ab913730";
    sha256 = "18lb0a1yql0rfpmr92z6fvsra5qidns1arg3j0s8yxh48fcgdp9h";
  }