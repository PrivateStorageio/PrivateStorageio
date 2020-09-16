let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "333a3e3927a4cf0952447d94ea48d8f07916cf70";
    sha256 = "1sl3xy7nfs5xw2n5mrjcdpma6v1mk2ldi3kd59ns5aj1wvsdipqh";
  }