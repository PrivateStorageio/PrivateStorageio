let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "privatestorageio";
    repo = "zkapauthorizer";
    rev = "0ae5bb532b9dfd515c65852bdbe86bd85d70f0e8";
    sha256 = "06vsy7lbn4j9rwgzb5qcjj6255x27q1a2z84xphr0675rdi27f4f";
  }