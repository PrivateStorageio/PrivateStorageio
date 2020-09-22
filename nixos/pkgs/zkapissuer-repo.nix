let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "a83bca9b62ab6b80112116e26bb83d9beb69e015";
    sha256 = "1i4z7gqyrv21p6v99aaf1vk849n47c30ffs5y3nmmrb2pv3gx6iv";
  }