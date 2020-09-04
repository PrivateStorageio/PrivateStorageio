let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "7b4796470764f47f6b2f57d7678cc2311e5bd18e";
    sha256 = "1b5z7mha8sak46b2sxdd44hqc0a1wx7frcydzgzs25ncq4a516aa";
  }