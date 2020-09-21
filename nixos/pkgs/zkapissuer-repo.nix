let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "354d174f641e2e433c72dde8eb12c9fbaeb875a4";
    sha256 = "0mv3q8pgic0cpdzx19w296d29cwamwv0pjxb8z6p01dj2jf94zzs";
  }