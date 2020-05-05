let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "27a2f31e5483fa732785cf550e3beef09d67c398";
    sha256 = "0chd3x5zvv873jah9z0dj4fpq4ika7i919dfzx53ckf395y69dzm";
  }