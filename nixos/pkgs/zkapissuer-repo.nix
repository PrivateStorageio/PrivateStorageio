let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "e3167f2f0333755ab654120404fbd69358e561ee";
    sha256 = "1fvakpjfp7h3dvswagharpikr48f4wz0sl4qh8pcf0nyp639nf62";
  }