let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "f1545e6e932b294ec12142141eaaaadd9318ee8d";
    sha256 = "01xcs4ai2gqck94da7350j1az9c47qf3mxq6z0c3q4yp4m0jmfja";
  }