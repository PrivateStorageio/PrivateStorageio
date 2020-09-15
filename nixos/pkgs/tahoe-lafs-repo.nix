let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "23e1223c94330741f5b1dda476c3aeb42c3a012f";
    sha256 = "1zh37rvkiigciwadgrjvnq9519lap1c260v8593g65qrpc1zwjxz";
  }