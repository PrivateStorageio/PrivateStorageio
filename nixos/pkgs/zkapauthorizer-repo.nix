let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "ee6b7bc377575ded9a3aaad149f960bc564c1124";
    sha256 = "05hrk96hf3ijj9sad4rjbwyb0355sdqvwagbxnhzxd71nd3ssm69";
  }