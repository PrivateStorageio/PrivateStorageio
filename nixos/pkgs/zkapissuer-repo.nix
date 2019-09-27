let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "94fb418962abee71fa97c09c76e85ccc13cf4c1e";
    sha256 = "15v71hqhs3rd8c77igbzbi2lbvrb6yyshasq3ijs51w7pwp10dac";
  }