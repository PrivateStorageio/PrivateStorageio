let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "996f0acdb46dc0f2ef14a06ae0012771b43c087c";
    sha256 = "09kkzq6pd61xwaq6dlfl25rqbi7ssdzkvknhsx59cyanxpk66rcd";
  }