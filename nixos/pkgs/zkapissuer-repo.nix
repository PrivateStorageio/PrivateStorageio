let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "967e34f14afed67e0ecd9b383b746f454eb6da97";
    sha256 = "0vmph0l74ncngzdljqxc87jz3zvzjr03l7z37p5mdvkzm8cjjfj3";
  }