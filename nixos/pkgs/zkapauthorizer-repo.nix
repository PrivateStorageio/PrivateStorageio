let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "b703f99ef9447f41acaa5b7402b29b26ebfb5d94";
    sha256 = "0xhbznfc27mdkckw8rw1w21pzmqw8haf5j62jfm8yb9n3vaqlchs";
  }