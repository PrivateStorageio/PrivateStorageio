let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "ede17a6e2e53d56978dcd5962322987c15d59634";
    sha256 = "1i1cmj6mnmr3i1md7qks57xqdp1blhr375jsxds29glk9b8wp757";
  }