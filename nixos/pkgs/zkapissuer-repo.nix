let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "17461e03ea9f50e6f4d5b22bb6cb5fabe7b46d84";
    sha256 = "18lb0a1yql0rfpmr92z6fvsra5qidns1arg3j0s8yxh48fcgdp9h";
  }